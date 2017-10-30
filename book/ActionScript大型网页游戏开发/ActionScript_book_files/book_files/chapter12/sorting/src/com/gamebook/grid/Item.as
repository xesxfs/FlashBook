package com.gamebook.grid {
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../assets/assets.swf', symbol='Item')]
	public class Item extends MovieClip implements ISortableItem{
		
		private var _col:int;
		private var _row:int;
		private var _cols:int;
		private var _rows:int;
		private var _type:int;
		
		public function Item() {
			stop();
			filters = [new DropShadowFilter(2, 45, 0, .1)];
		}
		
		public function get col():int { return _col; }
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function get row():int { return _row; }
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get cols():int { return _cols; }
		
		public function set cols(value:int):void {
			_cols = value;
		}
		
		public function get rows():int { return _rows; }
		
		public function set rows(value:int):void {
			_rows = value;
		}
		
		public function get type():int { return _type; }
		
		public function set type(value:int):void {
			_type = value;
			gotoAndStop(_type + 1);
			switch (_type) {
				case 0:
					_cols = 1;
					_rows = 1;
					break;
				case 1:
					_cols = 2;
					_rows = 1;
					break;
				case 2:
					_cols = 1;
					_rows = 2;
					break;
			}
		}
		
		
	}
	
}