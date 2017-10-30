package com.gamebook.tankgame {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../assets/tankGame.swf', symbol='LoginScreen')]
	public class LoginScreen extends MovieClip{
		
		public static const SUBMIT_CLICKED:String = "submitClicked";
		
		
		public var submit_btn:SimpleButton;
		public var name_txt:TextField;
		public var logo_mc:MovieClip;
		public var instructions_mc:MovieClip;
		public var textbg_mc:MovieClip;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='LoginScreenMusic')]
		private var LoginScreenMusic:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='MouseOverSound')]
		private var MouseOverSound:Class;
		
		private var _music:SoundChannel;
		
		public function LoginScreen() {
			submit_btn.addEventListener(MouseEvent.CLICK, onClick);
			submit_btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			
			logo_mc.stop();
			
			name_txt.text = "player" + Math.round(1000 * Math.random()).toString();
			
			var snd:Sound = new LoginScreenMusic();
			_music = snd.play(0, 1000, new SoundTransform(.35));
		}
		
		private function onRollOver(e:MouseEvent):void {
			var snd:Sound = new MouseOverSound();
			snd.play();
		}
		
		private function onClick(e:MouseEvent):void {
			if (name_txt.text.length > 0) {
				submit_btn.visible = false;
				textbg_mc.visible = false;
				instructions_mc.visible = false;
				name_txt.visible = false;
				logo_mc.play();
				
				logo_mc.addFrameScript(19, stopLogoPlaying);
				
				dispatchEvent(new Event(SUBMIT_CLICKED));
			}
		}
		
		public function destroy():void {
			_music.stop();
		}
		
		private function stopLogoPlaying():void{
			logo_mc.stop();
		}
		
	}
	
}