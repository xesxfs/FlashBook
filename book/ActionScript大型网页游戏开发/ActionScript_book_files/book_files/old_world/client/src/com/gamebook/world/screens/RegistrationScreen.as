package com.gamebook.world.screens {
	import com.gamebook.world.animation.AnimationLoader;
	import com.gamebook.world.animation.SpriteAnimation;
	import com.gamebook.world.avatar.Avatar;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='RegistrationScreen')]
	public class RegistrationScreen extends MovieClip{
		
		public static const CREATE_AVATAR:String = "createAvatar";
		
		public var male_btn:SimpleButton;
		public var female_btn:SimpleButton;
		public var left_btn:SimpleButton;
		public var right_btn:SimpleButton;
		public var hairStyle_txt:TextField;
		public var name_txt:TextField;
		public var password_txt:TextField;
		public var createAvatar_btn:SimpleButton;
		
		private var _gender:String;
		private var _hairTypeId:int;
		private var _hairIndex:int = 0;
		private var _maleHairTypes:Array = [ { name:"Goatee", id:14, fileName:"hair_goatee.png"}, { name:"Mustache", id:15, fileName:"hair_mustache.png"} ];
		private var _femaleHairTypes:Array = [ { name:"Red Hair", id:1, fileName:"hair_red.png"}, { name:"Blonde Hair", id:2, fileName:"hair_blonde.png"} ];
		private var _currentHairTypes:Array;
		private var _spriteAnimation:SpriteAnimation;
		private var _animationLoader:AnimationLoader;
		private var _avatarBitmap:Bitmap;
		private var _avatarLoaded:Boolean = false;
		
		
		public function RegistrationScreen() {
			
			createAvatar_btn.addEventListener(MouseEvent.CLICK, onClick);
			left_btn.addEventListener(MouseEvent.CLICK, onClick);
			right_btn.addEventListener(MouseEvent.CLICK, onClick);
			male_btn.addEventListener(MouseEvent.CLICK, onClick);
			female_btn.addEventListener(MouseEvent.CLICK, onClick);
			
			_gender = Avatar.MALE;
			_currentHairTypes = _maleHairTypes;
			nextHair(0);
			
			buildAvatar();
			
			addEventListener(Event.ENTER_FRAME, run);
		}
		
		private function run(e:Event):void {
			if (_avatarLoaded) {
				_spriteAnimation.nextFrame();
				_avatarBitmap.bitmapData = _spriteAnimation.bitmapData;
				_avatarBitmap.smoothing = true;
			}
		}
		
		private function buildAvatar():void {
			
			if (_spriteAnimation != null) {
				_spriteAnimation = null;
				_animationLoader.removeEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
				_animationLoader = null;
			}
			
			_avatarLoaded = false;
			
			_spriteAnimation = new SpriteAnimation(220, 400);
			_spriteAnimation.framesToHold = 6;
			
			_animationLoader = new AnimationLoader();
			_animationLoader.spriteAnimation = _spriteAnimation;
			_animationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
			
			var baseDir:String = "files/avatars/big/" + _gender + "/";
			var urls:Array;
			if (_gender == Avatar.FEMALE) {
				urls = [baseDir + "base.png", baseDir + "armored_skirt.png", baseDir + "sandals.png", baseDir + "ivory_dress.png", baseDir + _currentHairTypes[_hairIndex].fileName];
			} else if (_gender == Avatar.MALE) {
				urls = [baseDir + "base.png", baseDir + "armored_pants.png", baseDir + "boots.png", baseDir + "armored_shirt.png", baseDir + _currentHairTypes[_hairIndex].fileName];
			}
			_animationLoader.loadFiles(urls);
		}
		
		private function onAnimationDoneLoading(e:Event):void {
			if (_avatarBitmap == null) {
				_avatarBitmap = new Bitmap();
			}
			
			_avatarLoaded = true;
			
			_avatarBitmap.scaleX = _avatarBitmap.scaleY = .75;
			_avatarBitmap.x = 440;
			_avatarBitmap.y = 115;
			
			addChild(_avatarBitmap);
			
		}
		
		private function onClick(e:MouseEvent):void {
			switch (e.target) {
				case createAvatar_btn:
					if (name_txt.text.length > 0 && password_txt.text.length > 0) {
						removeEventListener(Event.ENTER_FRAME, run);
						dispatchEvent(new Event(CREATE_AVATAR));
					}
					break;
				case left_btn:
					nextHair( -1);
					break;
				case right_btn:
					nextHair( 1);
					break;
				case male_btn:
					_gender = Avatar.MALE;
					_currentHairTypes = _maleHairTypes;
					_hairIndex = 0;
					nextHair(0);
					buildAvatar();
					break;
				case female_btn:
					_gender = Avatar.FEMALE;
					_currentHairTypes = _femaleHairTypes;
					_hairIndex = 0;
					nextHair(0);
					buildAvatar();
					break;
			}
		}
		
		private function nextHair(dir:int):void{
			_hairIndex += dir;
			if (_hairIndex < 0) {
				_hairIndex = _currentHairTypes.length - 1;
			} else if (_hairIndex == _currentHairTypes.length) {
				_hairIndex = 0;
			}
			var hairOb:Object = _currentHairTypes[_hairIndex];
			_hairTypeId = hairOb.id;
			hairStyle_txt.text = hairOb.name;
			
			if (dir != 0) {
				buildAvatar();
			}
		}
		
		public function get hairTypeId():int { return _hairTypeId; }
		
		public function get gender():String { return _gender; }
		
	}
	
}