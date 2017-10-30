package com.gamebook.renderer {
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Background extends Sprite{
		
		public static const DONE_LOADING:String = "doneLoading";
		
		private var _baseDirectory:String;
		private var _bitmap:Bitmap;
		private var _ready:Boolean;
		private var _cols:int;
		private var _rows:int;
		private var _file:String;
		private var _xOffset:int;
		private var _yOffset:int;
		
		private var _asl:AssetsLoader;
		
		public function Background() {
			
		}
		
		public function fromXML(info:XML):void {
			_file = info.background.@file;
			_cols = int(info.background.@cols);
			_rows = int(info.background.@rows);
			_xOffset = int(info.background.@x_offset);
			_yOffset = int(info.background.@y_offset);
			
			_asl = new AssetsLoader();
			_asl.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			_asl.loadAsset(_baseDirectory+file, AssetType.IMAGE);
		}
		
		public function toXML():String
		{
			return "<background file='" + _file + "' x_offset='" + _xOffset + "' y_offset='" + _yOffset + "' cols='" + _cols + "' rows='" + _rows + "' />";
		}
		
		private function onAssetComplete(e:AssetEvent):void {
			if (e.success) {
				var b:Bitmap = e.asset.loader.content as Bitmap;
				var bitmap:Bitmap = new Bitmap(b.bitmapData);
				
				_bitmap = bitmap;
				_bitmap.x = _xOffset;
				_bitmap.y = _yOffset;
				addChild(_bitmap);
				
				_ready = true;
				
				dispatchEvent(new Event(DONE_LOADING));
			} else {
				throw new Error("Failed to load background image form here: " + e.asset.url);
			}
		}
		
		public function get ready():Boolean { return _ready; }
		
		public function get cols():int { return _cols; }
		
		public function get rows():int { return _rows; }
		
		public function get file():String { return _file; }
		
		public function get xOffset():int { return _xOffset; }
		
		public function set xOffset( newVal:int ):void 
		{ 
			_xOffset = newVal;
			_bitmap.x = _xOffset; 
			dispatchEvent( new Event( Event.CHANGE ) );
		};
				
		public function get yOffset():int { return _yOffset; }
		
		public function set yOffset( newVal:int ):void 
		{ 
			_yOffset = newVal;
			_bitmap.y = _yOffset; 
			dispatchEvent( new Event( Event.CHANGE ) );
		};
		
		public function set baseDirectory(value:String):void {
			_baseDirectory = value;
		}
		
	}
	
}