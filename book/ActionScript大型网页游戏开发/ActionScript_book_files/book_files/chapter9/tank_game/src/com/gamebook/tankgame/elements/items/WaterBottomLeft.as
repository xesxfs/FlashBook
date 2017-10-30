package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterBottomLeft')]
	public class WaterBottomLeft extends Water {
		
		public function WaterBottomLeft() {
			
			decal = ItemTypes.WATER_BOTTOM_LEFT;
			hitWidth = 150;
			hitHeight = 150;
			
			isObstacle = true;
			isHittable = false;
		}
		
		
	}
	
}