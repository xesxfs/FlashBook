package com.gamebook.coop.player.avatars {
	
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class Avatar extends MovieClip {
		
		// stage variables in the asset
		public var bounceRight:MovieClip;
		public var bounceLeft:MovieClip;
		public var bounceUp:MovieClip;
		public var bounceDown:MovieClip;
		public var attackRight:MovieClip;
		public var attackLeft:MovieClip;
		public var attackUp:MovieClip;
		public var attackDown:MovieClip;
		
		private var _currentAnimationClip:MovieClip;
		private var _currentRotation:int = 0;
		private var _currentState:String = "bounce";
		
		public function Avatar() {
			initialize();
		}
		
		private function initialize():void {
			
			// stop all clips
			bounceRight.gotoAndStop(1);
			bounceLeft.gotoAndStop(1);
			bounceUp.gotoAndStop(1);
			bounceDown.gotoAndStop(1);
			attackRight.gotoAndStop(1);
			attackLeft.gotoAndStop(1);
			attackUp.gotoAndStop(1);
			attackDown.gotoAndStop(1);
			
			// hide all clips
			bounceRight.visible = false;
			bounceLeft.visible = false;
			bounceUp.visible = false;
			bounceDown.visible = false;
			attackRight.visible = false;
			attackLeft.visible = false;
			attackUp.visible = false;
			attackDown.visible = false;
			
			_currentAnimationClip = bounceRight;
			_currentAnimationClip.visible = true;
		}
		
		public function setCurrentState(state:String):void {
			
			if (_currentState != state) {
				
				// stop the current clip
				_currentAnimationClip.stop();
				_currentAnimationClip.visible = false;
				
				_currentState = state;
				var clipName:String = _currentState + getDirName(_currentRotation);
				_currentAnimationClip = this[clipName];
				_currentAnimationClip.visible = true;
			}
			
		}
		
		public function setRotation(rotationIndex:int):void {
			
			//trace("setRotation: " + rotationIndex);
			
			if (rotationIndex != _currentRotation) {
				
				// stop the current clip
				_currentAnimationClip.stop();
				_currentAnimationClip.visible = false;
				
				// set the new clip
				_currentRotation = rotationIndex;
				var clipName:String = _currentState + getDirName(_currentRotation);
				//trace(clipName);
				_currentAnimationClip = this[clipName];
				_currentAnimationClip.visible = true;
			}
		}
		
		private function getDirName(rotation:int):String {
			
			var directionName:String = "Right";
			
			switch (rotation) {
				case 0 :
					directionName = "Right";
					break;
				case 1 :
					directionName = "Right";
					break;
				case 2 :
					directionName = "Down";
					break;
				case 3 :
					directionName = "Down";
					break;
				case 4 :
					directionName = "Left";
					break;
				case 5 :
					directionName = "Left";
					break;
				case 6 :
					directionName = "Up";
					break;
				case 7 :
					directionName = "Up";
					break;
			}
			
			return directionName;
		}
		
		public function get currentAnimationClip():MovieClip	{ return _currentAnimationClip; }
		public function get currentState():String				{ return _currentState; }
	}
	
}