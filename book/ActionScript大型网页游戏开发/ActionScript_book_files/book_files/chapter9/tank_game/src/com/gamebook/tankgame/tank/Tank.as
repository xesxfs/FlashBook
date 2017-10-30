package com.gamebook.tankgame.tank {
	import com.gamebook.tankgame.elements.MuzzleFlare;
	import com.gamebook.utils.network.movement.Converger;
	import com.gamebook.utils.NumberUtil;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/tankGame.swf', symbol='Tank')]
	public class Tank extends MovieClip{
		
		private var _score:int;
		private var _playerName:String;
		private var _health:int;
		private var _alive:Boolean;
		private var _numKills:int;
		private var _numDeaths:int;
		private var _turretRotation:Number;
		private var _lastShotTime:Number;
		private var _isMe:Boolean;
		private var _healthBar:HealthBar;
		private var _namePlate:NamePlate;
		
		private var _converger:Converger;
		
		public var base_mc:MovieClip;
		public var turret_mc:MovieClip;
		public var hitArea_mc:MovieClip;
		
		public function Tank() {
			_isMe = false;
			_health = 100;
			_alive = true;
			_numDeaths = 0;
			_numKills = 0;
			_turretRotation = 0;
			_lastShotTime = -1;
			
			_converger = new Converger();
			_converger.interceptTimeMultiplier = 6;
			_converger.maxDurationInterceptTime = 700;
			
			_healthBar = new HealthBar();
			_healthBar.y = 15;
			addChildAt(_healthBar, 0);
			
			_namePlate = new NamePlate();
			_namePlate.y = 23;
			addChildAt(_namePlate, 0);
			
			hitArea_mc.alpha = 0;
			hitArea_mc.cacheAsBitmap = true;
		}
		
		public function run():void {
			_converger.run();
			
			x = int(_converger.view.x);
			y = int(_converger.view.y);
			
			base_mc.rotation = _converger.view.angle;
			//turret_mc.rotation = _turretRotation;
			
			
			
			var k:Number = .25;
			var rot:Number = turret_mc.rotation;
			var diff:Number = _turretRotation - rot;
			var angMov:Number = NumberUtil.getRotationEaseAmount(diff, k);
			
			turret_mc.rotation += angMov;
			
		}
		
		public function shot():void {
			var mf:MuzzleFlare = new MuzzleFlare();
			mf.x = 65;
			turret_mc.addChild(mf);
		}
		
		public function get score():int { return _score; }
		
		public function set score(value:int):void {
			_score = value;
		}
		
		public function get isMe():Boolean { return _isMe; }
		
		public function set isMe(value:Boolean):void {
			_isMe = value;
		}
		
		public function get health():int { return _health; }
		
		public function set health(value:int):void {
			_health = value;
			_healthBar.bar_mc.scaleX = value / 100;
		}
		
		public function get alive():Boolean { return _alive; }
		
		public function set alive(value:Boolean):void {
			_alive = value;
		}
		
		public function get numKills():int { return _numKills; }
		
		public function set numKills(value:int):void {
			_numKills = value;
		}
		
		public function get numDeaths():int { return _numDeaths; }
		
		public function set numDeaths(value:int):void {
			_numDeaths = value;
		}
		
		public function get turretRotation():Number { return _turretRotation; }
		
		public function set turretRotation(value:Number):void {
			_turretRotation = value;
		}
		
		public function get lastShotTime():Number { return _lastShotTime; }
		
		public function set lastShotTime(value:Number):void {
			_lastShotTime = value;
		}
		
		public function get converger():Converger { return _converger; }
		
		public function get playerName():String { return _playerName; }
		
		public function set playerName(value:String):void {
			_playerName = value;
			_namePlate.name_txt.text = _playerName;
		}
		
	}
	
}