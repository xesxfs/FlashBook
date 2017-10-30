package com.gamebook.world.events {
	import com.gamebook.world.avatar.Avatar;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	public class BuddyListEvent extends Event {
		
		public static const BUDDY_SELECTED:String 		= "buddySelected";
		public static const GO_TO_HOME:String = "buddyInviteToHome";
		public static const BUDDY_REMOVE:String 		= "buddyRemove";
		
		private var _avatar:Avatar;
		
		public function BuddyListEvent(type:String, avatar:Avatar, bubbles:Boolean=false, cancelable:Boolean=false) { 
			_avatar = avatar;
			super(type, bubbles, cancelable);			
		} 
		
		public override function clone():Event { 
			return new BuddyListEvent(type, _avatar, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("BuddyListEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get avatar():Avatar { return _avatar; }
		
	}
	
}