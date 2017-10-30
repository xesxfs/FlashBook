package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='WaterLeft')]
	public class WaterLeft extends Water {
		
		public function WaterLeft() {
			
			decal = ItemTypes.WATER_LEFT;
			hitWidth = 150;
			hitHeight = 200;
			isObstacle = true;
			isHittable = false;
		}
		
	}
	
}