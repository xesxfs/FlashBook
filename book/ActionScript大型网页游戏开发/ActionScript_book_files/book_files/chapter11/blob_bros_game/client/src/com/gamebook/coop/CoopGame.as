package com.gamebook.coop {
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.plugin.Plugin;
	import com.electrotank.electroserver4.room.Room;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.PluginRequest;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	
	//Game imports
	import com.gamebook.coop.Game;
	import com.gamebook.coop.PluginConstants;
	import com.gamebook.coop.player.PlayerManager;
	import com.gamebook.coop.player.Player;
	import com.gamebook.coop.elements.LaserTower;
	import com.gamebook.coop.events.PositionUpdateEvent;
	import com.gamebook.coop.events.PlayerDiedEvent;
	import com.gamebook.coop.events.AttemptToggleSwitchEvent;
	import com.gamebook.coop.events.AttemptDestroyTowerEvent;
	import com.gamebook.coop.events.AttemptPushRockEvent;
	import com.gamebook.coop.events.SavePointReachedEvent;
	import com.gamebook.coop.events.AttemptGoalReachedEvent;
	
	//Flash imports
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * Handle communcation with the server to drive the game.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class CoopGame extends Sprite {
		
		private const TOTAL_LEVELS:int = 2;
		
		private var _game:Game;
		private var _es:ElectroServer;
		private var _room:Room;
		private var _playerManager:PlayerManager;
		private var _myUsername:String;
		private var _currentLevel:int = 1;
		private var _currentLevelXML:XML;
		
		public function CoopGame() {
			
		}
		
		public function initialize():void {
			
			//add some server listeners
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
			
			_myUsername = _es.getUserManager().getMe().getUserName();
			trace("my user name: " + _myUsername);
			
			_playerManager = new PlayerManager();
			_game = new Game(_playerManager);
			addChild(_game);
			
			//join a room to play the game
			joinRoom();
		}
		
		/**
		 * Create a room with the CoopGamePlugin plugin
		 */
		private function joinRoom():void {
			trace("attempting to join room..");
			
			//create the request
			var crr:CreateRoomRequest = new CreateRoomRequest();
			crr.setRoomName("Coop Game Room");
			crr.setZoneName("Coop Game Zone");
			
			//create the plugin
			var pl:Plugin = new Plugin();
			pl.setExtensionName("GameBook");
			pl.setPluginHandle("CoopGamePlugin");
			pl.setPluginName("CoopGamePlugin");
			
			//add to the list of plugins to create
			crr.setPlugins([pl]);
			
			//send it
			_es.send(crr);
		}
		
		/**
		 * Called when you successfully join a room
		 */
		public function onJoinRoomEvent(e:JoinRoomEvent):void {
			
			trace("room joined: " + e.getRoomName());
			
			//store a reference to your room
			_room = e.room;
			
			// grab the xml file for the first level
			loadLevelXML(_currentLevel);
		}
		
		private function loadLevelXML(levelNumber:int):void {
			trace("loading level XML for level: " + levelNumber);
			var loader:URLLoader = new URLLoader(new URLRequest("levels/level"+levelNumber+".xml"));
			loader.addEventListener(Event.COMPLETE, onLevelXmlFileLoaded);
		}
		
		private function onLevelXmlFileLoaded(e:Event):void {
			
			trace("level XML file loaded");
			var loader:URLLoader = e.target as URLLoader;
			_currentLevelXML = new XML(loader.data);
			
			// build the level info
			var esob:EsObject = getLevelEsObject();
			trace(esob);
			
			//tell the plugin to try and initialize the level
			sendToPlugin(esob);
		}
		
		/**
		 * Return an EsObject to represent the level you want to initialize.
		 */
		private function getLevelEsObject():EsObject {
			
			// level info ----------------------------------------------------
			var lvlEsObj:EsObject = new EsObject();
			lvlEsObj.setString(PluginConstants.ACTION, PluginConstants.INIT_LEVEL);
			lvlEsObj.setInteger(PluginConstants.LEVEL_NUMBER, _currentLevel);
			var startX:int = _currentLevelXML.@startX * Game.TILE_WIDTH + Game.TILE_WIDTH / 2;
			var startY:int = _currentLevelXML.@startY * Game.TILE_HEIGHT + Game.TILE_HEIGHT / 2;
			lvlEsObj.setInteger(PluginConstants.X, startX);
			lvlEsObj.setInteger(PluginConstants.Y, startY);
			
			// gate info -----------------------------------------------------
			var gatesArray:Array = new Array();
			for each (var gate:XML in _currentLevelXML..gate) {
				var gatesObj:EsObject = new EsObject();
				gatesObj.setInteger(PluginConstants.GATE_ID, gate.@id);
				
				var switches:Array = new Array();
				for each (var switchId:XML in gate..switchId) {
					switches.push(switchId);
				}
				
				gatesObj.setIntegerArray(PluginConstants.LEVEL_GATE_SWITCHES, switches);
				gatesArray.push(gatesObj);
			}
			lvlEsObj.setEsObjectArray(PluginConstants.LEVEL_GATES, gatesArray);
			
			// tower info ---------------------------------------------------
			var towersArray:Array = new Array();
			for each (var tower:XML in _currentLevelXML..tower) {
				var towerObj:EsObject = new EsObject();
				towerObj.setInteger(PluginConstants.TOWER_ID, tower.@id);
				
				var switchesTower:Array = new Array();
				for each (var switchIdTower:XML in tower..switchId) {
					switchesTower.push(switchIdTower);
				}
				
				towerObj.setIntegerArray(PluginConstants.LEVEL_TOWER_SWITCHES, switchesTower);
				towersArray.push(towerObj);
			}
			lvlEsObj.setEsObjectArray(PluginConstants.LEVEL_TOWER, towersArray);
			
			// rocks info ----------------------------------------------------
			var rocksArray:Array = new Array();
			for each (var rock:XML in _currentLevelXML..rock) {
				rocksArray.push(rock.@id);
			}
			lvlEsObj.setIntegerArray(PluginConstants.LEVEL_ROCKS, rocksArray);
			
			return lvlEsObj;
		}
		
		/**
		 * Sends formatted EsObjects to the DigGame plugin
		 */
		private function sendToPlugin(esob:EsObject):void {
			//build the request
			var pr:PluginRequest = new PluginRequest();
			pr.setEsObject(esob);
			pr.setRoomId(_room.getRoomId());
			pr.setZoneId(_room.getZoneId());
			pr.setPluginName("CoopGamePlugin");
			
			//send it
			_es.send(pr);
			//trace(esob);
		}
		
		/**
		 * Called when a message is received from a plugin
		 */
		public function onPluginMessageEvent(e:PluginMessageEvent):void {
			var esob:EsObject = e.getEsObject();
			
			//get the action which determines what we do next
			var action:String = esob.getString(PluginConstants.ACTION);
			
			//if (action != PluginConstants.POSITION_UPDATE) trace("\n action = " + action + "\n");
			
			switch (action) {
				case PluginConstants.INIT_LEVEL :
					handleInitLevel(esob);
					break;
				case PluginConstants.PLAYER_LIST :
					handlePlayerList(esob);
					break;
				case PluginConstants.ADD_PLAYER :
					handleAddPlayer(esob);
					break;
				case PluginConstants.REMOVE_PLAYER :
					handleRemovePlayer(esob);
					break;
				case PluginConstants.POSITION_UPDATE :
					handlePositionUpdate(esob);
					break;
				case PluginConstants.FLIP_SWITCH :
					handleFlipSwitch(esob);
					break;
				case PluginConstants.DESTROY_TOWER :
					handleDestroyTower(esob);
					break;
				case PluginConstants.PUSH_ROCK:
					handlePushRock(esob);
					break;
				case PluginConstants.PLAYER_DIED :
					handlePlayerDied(esob);
					break;
				case PluginConstants.REVIVE_ME :
					handleReviveMe(esob);
					break;
				case PluginConstants.UPDATE_SPAWN_LOCATION :
					handleUpdateSpawnLocation(esob);
					break;
				case PluginConstants.LEVEL_COMPLETE :
					handleLevelComplete(esob);
					break;
				case PluginConstants.GAME_OVER :
					handleGameOver(esob);
					break;
				case PluginConstants.ERROR :
					handleError(esob);
					break;
				default:
					trace("Action not handled: " + action);
			}
		}
		
		/**
		 * The level has been initialized.
		 * Now init the player.
		 */
		private function handleInitLevel(esob:EsObject):void {
			trace("handleInitLevel");
			
			_game.initializeLevel(_currentLevelXML);
			
			//tell the plugin that you're ready
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.INIT_ME);
			sendToPlugin(esob);
		}
		
		/**
		 * A player just bit the dust
		 */
		private function handlePlayerDied(esob:EsObject):void {
			trace("handlePlayerDied");
			var deadPlayerName:String = esob.getString(PluginConstants.NAME);
			_game.setPlayerAsDead(deadPlayerName);
		}
		
		/**
		 * A player has been revived.
		 * Respawn the player at the last saved spawn point.
		 */
		private function handleReviveMe(esob:EsObject):void {
			trace("handleReviveMe");
			trace(esob);
			var revivedPlayerName:String = esob.getString(PluginConstants.NAME);
			var spawnX:int = esob.getInteger(PluginConstants.X);
			var spawnY:int = esob.getInteger(PluginConstants.Y);
			var livesRemaining:int = esob.getInteger(PluginConstants.LIVES_REMAINING);
			_game.revivePlayer(revivedPlayerName, spawnX, spawnY, livesRemaining);
		}
		
		/**
		 * Destroy a tower.
		 */
		private function handleDestroyTower(esob:EsObject):void {
			trace("handleDestroyTower");
			trace(esob);
			var towerId:int = esob.getInteger(PluginConstants.TOWER_ID);
			var playerNameWhoDestroyed:String = esob.getString(PluginConstants.NAME);
			_game.setTowerState(towerId, LaserTower.STATE_DESTROYED, playerNameWhoDestroyed);
		}
		
		/**
		 * A switch has been fliped.
		 */
		private function handleFlipSwitch(esob:EsObject):void {
			trace("handleFlipSwitch");
			
			// the switch that was flipped
			var switchId:int = esob.getInteger(PluginConstants.SWITCH_ID);
			var switchState:int = esob.getInteger(PluginConstants.SWITCH_STATE);
			_game.toggleSwitch(switchId, switchState);
			
			// who fliped it?
			var playerNameWhoFlippedSwitch:String = esob.getString(PluginConstants.NAME);
			
			// the results of what was flipped
			var switchResults:EsObject = esob.getEsObject(PluginConstants.SWITCH_RESULTS);
			
			// was it a gate or laser tower?
			if (switchResults.doesPropertyExist(PluginConstants.GATE_ID)) {
				
				var gateId:int = switchResults.getInteger(PluginConstants.GATE_ID);
				var gateState:int = switchResults.getInteger(PluginConstants.GATE_STATE);
				_game.toggleGate(gateId, gateState);
				
			} else if (switchResults.doesPropertyExist(PluginConstants.TOWER_ID)) {
				
				var towerId:int = switchResults.getInteger(PluginConstants.TOWER_ID);
				var towerState:int = switchResults.getInteger(PluginConstants.TOWER_STATE);
				_game.setTowerState(towerId, towerState, playerNameWhoFlippedSwitch);
			}
		}
		
		/**
		 * Position update
		 */
		private function handlePositionUpdate(esob:EsObject):void {
			//trace("handlePositionUpdate");
			
			var name:String = esob.getString(PluginConstants.NAME);
			var x:int = esob.getInteger(PluginConstants.X);
			var y:int = esob.getInteger(PluginConstants.Y);
			
			var p:Player = _playerManager.getPlayerByName(name);
			if (!p.isMe) {
				p.walkTo(x, y);
			}
		}
		
		/**
		 * Add a player
		 */
		private function handleAddPlayer(esob:EsObject):void {
			trace("handle add player");
			addPlayer(esob);
		}
		
		/**
		 * Remove a player
		 */
		private function handleRemovePlayer(esob:EsObject):void {
			trace("handle remove player");
			var name:String = esob.getString(PluginConstants.NAME);
			_game.removePlayer(_playerManager.getPlayerByName(name));
			_playerManager.removePlayer(name);
		}
		
		/**
		 * Parse the player list
		 */
		private function handlePlayerList(esob:EsObject):void {
			trace("handle palyer list");
			
			var players:Array = esob.getEsObjectArray(PluginConstants.PLAYER_LIST);
			for (var i:int = 0; i < players.length;++i) {
				var player_esob:EsObject = players[i];
				addPlayer(player_esob);
			}
		}
		
		/**
		 * The current level has been completed successfully.
		 */
		private function handleLevelComplete(esob:EsObject):void {
			trace("handleLevelComplete");
			_game.levelCompleted();
			_currentLevel++;
			
			if (_currentLevel > TOTAL_LEVELS) {
				_game.victoryAchieved();
			} else {
				loadLevelXML(_currentLevel);
			}
			
		}
		
		/**
		 * The game is over.
		 * Better luck next time.
		 */
		private function handleGameOver(esob:EsObject):void {
			trace("handle game over");
			var loserName:String = esob.getString(PluginConstants.NAME);
			_game.gameOver(loserName);
		}
		
		/**
		 * The spawn location has been updated.
		 */
		private function handleUpdateSpawnLocation(esob:EsObject):void {
			trace("handleUpdateSpawnLocation");
			_game.spawnLocationUpdated();
		}
		
		/**
		 * A rock has been pushed.
		 */
		private function handlePushRock(esob:EsObject):void {
			trace("handlePushRock");
			var rockId:int = esob.getInteger(PluginConstants.ROCK_ID);
			
			var tileX:int = esob.getInteger(PluginConstants.X);
			var tileY:int = esob.getInteger(PluginConstants.Y);
			var dirName:String = esob.getString(PluginConstants.DIRECTION);
			
			_game.pushRock(rockId, tileX, tileY, dirName);
		}
		
		/**
		 * Add a player.
		 */
		private function addPlayer(esob:EsObject):void {
			
			// grab all of the player info
			var playerObj:EsObject = esob.getEsObject(PluginConstants.PLAYER);
			var name:String = playerObj.getString(PluginConstants.NAME);
			var isMe:Boolean = name == _myUsername;
			var type:int = playerObj.getInteger(PluginConstants.PLAYER_TYPE);
			var lives:int = playerObj.getInteger(PluginConstants.LIVES_REMAINING);
			var x:int = playerObj.getInteger(PluginConstants.X);
			var y:int = playerObj.getInteger(PluginConstants.Y);
			
			// create a new player using the info sent to us
			var p:Player = new Player(name, isMe, type, lives, x , y, _game.grid);
			
			_playerManager.addPlayer(p);
			_game.addPlayer(p);
			
			trace("added player: " + p.name + " to location [" + x + ", " + y + "]" );
			//trace(esob);
			
			if (isMe) {
				_game.addEventListener(PositionUpdateEvent.POSITION_UPDATE, onPositionUpdate);
				_game.addEventListener(AttemptToggleSwitchEvent.TOGGLE_SWITCH, onToggleSwitchAttempt);
				_game.addEventListener(AttemptDestroyTowerEvent.DESTROY, onDestroyTowerAttempt);
				_game.addEventListener(PlayerDiedEvent.DIE, onPlayerDie);
				_game.addEventListener(SavePointReachedEvent.SAVE_POINT, onSavePointReached);
				_game.addEventListener(AttemptGoalReachedEvent.GOAL_REACHED, onGoalReachedAttempt);
				_game.addEventListener(AttemptPushRockEvent.PUSH, onPushRockAttempt);
			}
		}
		
		/**
		 * Called when the server tells the client something went wrong
		 */
		private function handleError(esob:EsObject):void {
			var errorCode:String = esob.getString(PluginConstants.ERROR_CODE);
			var errorDescription:String = esob.getString(PluginConstants.ERROR_DESCRIPTION);
			switch (errorCode) {
				case PluginConstants.GAME_FULL:
					trace("the game is full");
					break;
				case PluginConstants.INVALID_ACTION:
					trace("invalid action");
					break;
				default:
					trace("Error not handled: " + errorCode);
			}
		}
		
		/**
		 * I have updated my position.
		 * Send the info to the server.
		 */
		private function onPositionUpdate(pue:PositionUpdateEvent):void {
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.POSITION_UPDATE);
			esob.setInteger(PluginConstants.X, pue.x);
			esob.setInteger(PluginConstants.Y, pue.y);
			sendToPlugin(esob);
		}
		
		/**
		 * I am attempting to toggle a switch.
		 * Send the info to the server.
		 */
		private function onToggleSwitchAttempt(atse:AttemptToggleSwitchEvent):void {
			trace("onToggleSwitch: " + atse.switchId + ", " + atse.isOn);
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.FLIP_SWITCH);
			esob.setInteger(PluginConstants.SWITCH_ID, atse.switchId);
			esob.setInteger(PluginConstants.SWITCH_STATE, atse.isOn == true ? 1 : 0);
			sendToPlugin(esob);
		}
		
		/**
		 * I want to destory a tower.
		 * Tell the server.
		 */
		private function onDestroyTowerAttempt(adte:AttemptDestroyTowerEvent):void {
			trace("onDestroyTowerAttempt");
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.DESTROY_TOWER);
			esob.setInteger(PluginConstants.TOWER_ID, adte.towerId);
			sendToPlugin(esob);
		}
		
		/**
		 * I am attempting to push a rock.
		 * Tell the server.
		 */
		private function onPushRockAttempt(apre:AttemptPushRockEvent):void {
			trace("onPushRockAttempt");
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.PUSH_ROCK);
			esob.setInteger(PluginConstants.ROCK_ID, apre.rockId);
			
			// only needed if we are trying to push
			if (apre.isPusing) {
				esob.setInteger(PluginConstants.X, apre.x);
				esob.setInteger(PluginConstants.Y, apre.y);
				esob.setString(PluginConstants.DIRECTION, apre.direction);
			}
			
			sendToPlugin(esob);
		}
		
		/**
		 * A save point has been reached by me.
		 * Tell the server.
		 */
		private function onSavePointReached(spre:SavePointReachedEvent):void {
			trace("onSavePointReached");
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.UPDATE_SPAWN_LOCATION);
			esob.setInteger(PluginConstants.X, spre.x);
			esob.setInteger(PluginConstants.Y, spre.y);
			sendToPlugin(esob);
		}
		
		/**
		 * Tell the server the goal has been reached by me.
		 */
		private function onGoalReachedAttempt(agre:AttemptGoalReachedEvent):void {
			trace("onGoalReachedAttempt");
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.LEVEL_COMPLETE);
			esob.setInteger(PluginConstants.SWITCH_STATE, agre.isOn == true ? 1 : 0);
			sendToPlugin(esob);
		}
		
		/**
		 * A player has died.
		 * It happens.
		 */
		private function onPlayerDie(pde:PlayerDiedEvent):void {
			trace("onPlayerDie: " + pde.playerName);
			
			if (_playerManager.getPlayerByName(pde.playerName).isMe) {
				var esob:EsObject = new EsObject();
				esob.setString(PluginConstants.ACTION, PluginConstants.PLAYER_DIED);
				sendToPlugin(esob);
			}
		}
		
		public function set es(value:ElectroServer):void { _es = value; }
	}
	
}