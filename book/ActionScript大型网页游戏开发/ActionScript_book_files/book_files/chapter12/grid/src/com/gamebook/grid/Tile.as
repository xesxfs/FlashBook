package com.gamebook.grid {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../assets/assets.swf', symbol='Tile')]
	public class Tile extends MovieClip{
		
		public function Tile() {
			cacheAsBitmap = true;
		}
		
	}
	
}