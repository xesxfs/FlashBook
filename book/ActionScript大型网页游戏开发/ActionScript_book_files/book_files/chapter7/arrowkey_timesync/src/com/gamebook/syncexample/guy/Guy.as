package com.gamebook.syncexample.guy {
	import com.gamebook.utils.network.movement.Converger;
	import com.gamebook.utils.NumberUtil;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Guy')]
	public class Guy extends MovieClip{
		
		private var _playerName:String;
		private var _isMe:Boolean;
		private var _converger:Converger;

		private var ani_mc:MovieClip;
		
		private var _lastXDir:int;
		private var _lastYDir:int;
		
		//declare stage variables in the character
		public var ani0_mc:MovieClip;
		public var ani1_mc:MovieClip;
		public var ani2_mc:MovieClip;
		public var ani3_mc:MovieClip;
		public var ani4_mc:MovieClip;
		public var ani5_mc:MovieClip;
		public var ani6_mc:MovieClip;
		public var ani7_mc:MovieClip;
		
		
		public function Guy() {
			_isMe = false;
			_converger = new Converger();
			_converger.interceptTimeMultiplier = 5;
			_converger.maxDurationInterceptTime = 800;
			
			_lastXDir = 0;
			_lastYDir = 0;
			
			
			//turn off all 8 rotations and stop them from animating
			for (var i:int = 0; i < 8;++i) {
				var ani:MovieClip = this["ani" + i.toString() + "_mc"];
				ani.visible = false;
				ani.stop();
			}
			
			//turn on 1 direction so we can see it
			ani_mc = ani0_mc;
			ani_mc.visible = true;
		}
		
		public function run():void {
			_converger.run();
			
			x = _converger.view.x;
			y = _converger.view.y;
			
			showCharacterAngle();
		}
		
		private function showCharacterAngle():void {
			var isWalking:Boolean = _converger.view.speed > 0;
			var angle:Number = _converger.view.angle;
			var rotationIndex:int = NumberUtil.findAngleIndex(angle, 45);
			var ani:MovieClip = this["ani" + rotationIndex.toString() + "_mc"];
			if (ani != ani_mc) {
				ani_mc.visible = false;
				ani_mc.stop();
				
				ani_mc = ani;
				ani_mc.visible = true;
			}
			if (!isWalking) {
				ani_mc.stop();
			} else {
				ani_mc.play();
			}
		}
		
		public function get playerName():String { return _playerName; }
		
		public function set playerName(value:String):void {
			_playerName = value;
		}
		
		public function get isMe():Boolean { return _isMe; }
		
		public function set isMe(value:Boolean):void {
			_isMe = value;
		}
		
		public function get converger():Converger { return _converger; }
		
		public function get lastXDir():int { return _lastXDir; }
		
		public function set lastXDir(value:int):void {
			_lastXDir = value;
		}
		
		public function get lastYDir():int { return _lastYDir; }
		
		public function set lastYDir(value:int):void {
			_lastYDir = value;
		}
		
	}
	
}