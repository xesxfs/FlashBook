package com.gamebook.utils.assetsloader.events {
	
	import flash.events.Event;
	
	
	/**
	 * AssetsLoaderProgressEvent 
	 * ...
	 * @author Jobe Makar, Electrotank© 2009
	 */
	public class AssetsLoaderProgressEvent extends Event {
		
		
		/*-:| Private Data |:-*/
		
			// Cumlative Bytes Loaded
			private var _bytesLoaded : int ;
			
			// Load Totals
			private var _bytesTotal : int ;
			private var _assetsTotal : int ;
			
			// Assets Progress
			private var _assetsComplete : int ;
			private var _assetsFailed : int ;
			

		
		/*-:| Properties |:-*/
		
			/**
			 * Total Bytes Loaded
			 */
			public function get bytesLoaded () : int {
				return _bytesLoaded ;
			}
			public function set bytesLoaded ( val : int ) : void {
				_bytesLoaded = val ;
			}
			
			/**
			 * Total Bytes to Load
			 */
			public function get bytesTotal () : int {
				return _bytesTotal ;
			}
			public function set bytesTotal ( val : int ) : void {
				_bytesTotal = val ;
			}
			
			/**
			 * Total Assets
			 */
			public function get assetsTotal () : int {
				return _assetsTotal ;
			}
			public function set assetsTotal ( val : int ) : void {
				_assetsTotal = val ;
			}
			
			/**
			 * Assets Completed
			 */
			public function get assetsComplete () : int {
				return _assetsComplete ;
			}
			public function set assetsComplete ( val : int ) : void {
				_assetsComplete = val ;
			}
			
			/**
			 * Assets Failed
			 */
			public function get assetsFailed () : int {
				return _assetsFailed ;
			}
			public function set assetsFailed ( val : int ) : void {
				_assetsFailed = val ;
			}
		
		
			
		/*-:| Event Types |:-*/
		
			/**
			 * Event to listen for to receive progress on all assets loading.
			 */
			public static const ASSETS_PROGRESS : String = 'as_p';
			
			
		
		/**
		 * AssetsLoaderProgressEvent
		 * ...
		 * @param	type
		 */
		public function AssetsLoaderProgressEvent( type : String ) {
			super( type );
		}
		
	}
	
}