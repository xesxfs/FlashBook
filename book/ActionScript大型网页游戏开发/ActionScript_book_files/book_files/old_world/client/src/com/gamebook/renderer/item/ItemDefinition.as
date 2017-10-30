package com.gamebook.renderer.item {
	import com.gamebook.utils.assetsloader.Asset;
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ItemDefinition extends EventDispatcher{
		
		private var _baseDirectory:String;
		private var _file:String;
		private var _bitmapData:BitmapData;
		private var _cols:int;
		private var _rows:int;
		private var _xOffset:int;
		private var _yOffset:int;
		private var _walkable:Boolean;
		private var _id:String;
		private var _asl:AssetsLoader;
		private var _asset:Asset;
		private var _overlap:Boolean;
		
		public function ItemDefinition() {
			_overlap = false;
		}
		
		public function fromXML(info:XML):void {
			_file = info.@file;
			_cols = int(info.@cols);
			_rows = int(info.@rows);
			_xOffset = int(info.@x_offset);
			_yOffset = int(info.@y_offset);
			_overlap = info.@overlap == "true";
			_id = info.@id;
			_walkable = info.@walkable == "true";
			load();
		}
		
		public function toXML():String
		{
			return "<ItemDefinition id='" + _id + "' file='" + _file + "' x_offset='" + _xOffset + "' y_offset='" + _yOffset + "' rows='" + _rows + "' cols='" + _cols + "' walkable='" + _walkable + "' overlap='" + _overlap + "'/>";		
		}
		
		public function load():void {
			_asl.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			_asset = _asl.loadAsset(_baseDirectory+_file, AssetType.IMAGE);
		}
		
		private function onAssetComplete(e:AssetEvent):void {
			if (e.asset == _asset) {
				if (e.success) {
					_bitmapData = (_asset.loader.content as Bitmap).bitmapData;
					
					_asl.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
					_asl = null;
				} else {
					throw new Error("Asset failed to load from here: " + _asset.url);
				}
			}
		}
		
		public function get file():String { return _file; }
		
		public function get cols():int { return _cols; }
		
		public function get rows():int { return _rows; }
		
		public function get xOffset():int { return _xOffset; }
		
		public function get yOffset():int { return _yOffset; }
		
		public function get id():String { return _id; }
		
		public function get walkable():Boolean { return _walkable; }
		
		public function set asl(value:AssetsLoader):void {
			_asl = value;
		}
		
		public function set baseDirectory(value:String):void {
			_baseDirectory = value;
		}
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		public function get overlap():Boolean { return _overlap; }
		
		public function set file(value:String):void {
			_file = value;
		}
		
		public function set cols(value:int):void {
			_cols = value;
		}
		
		public function set rows(value:int):void {
			_rows = value;
		}
		
		public function set xOffset(value:int):void {
			_xOffset = value;
		}
		
		public function set yOffset(value:int):void {
			_yOffset = value;
		}
		
		public function set walkable(value:Boolean):void {
			_walkable = value;
		}
		
		public function set id(value:String):void {
			_id = value;
		}
		
		public function set overlap(value:Boolean):void {
			_overlap = value;
		}
		
	}
	
}