package com.gamebook.world.screens {
	import com.gamebook.world.avatar.Avatar;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='BuddyConfirmationPopup')]
	public class BuddyConfirmationPopup extends Sprite {
		
		public static const CONFIRM_YES:String = "confirmYes";
		public static const CONFIRM_NO:String = "confirmNo";
		
		public var yes_btn:SimpleButton;
		public var no_btn:SimpleButton;
		public var message_txt:TextField;
		
		private var _avatar:Avatar;
		
		public function BuddyConfirmationPopup(avatar:Avatar, messageText:String) {
			message_txt.text = messageText;
			_avatar = avatar;
			
			yes_btn.addEventListener(MouseEvent.CLICK, onClick);
			no_btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function destroy():void {
			yes_btn.removeEventListener(MouseEvent.CLICK, onClick);
			no_btn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			e.stopImmediatePropagation();
			
			switch (e.target) {
				case yes_btn: 
					dispatchEvent(new Event(CONFIRM_YES));
					break;
				case no_btn:
					dispatchEvent(new Event(CONFIRM_NO));
					break;
				default: trace("unhandled click");
			}			
		}			
		
		public function get avatar():Avatar { return _avatar; }
		
	}
	
}