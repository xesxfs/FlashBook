package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='DeathSmudge')]
	public class DeathSmudge extends MovieClip{
		
		public function DeathSmudge() {
			cacheAsBitmap = true;
		}
		
	}
	
}