package com.gamebook.tankgame {
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			var gameFlow:GameFlow = new GameFlow();
			addChild(gameFlow);
			
		}
		
	}
	
}