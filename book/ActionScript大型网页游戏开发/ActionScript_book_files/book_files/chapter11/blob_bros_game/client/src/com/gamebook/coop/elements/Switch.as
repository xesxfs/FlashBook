package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import com.gamebook.coop.elements.Lever;
	import com.gamebook.coop.elements.TriggerPad;
	import flash.display.MovieClip;
	
	/**
	 * A switch clip that has 3 states.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class Switch extends MovieClip {
		
		private var _id:int;
		private var _isOn:Boolean;
		private var _clip:MovieClip;
		
		/**
		 * Place the switch in the correct location and turn it on or off.
		 */
		public function Switch(id:int, tile:Tile, isOn:Boolean, type:String="lever") {
			
			_id = id;
			this.x = tile.x;
			this.y = tile.y;
			
			if (type == "deathTrigger") {
				_clip = new TriggerPad();
			} else {
				_clip = new Lever();
			}
			addChild(_clip);
			
			_isOn = isOn;
			if (_isOn) {
				_clip.gotoAndStop("on");
			} else {
				_clip.gotoAndStop("off");
			}
			
			tile.trigger = _id;
		}
		
		public function get isOn():Boolean { return _isOn; }
		
		public function turnOn():void {
			_isOn = true;
			_clip.gotoAndStop("on");
		}
		
		public function turnOff():void {
			_isOn = false;
			_clip.gotoAndStop("off");
		}
		
	}
	
}