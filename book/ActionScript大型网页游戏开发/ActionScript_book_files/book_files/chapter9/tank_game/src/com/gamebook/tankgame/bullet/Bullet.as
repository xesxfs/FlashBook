package com.gamebook.tankgame.bullet {
	import com.gamebook.utils.network.movement.Converger;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Bullet')]
	public class Bullet extends MovieClip{
		
		private var _id:int;
		
		private var _converger:Converger;
		
		private var _hitTime:Number;
		private var _hitX:int = -1;
		private var _hitY:int = -1;
		
		private var _alive:Boolean = true;
		
		public function Bullet() {
			_converger = new Converger();
			_converger.interceptTimeMultiplier = 2;
			_converger.maxDurationInterceptTime = 300;
			
			this.cacheAsBitmap = true;
		}
		
		public function run():void {
			_converger.run();
			
			x = _converger.view.x;
			y = _converger.view.y;
			rotation = _converger.course.angle;
		}
		
		public function get id():int { return _id; }
		
		public function set id(value:int):void {
			_id = value;
		}
		
		public function get converger():Converger { return _converger; }
		
		
		public function get hitX():int { return _hitX; }
		
		public function set hitX(value:int):void {
			_hitX = value;
		}
		
		public function get hitY():int { return _hitY; }
		
		public function set hitY(value:int):void {
			_hitY = value;
		}
		
		public function get hitTime():Number { return _hitTime; }
		
		public function set hitTime(value:Number):void {
			_hitTime = value;
		}
		
		public function get alive():Boolean { return _alive; }
		
		public function set alive(value:Boolean):void {
			_alive = value;
		}
		
	}
	
}