package com.gamebook.coop.player {
	
	//Game imports
	import com.gamebook.coop.grid.Grid;
	import com.gamebook.coop.player.avatars.Avatar;
	import com.gamebook.coop.events.PlayerDiedEvent;
	import com.gamebook.coop.player.avatars.BluePlayer;
	import com.gamebook.coop.player.avatars.GreenPlayer;
	import com.gamebook.coop.grid.Tile;
	import com.gamebook.utils.NumberUtil;
	import com.gamebook.coop.SoundManager;
	
	//Flash imports
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class Player extends Sprite {
		
		public static const STOP_ATTACK:String = "stop_attack";
		
		public static const TYPE_DEFENDER:int = 1;
		public static const TYPE_ATTACKER:int = 0;
		
		public static const DIR_EAST:int  = 0;
		public static const DIR_SOUTH:int = 1;
		public static const DIR_WEST:int  = 2;
		public static const DIR_NORTH:int = 3;
		
		
		private static const ATTACK_TIME:int = 1000; // milliseconds to attack
		
		// info
		private var _type:int;
		private var _isMe:Boolean;
		private var _score:int;
		private var _lives:int;
		private var _isDead:Boolean = false;
		
		// movement
		private var _sortMove:int;
		private var _endx:Number;
		private var _endy:Number;
		private var _lastReportedX:Number;
		private var _lastReportedY:Number;
		private var _angleWalking:Number;
		private var _currentDirection:int;
		private var _grid:Grid;
		
		// avatar
		private var _avatarClip:Avatar;
		private var _glow:GlowFilter;
		private var _laserHitCtr:int = 0;
		
		// attacking
		private var _isAttacking:Boolean = false;
		private var _attackStarted:int;
		private var _attackTargetId:int;
		
		// pushing a rock
		private var _isPushingRock:Boolean = false;
		private var _rockId:int;
		
		/**
		 * Constructor
		 */
		public function Player(name:String, isMe:Boolean, type:int, lives:int, x:int, y:int, grid:Grid) {
			this.name = name;
			_isMe = isMe;
			_type = type;
			_lives = lives;
			this.x = x;
			this.y = y;
			_grid = grid;
			_score = 0;
			
			_endx = x;
			_endy = y;
			_lastReportedX = x;
			_lastReportedY = y;
			
			initializeGraphics();
		}
		
		public function get type():int				{ return _type; }
		public function get isMe():Boolean			{ return _isMe; }
		public function get score():int				{ return _score; }
		public function get isDead():Boolean		{ return _isDead; }
		public function get isAttacking():Boolean	{ return _isAttacking; }
		public function get attackTargetId():int	{ return _attackTargetId; }
		public function get lastReportedX():Number	{ return _lastReportedX; }
		public function get lastReportedY():Number	{ return _lastReportedY; }
		public function get currentDirection():int	{ return _currentDirection; }
		public function get isPushingRock():Boolean	{ return _isPushingRock; }
		public function get rockId():int			{ return _rockId; }
		public function get sortMove():int			{ return _sortMove; }
		
		public function set score(value:int):void				{ _score = value; }
		public function set angleWalking(value:Number):void		{ _angleWalking = value; }
		public function set isDead(value:Boolean):void			{ _isDead = value; }
		public function set lastReportedX(value:Number):void	{ _lastReportedX = value; }
		public function set lastReportedY(value:Number):void	{ _lastReportedY = value; }
		public function set currentDirection(value:int):void	{ _currentDirection = value; }
		public function set sortMove(value:int):void			{ _sortMove = value; }
		
		private function initializeGraphics():void {
			
			/*var color:Number = 0x00FF00;
			if (_type == Player.TYPE_DEFENDER) color = 0xFFFF00;
			
			graphics.beginFill(color, 1.0);
			graphics.drawRect(-10, -10, 20, 20);
			graphics.endFill();*/
			
			if (_type == Player.TYPE_ATTACKER) {
				_avatarClip = new GreenPlayer();
			} else {
				_avatarClip = new BluePlayer();
			}
			_avatarClip.setRotation(0);
			addChild(_avatarClip);
			
			// for use when getting hit by laser
			_glow = new GlowFilter(0xffff00, 1);
		}
		
		public function setIsPushingRock(rockId:int):void {
			_isPushingRock = true;
			_rockId = rockId;
		}
		
		public function setNotPushingRock():void {
			_isPushingRock = false;
		}
		
		public function walkTo(endx:Number, endy:Number):void {
			_endx = endx;
			_endy = endy;
		}
		
		/**
		 * Used to place a player directly in a specific location.
		 * This is likely called after a respawn.
		 */
		public function setLocation(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
			_endx = this.x;
			_endy = this.y;
		}
		
		/**
		 * A laser is now hitting the player.
		 * React accordingly.
		 */
		public function setHitWithLaser():void {
			_laserHitCtr++;
			this.filters = [_glow];
			if (_type == TYPE_DEFENDER) {
				_avatarClip.setCurrentState("attack");
			}
		}
		
		/**
		 * A laser is no longer hitting the player.
		 */
		public function setLaserDone():void {
			_laserHitCtr--;
			if (_laserHitCtr < 1) {
				this.filters = null;
				_avatarClip.setCurrentState("bounce");
			}
		}
		
		/**
		 * Attack.
		 */
		public function attack(towerId:int):void {
			if (_isAttacking) return;
			
			trace("attack");
			_isAttacking = true;
			_attackTargetId = towerId;
			_avatarClip.setCurrentState("attack");
			_attackStarted = getTimer();
		}
		
		public function stopAttack():void {
			if (!_isAttacking) return;
			
			trace("stop attack");
			_isAttacking = false;
			_avatarClip.setCurrentState("bounce");
			dispatchEvent(new Event(STOP_ATTACK));
		}
		
		/**
		 * Displays the correct angle and walk state for the character
		 */
		private function showCharacterAngle():void {
			
			var isWalking:Boolean = x != _endx || y != _endy;
			
			if (!isWalking) {
				//_avatarClip.currentAnimationClip.gotoAndStop(1);
			} else {
				var angle:Number = Math.atan2(_endy - y, _endx - x) * 180 / Math.PI;
				if (isMe) {
					angle = _angleWalking;
				}
				var rotationIndex:int = NumberUtil.findAngleIndex(angle, 45);
				_avatarClip.setRotation(rotationIndex);
			}
		}
		
		/**
		 * Run
		 */
		public function run():void {
			
			if (_isDead) return;
			
			if (_isAttacking) {
				if (getTimer() - _attackStarted > ATTACK_TIME) stopAttack();
			}
			
			if (!isMe) {
				//linear
				if (_endx != x || _endy != y) {
					
					_endy > y ? _sortMove = 1 : _endy < y ? _sortMove = -1 : 0;
					
					//angle character is walking
					var ang:Number = Math.atan2(_endy - y, _endx - x);
					
					//frame-based speed
					var speed:Number = 3;
					
					//distance to travel in the x and y directions based on the angle
					var xs:Number = speed * Math.cos(ang);
					var ys:Number = speed * Math.sin(ang);
					
					//where the character will be after this frame
					var tx:Number = x + xs;
					var ty:Number = y + ys;
					
					//determine if we past the target
					var xdir1:Number = (_endx - x) / Math.abs(_endx - x);
					var xdir2:Number = (_endx - tx) / Math.abs(_endx - tx);
					var ydir1:Number = (_endy - y) / Math.abs(_endy - y);
					var ydir2:Number = (_endy - ty) / Math.abs(_endy - ty);
					
					//check to see if you diveded by zero above
					if (isNaN(xdir1) || isNaN(xdir2)) {
						xdir1 = 0;
						xdir2 = 0;
					}
					
					//check to see if you diveded by zero above
					if (isNaN(ydir1) || isNaN(ydir2)) {
						ydir1 = 0;
						ydir2 = 0;
					}
					
					//if the normalized directions don't match, then you've just stepped past the target position
					if (xdir1 != xdir2 || ydir1 != ydir2) {
						tx = _endx;
						ty = _endy;
					}
					
					// what tile did I leave, and where am I going?
					var currentTile:Tile = _grid.getTileAtLocation(x, y);
					var attemptedTile:Tile = _grid.getTileAtLocation(tx, ty);
					
					//update position
					x = tx;
					y = ty;
					
					// react to tile changes
					if (attemptedTile != currentTile) {
						if (attemptedTile.isSavePoint) {
							SoundManager.instance.playSound(SoundManager.SAVE_POINT);
						}
						if (attemptedTile.trigger > -1) {
							SoundManager.instance.playSound(SoundManager.STRAIN);
						}
					}
				} else {
					_sortMove = 0;
				}
			}
			
			//show the right character angle and walk state
			showCharacterAngle();
			
			//if the charcter is me, then send the target position to the current position
			if (isMe) {
				_endx = x;
				_endy = y;
			}
		}
		
	}
	
}