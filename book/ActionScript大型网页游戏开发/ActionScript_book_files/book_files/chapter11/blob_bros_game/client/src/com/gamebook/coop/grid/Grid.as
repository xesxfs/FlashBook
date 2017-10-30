package com.gamebook.coop.grid {
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class Grid {
		
		private var _columns:int;
		private var _rows:int;
		private var _tileWidth:int;
		private var _tileHeight:int;
		private var _tiles:Array;
		
		/**
		 * Constructor
		 */
		public function Grid(columns:int, rows:int, tileWidth:int, tileHeight:int) {
			_columns = columns;
			_rows = rows;
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			
			_tiles = new Array();
			for ( var i:int = 0; i < columns; i++ ) {
				_tiles[i] = new Array();
				for ( var j:int = 0; j < rows; j++ ) {
					_tiles[i][j] = new Tile(i, j, _tileWidth, _tileHeight, true);
				}
			}
		}
		
		
		/**
		 * Fetch the specified tile by column and row.
		 */
		public function getTile(column:int, row:int):Tile {
			if ( column >= _columns || row >= _rows || column < 0 || row < 0 ) return null;
			return _tiles[column][row];
		}
		
		
		/**
		 * Fetch the tile based upon the x and y coordinates.
		 */
		public function getTileAtLocation(x:Number, y:Number):Tile {
			var col:int = Math.floor(x / _tileWidth);
			var row:int = Math.floor(y / _tileHeight);
			
			if ( col >= _columns || row >= _rows || col < 0 || row < 0 ) return null;
			return _tiles[col][row];
		}
		
		
		public function get columns():int	{ return _columns; }
		public function get rows():int		{ return _rows; }
		
	}
	
}