package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class PlayerDiedEvent extends Event 
	{
		public static const DIE:String = "die";
		
		public var playerName:String;
		
		public function PlayerDiedEvent(type:String, playerName:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.playerName = playerName;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new PlayerDiedEvent(type, playerName, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PlayerDiedEvent", "type", "playerName", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}