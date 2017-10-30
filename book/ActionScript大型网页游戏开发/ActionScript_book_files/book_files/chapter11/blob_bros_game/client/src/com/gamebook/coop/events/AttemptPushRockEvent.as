package com.gamebook.coop.events {
	
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class AttemptPushRockEvent extends Event {
		
		public static const PUSH:String = "push";
		
		public var rockId:int;
		public var isPusing:Boolean;
		public var x:int;
		public var y:int;
		public var direction:String;
		
		public function AttemptPushRockEvent(type:String, rockId:int, isPusing:Boolean, x:int, y:int, direction:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			this.rockId = rockId;
			this.isPusing = isPusing;
			this.x = x;
			this.y = y;
			this.direction = direction;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new AttemptPushRockEvent(type, rockId, isPusing, x, y, direction, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AttemptPushRockEvent", "type", "rockId", "isPusing", "x", "y", "direction", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}