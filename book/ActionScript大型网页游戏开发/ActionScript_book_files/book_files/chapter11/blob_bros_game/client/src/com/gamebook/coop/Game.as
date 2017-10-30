package com.gamebook.coop {
	
	//ElectroServer imports
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.coop.elements.GoalPad;
	import com.gamebook.coop.events.AttemptGoalReachedEvent;
	import com.gamebook.coop.windows.GameOver;
	import com.gamebook.coop.windows.Victory;
	import flash.display.DisplayObject;
	
	//Game imports
	import com.gamebook.coop.SoundManager;
	import com.gamebook.coop.player.Player;
	import com.gamebook.coop.player.PlayerManager;
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import com.gamebook.coop.events.PositionUpdateEvent;
	import com.gamebook.coop.events.AttemptToggleSwitchEvent;
	import com.gamebook.coop.grid.Grid;
	import com.gamebook.coop.grid.Tile;
	import com.gamebook.coop.elements.Wall;
	import com.gamebook.coop.elements.Gate;
	import com.gamebook.coop.elements.Switch;
	import com.gamebook.coop.elements.Rock;
	import com.gamebook.coop.elements.LaserTower;
	import com.gamebook.coop.elements.SavePad;
	import com.gamebook.coop.elements.LaserBeam;
	import com.gamebook.coop.events.FireLaserEvent;
	import com.gamebook.coop.events.SavePointReachedEvent;
	import com.gamebook.coop.events.AttemptDestroyTowerEvent;
	import com.gamebook.coop.events.AttemptPushRockEvent;
	import com.gamebook.coop.events.PlayerDiedEvent;
	
	//Flash imports
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * This is the core game logic.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class Game extends Sprite {
		
		public static const TILE_WIDTH:int  = 32;
		public static const TILE_HEIGHT:int = 32;
		
		// player info
		private var _playerManager:PlayerManager;
		private var _myPlayer:Player;
		private var _buddyPlayer:Player;
		private var _lastTimeSent:int;
		
		// user input
		private var _keyManager:KeyManager;
		private var _left:KeyCombo;
		private var _right:KeyCombo;
		private var _up:KeyCombo;
		private var _down:KeyCombo;
		private var _space:KeyCombo;
		
		// game elements
		private var _soundManager:SoundManager;
		private var _gameContainer:Sprite;
		private var _tilesContainer:Sprite;
		private var _gameObjectContainer:Sprite;
		private var _grid:Grid;
		private var _switchesById:Dictionary;
		private var _gatesById:Dictionary;
		private var _towersById:Dictionary;
		private var _rocksById:Dictionary;
		
		// gui
		private var _myLivesText:TextField;
		private var _otherPlayersLivesText:TextField;
		
		/**
		 * Constructor
		 */
		public function Game(pm:PlayerManager) {
			
			_playerManager = pm;
			_lastTimeSent = 0;
			
			_myLivesText = new TextField();
			_otherPlayersLivesText = new TextField();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function get grid():Grid { return _grid; }
		
		/**
		 * Set up user input handlers.
		 */
		private function onAddedToStage(e:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_keyManager = new KeyManager();
			stage.addChild(_keyManager);
			
			_left = _keyManager.createKeyCombo(Key.LEFT);
			_right = _keyManager.createKeyCombo(Key.RIGHT);
			_up = _keyManager.createKeyCombo(Key.UP);
			_down = _keyManager.createKeyCombo(Key.DOWN);
			_space = _keyManager.createKeyCombo(Key.SPACE);
			
			_soundManager = SoundManager.instance;
			_soundManager.initialize();
		}
		
		public function initializeLevel(levelXML:XML):void {
			
			_gameContainer = new Sprite();
			_tilesContainer = new Sprite();
			_gameObjectContainer = new Sprite();
			_gameContainer.addChild(_tilesContainer);
			_gameContainer.addChild(_gameObjectContainer);
			addChild(_gameContainer);
			
			setupGrid(levelXML.@columns, levelXML.@rows);
			setupUI();
			setupGameElements(levelXML);
			setupListeners();
			_soundManager.playSound(SoundManager.ARE_YOU_READY);
			
			// put players in correct location
			for each (var player:Player in _playerManager.players) {
				player.setLocation(levelXML.@startX, levelXML.@startY);
			}
			
			//add frame event listener for updating character positions
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function setupListeners():void {
			for each ( var tower:LaserTower in _towersById ) {
				tower.addEventListener(FireLaserEvent.FIRE, onLaserFired);
			}
		}
		
		public function levelCompleted():void {
			trace("level completed");
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			destroyLevel();
		}
		
		/**
		 * Do some cleaning up.
		 */
		private function destroyLevel():void {
			for each ( var tower:LaserTower in _towersById ) {
				tower.removeEventListener(FireLaserEvent.FIRE, onLaserFired);
			}
			
			removeChild(_gameContainer);
			_gameContainer = null;
		}
		
		/**
		 * Set the grid and the add the grid's tiles to the level.
		 */
		private function setupGrid(cols:int, rows:int):void {
			_grid = new Grid(cols, rows, TILE_WIDTH, TILE_HEIGHT);
			
			for ( var i:int = 0; i < _grid.rows; i++ ) {
				for ( var j:int = 0; j < _grid.columns; j++ ) {
					_grid.getTile(j, i).x = j * TILE_WIDTH;
					_grid.getTile(j, i).y = i * TILE_HEIGHT;
					_tilesContainer.addChild(_grid.getTile(j, i));
				}
			}
		}
		
		private function setupUI():void {
			_gameContainer.addChild(_myLivesText);
			_gameContainer.addChild(_otherPlayersLivesText);
			
			_myLivesText.selectable = false;
			_otherPlayersLivesText.selectable = false;
			
			_myLivesText.x = 10;
			_myLivesText.y = _grid.rows * TILE_HEIGHT + 5;
			
			_otherPlayersLivesText.x = _myLivesText.x + _myLivesText.width + 10;
			_otherPlayersLivesText.y = _myLivesText.y;
			
			_myLivesText.text = "My Lives: 3";
			_otherPlayersLivesText.text = "Buddy's Lives: 3";
		}
		
		/**
		 * Set up the elements of the game board.
		 */
		private function setupGameElements(levelXML:XML):void {
			
			_switchesById = new Dictionary();
			_gatesById    = new Dictionary();
			_towersById  = new Dictionary();
			_rocksById    = new Dictionary();
			
			// walls
			for each (var wall:XML in levelXML..wall) {
				_gameObjectContainer.addChild(new Wall(_grid.getTile(wall.@x, wall.@y)));
			}
			
			// goal pad
			_gameObjectContainer.addChild(new GoalPad(_grid.getTile(levelXML.@goalX, levelXML.@goalY)));
			
			// save pads
			for each (var savePoint:XML in levelXML..savePoint) {
				_gameObjectContainer.addChild(new SavePad(_grid.getTile(savePoint.@x, savePoint.@y)));
			}
			
			// gate info -----------------------------------------------------
			for each (var gate:XML in levelXML..gate) {
				
				// add the gate
				var gateId:int = gate.@id;
				var tileX:int = gate.@x;
				var tileY:int = gate.@y;
				var gateObj:Gate = new Gate(gateId, _grid.getTile(tileX, tileY), true);
				_gatesById[gateId] = gateObj;
				_gameObjectContainer.addChild(gateObj);
			}
			
			// switch info ---------------------------------------------------
			for each (var switchLever:XML in levelXML..switchLever) {
				
				// add the switch
				var switchId:int = switchLever.@id;
				var switchTileX:int = switchLever.@x;
				var switchTileY:int = switchLever.@y;
				var switchType:String = switchLever.@type;
				var switchObj:Switch = new Switch(switchId, _grid.getTile(switchTileX, switchTileY), false, switchType);
				_switchesById[switchId] = switchObj;
				_gameObjectContainer.addChild(switchObj);
			}
			
			// rocks ---------------------------------------------------------
			for each (var rock:XML in levelXML..rock) {
				
				// add the rock
				var rockId:int = rock.@id;
				var rockTileX:int = rock.@x;
				var rockTileY:int = rock.@y;
				var rockType:int = rock.@type;
				var rockObj:Rock = new Rock(
					rockId,
					_grid.getTile(rockTileX, rockTileY),
					rockType
				);
				_rocksById[rockId] = rockObj;
				_gameObjectContainer.addChild(rockObj);
			}
			
			// laser towers --------------------------------------------------
			for each (var tower:XML in levelXML..tower) {
				
				// add the tower
				var towerId:int = tower.@id;
				var towerTileX:int = tower.@x;
				var towerTileY:int = tower.@y;
				var towerObj:LaserTower = new LaserTower(towerId, _grid.getTile(towerTileX, towerTileY));
				_towersById[towerId] = towerObj;
				_gameObjectContainer.addChild(towerObj);
			}
		}
		
		/**
		 * Toggle the specified switch.
		 */
		public function toggleSwitch(id:int, state:int):void {
			if (state == 1) {
				if (!_switchesById[id].isOn) {
					_switchesById[id].turnOn();
					_soundManager.playSound(SoundManager.LEVER);
				}
			} else {
				if (_switchesById[id].isOn) {
					_switchesById[id].turnOff();
					_soundManager.playSound(SoundManager.LEVER);
				}
			}
		}
		
		/**
		 * Toggle the specified gate.
		 */
		public function toggleGate(id:int, state:int):void {
			if (state == 1) {
				if (!_gatesById[id].isOn) {
					_gatesById[id].turnOn();
					_soundManager.playSound(SoundManager.GATE);
				}
			} else {
				if (_gatesById[id].isOn) {
					_gatesById[id].turnOff();
					_soundManager.playSound(SoundManager.GATE);
				}
			}
		}
		
		/**
		 * Set the tower state.
		 */
		public function setTowerState(id:int, state:int, playerName:String):void {
			trace("set tower state: " + id + ", " + state + ", " + playerName);
			_towersById[id].setState(state, playerName);
			
			if (state == LaserTower.STATE_DESTROYED) {
				_soundManager.playSound(SoundManager.DESTROY_TOWER);
				if (_myPlayer.name != playerName) {
					_playerManager.getPlayerByName(playerName).attack(id);
				}
			}
		}
		
		/**
		 * Add a player to the game screen.
		 */
		public function addPlayer(p:Player):void {
			if (p.isMe) _myPlayer = p;
			else _buddyPlayer = p;
			p.visible = true;
			_gameObjectContainer.addChild(p);
		}
		
		/**
		 * Remove a player from the game screen.
		 */
		public function removePlayer(p:Player):void {
			if (_gameObjectContainer.contains(p)) _gameObjectContainer.removeChild(p);
			if (p == _buddyPlayer) _buddyPlayer = null;
		}
		
		/**
		 * The driving force of the game engine.
		 */
		private function enterFrame(e:Event):void {
			
			if (_myPlayer != null) {
				checkKeys();
				movePlayers();
				
				//send a position update every 500ms
				if (getTimer() - _lastTimeSent > 500) {
					if (_myPlayer.x != _myPlayer.lastReportedX || _myPlayer.y != _myPlayer.lastReportedY) {
						dispatchEvent(new PositionUpdateEvent(PositionUpdateEvent.POSITION_UPDATE, _myPlayer.x, _myPlayer.y));
						_myPlayer.lastReportedX = x;
						_myPlayer.lastReportedY = y;
					}
					_lastTimeSent = getTimer();
				}
				
				// sort the players
				if (_buddyPlayer != null) {
					if (_myPlayer.sortMove != 0 || _buddyPlayer.sortMove != 0) {
						if (
							_gameObjectContainer.contains(_myPlayer) && _gameObjectContainer.contains(_buddyPlayer)
							&&
							(
								_myPlayer.y > _buddyPlayer.y && _gameObjectContainer.getChildIndex(_myPlayer) < _gameObjectContainer.getChildIndex(_buddyPlayer) ||
								_myPlayer.y < _buddyPlayer.y && _gameObjectContainer.getChildIndex(_myPlayer) > _gameObjectContainer.getChildIndex(_buddyPlayer)
							)
						) {
							_gameObjectContainer.swapChildren(_myPlayer, _buddyPlayer);
						}
					}
				}
			}
		}
		
		/**
		 * Update player positions
		 */
		private function movePlayers():void{
			for (var i:int = 0; i < _playerManager.players.length; ++i) {
				Player(_playerManager.players[i]).run();
			}
		}
		
		/**
		 * Handle user input.
		 */
		private function checkKeys():void {
			
			if (_myPlayer.isDead || _myPlayer.isAttacking) return;
			
			var sp:Number = 3;
			
			// no diagonal movements allowed in this game
			var xs:Number = 0;
			var ys:Number = 0;
			if (_left.getComboActivated()) {
				xs = -sp;
				_myPlayer.currentDirection = Player.DIR_WEST;
			} else if (_right.getComboActivated()) {
				xs = sp;
				_myPlayer.currentDirection = Player.DIR_EAST;
			} else if (_up.getComboActivated()) {
				ys = -sp;
				_myPlayer.currentDirection = Player.DIR_NORTH;
				_myPlayer.sortMove = -1;
			} else if (_down.getComboActivated()) {
				ys = sp;
				_myPlayer.currentDirection = Player.DIR_SOUTH;
				_myPlayer.sortMove = 1;
			} else {
				if (_myPlayer.isPushingRock) {
					dispatchEvent(new AttemptPushRockEvent(AttemptPushRockEvent.PUSH, _myPlayer.rockId, false, 0, 0, ""));
					_myPlayer.setNotPushingRock();
				}
				
				_myPlayer.sortMove = 0;
				return;
			}
			
			var ang:Number = Math.atan2(ys, xs) * 180 / Math.PI;
			
			if (ys != 0 || xs != 0) {
				
				_myPlayer.angleWalking = ang;
				var lastX:Number = _myPlayer.x;
				var lastY:Number = _myPlayer.y;
				_myPlayer.x += sp * Math.cos(ang * Math.PI / 180);
				_myPlayer.y += sp * Math.sin(ang * Math.PI / 180);
				
				// am I trying to enter an unwalkable tile?
				var currentTile:Tile = _grid.getTileAtLocation(lastX, lastY);
				var attemptedTile:Tile = _grid.getTileAtLocation(_myPlayer.x, _myPlayer.y);
				
				if (!attemptedTile) { // does the tile exist?
					_myPlayer.x = lastX;
					_myPlayer.y = lastY;
				} else if (!attemptedTile.isWalkable) {
					
					// does this unwalkable tile have a rock on it?
					if (attemptedTile.hasRock) {
						if (!_myPlayer.isPushingRock && !attemptedTile.currentRock.isSliding) {
							_myPlayer.setIsPushingRock(attemptedTile.currentRock.id);
							attemptPushRock(attemptedTile.currentRock, _myPlayer.currentDirection);
							_soundManager.playSound(SoundManager.STRAIN);
						}
					}
					
					// does this unwalkable tile have a tower on it that I can destroy?
					if (attemptedTile.hasTower && _myPlayer.type == Player.TYPE_ATTACKER) {
						if (!attemptedTile.currentTower.isDestroyed && !_myPlayer.isAttacking) {
							_myPlayer.attack(attemptedTile.currentTower.id);
							dispatchEvent(new AttemptDestroyTowerEvent(AttemptDestroyTowerEvent.DESTROY, attemptedTile.currentTower.id));
						}
					}
					
					_myPlayer.x = lastX;
					_myPlayer.y = lastY;
					
				} else if (currentTile != attemptedTile) {
					
					// handle any triggers
					if (currentTile.trigger > -1) {
						dispatchEvent(new AttemptToggleSwitchEvent(AttemptToggleSwitchEvent.TOGGLE_SWITCH, currentTile.trigger, false));
					}
					if (attemptedTile.trigger > -1) {
						dispatchEvent(new AttemptToggleSwitchEvent(AttemptToggleSwitchEvent.TOGGLE_SWITCH, attemptedTile.trigger, true));
						_soundManager.playSound(SoundManager.STRAIN);
					}
					
					// is this tile a save point?
					if (attemptedTile.isSavePoint) {
						var newSpawnX:int = attemptedTile.x + attemptedTile.width / 2;
						var newSpawnY:int = attemptedTile.y + attemptedTile.height / 2;
						dispatchEvent(new SavePointReachedEvent(SavePointReachedEvent.SAVE_POINT, newSpawnX, newSpawnY));
						_soundManager.playSound(SoundManager.SAVE_POINT);
					}
					
					// is the tile the goal point?
					if (currentTile.isGoalPoint) {
						dispatchEvent(new AttemptGoalReachedEvent(AttemptGoalReachedEvent.GOAL_REACHED, false));
					}
					if (attemptedTile.isGoalPoint) {
						dispatchEvent(new AttemptGoalReachedEvent(AttemptGoalReachedEvent.GOAL_REACHED, true));
					}
				}
			}
		}
		
		/**
		 * Push the rock if possible.
		 */
		public function pushRock(rockId:int, tileX:int, tileY:int, dirName:String):void {
			
			var rock:Rock = _rocksById[rockId];
			
			var destinationTile:Tile = _grid.getTile(tileX, tileY);
			rock.move(destinationTile);
			_soundManager.playSound(SoundManager.MOVE_ROCK);
			dispatchEvent(new AttemptPushRockEvent(AttemptPushRockEvent.PUSH, rockId, false, tileX, tileY, dirName));
		}
		
		/**
		 * Attempt to push a rock.
		 */
		private function attemptPushRock(rock:Rock, direction:int):void {
			trace("push rock: " + rock.id + " in direction " + direction);
			
			var xMove:int = 0;
			var yMove:int = 0;
			var dirName:String;
			
			switch (direction) {
				case Player.DIR_NORTH :
					yMove = -1;
					dirName = "north";
					break;
				case Player.DIR_SOUTH :
					yMove = 1;
					dirName = "south";
					break;
				case Player.DIR_EAST :
					xMove = 1;
					dirName = "east";
					break;
				case Player.DIR_WEST :
					xMove = -1;
					dirName = "west";
					break;
			}
			
			var destinationTile:Tile = _grid.getTile(rock.currentTile.column + xMove, rock.currentTile.row + yMove);
			
			// is the destination tile ok to push a rock into?
			if (!destinationTile || !destinationTile.isWalkable) {
				trace("can't push rock there!");
			} else {
				dispatchEvent(new AttemptPushRockEvent(AttemptPushRockEvent.PUSH, rock.id, true, destinationTile.column, destinationTile.row, dirName));
			}
		}
		
		/**
		 * A laser was fired.
		 * Draw the laser from the firing tower to the victim.
		 */
		private function onLaserFired(fle:FireLaserEvent):void {
			
			trace("\n onLaserFired, target: " + fle.targetPlayerName);
			
			var shooter:LaserTower = _towersById[fle.target.id];
			var victim:Player = _playerManager.getPlayerByName(fle.targetPlayerName);
			
			// shooter can only fire one shot at a time
			if (shooter.isFiring) {
				return;
			}
			
			shooter.isFiring = true;
			
			var laserBeam:LaserBeam = new LaserBeam(shooter, victim);
			laserBeam.addEventListener(LaserBeam.LASER_DONE, onLaserDone);
			_soundManager.playSound(SoundManager.LASER_BEAM);
			_gameObjectContainer.addChild(laserBeam);
		}
		
		/**
		 * The laser is done firing. Remove it.
		 * Kill the victim.
		 */
		private function onLaserDone(e:Event):void {
			trace("laser done");
			
			var laserBeam:LaserBeam = LaserBeam(e.target);
			laserBeam.removeEventListener(LaserBeam.LASER_DONE, onLaserDone);
			_gameObjectContainer.removeChild(laserBeam);
			laserBeam.victim.setLaserDone();
			laserBeam.shooter.isFiring = false;
			
			// lasers kill the player who cannot defend
			if (laserBeam.victim.type != Player.TYPE_DEFENDER) {
				dispatchEvent(new PlayerDiedEvent(PlayerDiedEvent.DIE, laserBeam.victim.name));
				laserBeam.victim.isDead = true;
			}
		}
		
		/**
		 * Set a player as dead.
		 * Remove the player until he/she is revived.
		 */
		public function setPlayerAsDead(playerName:String):void {
			var deadPlayer:Player = _playerManager.getPlayerByName(playerName);
			deadPlayer.isDead = true;
			deadPlayer.visible = false;
			_soundManager.playSound(SoundManager.DEATH);
		}
		
		/**
		 * Set a player as not dead.
		 * Set the position to the spawn location.
		 * Show the player.
		 */
		public function revivePlayer(playerName:String, spawnX:int, spawnY:int, livesRemaining:int):void {
			var revivedPlayer:Player = _playerManager.getPlayerByName(playerName);
			revivedPlayer.isDead = false;
			revivedPlayer.setLocation(spawnX, spawnY);
			revivedPlayer.visible = true;
			_gameObjectContainer.addChild(revivedPlayer);
			_soundManager.playSound(SoundManager.SPAWN);
			
			if (revivedPlayer == _myPlayer) {
				_myLivesText.text = "My Lives: " + livesRemaining;
			} else {
				_otherPlayersLivesText.text = "Buddy's Lives: " + livesRemaining;
			}
		}
		
		public function spawnLocationUpdated():void {
			_soundManager.playSound(SoundManager.SAVE_POINT);
		}
		
		/**
		 * The game has been won.
		 */
		public function victoryAchieved():void {
			trace("victoryAchieved");
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			_soundManager.stopAll();
			_soundManager.playSound(SoundManager.VICTORY);
			
			var victoryWindow:Victory = new Victory();
			addChild(victoryWindow);
		}
		
		/**
		 * The game is over.
		 */
		public function gameOver(loserName:String):void {
			trace("the game is over, and was lost by: " + loserName);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			_soundManager.stopAll();
			_soundManager.playSound(SoundManager.GAME_OVER);
			
			var gameOverWindow:GameOver = new GameOver(loserName);
			addChild(gameOverWindow);
		}
	}
	
}