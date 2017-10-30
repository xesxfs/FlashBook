package com.gamebook.renderer.tile {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class WayPoint {
		
		private var _time:Number;
		private var _tile:Tile;
		
		public function WayPoint() {
			
		}
		
		public function get time():Number { return _time; }
		
		public function set time(value:Number):void {
			_time = value;
		}
		
		public function get tile():Tile { return _tile; }
		
		public function set tile(value:Tile):void {
			_tile = value;
		}
		
		
	}
	
}