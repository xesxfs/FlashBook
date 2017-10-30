package com.gamebook.tankgame.tank {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class TankManager {
		
		private var _tanks:Array;
		private var _tanksByName:Dictionary;
		private var _myTank:Tank;
		
		public function TankManager() {
			_tanks = [];
			_tanksByName = new Dictionary();
		}
		
		public function tankByName(name:String):Tank {
			return _tanksByName[name];
		}
		
		public function addTank(t:Tank):void {
			if (t.isMe) {
				_myTank = t;
			}
			_tanks.push(t);
			_tanksByName[t.playerName] = t;
		}
		
		public function removeTank(name:String):void {
			var t:Tank = _tanksByName[name];
			_tanksByName[name] = null;
			
			for (var i:int = 0; i < _tanks.length;++i) {
				if (_tanks[i] == t) {
					_tanks.splice(i, 1);
					break;
				}
			}
		}
		
		public function get tanks():Array { return _tanks; }
		
		public function get myTank():Tank { return _myTank; }
		
		
	}
	
}