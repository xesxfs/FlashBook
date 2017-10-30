package com.gamebook.utils.assetsloader.constants {
	
	
	/**
	 * AssetsLoaderMode
	 * ...
	 * Use these constants when instantiating a new <code>AssetsLoader</code> object.
	 * ...
	 * @usage new AssetsLoader( AssetsLoaderMode.BATCH_MODE );
	 * @author Jobe Makar, Electrotank© 2008
	 */
	public class AssetsLoaderMode {
		
		/*-:| Loading Modes |:-*/
		
			/**
			 * This mode allows assets to load at will firing only an AssetEvent.ASSET_COMPLETE as each Asset 
			 * completes/fails loading.
			 */
			public static const FILES_AT_WILL_MODE : String = "files_at_will_mode";
			
			/**
			 * This mode allows assets to load according to flash's control. [ Non-preemptive queue Policy ]
			 */
			public static const BATCH_MODE : String = "batch_mode"; 
			
			/**
			 * This mode allows assets to load one after the other in a queue [ FCFS Policy ]
			 */
			public static const LINEAR_MODE : String = "linear_mode";
			
			/**
			 * This "flavor" of linear mode prioritizes assets and loads in a linear order [ Preemptive Queue - Priority Policy ].
			 */
			public static const PRIORITY_MODE : String = 'priority_mode';
			
	}
	
}