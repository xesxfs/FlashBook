package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Target')]
	public class Target extends MovieClip {
		
		public var disc_mc:MovieClip;
		
		public function Target() {
			alpha = .5;
			addEventListener(Event.ENTER_FRAME, run);
		}
		
		private function run(e:Event):void {
			disc_mc.rotation += 2;
		}
		
	}
	
}