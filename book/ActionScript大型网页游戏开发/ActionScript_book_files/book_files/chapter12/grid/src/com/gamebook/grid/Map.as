package com.gamebook.grid {
	import com.gamebook.utils.geom.Coordinate;
	import com.gamebook.utils.Isometric;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Map extends MovieClip{
		
		private var _grid:Array;
		private var _iso:Isometric;
		private var _tileWidthOnScreen:int;
		private var _tileHeightOnScreen:int;
		private var _tileWidth:Number;
		private var _tileHeight:Number;
		
		public function Map() {
			initialize();
		}
		
		private function initialize():void{
			
			_iso = new Isometric();
			
			//when mapped to the screen the tile makes a diamond of these dimensions
			_tileWidthOnScreen = 64;
			_tileHeightOnScreen = 32;
			
			//figure out the width of the tile in 3D space - 45.254833995939045
			_tileWidth = _iso.mapToIsoWorld(64, 0).x;
			
			trace(_iso.mapToScreen(40, 0, 0).x);
			
			//the tile is a square in 3D space so the height matches the width
			_tileHeight = _tileWidth;
			
			buildGrid();
		}
		
		private function buildGrid():void {
			_grid = [];
			
			//establish dimensions
			var cols:int = 10;
			var rows:int = 10;
			
			//build the grid
			for (var i:int = 0; i < cols;++i) {
				_grid[i] = [];
				for (var j:int = 0; j < rows;++j) {
					//create tile
					var t:Tile = new Tile();
					
					//position it in 3D
					var tx:Number = i * _tileWidth;
					var tz:Number = -j * _tileHeight;
					
					//map 3D to screen
					var coord:Coordinate = _iso.mapToScreen(tx, 0, tz);
					
					//position on screen
					t.x = coord.x;
					t.y = coord.y;
					
					//store tile
					_grid[i][j] = t;
					
					//add to screen
					addChild(t);
				}
			}
		}
		
		private function getTile(col:int, row:int):Tile {
			return _grid[col][row];
		}
		
	}
	
}