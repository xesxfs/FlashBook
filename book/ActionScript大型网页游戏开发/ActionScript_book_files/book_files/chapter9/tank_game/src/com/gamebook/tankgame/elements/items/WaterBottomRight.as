package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterBottomRight')]
	public class WaterBottomRight extends Item {
		
		public function WaterBottomRight() {
			
			decal = ItemTypes.WATER_BOTTOM_RIGHT;
			hitWidth = 150;
			hitHeight = 150;
			isObstacle = true;
			isHittable = false;
			
		}
		
		
	}
	
}