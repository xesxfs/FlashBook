package com.gamebook.coop.windows {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='GameOverWindow')]
	public class GameOver extends MovieClip {
		
		public var msg_txt:TextField;
		
		public function GameOver(loserName:String) {
			msg_txt.text = loserName + " lost the game!";
		}
		
	}
	
}