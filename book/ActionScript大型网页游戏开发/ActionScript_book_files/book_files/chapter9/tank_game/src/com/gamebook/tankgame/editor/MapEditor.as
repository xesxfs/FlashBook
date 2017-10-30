package com.gamebook.tankgame.editor {
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.tankgame.elements.spawn.PowerupSpawnPoint;
	import com.gamebook.tankgame.elements.spawn.SpawnPoint;
	import com.gamebook.tankgame.elements.spawn.TankSpawnPoint;
	import com.gamebook.tankgame.Map;
	import com.gamebook.tankgame.elements.items.*;
	import com.gamebook.tankgame.PluginConstants;
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.TextInput;
	import fl.controls.TileList;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.events.Event;
	import flash.net.FileReferenceList;
	import flash.xml.XMLDocument;

	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class MapEditor extends MovieClip{
		
		
		private var _fileRefList:FileReferenceList;
		private var _fileToLoad:FileReference;
		private var _txtFilter:FileFilter = new FileFilter("Level XML", "*.xml");
		
		private var _mapHolder:MovieClip;
		private var _uiHolder:MovieClip;
		
		private var _newButton:Button;
		private var _saveButton:Button;
		private var _openButton:Button;
		private var _fileName:TextInput;
		
		private var _map:Map;
		
		private var _km:KeyManager;
		private var _up:KeyCombo;
		private var _down:KeyCombo;
		
		public function MapEditor() {
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			_mapHolder = new MovieClip();
			addChild(_mapHolder);
			
			_uiHolder = new MovieClip();
			addChild(_uiHolder);
			
			buildUI();
			
		}
		
		private function addedToStage(e:Event):void {
			_km = new KeyManager();
			addChild(_km);
			
			_up = _km.createKeyCombo(Key.UP);
			_up.addEventListener(KeyCombo.COMBO_PRESSED, onScaleKeyPressed);
			_down = _km.createKeyCombo(Key.DOWN);
			_down.addEventListener(KeyCombo.COMBO_PRESSED, onScaleKeyPressed);
		}
		
		private function onScaleKeyPressed(e:Event):void {
			if (_map) {
				switch (e.target) {
					case _up:
						_map.scaleY = _map.scaleX = _map.scaleX - .1;
						break;
					case _down:
						_map.scaleY = _map.scaleX = _map.scaleX + .1;
						break;
				}
			}
		}
		private function onButtonClick(e:MouseEvent):void {
			switch (e.target) {
				case _newButton:
					newMap();
					break;
				case _saveButton:
					saveMap();
					break;
				case _openButton:
					openMap();
					break;
			}
		}
		
		private function openMap():void {
			_fileRefList = new FileReferenceList();
			_fileRefList.addEventListener(Event.SELECT, onFileBrowseComplete);
			_fileRefList.browse([_txtFilter]);
			
		}
		
		private function saveMap():void{
			saveFile(_map.toXML(), _fileName.text);
		}
		
		private function newMap():void {
			prepForEditing();
			
			var esob:EsObject = new EsObject();
			esob.setEsObjectArray(PluginConstants.ITEM_LIST, []);
			esob.setEsObjectArray(PluginConstants.POWERUP_SPAWN_LIST, []);
			esob.setEsObjectArray(PluginConstants.TANK_SPAWN_LIST, []);
			_map.build(esob);
			
		}
		
		private function prepForEditing():void {
			addEventListener(Event.ENTER_FRAME, run);
			
			_map = new Map();
			_map.isEditor = true;
			_mapHolder.addChild(_map);
			
			buildItemUI();
			
			
			showSaveAndFileName();
			
		}
		
		private function run(e:Event):void {
			var speed:Number = 10;
			if (mouseY < 8) {
				_map.y += speed;
			} else if (mouseY > 590) {
				_map.y -= speed;
			} else if (mouseX < 10) {
				_map.x += speed;
			} else if (mouseX > 790) {
				_map.x -= speed;
			}
		}
		
		private function buildItemUI():void {
			var arr:Array = [House, Tree, WallEndBottom, WallEndLeft, WallEndRight, Bridge, WaterLeft, WaterRight, WaterTopLeft, WaterTopRight, WaterBottomLeft, WaterBottomRight, WallEndTop, WallVertical, TankSpawnPoint, PowerupSpawnPoint];
			
			var startx:int = 220;
			var starty:int = 10;
			
			var numSpawns:int = 0;
			
			for (var i:int = 0; i < arr.length;++i) {
				var CLASS:Class = arr[i];
				var itm:MovieClip = new CLASS() as MovieClip;
				
				itm.x = startx + 40 * i;
				itm.y = starty;
				
				if (itm as SpawnPoint) {
					itm.y = 55;
					itm.x = 20+ numSpawns * 40;
					
					++numSpawns;
				}
				
				if (itm.width > 35) {
					itm.width = 35;
					itm.scaleY = itm.scaleX;
					
					itm.filters = [new DropShadowFilter()];
					
					itm.addEventListener(MouseEvent.MOUSE_DOWN, onNewItemClick);
					itm.addEventListener(MouseEvent.MOUSE_OVER, onNewItemMouseOver);
					itm.addEventListener(MouseEvent.MOUSE_OUT, onNewItemMouseOut);
				}
				
				addChild(itm);
			}
		}
		
		private function onNewItemMouseOut(e:MouseEvent):void {
			var itm:MovieClip = e.target as MovieClip;
			itm.filters = [new DropShadowFilter() ];
		}
		
		private function onNewItemMouseOver(e:MouseEvent):void {
			var itm:MovieClip = e.target as MovieClip;
			itm.filters = [new GlowFilter() ];
			
		}
		
		private function onNewItemClick(e:MouseEvent):void {
			
			if (e.target as Item) {
				var itm:Item = e.target as Item;
				var newItem:Item = _map.parseAndAdd(itm.getEsObject(), true);
			} else if (e.target as TankSpawnPoint) {
				_map.parseAndAddTankSpawnPoint(TankSpawnPoint(e.target).getEsObject(), true);
			} else if (e.target as PowerupSpawnPoint) {
				_map.parseAndAddPowerupSpawnPoint(PowerupSpawnPoint(e.target).getEsObject(), true);
			}
			
		}
		
		private function showSaveAndFileName():void{
			_openButton.visible = false;
			_newButton.visible = false;
			_saveButton.visible = true;
			_fileName.visible = true;
		}
		
		private function saveFile(content:String, name:String):void {
			
			var fileRef:FileReference = new FileReference();
			fileRef.save(content, name);
		}
		
		
		
		private function onFileBrowseCancel(e:Event):void {
		}
		
		private function onLoadComplete(e:Event):void {
			prepForEditing();
			
			var xml:XMLDocument = new XMLDocument();
			xml.ignoreWhite = true;
			xml.parseXML(_fileToLoad.data.toString());
			
			_map.fromXML(xml.firstChild);
			
		}
		
		private function onFileBrowseComplete(e:Event):void {
			_fileToLoad = _fileRefList.fileList[0];
			_fileToLoad.addEventListener(Event.COMPLETE, onLoadComplete);
			_fileToLoad.load();
		}
		private function buildUI():void {
			
			_openButton = new Button();
			_openButton.label = "open";
			_openButton.x = 5;
			_openButton.y = 10;
			_openButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			_uiHolder.addChild(_openButton);
			
			_newButton = new Button();
			_newButton.label = "new map";
			_newButton.x = _openButton.getBounds(_uiHolder).right + 5;
			_newButton.y = 10;
			_newButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			_uiHolder.addChild(_newButton);
			
			_saveButton = new Button();
			_saveButton.label = "save";
			_saveButton.x = 5;
			_saveButton.y = 10;
			_saveButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			_uiHolder.addChild(_saveButton);
			_saveButton.visible = false;
			
			_fileName = new TextInput();
			_fileName.text = "map.xml";
			_fileName.x = _saveButton.getBounds(_uiHolder).right + 5;
			_fileName.y = 10;
			_uiHolder.addChild(_fileName);
			_fileName.visible = false;
			
			
		}
		
		
		
	}
	
}