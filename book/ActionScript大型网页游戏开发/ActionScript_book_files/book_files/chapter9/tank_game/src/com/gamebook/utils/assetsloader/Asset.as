package com.gamebook.utils.assetsloader {
	
	/* Import Core */
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetEvent;
	import com.gamebook.utils.assetsloader.events.AssetProgressEvent;
	
	/* Import Flash Data */
	import flash.media.SoundLoaderContext;
	import flash.system.ApplicationDomain;	
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.system.LoaderContext;
	
	/* Import Flash Events */
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.IEventDispatcher;
	
	
	/**
	 * Asset
	 * ...
	 * @author Jobe Makar, Electrotank© 2009
	 */
	public class Asset extends EventDispatcher implements IEventDispatcher {
		
		// Use Internal Namespace
		use namespace asl_internal;
		
		asl_internal var _completeFx : Function ;
		asl_internal var _failedFx : Function ;
		asl_internal var _openedFx : Function ;
		asl_internal var _progressFx : Function ;
		
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if ( _completeFx != null || _failedFx != null || _openedFx != null || _progressFx != null ) {
				//_logger.error( 'This asset is being handled by an AssetsLoader object -> Listen to the AssetsLoader instead.');
				return;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/*-:| Private Data |:-*/
			
			// Logging
			
			// Loading
			private var _loader : Loader ;
			private var _urlLoader : URLLoader ;
			private var _data : Object ;
			private var _loadingContext : Object ;
			
			// Loaded Flag
			private var _isLoaded : Boolean ;
			
			// Loading Data
			private var _type : String ;
			private var _url : String ;
			
			// Status
			private var _httpStatusCode : int ;
			
			// Progress
			private var _bytesLoaded : int ;
			private var _bytesTotal : int ;
			
			// Error
			private var _errorStrings : Array ;
			
			// Refs
			private var _sound : Sound ;
			
			// Extra Data
			private var _extraData : * ;
			
			// Flags
			private var _isOpened : Boolean ;
			private var _isFailure : Boolean ;
			private var _paused : Boolean = false;
			private var _receivedHTTPStatusEvent : Boolean ;
			private var _priority : uint ;
			
		
		/**
		 * Asset
		 * ...
		 * @param	url					: String .................. Path to the file to load.
		 * @param	type				: String .................. The data format of the file to load.
		 * @param   loadingContext		: Object .................. The loading context [Optional] - For SWFS and images it defaults to auto check policy file = false, and ApplicationDomain.currentDomain
		 * @param	autoStart			: Boolean ................. Automatically begins the load.
		 */
		public function Asset( url : String, type : String, loadingContext : Object = null, autoStart : Boolean = true ) {
			
			// Initialize Data
			_url = url;
			_type = type;
			
			
			_loadingContext = loadingContext;
			
			// Initialize Error Strings
			_errorStrings = new Array();
			
			// Initialize Flags
			_isOpened = _isLoaded = _isFailure = _receivedHTTPStatusEvent = false;
			_paused = !autoStart;
			
			// Auto-Start Load
			if ( autoStart ) setAsset(url, type, loadingContext);
			
		}
		
		/**
		 * An asset who hasn't begun loading can be manually started here.
		 * @param	force 				: Boolean ................ Forces a reload.
		 */
		public function load( force : Boolean = false ) : void {
			if ( ( !_isLoaded ) || ( force ) ) setAsset( _url, _type, _loadingContext );
		}
		
		
		
		/**
		 * [ private ]
		 * This function sets all necessary flags, events, and loaders for a given asset type.
		 * ...
		 * @param	url					: String .................. Path to the file to load.
		 * @param	type				: String .................. The data format of the file to load.
		 * @param   loadingContext		: Object .................. The loading context [Optional]
		 */
		private function setAsset( url : String, type : String, loadingContext : Object ) : void {		
			
			// Set Flag - This is for queued loading assets.
			_isLoaded = true;
			
			// Set URL Request
			var urlRequest : URLRequest = new URLRequest( url );
			
			// Setup Loader and Events based on asset type
			switch ( type ) {
				
				// Basic Types
				case AssetType.TEXT: case AssetType.BINARY: case AssetType.VARIABLES:
				
					// URL Loader for Text, Binary, and Variables
					_urlLoader = new URLLoader();
					
					// Add Listeners
					_urlLoader.addEventListener( Event.COMPLETE, completeHandler );
					_urlLoader.addEventListener( ProgressEvent.PROGRESS, progressHandler );
					_urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					_urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
					_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					_urlLoader.addEventListener( Event.OPEN, openHandler );
					
					// Set Format
					_urlLoader.dataFormat = type;
					
					// Load
					_urlLoader.load( urlRequest );
					
				break;
				
				
				// Image and SWF Types
				case AssetType.IMAGE: case AssetType.SWF:
					
					// Define a context
					var context : LoaderContext;
					
					// Create new Loader
					_loader = new Loader();
					
					// Add Listeners
					_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler );
					_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
					_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					_loader.contentLoaderInfo.addEventListener( Event.OPEN, openHandler );
					_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressHandler );
					
					// *MUST* use 'as'. Default to the most-used parameters
					context = LoaderContext(((loadingContext as LoaderContext) == null)?new LoaderContext(false, ApplicationDomain.currentDomain):loadingContext);
					
					
					// Load
					_loader.load( urlRequest, context );
					
				break;
				
				
				// Sound Types
				case AssetType.SOUND:
				
					// Define Context
					var sContext:SoundLoaderContext;
					
					// Create a new Sound
					_sound = new Sound();
					
					// Add Listeners
					_sound.addEventListener( Event.COMPLETE, completeHandler );
					_sound.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
					_sound.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					_sound.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					_sound.addEventListener( Event.OPEN, openHandler );
					_sound.addEventListener( ProgressEvent.PROGRESS, progressHandler );
					
					// Attempt Cast
					sContext = SoundLoaderContext(((loadingContext as SoundLoaderContext)==null)?new SoundLoaderContext(1000, false):loadingContext);
					
					// Load
					_sound.load( urlRequest, sContext );
					
				break;
				
				
				// Default
				default:
					
					throw new Error( 'Asset Type: ' + type + ' is not supported.' );
				
				break;
				
			}
			
			// Unpause
			_paused = false;
			
		}
		
		
		/**
		 * Pauses asset loading by closing the connection - All bytes are cached.
		 */
		public function pause() : void {
			
			// Check
			if ( !( _type == AssetType.TEXT || _type == AssetType.BINARY || _type == AssetType.VARIABLES || _type == AssetType.IMAGE || _type == AssetType.SWF || _type == AssetType.SOUND ) ) {
				throw new Error( 'Asset Type: ' + _type + ' is not supported.' );
			}
				
			// Close Connection
			( ( _type == AssetType.TEXT || _type == AssetType.BINARY || _type == AssetType.VARIABLES ) ? _urlLoader : ( ( _type == AssetType.IMAGE || _type == AssetType.SWF ) ? _loader : _sound ) ).close();
			
			// Set Paused
			_paused = true;
			
		}
		
		/**
		 * Resumes Loading a paused asset.
		 */
		public function resume() : void {
			
			// Check
			if ( !_paused ) return;
			
			// Set Asset
			setAsset( _url, _type, _loadingContext );
			
		}
		
		
		/**
		 * Handles load failure.
		 */
		private function loadFail( event : Event ) : void {
			
			// Push Error String
			errorStrings.push( event.toString() );
			
			// Check Current Status
			if ( !_isFailure ) {
				
				// Set Flags
				_isFailure = true;
				
				// Remove Listeners
				killListeners();
				_isLoaded = false;
			
				if ( _failedFx != null ) {
					
					_failedFx( this );
					
				} else { 
				
					dispatchEvent( new AssetEvent( AssetEvent.ASSET_FAILED, this ) );
				
				}
			}
			
		}
		
		/**
		 * When an asset is successfully loaded this is called.
		 * @param	The event.
		 */
        private function completeHandler( event : Event ) : void {
			
			// Check
			if ( !( _type == AssetType.TEXT || _type == AssetType.BINARY || _type == AssetType.VARIABLES || _type == AssetType.IMAGE || _type == AssetType.SWF || _type == AssetType.SOUND ) ) {
				throw new Error( 'Asset Type: ' + _type + ' is not supported.' );
			}
			
			// Remove Listeners
			killListeners();
			_isLoaded = false;
			
			// Set Data
			_data = ( ( _type == AssetType.TEXT || _type == AssetType.BINARY || _type == AssetType.VARIABLES ) ? _urlLoader.data : ( _type == AssetType.IMAGE || _type == AssetType.SWF ) ? _loader.content : _sound ) as Object;
			
			if ( _completeFx != null ) {
				
				_completeFx( this );
				
			} else {
			
				dispatchEvent( new AssetEvent( AssetEvent.ASSET_COMPLETE, this ) );
				
			}
			
        }
		
		/**
		 * Handles the open event for the asset.
		 */
        private function openHandler( event : Event ) : void {
			
			// Set Flag
			_isOpened = true;
			
			if ( _openedFx != null ) { 
				
				_openedFx( this );
				
			} 
        }  
		
		/**
		 * Handles progress loading for the asset.
		 */
        private function progressHandler( event : ProgressEvent ) : void {
			
			// Set Data
            _bytesLoaded = event.bytesLoaded;
			_bytesTotal = event.bytesTotal;
			
			var ape : AssetProgressEvent = new AssetProgressEvent( AssetProgressEvent.ASSET_PROGRESS, _bytesLoaded, _bytesTotal, this );
			
			if ( _progressFx != null ) {
				
				_progressFx( ape );
				
			} else {
				
				dispatchEvent( ape );
				
			}
			
			
        }
		
		/**
		 * Handles HTTP Status
		 */
        private function httpStatusHandler( event : HTTPStatusEvent ) : void {
			
			// Set Data
			_httpStatusCode = event.status;
			
			// Set Flag
			_receivedHTTPStatusEvent = true;
        }
		
		/**
		 * Handles a Security Error
		 */
        private function securityErrorHandler( event : SecurityErrorEvent ) : void {
			
			// Call Failure handler
            loadFail( event );
			
        }
		
		/**
		 * Handles IO Error
		 */
        private function ioErrorHandler( event : IOErrorEvent ) : void {
			
			// Call Failure Handler
            loadFail( event );
			
        }	
		
		
		/**
		 * Destroys all references tied to this <code>Asset</code> object.
		 */
		public function destroy( all : Boolean = false ) : void {
			
			// Pause All
			pause();
			
			// Kill Loading Listeners
			killListeners();
			
			if ( all ) {
			
				// Strip/Destroy Loader
				if ( _loader ) {
					_loader.close();
					_loader.unload();
					//FlashCleanup.instance.destroyClip( _loader );
					_loader = null;
				}
				
				if ( _sound ) {
					_sound.close();
					_sound = null;
				}
				
			}
			
			if ( _errorStrings != null ) {
				_errorStrings.length = 0;
				_errorStrings = null;
			}
			
		}
		
		/**
		 * Destroys Listeners for the Asset
		 */
		public function killListeners() : void {
			
			// Handle Type
			switch ( _type ) {
				
				// Basic Types
				case AssetType.TEXT: case AssetType.BINARY: case AssetType.VARIABLES:

					// Remove Listeners
					if ( _urlLoader != null ) {
						_urlLoader.removeEventListener( Event.COMPLETE, completeHandler );
						_urlLoader.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
						_urlLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
						_urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
						_urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
						_urlLoader.removeEventListener( Event.OPEN, openHandler );
					}
						
					
				break;
				
				
				// Image and SWF Types
				case AssetType.IMAGE: case AssetType.SWF:
					
					// Remove Listeners
					if ( ( _loader != null ) && ( _loader.contentLoaderInfo != null ) ) {
						_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, completeHandler );
						_loader.contentLoaderInfo.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
						_loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
						_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
						_loader.contentLoaderInfo.removeEventListener( Event.OPEN, openHandler );
						_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
					}
					
				break;
				
				
				// Sound Types
				case AssetType.SOUND:
					
					// Remove Listeners
					if ( _sound != null ) {
						_sound.removeEventListener( Event.COMPLETE, completeHandler );
						_sound.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
						_sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
						_sound.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
						_sound.removeEventListener( Event.OPEN, openHandler );
						_sound.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
					}
					
				break;
			
				
			}
			
		}
		
		
		
		/*-:| Properties |:-*/
			

			/**
			 * The status of the asset.
			 */
			public function get paused() : Boolean 						{ return _paused; }
		
			/**
			 * Load success.
			 */
			public function get success() : Boolean 					{ return !_isFailure; }
			
			/**
			 * Data loaded.
			 */
			public function get data() : Object 						{ return ( _type == AssetType.SOUND ? Object( _sound ) : _data ); }
			
			/**
			 * [TRUE] if asset is open for load.
			 */
			public function get opened() : Boolean 						{ return _isOpened; }
			
			/**
			 * URL Loader.
			 */
			public function get urlLoader() : URLLoader 				{ return _urlLoader; }
			
			/**
			 * URL of Asset
			 */
			public function get url () : String 						{ return _url; }
			
			/**
			 * Loader.
			 */
			public function get loader() : Loader 						{ return _loader; }
			
			/**
			 * The total bytes of the file.
			 */
			public function get bytesTotal() : int 						{ return _bytesTotal; }
			
			/**
			 * The number of bytes loaded.
			 */
			public function get bytesLoaded() : int 					{ return _bytesLoaded; }
			
			/**
			 * Priority of the asset.
			 */
			public function get priority() : uint 						{ return _priority; }
			public function set priority( val : uint ) : void 			{ _priority = val; }
			
			/**
			 * Array of strings representing any errors captured during the loading process.
			 */
			public function get errorStrings() : Array 					{ return _errorStrings; }
			
			/**
			 * HTTP Status Event is recieved [ TRUE ].
			 */
			public function get httpStatusEvent() : Boolean 			{ return _receivedHTTPStatusEvent; }
			
			/**
			 * When an HTTP Status Event is capture the status code is stored. This method returns that.
			 */
			public function get httpStatusCode() : int 					{ return _httpStatusCode; }
			
			/**
			 * The type of the Asset to load.
			 */
			public function get type() : String 						{ return _type; }		
			
			/**
			 * Extra Data
			 */
			public function get extraData() : *							{ return _extraData; }
			public function set extraData( val : * ) : void 			{ _extraData = val ; }
			
		
	}
	
}