package com.gamebook.coop.elements {
	
	import com.gamebook.coop.player.Player;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	
	/**
	 * A beam of light that kills you.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class LaserBeam extends Sprite {
		
		public static const LASER_DONE:String = "laser_done";
		
		private const MAX_LIFE:int = 1000; // how many milliseconds the laser "lives"
		
		private var _shooter:LaserTower;
		private var _victim:Player;
		private var _glow:GlowFilter;
		private var _firstShotTime:int;
		
		/**
		 * Store a reference to the shooter and victim so we can lock on and
		 * draw the laser in the correct place.
		 */
		public function LaserBeam(shooter:LaserTower, victim:Player) {
			_shooter = shooter;
			_victim = victim;
			
			_glow = new GlowFilter(0xffff00, 1);
			this.filters = [_glow];
			
			_firstShotTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// tell the victim he/she is being shot
			_victim.setHitWithLaser();
		}
		
		/**
		 * Draw the laser or destroy it if enough time has passed.
		 */
		private function onEnterFrame(e:Event):void {
			
			// time to quit?
			if (getTimer() - _firstShotTime > MAX_LIFE) {
				
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				dispatchEvent(new Event(LASER_DONE));
				
				return;
			}
			
			// draw the laser
			graphics.clear();
			graphics.lineStyle(2, 0xff0000, 1.0);
			graphics.moveTo(_shooter.x + _shooter.width / 2, _shooter.y + _shooter.width / 2 - 7);
			graphics.lineTo(_victim.x, _victim.y - 5);
		}
		
		public function get shooter():LaserTower	{ return _shooter; }
		public function get victim():Player			{ return _victim; }
	}
	
}