package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterTopLeft')]
	public class WaterTopLeft extends Water {
		
		public function WaterTopLeft() {
			
			decal = ItemTypes.WATER_TOP_LEFT;
			hitWidth = 150;
			hitHeight = 150;
			isObstacle = true;
			isHittable = false;
		}
		
		
	}
	
}