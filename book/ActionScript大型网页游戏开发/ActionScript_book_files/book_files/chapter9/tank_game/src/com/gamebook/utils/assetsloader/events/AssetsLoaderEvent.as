package com.gamebook.utils.assetsloader.events {

	/* Import Flash */
	import com.gamebook.utils.assetsloader.constants.AssetsLoaderMode;
	import flash.events.Event;
	
	
	/**
	 * AssetsLoaderEvent [ Event ]
	 * ...
	 * @author Jobe Makar, Electrotank© 2009
	 */
	public class AssetsLoaderEvent extends Event {
		
		/*-:| Private Data |:-*/
		
			// Assets
			private var _assetsComplete : Array ; 
			private var _assetsFailed : Array ;
			
			// Status
			private var _success : Boolean ;
			
			
			
		/*-:| Properties |:-*/
		
			/**
			 * Full-Success
			 */
			public function get success() : Boolean { 
				return _success; 
			}
			public function set success( val : Boolean ) : void {
				_success = val ;
			}
			
			public function get assetsCompleted() : Array {
				return _assetsComplete;
			}
			
			public function get assetsFailed() : Array {
				return _assetsFailed;
			}
			
			
		/*-:| Event Types |:-*/
		
			/**
			 * Event to listen for to receive notification when all assets that can be loaded have been loaded.
			 */
			public static const ASSETS_COMPLETE : String = 'as_c';
			
			
		/**
		 * AssetsLoaderEvent
		 * ...
		 * Event related to the loading of an asset or assets. 
		 * ...
		 * @param	type			: String .......... Use AssetsLoaderEvent.[EVENT_TYPE]
		 * @param	complete		: Array ........... Array of completed assets.
		 * @param	failed			: Array ........... Array of failed assets.
		 */
		public function AssetsLoaderEvent( type : String, complete : Array = null, failed : Array = null ) {
			if ( complete == null ) _assetsComplete = new Array(); else _assetsComplete = complete;
			if ( failed == null ) _assetsFailed = new Array(); else _assetsFailed = failed;
			super( type, false, false );
		}
		
	}
	
}