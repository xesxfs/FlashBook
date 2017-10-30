package com.gamebook.astarexample {
	import flash.display.MovieClip;
	import flash.events.Event;
	public class Main extends MovieClip {

		public function Main() {

			var grid:Grid = new Grid();
			grid.initialize(20, 15);
			addChild(grid);
		}
	}
	
}
