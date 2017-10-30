package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterRight')]
	public class WaterRight extends Water {
		
		public function WaterRight() {
			
			decal = ItemTypes.WATER_RIGHT;
			hitWidth = 150;
			hitHeight = 200;
			isObstacle = true;
			isHittable = false;
		}
		
		
	}
	
}