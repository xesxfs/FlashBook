package com.gamebook.tankgame {
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../assets/tankGame.swf', symbol='Chat')]
	public class Chat extends MovieClip{
		
		
		public var history_txt:TextField;
		public var input_txt:TextField;
		
		public function Chat() {
			history_txt.text = "";
			history_txt.htmlText = "";
			
		}
		
		public function addChatMessage(from:String, message:String):void {
			history_txt.htmlText += from + ": " + message + "<br>";
			
			history_txt.scrollV = history_txt.maxScrollV;
		}
		
		public function addEventMessage(message:String):void {
			history_txt.htmlText += "<font color='#00FF00'>***" + message + "</font><br>";
			history_txt.scrollV = history_txt.maxScrollV;
		}
		
	}
	
}