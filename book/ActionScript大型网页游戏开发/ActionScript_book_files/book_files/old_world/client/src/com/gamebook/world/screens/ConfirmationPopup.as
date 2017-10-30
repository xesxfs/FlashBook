package com.gamebook.world.screens {
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='ConfirmationPopup')]
	public class ConfirmationPopup extends Sprite {
		
		public static const CONFIRM_YES:String = "confirmYes";
		public static const CONFIRM_NO:String = "confirmNo";
		
		public var yes_btn:SimpleButton;
		public var no_btn:SimpleButton;
		public var message_txt:TextField;
		
		private var _data:Object;
		
		public function ConfirmationPopup(data:Object, messageText:String) {
			message_txt.text = messageText;
			_data = data;
			yes_btn.addEventListener(MouseEvent.CLICK, onClick);
			no_btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function destroy():void {
			yes_btn.removeEventListener(MouseEvent.CLICK, onClick);
			no_btn.removeEventListener(MouseEvent.CLICK, onClick);
			_data = null;
		}
		
		public function get data():Object { return _data; }
		
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
		
	}
	
}