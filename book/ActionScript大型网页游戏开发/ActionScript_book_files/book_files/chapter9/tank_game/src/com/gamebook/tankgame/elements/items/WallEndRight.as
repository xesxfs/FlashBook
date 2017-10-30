package com.gamebook.tankgame.elements.items {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WallEndRight')]
	public class WallEndRight extends Item{
		
		public function WallEndRight() {
			decal = ItemTypes.WALL_END_RIGHT;
			hitWidth = 100;
			hitHeight = 50;
		}
		
	}
	
}