package com.gamebook.tankgame.elements.items {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='Bridge')]
	public class Bridge extends Item{
		
		public function Bridge() {
			
			decal = ItemTypes.BRIDGE;
			hitWidth = 300;
			hitHeight = 165;
			isObstacle = false;
			isHittable = false;
		}
		
	}
	
}