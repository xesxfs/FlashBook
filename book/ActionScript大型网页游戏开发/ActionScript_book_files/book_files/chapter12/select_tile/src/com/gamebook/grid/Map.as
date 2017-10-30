package com.gamebook.grid {
	import com.gamebook.utils.geom.Coordinate;
	import com.gamebook.utils.Isometric;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
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
		private var _cols:int;
		private var _rows:int;
		
		private var _lastTile:Tile;
		
		public function Map() {
			initialize();
		}
		
		private function initialize():void{
			_iso = new Isometric();
			
			
			//when mapped to the screen the tile makes a diamond of these dimensions
			_tileWidthOnScreen = 64;
			_tileHeightOnScreen = 32;
			
			//figure out the width of the tile in 3D space
			_tileWidth = _iso.mapToIsoWorld(64, 0).x;
			
			//the tile is a square in 3D space so the height matches the width
			_tileHeight = _tileWidth;
			
			buildGrid();
			
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
		}
		
		private function mouseMoved(e:MouseEvent):void {
			if (_lastTile != null) {
				_lastTile.alpha = 1;
				_lastTile = null;
			}
			
			var coord:Coordinate = _iso.mapToIsoWorld(mouseX, mouseY);
			var col:int = Math.floor(coord.x / _tileWidth);
			var row:int = Math.floor(Math.abs(coord.z / _tileHeight));
			
			if (col < _cols && row < _rows) {
				var tile:Tile = getTile(col, row);
				tile.alpha = .5;
				_lastTile = tile;
			}
		}
		
		private function buildGrid():void{
			_grid = [];
			_cols = 10;
			_rows = 10;
			for (var i:int = 0; i < _cols;++i) {
				_grid[i] = [];
				for (var j:int = 0; j < _rows;++j) {
					var t:Tile = new Tile();
					
					var tx:Number = i * _tileWidth;
					var tz:Number = -j * _tileHeight;
					
					var coord:Coordinate = _iso.mapToScreen(tx, 0, tz);
					
					t.x = coord.x;
					t.y = coord.y;
					
					_grid[i][j] = t;
					
					addChild(t);
				}
			}
		}
		
		private function getTile(col:int, row:int):Tile {
			return _grid[col][row];
		}
		
	}
	
}