package com.gamebook.tankgame.elements.items {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WallVertical')]
	public class WallVertical extends Item{
		
		public function WallVertical() {
			decal = ItemTypes.WALL_VERTICAL;
			hitWidth = 50;
			hitHeight = 100;
		}
		
	}
	
}