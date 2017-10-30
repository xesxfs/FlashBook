package com.gamebook.utils.assetsloader.constants {
	import flash.net.URLLoaderDataFormat;
	
	/**
	 * AssetTypes
	 * ...
	 * @author Matt Bolt, Electrotank© 2009
	 */
	public class AssetType { 
		
		/*-:| Asset Types |:-*/
		
			/**
			 * TEXT data format. Uses the URLLoader class.
			 */
			public static const TEXT:String = URLLoaderDataFormat.TEXT;
			
			/**
			 * BINARY data format. Uses the URLLoader class.
			 */
			public static const BINARY:String = URLLoaderDataFormat.BINARY;
			
			/**
			 * VARIABLES data format. Uses the URLLoader class.
			 */
			public static const VARIABLES:String = URLLoaderDataFormat.VARIABLES;
			
			/**
			 * SWF data format (DisplayObject). Uses the Loader class.
			 */
			public static const SWF:String = "swf";
			
			/**
			 * IMAGE data format (DisplayObject). Uses the Loader class.
			 */
			public static const IMAGE:String = "image";
			
			/**
			 * SOUND data format. Uses the Sound class for loading.
			 */
			public static const SOUND:String = "sound";
			
	}
	
}