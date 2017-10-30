package com.gamebook.utils.assetsloader.events {
	import com.gamebook.utils.assetsloader.Asset;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	
	/**
	 * AssetProgressEvent
	 * ...
	 * @author Jobe Makar, Electrotank© 2009
	 */
	public class AssetProgressEvent extends Event {
		
		/*-:| Private Data |:-*/
		
			// Asset
			private var _asset : Asset ;
			
			// Load Progress
			private var _bytesLoaded : int ;
			private var _bytesTotal : int ;
			
			
		/*-:| Properties |:-*/
		
			/**
			 * Bytes loaded thus far.
			 */
			public function get bytesLoaded () : int {
				return _bytesLoaded;
			}
			
			/**
			 * Total bytes to load.
			 */		
			public function get bytesTotal () : int {
				return _bytesTotal;
			}
		
			/**
			 * Asset
			 */
			public function get asset () : Asset {
				return _asset ;
			}
	
			
		/*-:| Event Types |:-*/
		
			// Progress
			public static const ASSET_PROGRESS : String = 'asset_prog';
			
			
			
		/**
		 * AssetProgressEvent
		 * ...
		 * @param	type				: String .......... Use AssetEvent.[EVENT_TYPE]
		 * @param	bytesLoaded			: int ............. Bytes loaded thus far.
		 * @param	bytesTotal			: int ............. Total bytes to load.
		 */
		public function AssetProgressEvent( type : String, bytesLoaded : int, bytesTotal : int, asset : Asset ) {
			
			// Set Progress Data
			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
			
			// Set Asset
			_asset = asset ;
			
			// Call Base Class Constructor
			super( type );
			
		}
		
	}
	
}