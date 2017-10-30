package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class FireLaserEvent extends Event 
	{
		public static const FIRE:String = "fire";
		
		public var targetPlayerName:String;
		
		public function FireLaserEvent(type:String, targetPlayerName:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.targetPlayerName = targetPlayerName;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new FireLaserEvent(type, targetPlayerName, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FireLaserEvent", "type", "targetPlayerName", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}