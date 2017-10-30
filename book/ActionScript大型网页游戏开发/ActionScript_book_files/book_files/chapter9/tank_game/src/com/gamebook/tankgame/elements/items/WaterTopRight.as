package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterTopRight')]
	public class WaterTopRight extends Water {
		
		public function WaterTopRight() {
			
			decal = ItemTypes.WATER_TOP_RIGHT;
			hitWidth = 150;
			hitHeight = 150;
			isObstacle = true;
			isHittable = false;
		}
		
		
	}
	
}