package com.gamebook.world.avatar {
	import com.gamebook.renderer.ISortable;
	import com.gamebook.renderer.tile.WayPoint;
	import com.gamebook.utils.NumberUtil;
	import com.gamebook.world.animation.AnimationLoader;
	import com.gamebook.world.animation.SpriteAnimation;
	import com.gamebook.world.chat.ChatBubble;
	import com.gamebook.world.clothing.Clothing;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Avatar extends MovieClip implements ISortable{
		
		public static const MALE:String = "M";
		public static const FEMALE:String = "F";
		
		public static const WALKING:String = "walking";
		public static const IDLE:String = "idle";
		
		private var _avatarName:String;
		private var _gender:String;
		private var _money:int;
		private var _avatarId:int;
		
		
		private var _hair:Clothing;
		private var _top:Clothing;
		private var _bottom:Clothing;
		private var _shoes:Clothing;
		private var _isMe:Boolean = false;
		
		private var _walkSpeed:Number = .09;
		
		private var _ownedClothing:Array;
		private var _spriteAnimation:SpriteAnimation;
		private var _avatarLoaded:Boolean = false;
		private var _walkAnimationLoader:AnimationLoader;
		private var _idleAnimationLoader:AnimationLoader;
		private var _avatarBitmap:Bitmap = new Bitmap();
		private var _walkingAnimation:SpriteAnimation;
		private var _idleAnimation:SpriteAnimation;
		private var _angleIndex:int = 1;
		private var _angle:Number;
		private var _cosAngle:Number;
		private var _sinAngle:Number;
		
		private var _wayPoints:Array;
		private var _wayPointIndex:int;
		
		private var _col:int;
		private var _row:int;
		
		private var _state:String;
		
		private var _chatBubble:ChatBubble = new ChatBubble();
		private var _namePlate:NamePlate = new NamePlate();
		
		private var _isOnline:Boolean = true;
		
		
		public function Avatar() {
			
		}
		
		public function run():void {
			if (_spriteAnimation != null && _spriteAnimation.ready) {
				_spriteAnimation.row = _angleIndex;
				_spriteAnimation.nextFrame();
				_avatarBitmap.bitmapData = _spriteAnimation.bitmapData;
			}
			
			chatBubble.x = x;
			chatBubble.y = y - 120;
			
			namePlate.x = x;
			namePlate.y = y+10;
		}
		
		public function build():void {
			
			addChild(_avatarBitmap);
			_avatarBitmap.x = -33;
			_avatarBitmap.y = -100;
			
			_avatarLoaded = false;
			
			_walkingAnimation = new SpriteAnimation(66, 120);
			_walkingAnimation.framesToHold = 3;
			
			_walkAnimationLoader = new AnimationLoader();
			_walkAnimationLoader.spriteAnimation = _walkingAnimation;
			_walkAnimationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
			
			var baseDir:String = "files/avatars/small/" + _gender + "/walk/";
			var urls:Array = [baseDir+"base.png", baseDir+_bottom.fileName, baseDir+_shoes.fileName, baseDir+_top.fileName, baseDir+_hair.fileName];
			_walkAnimationLoader.loadFiles(urls);
			
			_idleAnimation = new SpriteAnimation(66, 120);
			_idleAnimation.framesToHold = 6;
			
			_idleAnimationLoader = new AnimationLoader();
			_idleAnimationLoader.spriteAnimation = _idleAnimation;
			_idleAnimationLoader.addEventListener(AnimationLoader.DONE, onAnimationDoneLoading);
			
			baseDir = "files/avatars/small/" + _gender + "/idle/";
			urls = [baseDir+"base.png", baseDir+_bottom.fileName, baseDir+_shoes.fileName, baseDir+_top.fileName, baseDir+_hair.fileName];
			_idleAnimationLoader.loadFiles(urls);
		}
		
		public function walk(wayPoints:Array):void {
			_wayPoints = wayPoints;
			changeState(WALKING);
			
			wayPointIndex = 0;
		}
		
		public function changeState(newState:String):void {
			if (newState != _state) {
				_state = newState;
				switch (_state) {
					case WALKING:
						_spriteAnimation = _walkingAnimation
						break;
					case IDLE:
						_spriteAnimation = _idleAnimation;
						break;
				}
				_avatarBitmap.bitmapData = _spriteAnimation.bitmapData;
			}
		}
		
		private function onAnimationDoneLoading(e:Event):void {
			_avatarLoaded = true;
			
			if (_idleAnimationLoader.loaded && _walkAnimationLoader.loaded) {
				if (_state == null) {
					changeState(IDLE);
				}
			}
		}
		
		public function checkPointCollision(tx:int, ty:int):Boolean {
			var collision:Boolean = false;
			
			if (tx >= _avatarBitmap.x && tx < _avatarBitmap.x + _avatarBitmap.bitmapData.width && ty >= _avatarBitmap.y && ty < _avatarBitmap.y + _avatarBitmap.bitmapData.height) {
				collision = _avatarBitmap.bitmapData.getPixel32(tx - _avatarBitmap.x, ty - _avatarBitmap.y) != 0;
			}
			
			return collision;
		}
		
		/* INTERFACE com.gamebook.renderer.ISortable */
		
		public function get col():int{
			return _col;
		}
		
		public function get row():int{
			return _row;
		}
		
		public function get cols():int{
			return 1;
		}
		
		public function get rows():int{
			return 1;
		}
		
		public function get gender():String { return _gender; }
		
		public function set gender(value:String):void {
			_gender = value;
		}
		
		public function get money():int { return _money; }
		
		public function set money(value:int):void {
			_money = value;
		}
		
		public function get hair():Clothing { return _hair; }
		
		public function set hair(value:Clothing):void {
			_hair = value;
		}
		
		public function get top():Clothing { return _top; }
		
		public function set top(value:Clothing):void {
			_top = value;
		}
		
		public function get bottom():Clothing { return _bottom; }
		
		public function set bottom(value:Clothing):void {
			_bottom = value;
		}
		
		public function get shoes():Clothing { return _shoes; }
		
		public function set shoes(value:Clothing):void {
			_shoes = value;
		}
		
		public function get ownedClothing():Array { return _ownedClothing; }
		
		public function set ownedClothing(value:Array):void {
			_ownedClothing = value;
		}
		
		public function get isMe():Boolean { return _isMe; }
		
		public function set isMe(value:Boolean):void {
			_isMe = value;
		}
		
		public function get avatarName():String { return _avatarName; }
		
		public function set avatarName(value:String):void {
			_avatarName = value;
			_namePlate.name_txt.text = _avatarName;
		}
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get angleIndex():int { return _angleIndex; }
		
		public function set angleIndex(value:int):void {
			_angleIndex = value;
		}
		
		public function get walkSpeed():Number { return _walkSpeed; }
		
		public function set walkSpeed(value:Number):void {
			_walkSpeed = value;
		}
		
		public function get wayPointIndex():int { return _wayPointIndex; }
		
		public function set wayPointIndex(value:int):void {
			_wayPointIndex = value;
			
			_col = WayPoint(_wayPoints[_wayPointIndex]).tile.col;
			_row = WayPoint(_wayPoints[_wayPointIndex]).tile.row;
			
			if (_wayPointIndex < _wayPoints.length-1) {
				var wp1:WayPoint = _wayPoints[_wayPointIndex];
				var wp2:WayPoint = _wayPoints[_wayPointIndex + 1];
				
				var ang_rad:Number = Math.atan2(wp2.tile.row - wp1.tile.row, wp2.tile.col - wp1.tile.col);
				_cosAngle = Math.cos(ang_rad);
				_sinAngle = Math.sin(ang_rad);
				
				_angle = ang_rad * 180 / Math.PI;
				
				_angleIndex = NumberUtil.findAngleIndex(_angle, 45);
				
			}
		}
		
		public function get state():String { return _state; }
		
		public function get wayPoints():Array { return _wayPoints; }
		
		public function get angle():Number { return _angle; }
		
		public function set angle(value:Number):void {
			_angle = value;
		}
		
		public function get cosAngle():Number { return _cosAngle; }
		
		public function set cosAngle(value:Number):void {
			_cosAngle = value;
		}
		
		public function get sinAngle():Number { return _sinAngle; }
		
		public function set sinAngle(value:Number):void {
			_sinAngle = value;
		}
		
		public function get chatBubble():ChatBubble { return _chatBubble; }
		
		public function get namePlate():NamePlate { return _namePlate; }
		
		public function get avatarId():int { return _avatarId; }
		
		public function set avatarId(value:int):void {
			_avatarId = value;
		}
		
		public function get isOnline():Boolean { return _isOnline; }
		
		public function set isOnline(value:Boolean):void {
			_isOnline = value;
		}
		
		
	}
	
}