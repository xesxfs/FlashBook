package com.gamebook.world.screens {
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='IntroScreen')]
	public class IntroScreen extends MovieClip {
		
		public static const LOGIN_AVATAR:String = "loginAvatar";
		public static const LOGIN_GUEST:String = "loginGuest";
		
		public var login_txt:TextField;
		public var password_txt:TextField;
		public var send_btn:SimpleButton;
		public var register_btn:SimpleButton;
		
		private var _km:KeyManager;
		private var _enter:KeyCombo;
		
		public function IntroScreen() {
			
			send_btn.addEventListener(MouseEvent.CLICK, onClick);
			register_btn.addEventListener(MouseEvent.CLICK, onClick);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			stage.focus = login_txt;
			
			_km = new KeyManager();
			addChild(_km);
			
			_enter = _km.createKeyCombo(Key.ENTER);
			_enter.addEventListener(KeyCombo.COMBO_PRESSED, onEnterPressed);
		}
		
		private function onEnterPressed(e:Event):void {
			attemptLogin();
		}
		
		public function destroy():void {
			stage.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeChild(_km);
			
			_km = null;
		}
		
		private function onClick(e:MouseEvent):void {
			switch (e.target) {
				case send_btn:
					attemptLogin();
					break;
				case register_btn:
					dispatchEvent(new Event(LOGIN_GUEST));
					break;
			}
		}
		
		private function attemptLogin():void{
			if (login_txt.text.length > 0 && password_txt.text.length > 0) {
				dispatchEvent(new Event(LOGIN_AVATAR));
			}
		}
		
	}
	
}