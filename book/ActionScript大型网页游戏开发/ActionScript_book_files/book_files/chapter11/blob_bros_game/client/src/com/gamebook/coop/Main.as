package com.gamebook.coop {
	
	import flash.display.Sprite;
	
	/**
	 * The main entry point to the game.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[SWF(frameRate="31", width="800", height="600", backgroundColor="#666666")]
	public class Main extends Sprite {
		
		public function Main():void {
			var gameFlow:GameFlow = new GameFlow();
			addChild(gameFlow);
		}
		
	}
	
}