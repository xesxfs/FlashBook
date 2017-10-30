package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.tankgame.PluginConstants;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../../assets/tankGame.swf', symbol='House')]
	public class House extends Item {
		
		public function House() {
			decal = ItemTypes.HOUSE;
			hitWidth = 120;
			hitHeight = 90;
		}
		
		
		
		
	}
	
}