package com.gamebook.tankgame.powerup {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class PowerupManager {
		
		private var _powerups:Array;
		private var _powerupsById:Dictionary;
		
		public function PowerupManager() {
			_powerups = [];
			_powerupsById = new Dictionary();
		}
		
		public function powerupById(id:int):Powerup {
			return _powerupsById[id];
		}
		
		public function addPowerup(t:Powerup):void {
			_powerups.push(t);
			_powerupsById[t.id] = t;
		}
		
		public function removePowerup(id:int):void {
			var t:Powerup = _powerupsById[id];
			_powerupsById[id] = null;
			
			for (var i:int = 0; i < _powerups.length;++i) {
				if (_powerups[i] == t) {
					_powerups.splice(i, 1);
					break;
				}
			}
		}
		
		public function get powerups():Array { return _powerups; }
		
		
	}
	
}