package com.gamebook.tankgame.tank {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='HealthBar')]
	public class HealthBar extends MovieClip{
		
		public var bar_mc:MovieClip;
		
		public function HealthBar() {
			this.cacheAsBitmap = true;
		}
		
		
	}
	
}