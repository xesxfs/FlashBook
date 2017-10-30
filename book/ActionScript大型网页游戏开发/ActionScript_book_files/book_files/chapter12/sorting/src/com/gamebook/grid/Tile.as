package com.gamebook.grid {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../assets/assets.swf', symbol='Tile')]
	public class Tile extends MovieClip{
		
		private var _col:int;
		private var _row:int;
		private var _items:Array = [];
		
		public function Tile() {
			cacheAsBitmap = true;
		}
		
		public function addItem(item:Item):void {
			_items.push(item);
		}
		
		public function removeItem(item:Item):void {
			for (var i:int = 0; i < _items.length;++i) {
				if (_items[i] == item) {
					_items.splice(i, 1);
					break;
				}
			}
		}
		
		public function get col():int { return _col; }
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function get row():int { return _row; }
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get items():Array { return _items; }
		
	}
	
}