package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='Tree')]
	public class Tree extends Item {
		
		public function Tree() {
			
			decal = ItemTypes.TREE;
			hitWidth = 85;
			hitHeight = 75;
			
			isObstacle = false;
			isHittable = false;
		}
		
		
	}
	
}