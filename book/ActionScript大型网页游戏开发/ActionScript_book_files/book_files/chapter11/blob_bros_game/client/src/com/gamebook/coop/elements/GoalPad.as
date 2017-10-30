package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='GoalPad')]
	public class GoalPad extends MovieClip {
		
		public function GoalPad(tile:Tile) {
			this.x = tile.x;
			this.y = tile.y;
			tile.isGoalPoint = true;
		}
		
	}
	
}