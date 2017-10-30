package com.gamebook.coop.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class AttemptToggleSwitchEvent extends Event 
	{
		public static const TOGGLE_SWITCH:String = "toggle_switch";
		
		public var switchId:int;
		public var isOn:Boolean;
		
		public function AttemptToggleSwitchEvent(type:String, switchId:int, isOn:Boolean, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			this.switchId = switchId;
			this.isOn = isOn;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new AttemptToggleSwitchEvent(type, switchId, isOn, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("AttemptToggleSwitchEvent", "type", "switchId", "isOn", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}