package com.gamebook.tankgame.elements.items {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WallEndLeft')]
	public class WallEndLeft extends Item{
		
		public function WallEndLeft() {
			decal = ItemTypes.WALL_END_LEFT;
			hitWidth = 100;
			hitHeight = 50;
		}
		
	}
	
}