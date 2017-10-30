package com.gamebook.grid {
	import com.gamebook.utils.geom.Coordinate;
	import com.gamebook.utils.Isometric;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;
	
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
		
		private var _sortedItems:Array;
		
		private var _itemHolder:MovieClip;
		
		public function Map() {
			initialize();
		}
		
		private function initialize():void{
			_iso = new Isometric();
			
			
			_sortedItems = [];
			
			
			//when mapped to the screen the tile makes a diamond of these dimensions
			_tileWidthOnScreen = 64;
			_tileHeightOnScreen = 32;
			
			//figure out the width of the tile in 3D space
			_tileWidth = _iso.mapToIsoWorld(64, 0).x;
			
			//the tile is a square in 3D space so the height matches the width
			_tileHeight = _tileWidth;
			
			_cols = 10;
			_rows = 10;
			
			buildGrid();
			
			_itemHolder = new MovieClip();
			addChild(_itemHolder);
			
			
			for (var i:int = 0; i < 50;++i) {
				var col:int = Math.floor(_cols * Math.random());
				var row:int = Math.floor(_rows * Math.random());
				
				var item:Item = new Item();
				item.type = Math.floor(3*Math.random());
				
				if (testItemPlacement(item, col, row)) {
					addItem(item, col, row);
				}
			}
			
			sortAllItems();
		}
		
		private function sortAllItems():void{
			var list:Array = _sortedItems.slice(0);
			
			_sortedItems = [];
			
			for (var i:int = 0; i < list.length;++i) {
				var nsi:ISortableItem = list[i];
				
				var added:Boolean = false;
				for (var j:int = 0; j < _sortedItems.length;++j ) {
					var si:ISortableItem = _sortedItems[j];
					
					if (nsi.col <= si.col+si.cols-1 && nsi.row <= si.row+si.rows-1) {
						_sortedItems.splice(j, 0, nsi);
						added = true;
						break;
					}
				}
				if (!added) {
					_sortedItems.push(nsi);
				}
			}
			
			for (i = 0; i < _sortedItems.length;++i) {
				var disp:DisplayObject = _sortedItems[i] as DisplayObject;
				_itemHolder.addChildAt(disp, i);
			}
		}
		
		private function addItem(itm:Item, col:int, row:int):void {

			for (var i:int = col; i < col + itm.cols;++i) {
				for (var j:int = row; j < row +itm.rows;++j) {
					var tile:Tile = getTile(i, j);
					if (tile != null) {
						tile.addItem(itm);
					}
				}
			}
			
			var tx:Number = _tileWidth * col + _tileWidth / 2;
			var tz:Number = -(_tileHeight * row + _tileHeight / 2);
			
			var coord:Coordinate = _iso.mapToScreen(tx, 0, tz);
			itm.x = coord.x;
			itm.y = coord.y;
			
			itm.col = col;
			itm.row = row;
			
			_itemHolder.addChild(itm);
			
			_sortedItems.push(itm);
		}
		
		private function testItemPlacement(itm:Item, col:int, row:int):Boolean {
			var valid:Boolean = true;
			
			for (var i:int = col; i < col + itm.cols;++i) {
				for (var j:int = row; j < row +itm.rows;++j) {
					var tile:Tile = getTile(i, j);
					if (tile == null || tile.items.length > 0) {
						valid = false;
						break;
					}
				}
			}
			return valid;
		}
		
		
		private function buildGrid():void{
			_grid = [];
			for (var i:int = 0; i < _cols;++i) {
				_grid[i] = [];
				for (var j:int = 0; j < _rows;++j) {
					var t:Tile = new Tile();
					t.col = i;
					t.row = j;
					
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
			var tile:Tile;
			
			if (col < _cols && row < _rows) {
				tile = _grid[col][row];
			}
			
			return tile;
		}
		
	}
	
}