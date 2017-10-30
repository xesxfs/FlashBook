package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class LineFader extends MovieClip{
		
		public function LineFader() {
			addEventListener(Event.ENTER_FRAME, run);
			
			//filters = [new GlowFilter(0x990000, 1, 2, 1)];
		}
		
		private function run(e:Event):void {
			alpha -= .1;
			if (alpha <= 0) {
				removeEventListener(Event.ENTER_FRAME, run);
				this.parent.removeChild(this);
			}
		
		}
	}
	
}