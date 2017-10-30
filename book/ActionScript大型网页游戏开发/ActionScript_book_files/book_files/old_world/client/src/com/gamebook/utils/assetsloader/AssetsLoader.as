package com.gamebook.utils.assetsloader {

	
	/* Import Flash */
	import com.gamebook.utils.assetsloader.constants.AssetsLoaderMode;
	import com.gamebook.utils.assetsloader.events.AssetEvent;
	import com.gamebook.utils.assetsloader.events.AssetProgressEvent;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderEvent;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderProgressEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	
	/**
	 * AssetsLoader
	 * @example
	 * <listing>
	 * </listing>
	 * ...
	 * @author Jobe Makar, Electrotank© 2009
	 */
	public class AssetsLoader extends EventDispatcher implements IEventDispatcher {
		
		use namespace asl_internal;
		
		/*-:| Static Data |:-*/
		
			/**
			 * Cache Break Status
			 */
			private static var _cacheBreakEnabled : Boolean ;
			
			/**
			 * Version Tag
			 */
			private static var _version : String;
			
			/**
			 * Logger
			 */
			//private static var _logger : ILogger = Logger.getLogger('AssetsLoader');;
			private static var _logEvts : Boolean ;
			private static var _logActions : Boolean ;
			public static function setTraceDebug( actions : Boolean = true, events : Boolean = true ) : void {
				_logEvts = events;
				_logActions = actions;
			}
			
			
			
		/*-:| Private Data |:-*/	
			
			// Loading Mode
			private var _mode : String ;
			
			// Lists
			private var _assetsToLoad : Array;
			private var _assetsOpened : Array;
			private var _assetsComplete : Array;
			private var _assetsFailed : Array;
			private var _assetsPaused : Array;
			
			// Flags
			private var _completed : Boolean;
			private var _successful : Boolean;
			private var _isPaused : Boolean = false;
			private var _loadStarted : Boolean = false;
			
			// Pooling
			private var i : int;
			private var len : int ;
		
		
		/**
		 * Create a new instance of AssetsLoader.
		 */
		public function AssetsLoader( mode : String = AssetsLoaderMode.BATCH_MODE ) {
			
			// Set Loading Mode [ AssetsLoaderMode.[MODE] ]
			_mode = mode;
			
			// Initialize Lists
			_assetsComplete = new Array();
			_assetsToLoad = new Array();
			_assetsFailed = new Array();
			_assetsOpened = new Array();
			_assetsPaused = new Array();

			// Initialize Flags
			_successful = true;
			_completed = false;
			
		}

		/**
		 * Enables Cache Breaker
		 */
		public static function enableCacheBreaker( ver : String ) : void {
			_version = ver;
			_cacheBreakEnabled = true;
		}
		
		/**
		 * Disables Cache Breaker
		 */
		public static function disableCacheBreaker() : void {
			_cacheBreakEnabled = false;
		}
		
		/**
		 * Pauses Loading.
		 */
		public function get paused() : Boolean {
			return _isPaused;	
		}
		
		
		/**
		 * Loading Mode
		 */
		public function get mode() : String {
			return _mode;
		}
		public function set mode( val : String ) : void {
			_mode = val;
		}
		
		/**
		 * Completed Assets
		 */
		public function get assetsComplete() : Array {
			return _assetsComplete;
		}
		
		/**
		 * Failed Assets.
		 */
		public function get assetsFailed() : Array {
			return _assetsFailed;
		}
		
		
		private function log( message : String, type : String = 'info' ) : void {
			//if ( _logActions ) _logger[ type ] ( message );
		}
		
		/**
		 * This function begins loading for a previously scheduled list of assets. 
		 */
		public function startQueuedLoad() : void {
			if ( _loadStarted ) {
				if ( _logActions ) log( 'Load has already started!', 'error' );
				return ;
			}
			if ( _mode == AssetsLoaderMode.BATCH_MODE ) {
				if ( _logActions ) log( 'Start Queued Load in BATCH_MODE', 'info' );
				len = ( _assetsToLoad != null ) ? _assetsToLoad.length : 0 ;
				for ( i = 0; i < len; ++i ) {
					Asset( _assetsToLoad[ int(i) ] ).load();
				}
				_loadStarted = true;
			} else if ( _mode == AssetsLoaderMode.LINEAR_MODE ) {
				if ( _logActions ) log( 'Start Queued Load in LINEAR_MODE', 'info' );
				if ( ( _assetsToLoad != null ) && ( _assetsToLoad.length > 0 ) ) {
					Asset( _assetsToLoad[0] ).load();
				}
				_loadStarted = true;
			} else if ( _mode == AssetsLoaderMode.PRIORITY_MODE ) {
				if ( _logActions ) log( 'Start Queued Load in PRIORITY_MODE', 'info' );
				if ( ( _assetsToLoad != null ) && ( _assetsToLoad.length > 0 ) ) {
					_assetsToLoad.sortOn(['priority'], Array.NUMERIC );
					Asset( _assetsToLoad[0] ).load();
				}
				_loadStarted = true;
			}
		}
		
		/**
		 * Queues a new Asset to be loaded. This allows assets to be added over time without starting a load. You'll be able to define
		 * a priority and depending on the <code>AssetsLoaderMode</code>, the loading will actively use that priority. Define the data format 
		 * of the asset as AssetType.[TEXT, BINARY, VARIABLES, SWF, IMAGE, SOUND].
		 * ...
		 * @param	url							: String ................. The URL to the asset.
		 * @param	dataFormat					: String ................. The data format of the asset.
		 * @param	bypassCacheBreaker			: Boolean ................ [Optional] Bypass Cache Breaker
		 * @param   context						: Object ................. [Optional] The loading context instance 
		 * ...
		 * @return								: Asset ............. An instance of the asset loaded.
		 */
		public function queueAsset( url : String, dataFormat : String, priority : uint = 0, bypassCacheBreaker : Boolean = false, context : Object = null ) : Asset {
			
			// Tag the URL with the Version
			if ( _cacheBreakEnabled && !bypassCacheBreaker ) url += "?v=" + _version; 
			
			// Pool Variable
			var ass : Asset ;
			
			// Mode
			switch ( _mode ) {
				
				// Files At Will: Load all - no policy
				case AssetsLoaderMode.FILES_AT_WILL_MODE:
					return loadAsset( url, dataFormat, bypassCacheBreaker, context ); 
				break;
				
				// Batch Modes ( Queued )
				case AssetsLoaderMode.BATCH_MODE: case AssetsLoaderMode.LINEAR_MODE:
					if ( _loadStarted ) {
						return loadAsset( url, dataFormat, bypassCacheBreaker, context );
					} else {
						ass = new Asset( url, dataFormat, context, false );
						ass.priority = 0;
						_assetsToLoad.push(ass);
					}
				break;
				
				// Priority Batch Mode ( Linear - Queued )
				case AssetsLoaderMode.PRIORITY_MODE:
					ass = new Asset( url, dataFormat, context, false );
					ass.priority = priority;
					if ( _loadStarted ) {
						len = ( _assetsToLoad != null ) ? _assetsToLoad.length : 0 ;
						var insert : Boolean = false;
						for ( i = 0; i < len; ++i ) {
							if ( Asset( _assetsToLoad[ int(i) ] ).priority > priority ) {
								insert = true;
								_assetsToLoad.splice(i, 0, ass);
								break;
							}
						}
						if ( !insert ) {
							_assetsToLoad.push(ass);
						}
					} else {
						_assetsToLoad.push(ass);
					}
				break;
				
				default:
					throw new Error( 'Unidentified Mode: ' + _mode );
				
			}
			
			ass.asl_internal::_completeFx = onCompleteCallback;
			ass.asl_internal::_failedFx = onFailedCallback;
			ass.asl_internal::_openedFx = onOpenedCallback;
			ass.asl_internal::_progressFx = onProgress ;
			
			if ( _logActions ) log( 'Queued Asset: ' + url, 'info' );
			
			// Return the Asset
			return ass;
			
		}
		
		
		/**
		 * Initiates the loading of a new asset. It returns the Asset instance used to load that asset. Define the data format of the asset as 
		 * AssetType.[TEXT, BINARY, VARIABLES, SWF, IMAGE, SOUND].
		 * ...
		 * @param	url							: String ................. The URL to the asset.
		 * @param	dataFormat					: String ................. The data format of the asset.
		 * @param	bypassCacheBreaker			: Boolean ................ [Optional] Bypass Cache Breaker
		 * @param   context						: Object ................. [Optional] The loading context instance 
		 * ...
		 * @return								: Asset ............. An instance of the asset loaded.
		 */
		public function loadAsset( url : String, dataFormat : String, bypassCacheBreaker : Boolean = false, context : Object = null ) : Asset {
			var ass : Asset;
			
			if ( _mode == AssetsLoaderMode.PRIORITY_MODE ) {
				ass = queueAsset( url, dataFormat, 100000, bypassCacheBreaker, context );
				startQueuedLoad();
				return ass;
			}
			
			// Check Cache Break Status
			if ( _cacheBreakEnabled && !bypassCacheBreaker ) {
				url += "?v=" + _version; // Tag the URL with the Version
			}
			
			// Create a new Asset
			ass = new Asset( url, dataFormat, context, false );
			ass.asl_internal::_completeFx = onCompleteCallback;
			ass.asl_internal::_failedFx = onFailedCallback;
			ass.asl_internal::_openedFx = onOpenedCallback;
			ass.asl_internal::_progressFx = onProgress ;
			
			ass.load();
			
			// Check Mode
			if ( _mode != AssetsLoaderMode.FILES_AT_WILL_MODE ) {

				// Check Linear Mode
				if ( _mode == AssetsLoaderMode.LINEAR_MODE ) {
					
					// Pause Loading and Check Started
					ass.pause();
					if ( !_loadStarted ) {
						ass.resume();
						_loadStarted = true;
					}
					
				}
				
			}
			
			// Queue Asset
			_assetsToLoad.push( ass );
			
			if ( _logActions ) log( 'Loading Asset: ' + url, 'info' );
			
			// Return the Asset
			return ass;
			
		}
		
		private function onFailedCallback( ass : Asset ) : void {
			
			if ( _logEvts ) log( 'Asset Failed: ' + ass.url, 'info' );
			
			// Remove Asset
			removeAsset( ( ( ass.opened ) ? _assetsOpened : _assetsToLoad ), ass.url );
	
			// Add to Failed List
			_assetsFailed.push( ass );
			
			// Create Asset Complete Event
			var fail : AssetEvent = new AssetEvent( AssetEvent.ASSET_COMPLETE, ass );
			
			// Dispatch
			dispatchEvent( fail );
			
			// Check Complete
			checkForAllCompleted();
			
		}
		
		
		private function onCompleteCallback( ass : Asset ) : void {
			
			if ( _logEvts ) log( 'Asset Complete: ' + ass.url, 'info' );
			
			// Remove Asset
			removeAsset( ( ( ass.opened ) ?_assetsOpened : _assetsToLoad ), ass.url );
			
			// Push Complete
			_assetsComplete.push( ass );
				
			// Create Asset Complete Event
			var comp : AssetEvent = new AssetEvent( AssetEvent.ASSET_COMPLETE, ass );
			
			// Dispatch
			dispatchEvent( comp );

			// Check Mode
			switch ( _mode ) {
				
				// Use Linear and Priority
				case AssetsLoaderMode.LINEAR_MODE: case AssetsLoaderMode.PRIORITY_MODE:
				
					// Check Next Download
					startNextDownload();
				
				// Include Batch Mode
				case AssetsLoaderMode.BATCH_MODE: 
				
					// Check
					checkForAllCompleted();
				
				break;
				
				// Files at Will
				default:
					// Default here
					
			}
			
		}
		
		
		private function onOpenedCallback( ass : Asset ) : void {
			if ( _logEvts ) log( 'Asset Opened: ' + ass.url, 'info' );
			if ( !_isPaused ) {
				removeAsset( _assetsToLoad, ass.url );
				_assetsOpened.push( ass );
			} else {
				pauseAsset( ass );
			}
		}
		
		
		/**
		 * Remove the asset
		 * ...
		 * @param	assetList					: Array ................. List of assets to remove from.
		 * @param	url							: String ................ URL of the asset to remove.
		 * ...
		 * @return								: Boolean ............... Removal success.
		 */
		private function removeAsset( assetList : Array, url : String ) : Boolean {
			
			// Initialize
			var ass : Asset ;
			var success:Boolean = false;
			i = 0;
			
			// Iterate
			for ( ; i < assetList.length; ++i ) {
				ass = assetList[ i ];
				if ( ass.url == url ) {
					assetList.splice( i, 1 );
					success = true;
					break;
				}
			}
			
			// Return
			return success;
			
		}
		
		
		/**
		 * Pauses Asset Loading.
		 */
		private function pauseAsset( ass : Asset ) : void {
			
			// Pause
			ass.pause();
			
			// Add to Pause List
			_assetsPaused.push( ass );
			
		}
		
		/**
		 * Pauses Downloads.
		 */
		public function pause() : void {
			
			// Check Paused
			if ( _isPaused ) return;
			
			// List Length
			var l : int = _assetsOpened.length;
			
			// Iterate
			for ( i = 0; i < l; ++i ) {
				
				// Pause
				pauseAsset( _assetsOpened.shift() as Asset );
				
			}
				
				
		}
		
		
		/**
		 * Resume Loading.
		 */
		public function resume() : void {
			
			// Check Not Paused
			if ( !_isPaused ) return;
			
			// Paused List Length
			var l : uint = _assetsPaused.length;
			
			// Iterate
			for ( i = 0; i < l; ++i ) {
				
				// Resume
				( _assetsPaused.shift() as Asset ).resume();
				
			}
			
			// Set Flag
			_isPaused = false;
			
		}
		
		/**
		 * Start the next load on the list.
		 */
		private function startNextDownload() : void  {
			
			// Check Queue
			if ( _assetsToLoad.length ) {
				
				// Resume
				( _assetsToLoad[ 0 ] as Asset ).resume();
				
			} 
			
		}
				
		/**
		 * Status updater.
		 */
		private function checkForAllCompleted() : void {
			
			// Check Completion
			if ( ( !_assetsToLoad.length ) && ( !_assetsOpened.length ) ) {
				
				// Create Complete Event
				var comp : AssetsLoaderEvent = new AssetsLoaderEvent( AssetsLoaderEvent.ASSETS_COMPLETE, _assetsComplete.concat(), _assetsFailed.concat() );
				comp.success = ( !_assetsFailed.length );
				
				// Dispatch
				dispatchEvent( comp );
				
			}
			
			//_loadStarted = false;
			
		}
		
		
		/**
		 * Captures the progress event of an asset being loaded.
		 */
		private function onProgress( e : AssetProgressEvent ) : void {
			
			// Temp
			var bt : int = 0;
			var bl : int = 0;
			
			var ass : Asset = e.asset;
			
			if ( _logEvts ) log( 'Asset Progress: ' + Math.round( Number( ( e.bytesLoaded / e.bytesTotal ) * new Number(100) ) ), 'info' );
			
			// Check Mode
			if ( _mode == AssetsLoaderMode.BATCH_MODE ) {
				
				// Iterate through Complete
				for ( i = 0; i < _assetsComplete.length; ++i ) {
					
					// Get Asset
					ass = _assetsComplete[ i ];
					
					// Add Total Bytes
					bt += ass.bytesTotal;
					bl += ass.bytesLoaded;
					
				}
				
				// Iterate through Opened
				for ( i = 0; i < _assetsOpened.length; ++i ) {
					
					// Get Asset
					ass = _assetsOpened[ i ];
					
					// Add Total Bytes
					bt += ass.bytesTotal;
					bl += ass.bytesLoaded;
					
				}
				
			} else {
	
				// Get Front Asset
				ass = _assetsOpened[ 0 ];
				
				// Add Total Bytes
				bt += ass.bytesTotal;
				bl += ass.bytesLoaded;
				
			}
			
			// Single Asset Progress
			var soloAssetProgress : AssetProgressEvent = new AssetProgressEvent( AssetProgressEvent.ASSET_PROGRESS, e.bytesLoaded, e.bytesTotal, ass );
			dispatchEvent( soloAssetProgress );
			
			// New Progress Event
			var prog : AssetsLoaderProgressEvent = new AssetsLoaderProgressEvent( AssetsLoaderProgressEvent.ASSETS_PROGRESS );
			prog.bytesLoaded = bl;
			prog.bytesTotal = bt;
			prog.assetsFailed = _assetsFailed.length;
			prog.assetsTotal = this.totalAssets;
			prog.assetsComplete = _assetsComplete.length;
			
			// Dispatch
			dispatchEvent( prog );
			
		}
		
		/**
		 * Total Assets
		 */
		public function get totalAssets() : int {
			return _assetsToLoad.length + _assetsOpened.length + _assetsComplete.length + _assetsFailed.length;
		}
		
		
		public function reset() : void {
			
			// Pause Loading
			pause();
			
			var len : int = ( _assetsPaused != null ) ? _assetsPaused.length : 0 ;
			for ( i = 0; i < len; ++i ) {
				Asset( _assetsPaused[ int(i) ] ).destroy(true);
			}
			_assetsComplete.length = _assetsFailed.length = _assetsOpened.length = _assetsPaused.length = _assetsToLoad.length = 0;
			_loadStarted = false;
			_successful = true;
			_completed = false;
		}
		
		
		/**
		 * Destroys the Assets Loader.
		 */
		public function destroy( all : Boolean = false ) : void {
			
			// Pause
			pause();
			
			// Destroy Lists
			try { destroyList( _assetsComplete, all ); } catch (e:Error) { }
			try { destroyList( _assetsFailed, all ); } catch (e:Error) { }
			try { destroyList( _assetsOpened, all ); } catch (e:Error) { }
			try { destroyList( _assetsPaused, all ); } catch (e:Error) { }
			try { destroyList( _assetsToLoad, all ); } catch (e:Error) { }

			// Reference Lists to null for GC
			_assetsComplete = _assetsToLoad = _assetsFailed = _assetsOpened = _assetsPaused = null;
			
		}
		
		/**
		 * Procedure for destroying asset arrays.
		 * @param	assetList
		 */
		private function destroyList( assetList : Array, all : Boolean = false ) : void {
			
			// Return on Null
			if ( !assetList ) return ;
			
			// Pool
			var asset:Asset;
			
			for ( i = 0; i < assetList.length; ++i ) {
				asset = assetList[ int(i) ];
				//asset.removeEventListener( AssetEvent.ASSET_COMPLETE, onComplete );
				//asset.removeEventListener( AssetEvent.ASSET_FAILED, onFail );
				//asset.removeEventListener( AssetEvent.ASSET_OPEN, onOpen );
				//asset.removeEventListener( AssetProgressEvent.ASSET_PROGRESS, onProgress );
				asset.destroy( all );
			}
			assetList.length = 0;
			assetList = null;
			
		}
		
		
	}
	
}
