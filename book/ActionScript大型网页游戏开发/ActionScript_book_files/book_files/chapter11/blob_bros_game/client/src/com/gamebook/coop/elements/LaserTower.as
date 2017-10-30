package com.gamebook.coop.elements {
	
	import com.gamebook.coop.events.FireLaserEvent;
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='LaserTower')]
	public class LaserTower extends MovieClip {
		
		public static const STATE_FIRE:int			= 0;
		public static const STATE_CEASE_FIRE:int	= 1;
		public static const STATE_DESTROYED:int		= 2;
		
		private var _id:int;
		private var _tile:Tile;
		private var _isDestroyed:Boolean = false;
		private var _isFiring:Boolean = false;
		
		public function LaserTower(id:int, tile:Tile) {
			
			_id = id;
			this.x = tile.x;
			this.y = tile.y;
			
			_tile = tile;
			tile.isWalkable = false;
			gotoAndStop("default");
			
			// tell the tile there is a tower on it
			tile.hasTower = true;
			tile.currentTower = this;
		}
		
		public function setState(state:int, playerName:String):void {
			
			// if the tower has been destroyed, ignore further changes
			if (_isDestroyed) {
				trace("TOWER DESTROYED, ignoring state change");
				return;
			}
			
			switch (state) {
				case STATE_FIRE :
					trace("FIRE!!!");
					dispatchEvent(new FireLaserEvent(FireLaserEvent.FIRE, playerName));
					break;
				case STATE_CEASE_FIRE :
					trace("CEASE FIRE!");
					// do nothing because we don't care
					break;
				case STATE_DESTROYED :
					trace("DESTROYED");
					_isDestroyed = true;
					_tile.isWalkable = true;
					gotoAndStop("destroyed");
					break;
				default :
					throw new Error("Unknown state in LaserShooter.setState");
			}
		}
		
		public function get id():int				{ return _id; }
		public function get isDestroyed():Boolean	{ return _isDestroyed; }
		public function get isFiring():Boolean		{ return _isFiring; }
		
		public function set isFiring(val:Boolean):void { _isFiring = val; }
	}
	
}