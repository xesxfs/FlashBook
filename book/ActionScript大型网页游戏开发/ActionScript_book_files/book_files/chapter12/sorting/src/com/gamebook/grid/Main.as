package com.gamebook.grid {
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			
			var map:Map = new Map();
			map.x = 400;
			map.y = 100;
			addChild(map);
			
		}
		
	}
	
}