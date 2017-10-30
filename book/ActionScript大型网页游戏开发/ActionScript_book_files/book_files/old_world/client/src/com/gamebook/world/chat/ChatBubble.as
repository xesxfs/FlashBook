package com.gamebook.world.chat {
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='ChatBubble')]
	public class ChatBubble extends MovieClip{
		
		public var message_txt:TextField;
		
		private var _timer:Timer;
		
		public function ChatBubble() {
			visible = false;
		}
		
		public function showMessage(msg:String):void {
			message_txt.text = msg;
			
			visible = true;
			
			startTimer();
		}
		
		private function startTimer():void{
			killTimer();
			
			_timer = new Timer(3500, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		private function killTimer():void{
			if (_timer) {
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_timer.stop();
				_timer = null;
			}
		}
		
		private function onTimer(e:TimerEvent):void {
			killTimer();
			visible = false;
		}
		
	}
	
}