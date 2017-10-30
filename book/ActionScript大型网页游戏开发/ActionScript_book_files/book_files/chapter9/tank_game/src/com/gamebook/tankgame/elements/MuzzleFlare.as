package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='MuzzleFlare')]
	public class MuzzleFlare extends MovieClip{
		
		
		
		public function MuzzleFlare() {
			addEventListener(Event.ENTER_FRAME, run);
		}
		
		private function run(e:Event):void {
			alpha -= .15;
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, run);
				this.parent.removeChild(this);
			}
		}
		
	}
	
}