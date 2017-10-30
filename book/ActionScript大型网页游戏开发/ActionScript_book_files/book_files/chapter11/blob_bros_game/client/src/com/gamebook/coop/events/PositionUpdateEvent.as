package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class PositionUpdateEvent extends Event 
	{
		public static const POSITION_UPDATE:String = "position_update";
		
		public var x:int;
		public var y:int;
		
		public function PositionUpdateEvent(type:String, x:int, y:int, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.x = x;
			this.y = y;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new PositionUpdateEvent(type, x, y, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PositionUpdateEvent", "type", "x", "y", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}