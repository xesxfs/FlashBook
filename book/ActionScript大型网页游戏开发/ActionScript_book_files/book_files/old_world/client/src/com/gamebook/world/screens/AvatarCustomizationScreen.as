package com.gamebook.world.screens {
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.request.PluginRequest;
	import com.gamebook.world.animation.AnimationLoader;
	import com.gamebook.world.animation.SpriteAnimation;
	import com.gamebook.world.avatar.Avatar;
	import com.gamebook.world.clothing.Clothing;
	import com.gamebook.world.clothing.ClothingTypes;
	import com.gamebook.world.PluginConstants;
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
	[Embed(source='../../../../assets/assets.swf', symbol='AvatarCustomizationScreen')]
	public class AvatarCustomizationScreen extends MovieClip {
		
		public static const ENTER_WORLD:String = "enterWorld";
		
		public var leftHair_btn:SimpleButton;
		public var rightHair_btn:SimpleButton;
		public var hairStyle_txt:TextField;
		
		public var leftTop_btn:SimpleButton;
		public var rightTop_btn:SimpleButton;
		public var top_txt:TextField;
		
		public var leftBottom_btn:SimpleButton;
		public var rightBottom_btn:SimpleButton;
		public var bottom_txt:TextField;
		
		public var leftShoes_btn:SimpleButton;
		public var rightShoes_btn:SimpleButton;
		public var shoes_txt:TextField;
		
		public var enterWorld_btn:SimpleButton;
		
		private var _hairs:Array = [];
		private var _hairIndex:int = 0;
		
		private var _tops:Array = [];
		private var _topIndex:int = 0;
		
		private var _bottoms:Array = [];
		private var _bottomIndex:int = 0;
		
		private var _shoes:Array = [];
		private var _shoesIndex:int = 0;
		
		private var _avatar:Avatar;
		private var _spriteAnimation:SpriteAnimation;
		private var _animationLoader:AnimationLoader;
		private var _avatarBitmap:Bitmap;
		private var _avatarLoaded:Boolean = false;
		
		private var _es:ElectroServer;
		
		
		public function AvatarCustomizationScreen(avatar:Avatar) {
			_avatar = avatar;
			
			fillArrays();
			nextBottom(0);
			nextHair(0);
			nextShoes(0);
			nextTop(0);
			
			enterWorld_btn.addEventListener(MouseEvent.CLICK, onClick);
			enterWorld_btn.mouseEnabled = false;
			enterWorld_btn.alpha = .5;
			
			leftBottom_btn.addEventListener(MouseEvent.CLICK, onClick);
			rightBottom_btn.addEventListener(MouseEvent.CLICK, onClick);
			leftHair_btn.addEventListener(MouseEvent.CLICK, onClick);
			rightHair_btn.addEventListener(MouseEvent.CLICK, onClick);
			leftShoes_btn.addEventListener(MouseEvent.CLICK, onClick);
			rightShoes_btn.addEventListener(MouseEvent.CLICK, onClick);
			leftTop_btn.addEventListener(MouseEvent.CLICK, onClick);
			rightTop_btn.addEventListener(MouseEvent.CLICK, onClick);
			
			buildAvatar();
			addEventListener(Event.ENTER_FRAME, run);
		}
		
		public function enableEnterWorldButton():void {
			enterWorld_btn.mouseEnabled = true;
			enterWorld_btn.alpha = 1;
		}
		
		private function save(id:int):void {
			var pr:PluginRequest = new PluginRequest();
			pr.setPluginName("WorldPlugin");
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.EQUIP);
			esob.setInteger(PluginConstants.CLOTHING_ID, id);
			
			pr.setEsObject(esob);
			
			_es.send(pr);
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
			
			var baseDir:String = "files/avatars/big/" + _avatar.gender + "/";
			var urls:Array = [baseDir+"base.png", baseDir+_avatar.bottom.fileName, baseDir+_avatar.shoes.fileName, baseDir+_avatar.top.fileName, baseDir+_avatar.hair.fileName];
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
				case enterWorld_btn:
					removeEventListener(Event.ENTER_FRAME, run);
					dispatchEvent(new Event(ENTER_WORLD));
					break;
				case leftBottom_btn:
					nextBottom( -1);
					break;
				case rightBottom_btn:
					nextBottom(1);
					break;
				case leftHair_btn:
					nextHair( -1);
					break;
				case rightHair_btn:
					nextHair(1);
					break;
				case leftShoes_btn:
					nextShoes( -1);
					break;
				case rightShoes_btn:
					nextShoes(1);
					break;
				case leftTop_btn:
					nextTop( -1);
					break;
				case rightTop_btn:
					nextTop(1);
					break;
			}
		}
		
		private function fillArrays():void{
			var list:Array = _avatar.ownedClothing;
			for each (var clothing:Clothing in list) {
				switch (clothing.clothingTypeId) {
					case ClothingTypes.BOTTOM:
						_bottoms.push(clothing);
						if (clothing == _avatar.bottom) {
							_bottomIndex = _bottoms.length - 1;
						}
						break;
					case ClothingTypes.HAIR:
						_hairs.push(clothing);
						if (clothing == _avatar.hair) {
							_hairIndex = _hairs.length - 1;
						}
						break;
					case ClothingTypes.SHOES:
						_shoes.push(clothing);
						if (clothing == _avatar.shoes) {
							_shoesIndex = _shoes.length - 1;
						}
						break;
					case ClothingTypes.TOP:
						_tops.push(clothing);
						if (clothing == _avatar.top) {
							_topIndex = _tops.length - 1;
						}
						break;
				}
			}
		}
		
		private function nextHair(dir:int):void{
			_hairIndex += dir;
			if (_hairIndex < 0) {
				_hairIndex = _hairs.length - 1;
			} else if (_hairIndex == _hairs.length) {
				_hairIndex = 0;
			}
			
			var hair:Clothing = _hairs[_hairIndex];
			_avatar.hair = hair;
			hairStyle_txt.text = hair.name;
			
			if (dir != 0) {
				save(hair.id);
				buildAvatar();
			}
		}
		
		private function nextBottom(dir:int):void{
			_bottomIndex += dir;
			if (_bottomIndex < 0) {
				_bottomIndex = _bottoms.length - 1;
			} else if (_bottomIndex == _bottoms.length) {
				_bottomIndex = 0;
			}
			
			var bottom:Clothing = _bottoms[_bottomIndex];
			_avatar.bottom = bottom;
			bottom_txt.text = bottom.name;
			
			if (dir != 0) {
				save(bottom.id);
				buildAvatar();
			}
		}
		
		private function nextShoes(dir:int):void{
			_shoesIndex += dir;
			if (_shoesIndex < 0) {
				_shoesIndex = _shoes.length - 1;
			} else if (_shoesIndex == _shoes.length) {
				_shoesIndex = 0;
			}
			
			var shoes:Clothing = _shoes[_shoesIndex];
			_avatar.shoes = shoes;
			shoes_txt.text = shoes.name;
			
			if (dir != 0) {
				save(shoes.id);
				buildAvatar();
			}
		}
		
		private function nextTop(dir:int):void{
			_topIndex += dir;
			if (_topIndex < 0) {
				_topIndex = _tops.length - 1;
			} else if (_topIndex == _tops.length) {
				_topIndex = 0;
			}
			
			var top:Clothing = _tops[_topIndex];
			_avatar.top = top;
			top_txt.text = top.name;
			
			if (dir != 0) {
				save(top.id);
				buildAvatar();
			}
		}
		
		public function get avatar():Avatar { return _avatar; }
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
	}
	
}