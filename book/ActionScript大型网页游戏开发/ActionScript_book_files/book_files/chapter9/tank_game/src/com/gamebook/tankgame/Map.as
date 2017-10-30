package com.gamebook.tankgame {
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.tankgame.elements.DeathSmudge;
	import com.gamebook.tankgame.elements.items.*;
	import com.gamebook.tankgame.elements.LineFader;
	import com.gamebook.tankgame.powerup.Powerup;
	import com.gamebook.tankgame.elements.spawn.PowerupSpawnPoint;
	import com.gamebook.tankgame.elements.spawn.TankSpawnPoint;
	import com.gamebook.tankgame.elements.Target;
	import com.gamebook.tankgame.elements.Tile;
	import com.gamebook.utils.geom.IntersectionDetector;
	import com.gamebook.utils.geom.IntersectionTestResult;
	import com.gamebook.utils.geom.LineSegment;
	import com.gamebook.utils.geom.LineSegmentCollection;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.xml.XMLNode;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Map extends MovieClip{
		
		private var _target:Target;
		
		private var _bulletsHolder:MovieClip;
		
		private var _itemDragging:MovieClip;
		
		private var _tanksHolder:MovieClip;
		
		private var _isEditor:Boolean = false;
		
		private var _items:Array = [];
		private var _tankSpawnPoints:Array = [];
		private var _powerupSpawnPoints:Array = [];
		
		private var _mapWidtht:int;
		private var _mapHeight:int;
		
		private var _pathItemsCollection:LineSegmentCollection = new LineSegmentCollection();
		private var _bulletItemsCollection:LineSegmentCollection = new LineSegmentCollection();
		
		public function Map() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			if (_isEditor) {
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			}
		}
		
		private function mouseUp(e:MouseEvent):void {
			if (_itemDragging) {
				_itemDragging.stopDrag();
				
				_itemDragging = null;
			}
		}
		
		public function toXML():String {
			var esob:EsObject = new EsObject();
			var itms:Array = [];
			
			for (var i:int = 0; i < _items.length;++i) {
				var itm:Item = _items[i];
				itms.push(itm.getEsObject());
			}
			esob.setEsObjectArray(PluginConstants.ITEM_LIST, itms);
			
			var tank_sps:Array = [];
			for (i = 0; i < _tankSpawnPoints.length;++i) {
				var ts:TankSpawnPoint = _tankSpawnPoints[i];
				tank_sps.push(ts.getEsObject());
			}
			esob.setEsObjectArray(PluginConstants.TANK_SPAWN_LIST, tank_sps);
			
			var power_sps:Array = [];
			for (i = 0; i < _powerupSpawnPoints.length;++i) {
				var ps:PowerupSpawnPoint = _powerupSpawnPoints[i];
				power_sps.push(ps.getEsObject());
			}
			esob.setEsObjectArray(PluginConstants.POWERUP_SPAWN_LIST, power_sps);
			
			return esob.toXML();
		}
		
		public function fromXML(info:XMLNode):void {
			var esob:EsObject = new EsObject();
			esob.fromXML(info);
			
			build(esob);
		}
		
		public function parseAndAddTankSpawnPoint(esob:EsObject, drag:Boolean = false):void {
			var x:int = esob.getInteger(PluginConstants.X);
			var y:int = esob.getInteger(PluginConstants.Y);
			
			var ts:TankSpawnPoint = new TankSpawnPoint();
			ts.x = x;
			ts.y = y;
			
			_tankSpawnPoints.push(ts);
			
			
			if (isEditor) {
				addChild(ts);
				ts.doubleClickEnabled = true;
				ts.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnItem);
				ts.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClicked);
			}
			
			if (drag) {
				ts.x = mouseX;
				ts.y = mouseY;
				dragItem(ts);
			}
		}
		
		public function parseAndAddPowerupSpawnPoint(esob:EsObject, drag:Boolean = false):void {
			var x:int = esob.getInteger(PluginConstants.X);
			var y:int = esob.getInteger(PluginConstants.Y);
			
			var ts:PowerupSpawnPoint = new PowerupSpawnPoint();
			ts.x = x;
			ts.y = y;
			
			_powerupSpawnPoints.push(ts);
			
			
			if (isEditor) {
				addChild(ts);
				ts.doubleClickEnabled = true;
				ts.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnItem);
				ts.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClicked);
			}
			
			if (drag) {
				ts.x = mouseX;
				ts.y = mouseY;
				dragItem(ts);
			}
		}
		
		public function getCollisionPoint(point1:Point, point2:Point):Point {
			var seg:LineSegment = new LineSegment(point1, point2);
			var res:IntersectionTestResult = IntersectionDetector.segmentCollectionTest(seg, _bulletItemsCollection, point1);
			var point:Point = res.point;
			
			if (res.intersecting) {
				
				/*
				var shape:Shape = new Shape();
				var gfk:Graphics = shape.graphics;
				gfk.lineStyle(0, 0x990000);
				gfk.moveTo(point1.x, point1.y);
				gfk.lineTo(point2.x, point2.y);
				
				var fader:LineFader = new LineFader();
				
				fader.addChild(shape);
				addChild(fader);
				*/
			}
			
			return point;
		}
		
		public function validatePath(point1:Point, point2:Point):Boolean {
			//create a line segment that connects the two points
			var seg:LineSegment = new LineSegment(point1, point2);
			
			//check for a collision between the segment and all obstacles
			var res:IntersectionTestResult = IntersectionDetector.segmentCollectionTest(seg, _pathItemsCollection, point1);
			
			var valid:Boolean = !res.intersecting;
			
			if (!valid) {
				point2 = res.point;
				
				var shape:Shape = new Shape();
				var gfk:Graphics = shape.graphics;
				gfk.lineStyle(0, 0x990000);
				gfk.moveTo(point1.x, point1.y);
				gfk.lineTo(point2.x, point2.y);
				
				var fader:LineFader = new LineFader();
				
				fader.addChild(shape);
				addChild(fader);
			}
			
			return valid;
		}
		
		private function drawShape(itm:Item):void{
			var shape:Shape = new Shape();
			addChild(shape);
			var gfk:Graphics = shape.graphics;
			gfk.lineStyle(1, 0x000000);
			for (var i:int = 0; i < itm.lineSegmentCollection.lineSegments.length;++i) {
				var seg:LineSegment = itm.lineSegmentCollection.lineSegments[i];
				gfk.moveTo(seg.point1.x, seg.point1.y);
				gfk.lineTo(seg.point2.x, seg.point2.y);
			}
		}
		public function addDeathSmudge(ds:DeathSmudge):void {
			addChildAt(ds, getChildIndex(_tanksHolder) - 1);
		}
		public function addPowerup(powerup:Powerup):void {
			addChildAt(powerup, getChildIndex(_tanksHolder)-1);
		}
		
		public function removePowerup(powreup:Powerup):void {
			removeChild(powreup);
		}
		
		public function parseAndAdd(esob:EsObject, drag:Boolean=false):Item {
			var decal:String = esob.getString(PluginConstants.DECAL);
			var itm:Item = getNewItemByDecal(decal);
			itm.isHittable = esob.getBoolean(PluginConstants.HITTABLE);
			itm.isObstacle = esob.getBoolean(PluginConstants.OBSTACLE);
			itm.x = esob.getInteger(PluginConstants.X);
			itm.y = esob.getInteger(PluginConstants.Y);
			itm.hitWidth = esob.getInteger(PluginConstants.WIDTH);
			itm.hitHeight = esob.getInteger(PluginConstants.HEIGHT);
			
			if (itm as Tree || itm as House) {
				addChildAt(itm, getChildIndex(_tanksHolder)+2);
			} else {
				addChildAt(itm, getChildIndex(_tanksHolder)-1);
			}
			
			
			_items.push(itm);
			
			if (isEditor) {
				itm.doubleClickEnabled = true;
				itm.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOnItem);
				itm.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClicked);
			} else {
				itm.determineLineSegmentCollection();
				for (var i:int = 0; i < itm.lineSegmentCollection.lineSegments.length;++i) {
					var seg:LineSegment = itm.lineSegmentCollection.lineSegments[i];
					
					if (itm.isObstacle) {
						_pathItemsCollection.addLineSegment(seg);
						
					}
					if (itm.isHittable) {
						_bulletItemsCollection.addLineSegment(seg);
					}
				}
			}
			
			if (drag) {
				itm.x = mouseX - itm.width / 2;
				itm.y = mouseY - itm.height / 2;
				dragItem(itm);
			}
			
			return itm;
		}
		
		private function doubleClicked(e:MouseEvent):void {
			if (e.target as Item) {
				var itm:Item = e.target as Item;
				removeItem(itm);
			} else if (e.target as TankSpawnPoint) {
				var ts:TankSpawnPoint = e.target as TankSpawnPoint;
				removeTankSpawnPoint(ts);
			} else if (e.target as PowerupSpawnPoint) {
				var ps:PowerupSpawnPoint = e.target as PowerupSpawnPoint;
				removePowerupSpawnPoint(ps);
			}
		}
		
		private function removePowerupSpawnPoint(ts:PowerupSpawnPoint):void{
			for (var i:int = 0; i < _powerupSpawnPoints.length;++i) {
				if (_powerupSpawnPoints[i] == ts) {
					_powerupSpawnPoints.splice(i, 1);
					break;
				}
			}
			removeChild(ts);
		}
		
		private function removeTankSpawnPoint(ts:TankSpawnPoint):void{
			for (var i:int = 0; i < _tankSpawnPoints.length;++i) {
				if (_tankSpawnPoints[i] == ts) {
					_tankSpawnPoints.splice(i, 1);
					break;
				}
			}
			removeChild(ts);
		}
		
		private function removeItem(itm:Item):void{
			for (var i:int = 0; i < _items.length;++i) {
				if (_items[i] == itm) {
					_items.splice(i, 1);
					break;
				}
			}
			removeChild(itm);
		}
		
		private function mouseDownOnItem(e:MouseEvent):void {
			var itm:MovieClip = e.target as MovieClip;
			dragItem(itm);
		}
		
		private function dragItem(itm:MovieClip):void {
			itm.startDrag();
			_itemDragging = itm;
		}
		
		private function getNewItemByDecal(decal:String):Item {
			var item:Item;
			
			switch (decal) {
				case ItemTypes.HOUSE:
					item = new House();
					break;
				case ItemTypes.TREE:
					item = new Tree();
					break;
				case ItemTypes.BRIDGE:
					item = new Bridge();
					break;
				case ItemTypes.WATER_LEFT:
					item = new WaterLeft();
					break;
				case ItemTypes.WATER_RIGHT:
					item = new WaterRight();
					break;
				case ItemTypes.WATER_TOP_LEFT:
					item = new WaterTopLeft();
					break;
				case ItemTypes.WATER_TOP_RIGHT:
					item = new WaterTopRight();
					break;
				case ItemTypes.WATER_BOTTOM_LEFT:
					item = new WaterBottomLeft();
					break;
				case ItemTypes.WATER_BOTTOM_RIGHT:
					item = new WaterBottomRight();
					break;
				case ItemTypes.WALL_END_BOTTOM:
					item = new WallEndBottom();
					break;
				case ItemTypes.WALL_END_LEFT:
					item = new WallEndLeft();
					break;
				case ItemTypes.WALL_END_RIGHT:
					item = new WallEndRight();
					break;
				case ItemTypes.WALL_END_TOP:
					item = new WallEndTop();
					break;
				case ItemTypes.WALL_VERTICAL:
					item = new WallVertical();
					break;
				default:
					trace("trying to create new type and it isnt handled: " + decal);
			}
			
			return item;
		}
		
		public function build(esob:EsObject):void {
			
			var cols:int = 8;
			var rows:int = 8;
			var w:int = 200;
			var h:int = 200;
			
			_mapHeight = rows * h;
			_mapWidtht = cols * w;
			
			for (var i:int = 0; i < cols;++i) {
				for (var j:int = 0; j < rows;++j) {
					var tx:int = i * w;
					var ty:int = j * h;
					var t:Tile = new Tile();
					t.showTileIndex(0);
					t.x = tx;
					t.y = ty;
					addChild(t);
				}
			}
			_target = new Target();
			addChild(_target);
			
			_tanksHolder = new MovieClip();
			addChild(_tanksHolder);
			
			_bulletsHolder = new MovieClip();
			addChild(_bulletsHolder);
			
			var itms:Array = esob.getEsObjectArray(PluginConstants.ITEM_LIST);
			for (i = 0; i < itms.length;++i) {
				var itm_ob:EsObject = itms[i];
				var itm:Item = parseAndAdd(itm_ob);
			}
			
			var tank_sps:Array = esob.getEsObjectArray(PluginConstants.TANK_SPAWN_LIST);
			for (i = 0; i < tank_sps.length;++i) {
				var tank_sp_ob:EsObject = tank_sps[i];
				parseAndAddTankSpawnPoint(tank_sp_ob);
			}
			
			var power_sps:Array = esob.getEsObjectArray(PluginConstants.POWERUP_SPAWN_LIST);
			for (i = 0; i < power_sps.length;++i) {
				var power_sp_ob:EsObject = power_sps[i];
				parseAndAddPowerupSpawnPoint(power_sp_ob);
			}
			
			
		}
		
		public function get target():Target { return _target; }
		
		public function get bulletsHolder():MovieClip { return _bulletsHolder; }
		
		public function get isEditor():Boolean { return _isEditor; }
		
		public function set isEditor(value:Boolean):void {
			_isEditor = value;
		}
		
		public function get tanksHolder():MovieClip { return _tanksHolder; }
		
		public function get mapWidtht():int { return _mapWidtht; }
		
		public function get mapHeight():int { return _mapHeight; }
		
	}
	
}