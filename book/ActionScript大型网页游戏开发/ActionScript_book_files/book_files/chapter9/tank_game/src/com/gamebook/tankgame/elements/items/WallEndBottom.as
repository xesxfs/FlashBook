package com.gamebook.tankgame.elements.items {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WallEndBottom')]
	public class WallEndBottom extends Item{
		
		public function WallEndBottom() {
			decal = ItemTypes.WALL_END_BOTTOM;
			hitWidth = 50;
			hitHeight = 100;
		}
		
	}
	
}