package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class AttemptDestroyTowerEvent extends Event 
	{
		public static const DESTROY:String = "destory";
		
		public var towerId:int;
		
		public function AttemptDestroyTowerEvent(type:String, towerId:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.towerId = towerId;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new AttemptDestroyTowerEvent(type, towerId, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("AttemptDestroyTowerEvent", "type", "towerId", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}