package com.gamebook.utils.assetsloader.events {
	
	
	import com.gamebook.utils.assetsloader.Asset;
	import flash.events.Event;
	
	
	/**
	 * AssetEvent
	 * Fired by an <code>Asset</code> object.
	 * ...
	 * @usage	var _loader:AssetsLoader = new AssetsLoader( AssetsLoaderMode.BATCH_MODE );
	 * 			_loader.addEventListener( AssetEvent.ASSET_COMPLETE, onAssetCompleteEvent );
	 * @author	Jobe Makar, Electrotank© 2009
	 */
	public class AssetEvent extends Event {
		
		
		/*-:| Event Types |:-*/

			// Single Asset Complete
			public static const ASSET_COMPLETE : String = 'ac';
			
			public static const ASSET_FAILED : String = 'af';
			
			
		/*-:| Asset |:-*/
		
			// Asset 
			private var _asset : Asset ;
			private var _success : Boolean ;
			/**
			 * Asset Target
			 */
			public function get asset() : Asset {
				return _asset;
			}
			
			public function get success() : Boolean {
				return _success;
			}
			
		/**
		 * AssetEvent
		 * ...
		 * Event related to the loading of an asset.
		 * ...
		 * @param	type			: String .......... Use AssetEvent.[EVENT_TYPE]
		 */
		public function AssetEvent( type : String, asset : Asset ) {
			_asset = asset;
			_success = _asset.success;
			super ( type, false, false );
		}
		
	}
	
}