package com.gamebook.tankgame.elements.items {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WallEndTop')]
	public class WallEndTop extends Item{
		
		public function WallEndTop() {
			decal = ItemTypes.WALL_END_TOP;
			hitWidth = 50;
			hitHeight = 100;
		}
		
	}
	
}