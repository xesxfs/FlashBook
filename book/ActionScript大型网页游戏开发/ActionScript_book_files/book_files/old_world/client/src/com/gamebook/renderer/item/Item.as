package com.gamebook.renderer.item {
	import com.gamebook.renderer.ISortable;
	import com.gamebook.renderer.tile.GuideTile;
	import com.gamebook.renderer.tile.Tile;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Item extends Sprite implements ISortable {
		
		private var _itemDefinition:ItemDefinition;
		
		private var _bitmap:Bitmap;
		private var _source:String;
		private var _col:int;
		private var _row:int;
		private var _tiles:Array;
		private var _guideTile:GuideTile;
		private var _isInteractive:Boolean;
		private var _isInWorld:Boolean;
		private var _onStopEvent:String;
		private var _onClickEvent:String;
		
		public function Item() {
			_tiles = [];
			_isInteractive = true;
			_isInWorld = false;
		}
		
		public function checkPointCollision(tx:int, ty:int):Boolean {
			var collision:Boolean = false;
			
			if (tx >= _bitmap.x && tx < _bitmap.x + _bitmap.bitmapData.width && ty >= _bitmap.y && ty < _bitmap.y + _bitmap.bitmapData.height) {
				collision = _bitmap.bitmapData.getPixel32(tx - _bitmap.x, ty - _bitmap.y) != 0;
			}
			
			return collision;
		}
		
		public function addTile(t:Tile):void {
			_tiles.push(t);
			_isInWorld = true;
		}
		
		public function removeTile(t:Tile):void {
			for (var i:int = 0; i < _tiles.length;++i) {
				if (_tiles[i] == t) {
					_tiles.splice(i, 1);
					break;
				}
			}
			_isInWorld = _tiles.length > 0;
		}
		
		public function fromXML(info:XML):void {
			_source = info.@source;
			_col = int(info.@col);
			_row = int(info.@row);
			_onStopEvent = info.@onStop;
			_onClickEvent = info.@onClick;
			if (_onStopEvent == "") {
				_onStopEvent = null;
			}
			if (_onClickEvent == "") {
				_onClickEvent = null;
			}
			
		}
		
		public function toXMl():String
		{
			trace("|Item: " + _itemDefinition);
			if ( !_itemDefinition ) return "";
			
			var onStopParam:String = "";
			if (_onStopEvent != null) {
				onStopParam = " onStop='"+_onStopEvent+"'";
			}
				
			var onClickParam:String = "";
			if (_onClickEvent != null) {
				onClickParam = " onClick='"+_onClickEvent+"'";
			}
				
			return "<Item source='" + _itemDefinition.id + "' col='" + _col + "' row='" + _row + "' "+onStopParam+" "+onClickParam+"/>";
		}
		
		/* INTERFACE com.gamebook.renderer.item.ISortable */
		
		public function get cols():int{
			return _itemDefinition.cols;
		}
		
		public function get rows():int{
			return _itemDefinition.rows;
		}
		
		public function get itemDefinition():ItemDefinition { return _itemDefinition; }
		
		public function set itemDefinition(value:ItemDefinition):void {
			_itemDefinition = value;
			
			_bitmap = new Bitmap(_itemDefinition.bitmapData);
			_bitmap.x = _itemDefinition.xOffset;
			_bitmap.y = _itemDefinition.yOffset;
			
			_guideTile = new GuideTile();
			addChild(_guideTile);
			
			addChild(_bitmap);
		}
		
		/**
		 * Updates the bitmap's bitmapData and position based on the ItemDefinition values
		 */
		public function refresh():void {
			_bitmap.bitmapData = _itemDefinition.bitmapData;
			_bitmap.x = _itemDefinition.xOffset;
			_bitmap.y = _itemDefinition.yOffset;
		}
		
		public function updateOffsets():void
		{
			_bitmap.x = _itemDefinition.xOffset;
			_bitmap.y = _itemDefinition.yOffset;
		}
		
		public function get col():int { return _col; }
		
		public function get row():int { return _row; }
		
		public function get source():String { return _source; }
		
		public function get tiles():Array { return _tiles; }
		
		public function get isInteractive():Boolean { return _isInteractive; }
		
		public function set isInteractive(value:Boolean):void {
			_isInteractive = value;
		}
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get isInWorld():Boolean { return _isInWorld; }
		
		public function get guideTile():GuideTile { return _guideTile; }
		
		public function get onStopEvent():String { return _onStopEvent; }
		
		public function get onClickEvent():String { return _onClickEvent; }
		
	}
	
}