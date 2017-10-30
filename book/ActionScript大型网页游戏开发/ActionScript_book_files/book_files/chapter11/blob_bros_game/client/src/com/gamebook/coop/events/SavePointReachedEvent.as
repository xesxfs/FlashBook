package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class SavePointReachedEvent extends Event 
	{
		public static const SAVE_POINT:String = "save_point";
		
		public var x:int;
		public var y:int;
		
		public function SavePointReachedEvent(type:String, x:int, y:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.x = x;
			this.y = y;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new SavePointReachedEvent(type, x, y, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SavePointReachedEvent", "type", "x", "y", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}