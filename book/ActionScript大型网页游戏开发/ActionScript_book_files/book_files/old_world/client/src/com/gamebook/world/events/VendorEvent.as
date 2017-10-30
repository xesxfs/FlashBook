package com.gamebook.world.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	public class VendorEvent extends Event {
		
		public static const MERCHANDISE_SELECTED:String = "merchandiseSelected";
		
		private var _data:Object;
		
		public function VendorEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			_data = data;
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event { 
			return new VendorEvent(type, _data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VendorEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object { return _data; }
		
	}
	
}