package com.gamebook.world.animation {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class SpriteAnimation {
		
		private var _bitmapData:BitmapData;
		
		private var _grid:Array;
		
		private var _row:int;
		private var _col:int;
		private var _framesToHold:int;
		private var _frameIndex:int;
		
		private var _frameWidth:int;
		private var _frameHeight:int;
		
		private var _ready:Boolean = false;
		
		public function SpriteAnimation(width:int, height:int) {
			_frameWidth = width;
			_frameHeight = height;
			_grid = [];
			
			_col = 0;
			_frameIndex = -1;
			_row = 0;
			_framesToHold = 1;
		}
		
		public function nextFrame():void {
			++_frameIndex;
			if (_frameIndex == _framesToHold) {
				++_col;
				_frameIndex = 0;
				if (_col == _grid.length) {
					_col = 0;
				}
			}
			_bitmapData = getFrame(_col, _row);
		}
		
		public function layerBitmapData(bd:BitmapData):void {
			if (_bitmapData == null) {
				_bitmapData = bd.clone();
			} else {
				_bitmapData.draw(bd);
			}
		}
		
		public function getFrame(col:int, row:int):BitmapData {
			return _grid[col][row];
		}
		
		public function process():void {
			var cols:int = Math.floor(_bitmapData.width / _frameWidth);
			var rows:int = Math.floor(_bitmapData.height / _frameHeight);
			
			var rect:Rectangle = new Rectangle(0, 0, _frameWidth, _frameHeight);
			
			for (var i:int = 0; i < cols;++i) {
				_grid[i] = [];
				for (var j:int = 0; j < rows;++j) {
					var bd:BitmapData = new BitmapData(_frameWidth, _frameHeight, true, 0x990000);
					rect.x = i * _frameWidth;
					rect.y = j * _frameHeight;
					bd.copyPixels(_bitmapData, rect, new Point(0, 0));
					
					_grid[i][j] = bd;
				}
			}
			
			_bitmapData.dispose();
			_bitmapData = new BitmapData(_frameWidth, _frameHeight, true, 0x990000);
			nextFrame();
			_ready = true;
		}
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		public function get frameWidth():int { return _frameWidth; }
		
		public function set frameWidth(value:int):void {
			_frameWidth = value;
		}
		
		public function get frameHeight():int { return _frameHeight; }
		
		public function set frameHeight(value:int):void {
			_frameHeight = value;
		}
		
		public function get row():int { return _row; }
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get col():int { return _col; }
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function get framesToHold():int { return _framesToHold; }
		
		public function set framesToHold(value:int):void {
			_framesToHold = value;
		}
		
		public function get ready():Boolean { return _ready; }
		
	}
	
}