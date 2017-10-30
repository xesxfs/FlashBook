package com.gamebook.syncexample {
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			var se:SyncExample = new SyncExample();
			addChild(se);
		}
		
		
	}
	
}