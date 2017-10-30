package com.gamebook.world.screens {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Popup')]
	public class Popup extends MovieClip{
		
		public static const OK:String = "ok";
		
		public var message_txt:TextField;
		public var ok_btn:SimpleButton;
		
		public function Popup(msg:String) {
			message_txt.text = msg;
			ok_btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent(new Event(OK));
		}
		
	}
	
}