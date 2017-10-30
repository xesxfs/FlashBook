package com.gamebook.lobby {
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			
			//create the chat flow
			var lobbyFlow:LobbyFlow = new LobbyFlow();
			addChild(lobbyFlow);
		}
		
		
	}
	
}