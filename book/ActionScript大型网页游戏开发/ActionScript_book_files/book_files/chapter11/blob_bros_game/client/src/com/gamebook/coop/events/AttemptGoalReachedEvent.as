package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class AttemptGoalReachedEvent extends Event 
	{
		public static const GOAL_REACHED:String = "goal_reached";
		
		public var isOn:Boolean;
		
		public function AttemptGoalReachedEvent(type:String, isOn:Boolean, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.isOn = isOn;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new AttemptGoalReachedEvent(type, isOn, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("AttemptGoalReachedEvent", "type", "isOn", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}