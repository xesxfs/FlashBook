package com.gamebook.world.animation {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.events.HTTPStatusEvent
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class AnimationLoader extends EventDispatcher{
		
		public static const DONE:String = "done";
		
		private var _spriteAnimation:SpriteAnimation;
		
		private var _loaders:Array;
		private var _numComplete:int;
		
		private var _loaded:Boolean = false;
		
		public function AnimationLoader() {
			
		}
		
		public function loadFiles(files:Array):void {
			_loaders = [];
			_numComplete = 0;
			
			for (var i:int = 0; i < files.length;++i) {
				loadFile(files[i]);
			}
		}
		
		private function loadFile(url:String):void{
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileLoadComplete);
			
			_loaders.push(loader);
		}
		
		private function onFileLoadComplete(e:Event):void {
			++_numComplete;
			if (_numComplete == _loaders.length) {
				process();
				_loaded = true;
				dispatchEvent(new Event(DONE));
			}
		}
		
		private function process():void{
			for (var i:int = 0; i < _loaders.length;++i) {
				var loader:Loader = _loaders[i];
				var b:Bitmap = loader.content as Bitmap;
				_spriteAnimation.layerBitmapData(b.bitmapData);
				b.bitmapData.dispose();
				
				loader.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			}
			_spriteAnimation.process();
			
			_loaders = null;
		}
		
		
		public function get spriteAnimation():SpriteAnimation { return _spriteAnimation; }
		
		public function set spriteAnimation(value:SpriteAnimation):void {
			_spriteAnimation = value;
		}
		
		public function get loaded():Boolean { return _loaded; }
		
	}
	
}