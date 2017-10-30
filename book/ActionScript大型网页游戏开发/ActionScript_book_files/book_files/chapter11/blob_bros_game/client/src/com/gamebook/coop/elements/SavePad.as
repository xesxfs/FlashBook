package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='SavePad')]
	public class SavePad extends MovieClip {
		
		public function SavePad(tile:Tile) {
			this.x = tile.x;
			this.y = tile.y;
			tile.isSavePoint = true;
		}
		
	}
	
}