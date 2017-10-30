package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	
	/**
	 * The laser gate, which can be on or off.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Gate')]
	public class Gate extends MovieClip {
		
		private var _id:int;
		private var _isOn:Boolean = true;
		private var _tile:Tile;
		 
		public function Gate(id:int, tile:Tile, isOn:Boolean) {
			
			_id    = id;
			_tile  = tile;
			this.x = _tile.x + this.width / 2;
			this.y = _tile.y + this.height;
			
			if (isOn) {
				turnOn();
			} else {
				turnOff();
			}
		}
		
		public function get isOn():Boolean { return _isOn; }
		
		public function turnOn():void {
			_isOn = true;
			gotoAndStop("on");
			_tile.isWalkable = false;
		}
		
		public function turnOff():void {
			_isOn = false;
			gotoAndStop("off");
			_tile.isWalkable = true;
		}
		
	}
	
}