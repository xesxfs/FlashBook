package com.gamebook.tankgame.powerup {
	import com.gamebook.tankgame.PluginConstants;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Powerup')]
	public class Powerup extends MovieClip {
		
		private var _type:String;
		private var _id:int;
		private var _colleced:Boolean;
		
		public var hitArea_mc:MovieClip;
		
		public function Powerup() {
			stop();
			_colleced = false;
			
			hitArea_mc.alpha = 0;
			this.cacheAsBitmap = true;
		}
		
		public function get type():String { return _type; }
		
		public function set type(value:String):void {
			_type = value;
			switch (_type) {
				case PluginConstants.POWERUP_HEALTH:
					gotoAndStop(1);
					break;
			}
		}
		
		public function get id():int { return _id; }
		
		public function set id(value:int):void {
			_id = value;
		}
		
		public function get colleced():Boolean { return _colleced; }
		
		public function set colleced(value:Boolean):void {
			_colleced = value;
		}
		
	}
	
}