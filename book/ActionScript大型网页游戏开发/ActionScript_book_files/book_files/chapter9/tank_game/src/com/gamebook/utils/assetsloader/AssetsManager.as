package com.gamebook.utils.assetsloader {
	import com.gamebook.utils.assetsloader.constants.AssetsLoaderMode;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderEvent;

	public class AssetsManager {

		private static var MANAGERS:Object = new Object();
		private var _name:String;
		private var _ASL:AssetsLoader;
		private var _assets:Object;

		public function AssetsManager(name:String, addGlobally:Boolean = true) {
			
			_name = name;
			_ASL = new AssetsLoader( AssetsLoaderMode.BATCH_MODE );
			_ASL.addEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, onLoadComplete, false, -1, true);
			_assets = new Object();
			if (addGlobally) {
				AssetsManager.addManager(this);
			}
		}

		private static function addManager(manager:AssetsManager):void {
			if (MANAGERS[manager.name] != null) {
				throw new Error("AssetsManager " + manager.name + " already exists. Use AssetsManager.getManager(name) to create / get the AssetsManager.");
			} else {
				MANAGERS[manager.name] = manager;
			}
		}

		public function clearAssets():void {
			_assets = new Object();
		}

		public function getAsset(url:String, dataFormat:String):Object {
			if (_assets[dataFormat] != null) {
				return _assets[dataFormat][url];
			}
			return null;
		}

		public static function getManager(name:String):AssetsManager {
			if (MANAGERS[name] != null) {
				return MANAGERS[name];
			}
			var newManager:AssetsManager = new AssetsManager(name);
			return newManager;
		}

		public function get loader():AssetsLoader {
			return _ASL;
		}

		public function get name():String {
			return _name;
		}

		private function onLoadComplete(e:AssetsLoaderEvent):void {			
			var loadedAssets:Array = _ASL.assetsComplete;
			var asset:Asset;
			for (var i:int = 0;i < loadedAssets.length; i++) {
				asset = loadedAssets[i];
				if (_assets[asset.type] == null) {
					_assets[asset.type] = new Object();
				}
				_assets[asset.type][asset.url] = asset.data;
			}
			
			// this load is complete. transfer assets to the manager and reset the loader.
			_ASL = new AssetsLoader( AssetsLoaderMode.BATCH_MODE );
			_ASL.addEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, onLoadComplete, false, -1, true);
		}
	}
}
