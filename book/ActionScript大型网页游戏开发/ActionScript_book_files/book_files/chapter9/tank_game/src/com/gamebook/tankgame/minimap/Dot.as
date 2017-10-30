package com.gamebook.tankgame.minimap {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Dot')]
	public class Dot extends MovieClip{
		
		public function Dot() {
			this.cacheAsBitmap = true;
			stop();
		}
		
	}
	
}