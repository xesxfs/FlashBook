package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Tile')]
	public class Tile extends MovieClip{
		
		public function Tile() {
			stop();
			this.cacheAsBitmap = true;
		}
		
		public function showTileIndex(ind:int):void {
			gotoAndStop(ind + 1);
		}
		
	}
	
}