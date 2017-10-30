package com.gamebook.tankgame.elements {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Explosion')]
	public class Explosion extends MovieClip{
		
		public function Explosion() {
			scaleX = scaleY = .25;
			addFrameScript(13, removeMe);
		}
		
		private function removeMe():void{
			stop();
			this.parent.removeChild(this);
		}
		
	}
	
}