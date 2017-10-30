package com.gamebook.coop {
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class PluginConstants {
		
		// actions 
		public static const ACTION:String					= "a";
		public static const ERROR:String					= "err";
		public static const POSITION_UPDATE:String			= "pu";
		public static const PLAYER_DIED:String				= "pd";
		public static const INIT_ME:String					= "i";
		public static const ADD_PLAYER:String				= "au";
		public static const REMOVE_PLAYER:String			= "rp";
		public static const PLAYER_LIST:String				= "pl";
		public static const FLIP_SWITCH:String				= "fs";
		public static const TOGGLE_TOWER:String				= "ts";
		public static const PUSH_ROCK:String				= "pr";
		public static const GAME_OVER:String				= "over";
		public static const REVIVE_ME:String				= "heal";
		public static const INIT_LEVEL:String				= "il";
		public static const DESTROY_TOWER:String			= "ds";
		public static const UPDATE_SPAWN_LOCATION:String	= "url";
		public static const LEVEL_COMPLETE:String			= "lc";
		
		// parameters
		public static const NAME:String					= "n";
		public static const PLAYER:String				= "plyr";
		public static const PLAYER_TYPE:String			= "pa";
		public static const X:String					= "x";
		public static const Y:String					= "y";
		public static const SWITCH_ID:String			= "si";
		public static const SWITCH_STATE:String			= "sws";
		public static const ROCK_ID:String				= "ri";
		public static const TOWER_STATE:String			= "sts";
		public static const LIVES_REMAINING:String		= "plr";
		public static const TOWER_ID:String				= "sti";
		public static const SWITCH_RESULTS:String		= "sr";
		public static const GATE_ID:String				= "gi";
		public static const GATE_STATE:String			= "gs";
		public static const TIME_STAMP:String			= "tm";
		public static const SUCCESS:String				= "succ";
		public static const LEVEL_NUMBER:String			= "lvln";
		public static const LEVEL_GATES:String			= "lvlg";
		public static const LEVEL_GATE_SWITCHES:String	= "lvlgs";
		public static const LEVEL_TOWER:String			= "lvls";
		public static const LEVEL_TOWER_SWITCHES:String = "lvlss";
		public static const LEVEL_ROCKS:String			= "lvlr";
		public static const	DIRECTION:String			= "dir";
		
		public static const ERROR_CODE:String			= "errc";
		public static const ERROR_DESCRIPTION:String	= "errd";
		
		// errors
		public static const GAME_FULL:String				= "GameFull";
		public static const INVALID_ACTION:String			= "InvalidAction";
		public static const LEVEL_NOT_INITIALIZED:String	= "LevelNotInitialized";
	}
	
}