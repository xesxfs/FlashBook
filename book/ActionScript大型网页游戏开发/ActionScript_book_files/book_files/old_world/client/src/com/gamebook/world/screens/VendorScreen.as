package com.gamebook.world.screens {
	import com.gamebook.ui.buttons.CloseButton;
	import com.gamebook.utils.assetsloader.Asset;
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderEvent;
	import com.gamebook.world.events.VendorEvent;
	import com.gamebook.world.furniture.FurnitureDefinition;
	import fl.controls.ScrollBarDirection;
	import fl.controls.ScrollPolicy;
	import fl.controls.TileList;
	import fl.data.DataProvider;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	public class VendorScreen extends Sprite {
		
		private var _tl:TileList = new TileList();		
		private var _loader:AssetsLoader = new AssetsLoader();
		private var _closeButton:CloseButton = new CloseButton();
		private var _items:Array;
		
		
		private const THUMBS_ROOT:String = "assets/";
		
		public function VendorScreen(items:Array) {
			_loader.addEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, thumbsLoaded);
			_items = items;
			
			for each (var f:FurnitureDefinition in _items) {				
				_loader.loadAsset(THUMBS_ROOT + f.fileName, AssetType.IMAGE);				
			}
							
			_tl.width = 500;
			_tl.height = 230;
			
			//_tl.rowCount = 2;
			_tl.rowHeight = 150;
			_tl.columnWidth = 150;
			
			//	add a border to show off the TileList Skin
			_tl.setStyle("contentPadding", 20);
			
			//	for the cell labels
			_tl.setRendererStyle("textOverlayAlpha", 0.0);
			_tl.setRendererStyle("textPadding", 5);
			_tl.setRendererStyle("textFormat", new TextFormat("Rockwell Bold", 14, 0x7F610F));
			
			//	the "interior border" of the tiled cells -- higher values render a smaller thumbnail
			_tl.setRendererStyle("imagePadding", 20);			
			
			//_tl.scrollPolicy = ScrollPolicy.ON;
			//_tl.direction = ScrollBarDirection.VERTICAL;
			
			/**
			 * more at http://www.adobe.com/devnet/flash/quickstart/tilelist_component_as3/			 
			 */ 
		}
		
		public function destroy():void {
			_tl.removeEventListener(Event.CHANGE, onSelect);
			_closeButton.removeEventListener(MouseEvent.CLICK, onClose);
			
			removeChild(_tl);			
			_tl = null;			
			
			removeChild(_closeButton);
			_closeButton = null;
			
			_loader.destroy();			
			_loader = null;
			
			_items = null;			
		}
		
		private function thumbsLoaded(e:AssetsLoaderEvent):void {
			_loader.removeEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, thumbsLoaded);
			
			trace("vendor thumbnails loaded: " + _loader.assetsComplete.length + " of " + _loader.totalAssets);
			
			var dp:DataProvider = new DataProvider();
			
			for each (var f:FurnitureDefinition in _items) {
				var tile:Sprite = new Sprite();
				tile.addChild(DisplayObject(getThumbForURL(THUMBS_ROOT + f.fileName)));
				
				dp.addItem({label:f.name + " $" + f.cost, data:f, source:tile});	//	from TileList.swc
			}
			
			_tl.addEventListener(Event.CHANGE, onSelect);
			_tl.addEventListener(MouseEvent.CLICK, onClick);
			
			_tl.dataProvider = dp;
			
			addChild(_tl);
			
			_closeButton.addEventListener(MouseEvent.CLICK, onClose);
			_closeButton.x = _tl.x + _tl.width - _closeButton.width / 2;
			_closeButton.y = -_closeButton.height / 2;
			
			addChild(_closeButton);
		}
		
		private function onClose(e:MouseEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		//	seize the click to prevent it bubbling to stage as a "walk" command
		private function onClick(e:MouseEvent):void {
			e.stopImmediatePropagation();
		}
		
		private function onSelect(e:Event):void {
			
			var selected:FurnitureDefinition = TileList(e.target).selectedItem.data;
			
			trace("selected " + selected);					
			
			dispatchEvent(new VendorEvent(VendorEvent.MERCHANDISE_SELECTED, selected));
		}
		
		private function getThumbForURL(filePath:String):DisplayObject {
			
			var output:DisplayObject;
			var found:Boolean = false;
			
			for each (var a:Asset in _loader.assetsComplete) {
				if (a.url == filePath) {
					output = DisplayObject(a.data);
					
					if (output is Bitmap) {
						Bitmap(output).smoothing = true;
					}
					
					found = true;
					break;
				}
			}
			
			if (!found) {
				throw new Error("could not find loaded thumbnail for " + filePath);
			}
			
			return output;
		}
	}
}