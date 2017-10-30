package com.gamebook.tankgame.bullet {
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class BulletManager {
		
		private var _bullets:Array;
		private var _bulletsById:Dictionary;
		private var _nearlyDeadBullets:Array;
		private var _deadBulletLife:int;
		
		public function BulletManager() {
			_bullets = [];
			_nearlyDeadBullets = [];
			_bulletsById = new Dictionary();
			_deadBulletLife = 2000;
		}
		
		public function deadBulletCleanup():void {
			var tm:int = getTimer();
			for (var i:int = _nearlyDeadBullets.length - 1; i >= 0;--i ) {
				var dbh:DeadBulletHolder = _nearlyDeadBullets[i];
				if (tm - dbh.deathDate > _deadBulletLife) {
					_bulletsById[dbh.bullet.id] = null;
					_nearlyDeadBullets.splice(i, 1);
				}
			}
		}
		
		public function addBullet(bullet:Bullet):void {
			_bullets.push(bullet);
			_bulletsById[bullet.id] = bullet;
		}
		
		public function removeBullet(id:int, forGood:Boolean=true):void {
			var bullet:Bullet = _bulletsById[id];
			bullet.alive = false;
			if (forGood) {
				_bulletsById[id] = null;
			} else {
				var dbh:DeadBulletHolder = new DeadBulletHolder();
				dbh.bullet = bullet;
				dbh.deathDate = getTimer();
				
				_nearlyDeadBullets.push(dbh);
			}
			for (var i:int = 0; i < _bullets.length;++i) {
				if (bullet == _bullets[i]) {
					_bullets.splice(i, 1);
					break;
				}
			}
		}
		
		public function bulletById(id:int):Bullet {
			return _bulletsById[id];
		}
		
		public function get bullets():Array { return _bullets; }
		
		public function get deadBulletLife():int { return _deadBulletLife; }
		
		public function set deadBulletLife(value:int):void {
			_deadBulletLife = value;
		}
		
		
		
	}

}

import com.gamebook.tankgame.bullet.Bullet;
class DeadBulletHolder {
	private var _deathDate:int;
	private var _bullet:Bullet;
	
	public function DeadBulletHolder() {
		
	}
	
	public function get deathDate():int { return _deathDate; }
	
	public function set deathDate(value:int):void {
		_deathDate = value;
	}
	
	public function get bullet():Bullet { return _bullet; }
	
	public function set bullet(value:Bullet):void {
		_bullet = value;
	}
}

