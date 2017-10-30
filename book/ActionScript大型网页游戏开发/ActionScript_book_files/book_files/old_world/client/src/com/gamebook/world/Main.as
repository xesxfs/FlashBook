package com.gamebook.world {
	import com.gamebook.utils.FrameRateCounter;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends MovieClip{
		
		public function Main() {
			
			var gf:GameFlow = new GameFlow();
			addChild(gf);
			
            var frc:FrameRateCounter = new FrameRateCounter();
            frc.mouseChildren = frc.mouseEnabled = false;
			addChild(new FrameRateCounter());
		}
		
	}
	
}
