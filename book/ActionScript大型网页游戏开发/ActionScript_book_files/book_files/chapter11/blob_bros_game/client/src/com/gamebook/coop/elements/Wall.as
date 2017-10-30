package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	
	/**
	 * A wall graphic that can be placed on a tile on which you shouldn't walk.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Wall')]
	public class Wall extends MovieClip {
		
		public function Wall(tile:Tile) {
			this.x = tile.x;
			this.y = tile.y;
			tile.isWalkable = false;
		}
		
	}
	
}