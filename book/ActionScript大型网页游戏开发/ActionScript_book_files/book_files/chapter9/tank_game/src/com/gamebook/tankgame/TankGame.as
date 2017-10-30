package com.gamebook.tankgame {
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	import com.electrotank.electroserver4.message.event.PublicMessageEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.CreateOrJoinGameRequest;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.PluginRequest;
	import com.electrotank.electroserver4.message.request.PublicMessageRequest;
	import com.electrotank.electroserver4.message.request.QuickJoinGameRequest;
	import com.electrotank.electroserver4.message.response.CreateOrJoinGameResponse;
	import com.electrotank.electroserver4.room.Room;
	import com.gamebook.tankgame.bullet.Bullet;
	import com.gamebook.tankgame.bullet.BulletManager;
	import com.gamebook.tankgame.elements.DeathSmudge;
	import com.gamebook.tankgame.elements.Explosion;
	import com.gamebook.tankgame.minimap.MiniMap;
	import com.gamebook.tankgame.powerup.Powerup;
	import com.gamebook.tankgame.powerup.PowerupManager;
	import com.gamebook.tankgame.tank.HealthBar;
	import com.gamebook.tankgame.tank.Tank;
	import com.gamebook.tankgame.tank.TankManager;
	import com.gamebook.utils.FrameRateCounter;
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import com.gamebook.utils.network.clock.Clock;
	import com.gamebook.utils.network.movement.Heading;
	import fl.controls.List;
	import fl.data.DataProvider;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class TankGame extends MovieClip{
		
		private var _es:ElectroServer;
		private var _room:Room;
		private var _clock:Clock;
		private var _tankManager:TankManager;
		private var _powerupManager:PowerupManager;
		private var _playerListUI:List;
		
		private var _myUsername:String;
		private var _map:Map;
		
		private var _lastTimeTurretSent:Number;
		private var _shift:KeyCombo;
		private var _enter:KeyCombo;
		private var _km:KeyManager;
		
		private var _bulletManager:BulletManager;
		
		private var _lastTimeShotSent:Number;
		
		private var _viewWidth:int;
		private var _viewHeight:int;
		
		private var _mapData:EsObject;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='MainLoop')]
		private var MainLoop:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='ShootSound')]
		private var ShootSound:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='ExplodeSound')]
		private var ExplodeSound:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='CollectSound')]
		private var CollectSound:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='BadPathSound')]
		private var BadPathSound:Class;
		
		[Embed(source='../../../assets/tankGame.swf', symbol='GoodPathSound')]
		private var GoodPathSound:Class;
		
		//temporary till server gives me an id
		private var _bulletIds:int = 0;
		private var _minimap:MiniMap;
		private var _mainLoop:SoundChannel;
		
		private var _shootSound:Sound;
		private var _explodeSound:Sound;
		private var _collectSound:Sound;
		private var _goodPathSound:Sound;
		private var _badPathSound:Sound;
		private var _chat:Chat;
		
		public function TankGame() {
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_km = new KeyManager();
			stage.addChild(_km);
			
			_shift = _km.createKeyCombo(Key.SHIFT);
			_enter = _km.createKeyCombo(Key.ENTER);
			_enter.addEventListener(KeyCombo.COMBO_PRESSED, onEnterKeyPressed);
		}
		
		private function onEnterKeyPressed(e:Event):void {
			attemptSendChat();
		}
		
		private function attemptSendChat():void{
			var msg:String = _chat.input_txt.text;
			if (msg.length > 0) {
				_chat.input_txt.text = "";
				
				var pmr:PublicMessageRequest = new PublicMessageRequest();
				pmr.setMessage(msg);
				pmr.setRoomId(_room.getRoomId());
				pmr.setZoneId(_room.getZoneId());
				_es.send(pmr);
			}
		}
		
		public function initialize():void {
			var snd:Sound = new MainLoop() as Sound;
			_mainLoop = snd.play(12000, 1000, new SoundTransform(.25));
			
			_shootSound = new ShootSound() as Sound;
			_explodeSound = new ExplodeSound() as Sound;
			_collectSound = new CollectSound() as Sound;
			_badPathSound = new BadPathSound() as Sound;
			_goodPathSound = new GoodPathSound() as Sound;
			
			
			//add the player list UI
			_playerListUI = new List();
			_playerListUI.x = 490;
			_playerListUI.y = 10;
			_playerListUI.width = 640 - _playerListUI.x - 10;
			addChild(_playerListUI);
			
			addEventListener(Event.ENTER_FRAME, run);
			
			_viewWidth = 800;
			_viewHeight = 600;
			
			_lastTimeTurretSent = -1;
			_lastTimeShotSent = -1;
			
			//add some listeners
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
			_es.addEventListener(MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			
			_myUsername = _es.getUserManager().getMe().getUserName();
			
			_tankManager = new TankManager();
			
			_bulletManager = new BulletManager();
			
			_powerupManager = new PowerupManager();
			
			//join a room to play the game
			joinGame();
			
			buildMap();
			
			buildChat();
			
			addChild(new FrameRateCounter());
		}
		
		public function onPublicMessageEvent(e:PublicMessageEvent):void {
			_chat.addChatMessage(e.getUserName(), e.getMessage());
		}
		
		private function buildChat():void{
			_chat = new Chat();
			
			_chat.x = 5;
			_chat.y = 600 - 85;
			addChild(_chat);
		}
		
		private function run(e:Event):void {
			
			moveTurret();
			
			moveTanks();
			
			checkForPowerupCollection();
			
			moveBullets();
			
			_bulletManager.deadBulletCleanup();
			
			_minimap.run();
			
			moveScreen();
			
			stage.focus = _chat.input_txt;
			
		}
		
		private function checkForPowerupCollection():void{
			var tank:Tank = _tankManager.myTank;
			for (var i:int = 0; i < _powerupManager.powerups.length;++i) {
				var pw:Powerup = _powerupManager.powerups[i];
				if (pw.hitArea_mc.hitTestObject(tank.hitArea_mc)) {
					collectPowerup(pw);
					break;
				}
			}
		}
		
		private function collectPowerup(pw:Powerup):void{
			if (!pw.colleced) {
				pw.colleced = true;
				
				var esob:EsObject = new EsObject();
				esob.setString(PluginConstants.ACTION, PluginConstants.COLLECT_POWERUP);
				esob.setInteger(PluginConstants.ITEM_ID, pw.id);
				esob.setNumber(PluginConstants.TIME_STAMP, _clock.time);
				
				sendToPlugin(esob);
			}
		}
		
		private function moveBullets():void {
			for (var i:int = _bulletManager.bullets.length - 1; i >= 0; --i ) {
				var b:Bullet = _bulletManager.bullets[i];
				b.run();
				
				if (_clock.time >= b.hitTime) {
					if (b.alive) {
						_map.bulletsHolder.removeChild(b);
					}
					_bulletManager.removeBullet(b.id, false);
					
				} else {
					//bullet stil alive
					
					if (checkForTankCollision(b)) {
						if (b.alive) {
							_map.bulletsHolder.removeChild(b);
							
							
							var elapsed:Number = _clock.time-b.converger.course.time;
							var bx:Number = b.converger.course.x + b.converger.course.xspeed * elapsed;
							var by:Number = b.converger.course.y + b.converger.course.yspeed * elapsed;
							//createExplosion(new Point(bx, by));
							
							
							var transform:SoundTransform = getSpatialSoundTransform(.35, new Point(bx, by));
							if (transform.volume > 0) {
								_explodeSound.play(0, 0, transform);
							}
							showExplosion(b, _clock.time);
						}
						_bulletManager.removeBullet(b.id, false);
						
					}
				}
			}
		}
		
		private function createExplosion(point:Point):Explosion{
			var exp:Explosion = new Explosion();
			exp.x = point.x;
			exp.y = point.y;
			_map.addChild(exp);
			
			return exp;
		}
		
		private function checkForTankCollision(b:Bullet):Boolean {
			var collided:Boolean = false;
			
			var radius:Number = 20;
			var min_dis:Number = radius * radius;
			var elapsed:Number = _clock.time-b.converger.course.time;
			var bx:Number = b.converger.course.x + b.converger.course.xspeed * elapsed;
			var by:Number = b.converger.course.y + b.converger.course.yspeed * elapsed;
			for (var i:int = 0; i < _tankManager.tanks.length;++i) {
				var tank:Tank = _tankManager.tanks[i];
				
				var elapsed2:Number = _clock.time-tank.converger.course.time;
				
				var tx:Number = tank.converger.course.x + tank.converger.course.xspeed * elapsed2;
				var ty:Number = tank.converger.course.y + tank.converger.course.yspeed * elapsed2;
				var dis_squared:Number = Math.pow(tx-bx, 2) + Math.pow(ty-by, 2);
				if (dis_squared < min_dis) {
					collided = true;
					break;
				}
			}
			
			return collided;
		}
		
		private function moveScreen():void {
			
			if (_tankManager.myTank != null) {
				var endx:Number = -_tankManager.myTank.x + _viewWidth / 2;
				var endy:Number = -_tankManager.myTank.y + _viewHeight / 2;
				
				endx = Math.min(0, endx);
				endx = Math.max( -_map.mapWidtht + _viewWidth, endx);
				endy = Math.min(0, endy);
				endy = Math.max( -_map.mapHeight + _viewHeight, endy);
				
				var k:Number = .05;
				
				var xm:Number = (endx - _map.x) * k;
				var ym:Number = (endy - _map.y) * k;
				
				var tx:int = _map.x + xm;
				var ty:int = _map.y + ym;
				
				_map.x = tx;
				_map.y = ty;
			}
		}
		
		private function moveTurret():void {
			var tank:Tank = _tankManager.myTank;
			if (tank != null) {
				var angle:Number = Math.atan2(_map.mouseY - tank.y, _map.mouseX - tank.x) * 180 / Math.PI;
				tank.turretRotation = angle;
				
				if (_clock.time - _lastTimeTurretSent > 500) {
					_lastTimeTurretSent = _clock.time;
					
					var esob:EsObject = new EsObject();
					esob.setString(PluginConstants.ACTION, PluginConstants.UPDATE_TURRET_ROTATION);
					esob.setNumber(PluginConstants.ANGLE, angle);
					
					sendToPlugin(esob);
				}
			}
		}
		
		private function moveTanks():void{
			for (var i:int = 0; i < _tankManager.tanks.length;++i) {
				var t:Tank = _tankManager.tanks[i];
				t.run();
			}
		}
		
		private function buildMap():void{
			var mapOb:EsObject = _mapData;
			
			_map = new Map();
			_map.build(mapOb);
			addChild(_map);
			
			_minimap = new MiniMap();
			_minimap.y = 5;
			_minimap.x = _viewWidth - 105;
			addChild(_minimap);
			
			var bd:BitmapData = new BitmapData(_map.mapWidtht, _map.mapHeight);
			bd.draw(_map);
			_minimap.initialize(bd);
		}
		
		private function playSound(snd:Sound):void {
			snd.play();
		}
		
		/**
		 * Called when you successfully join a room
		 */
		public function onJoinRoomEvent(e:JoinRoomEvent):void {
			//store a reference to your room
			_room = e.room;
			
			//tell the plugin that you're ready
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.INIT_ME);
			
			//send to the plugin
			sendToPlugin(esob);
			
		}
		
		private function formatHeading(heading:Heading):EsObject {
			
			
			var esob:EsObject = new EsObject();
			esob.setInteger(PluginConstants.X, heading.x);
			esob.setInteger(PluginConstants.Y, heading.y);
			esob.setInteger(PluginConstants.TARGET_X, heading.targetX);
			esob.setInteger(PluginConstants.TARGET_Y, heading.targetY);
			esob.setNumber(PluginConstants.SPEED, heading.speed);
			esob.setNumber(PluginConstants.TIME_STAMP, heading.time);
			esob.setNumber(PluginConstants.ANGLE, heading.angle);
			
			return esob;
		}
		
		public function onCreateOrJoinGameResponse(e:CreateOrJoinGameResponse):void {
			if (!e.getSuccessful()) {
				trace(e.getEsError().getDescription());
			}
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
			pr.setPluginName(PluginConstants.PLUGIN_NAME);
			
			//send it
			_es.send(pr);
		}
		
		/**
		 * Called when a message is received from a plugin
		 */
		public function onPluginMessageEvent(e:PluginMessageEvent):void {
			if (e.getPluginName() == PluginConstants.PLUGIN_NAME) {
				var esob:EsObject = e.getEsObject();
				
				//get the action which determines what we do next
				var action:String = esob.getString(PluginConstants.ACTION);
				//trace(action);
				switch (action) {
					case PluginConstants.UPDATE_TURRET_ROTATION:
						handleTurretRotation(esob);
						break;
					case PluginConstants.HEADING_UPDATE:
						handleHeadingUpdate(esob);
						break;
					case PluginConstants.SHOOT:
						handleShoot(esob);
						break;
					case PluginConstants.SHOT_HIT:
						handleShotHit(esob);
						break;
					case PluginConstants.SPAWN_POWERUP:
						handleParseAndAddPowerup(esob.getEsObject(PluginConstants.POWERUP));
						break;
					case PluginConstants.HEALTH_UPDATE:
						handleHealthUpdate(esob);
						break;
					case PluginConstants.TANK_KILLED:
						handleTankKilled(esob);
						break;
					case PluginConstants.COLLECT_POWERUP:
						handleCollectPowerup(esob);
						break;
					case PluginConstants.BOARD_STATE:
						handleBoardState(esob);
						break;
					case PluginConstants.ADD_TANK:
						handleAddTank(esob);
						break;
					case PluginConstants.REMOVE_TANK:
						handleRemoveTank(esob);
						break;
					case PluginConstants.SPAWN_TANK:
						handleSpawnTank(esob);
						break;
					//The following are not needed for 'party style' play
					case PluginConstants.START_GAME:
					case PluginConstants.GAME_OVER:
					case PluginConstants.START_COUNTDOWN:
					case PluginConstants.STOP_COUNTDOWN:
						break;
					case PluginConstants.ERROR:
						handleError(esob);
						break;
					default:
						trace("Action not handled: " + action);
				}
			}
		}
		
		private function handleTankKilled(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			var tank:Tank = _tankManager.tankByName(name);
			trace(esob);
			if (tank != null) {
				tank.visible = false;
				
				var exp:Explosion = createExplosion(new Point(tank.x, tank.y));
				exp.scaleX = exp.scaleY = 1;
				
				var ds:DeathSmudge = new DeathSmudge();
				ds.x = tank.x;
				ds.y = tank.y;
				
				_map.addDeathSmudge(ds);
				
				_chat.addEventMessage(tank.playerName + " just got WASTED!");
			}
		}
		
		private function handleHealthUpdate(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			var tank:Tank = _tankManager.tankByName(name);
			if (tank != null) {
				tank.health = esob.getInteger(PluginConstants.HEALTH);
			}
		}
		
		private function handleCollectPowerup(esob:EsObject):void{
			var id:int = esob.getInteger(PluginConstants.ITEM_ID);
			var pw:Powerup = _powerupManager.powerupById(id);
			_map.removePowerup(pw);
			
			_powerupManager.removePowerup(id);
			
			var name:String = esob.getString(PluginConstants.NAME);
			var tank:Tank = _tankManager.tankByName(name);
			if (tank != null && tank.isMe) {
				_collectSound.play();
			}
		}
		
		private function handleSpawnTank(esob_outer:EsObject):void {
			var esob:EsObject = esob_outer.getEsObject(PluginConstants.NAME);
			
			var name:String = esob.getString(PluginConstants.NAME);
			var tank:Tank = _tankManager.tankByName(name);
			
			if (tank != null) {
				tank.visible = true;
				
				tank.health = esob.getInteger(PluginConstants.HEALTH);
				tank.numDeaths = esob.getInteger(PluginConstants.NUM_DEATHS);
				tank.numKills = esob.getInteger(PluginConstants.NUM_KILLS);
				
				var head_ob:EsObject = esob.getEsObject(PluginConstants.HEADING);
				
				var time:Number = head_ob.getNumber(PluginConstants.TIME_STAMP);
				var tx:int = head_ob.getInteger(PluginConstants.X);
				var ty:int = head_ob.getInteger(PluginConstants.Y);
				var sp:Number = head_ob.getNumber(PluginConstants.SPEED);
				
				var course:Heading = tank.converger.course;
				var view:Heading = tank.converger.view;
				
				course.x = tx;
				course.y = ty;
				course.speed = 0;
				course.angle = 0;
				course.time = time;
				course.targetX = tx;
				course.targetY = ty;
				course.targetTime = time;
				
				view.x = course.x;
				view.y = course.y;
				view.angle = course.angle;
			}
		}
		
		private function handleShotHit(esob:EsObject):void{
			var time:Number = esob.getNumber(PluginConstants.TIME_STAMP);
			var id:int = esob.getInteger(PluginConstants.ITEM_ID);
			var hitType:String = esob.getString(PluginConstants.HIT_TYPE);
			
			var b:Bullet = _bulletManager.bulletById(id);
			
			if (b != null) {
				var wasAlive:Boolean = b.alive;
				if (b.alive) {
					_map.bulletsHolder.removeChild(b);
				}
				_bulletManager.removeBullet(b.id, true);
				
				
				
				switch (hitType) {
					case PluginConstants.COLLISION_TANK:
						var health:int = esob.getInteger(PluginConstants.HEALTH);
						var name:String = esob.getString(PluginConstants.NAME);
						var tank:Tank = _tankManager.tankByName(name);
						tank.health = health;
						_tankManager.tankByName(name).health = health;
						
						
						if (wasAlive) {
							var transform:SoundTransform = getSpatialSoundTransform(.35, new Point(tank.x, tank.y));
							if (transform.volume > 0) {
								_explodeSound.play(0, 0, transform);
							}
							showExplosion(b, time);
						}
						break;
				}
			}
		}
		
		private function showExplosion(b:Bullet, time:Number):void{
			
			var course:Heading = b.converger.course;
			
			var tx:int = course.x + course.xspeed * (time-course.time);
			var ty:int = course.y + course.yspeed * (time-course.time);
			
			
			createExplosion(new Point(tx, ty));
		}
		
		private function handleShoot(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			var id:int = esob.getInteger(PluginConstants.ITEM_ID);
			var ob:EsObject = esob.getEsObject(PluginConstants.HEADING);
			
			parseAndApplyBulletHeading(name, ob, id);
			
		}
		
		private function handleTurretRotation(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			var angle:Number = esob.getNumber(PluginConstants.ANGLE);
			
			if (name == _myUsername) {
				//name = "my_mirror";
			}
			
			var tank:Tank = _tankManager.tankByName(name);
			if (tank != null && !tank.isMe) {
				tank.turretRotation = angle;
			}
			
			
		}
		
		private function handleHeadingUpdate(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			var ob:EsObject = esob.getEsObject(PluginConstants.HEADING);
			
			parseAndApplyHeading(name, ob);
		}
		
		private function parseAndApplyHeading(name:String, ob:EsObject, first:Boolean=false):void {
			if (name == _myUsername) {
				//name = "my_mirror";
			}
			
			var x:int = ob.getInteger(PluginConstants.X);
			var y:int = ob.getInteger(PluginConstants.Y);
			var targetx:int = ob.getInteger(PluginConstants.TARGET_X);
			var targety:int = ob.getInteger(PluginConstants.TARGET_Y);
			var time:Number = ob.getNumber(PluginConstants.TIME_STAMP);
			var speed:Number = ob.getNumber(PluginConstants.SPEED);
			
			var angle:Number = Math.atan2(targety - y, targetx - x) * 180 / Math.PI;
			var dis:Number = Math.sqrt(Math.pow(targety - y, 2) + Math.pow(targetx - x, 2));
			var targetTime:Number = time + dis / speed;
			
			var heading:Heading = new Heading();
			heading.time = time;
			heading.x = x;
			heading.y = y;
			heading.targetX = targetx;
			heading.targetY = targety;
			heading.speed = speed;
			heading.angle = angle;
			heading.targetTime = targetTime;
			
			var tank:Tank = _tankManager.tankByName(name);
			
			if (first) {
				tank.converger.course.x = heading.x + heading.xspeed * (_clock.time-heading.time);
				tank.converger.course.y = heading.y + heading.yspeed * (_clock.time-heading.time);
			}
			if (!tank.isMe) {
				tank.converger.intercept(heading);
			}
		}
		
		private function correctMyHeading(esob:EsObject):void {
			
			
			var tank:Tank = _tankManager.myTank;
			
			var x:int = esob.getInteger(PluginConstants.X);
			var y:int = esob.getInteger(PluginConstants.Y);
			var targetx:int = esob.getInteger(PluginConstants.TARGET_X);
			var targety:int = esob.getInteger(PluginConstants.TARGET_Y);
			var time:Number = esob.getNumber(PluginConstants.TIME_STAMP);
			var speed:Number = esob.getNumber(PluginConstants.SPEED);
			
			moveMyTank(x, y, targetx, targety, time, speed);
		}
		
		private function parseAndApplyBulletHeading(name:String, ob:EsObject, id:int, first:Boolean = false):void {
			if (name == _myUsername) {
				//name = "my_mirror";
			}
			
			var tm:int = getTimer();
			
			var x:int = ob.getInteger(PluginConstants.X);
			var y:int = ob.getInteger(PluginConstants.Y);
			var time:Number = ob.getNumber(PluginConstants.TIME_STAMP);
			var speed:Number = ob.getNumber(PluginConstants.SPEED);
			var angle:Number = ob.getNumber(PluginConstants.ANGLE);
			
			var heading:Heading = new Heading();
			heading.time = time;
			heading.x = x;
			heading.y = y;
			heading.speed = speed;
			heading.angle = angle;
			
			
			var tank:Tank = _tankManager.tankByName(name);
			tank.turretRotation = angle;
			tank.turret_mc.rotation = angle;
			
			tank.shot();
			
			var nose:Number = 30;
			
			var bullet:Bullet = new Bullet();
			bullet.converger.clock = _clock;
			bullet.id = id;
			
			var course:Heading = bullet.converger.course;
			course.x = tank.converger.view.x + nose * Math.cos(angle * Math.PI / 180);
			course.y = tank.converger.view.y + nose * Math.sin(angle * Math.PI / 180);
			
			bullet.converger.intercept(heading);
			
			addBullet(bullet);
			
			//find when it should die
			var life:Number = 3000;
			var endx:Number = course.x + course.xspeed * life;
			var endy:Number = course.y + course.yspeed * life;
			
			var point:Point = _map.getCollisionPoint(new Point(course.x, course.y), new Point(endx, endy));
			if (point) {
				var dis:Number = Math.sqrt(Math.pow(point.y - course.y, 2) + Math.pow(point.x - course.x, 2));
				life = dis / course.speed;
				bullet.hitX = point.x;
				bullet.hitY = point.y;
			}
			bullet.hitTime = course.time + life;
			
			
			
			var transform:SoundTransform = getSpatialSoundTransform(.35, new Point(course.x, course.y));
			if (transform.volume > 0) {
				_shootSound.play(0, 0, transform);
			}
		}
		
		private function getSpatialSoundTransform(maxVolume:Number, point2:Point):SoundTransform {
			//center of screen
			var point1:Point = new Point( -_map.x + _viewWidth / 2, -_map.y + _viewHeight / 2);
			
			var volDis:Number = Math.sqrt(Math.pow(point1.y - point2.y, 2) + Math.pow(point1.x - point2.x, 2));
			var maxVolDis:Number = 400;
			var volumeMultiplier:Number = 1 - Math.min(Math.max(volDis - 200, 0) / maxVolDis, 1);
			
			var maxPanDis:Number = 400;
			var panMultiplier:Number = (point2.x - point1.x) / maxPanDis;
			panMultiplier = Math.max( -1, panMultiplier);
			panMultiplier = Math.min(1, panMultiplier);
			
			return new SoundTransform(maxVolume * volumeMultiplier, panMultiplier);
		}
		
		private function mouseMoved(e:MouseEvent):void {
		}
		
		private function mouseDown(e:MouseEvent):void {
			if (_tankManager.myTank) {
				if (_shift.getComboActivated()) {
					sendNewWayPoint();
				} else {
					if (_clock.time - _lastTimeShotSent > 600) {
						sendNewShot();
					}
				}
			}
		}
		
		private function sendNewShot():void {
			_lastTimeShotSent = _clock.time;
			
			var x:int = _tankManager.myTank.converger.view.x;
			var y:int = _tankManager.myTank.converger.view.y;
			var nose:int = 30;
			var angle:Number = _tankManager.myTank.turretRotation;
			
			x = x + nose * Math.cos(angle * Math.PI / 180);
			y = y + nose * Math.sin(angle * Math.PI / 180);
			
			
			var bullet:Bullet = new Bullet();
			bullet.converger.clock = _clock;
			
			var course:Heading = bullet.converger.course;
			course.x = x;
			course.y = y;
			course.angle = angle;
			course.speed = .24;
			course.time = _clock.time;
			
			//bullet.run();
			
			//addBullet(bullet);
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.SHOOT);
			esob.setEsObject(PluginConstants.HEADING, formatHeading(course));
			
			sendToPlugin(esob);
			
		}
		
		private function addBullet(bullet:Bullet):void{
			_map.bulletsHolder.addChild(bullet);
			_bulletManager.addBullet(bullet);
		}
		
		private function refreshTankList():void {
			var dp:DataProvider = new DataProvider();
			
			for (var i:int = 0; i < _tankManager.tanks.length;++i) {
				var p:Tank = _tankManager.tanks[i];
				dp.addItem( { label:p.name + ", score: " + p.score.toString(), data:p } );
			}
			
			_playerListUI.dataProvider = dp;
		}
		
		
		private function handleBoardState(esob:EsObject):void{
			handleTankList(esob.getEsObjectArray(PluginConstants.TANK_LIST));
			
			handlePowerupList(esob.getEsObjectArray(PluginConstants.POWERUP_LIST));
		}
		
		private function handlePowerupList(powerups:Array):void{
			for (var i:int = 0; i < powerups.length;++i) {
				var power_ob:EsObject = powerups[i];
				handleParseAndAddPowerup(power_ob);
			}
		}
		
		private function handleParseAndAddPowerup(esob:EsObject):void{
			var id:int = esob.getInteger(PluginConstants.ITEM_ID);
			var type:String = esob.getString(PluginConstants.POWERUP_TYPE);
			var x:int = esob.getInteger(PluginConstants.X);
			var y:int = esob.getInteger(PluginConstants.Y);
			
			var pw:Powerup = new Powerup();
			pw.type = type;
			pw.x = x;
			pw.y = y;
			pw.id = id;
			_powerupManager.addPowerup(pw);
			
			_map.addPowerup(pw);
		}
		
		
		/**
		 * Parse the player list
		 */
		private function handleTankList(tanks:Array):void {
			for (var i:int = 0; i < tanks.length;++i) {
				var tank_esob:EsObject = tanks[i];
				var tank:Tank = parseAndAddNewTank(tank_esob);
				
			}
			refreshTankList();
			
			
		}
		
		private function parseAndAddNewTank(tank_esob:EsObject):Tank {
			var tank:Tank = new Tank();
			tank.converger.clock = _clock;
			tank.playerName = tank_esob.getString(PluginConstants.NAME);
			if (tank_esob.doesPropertyExist(PluginConstants.SCORE)) {
				tank.score = tank_esob.getInteger(PluginConstants.SCORE);
			}
			tank.isMe = tank.playerName == _myUsername;
			
			
			_tankManager.addTank(tank);
			
			if (tank_esob.doesPropertyExist(PluginConstants.HEADING)) {
				var heading_ob:EsObject = tank_esob.getEsObject(PluginConstants.HEADING);
				parseAndApplyHeading(tank.playerName, heading_ob, true);
			} else {
				
				tank.converger.course.x = 100;
				tank.converger.course.y = 300;
				
			}

			tank.run();
			
			_map.tanksHolder.addChild(tank);
			
			
			_minimap.addTank(tank);
			
			return tank;
		}
		
		private function sendNewWayPoint():void {
			var course:Heading = _tankManager.myTank.converger.course;
			var view:Heading = _tankManager.myTank.converger.view;
			
			//where the tank is now
			var sx:int = view.x;
			var sy:int = view.y;
			
			//where the tank wants to go
			var tx:int = _map.mouseX;
			var ty:int = _map.mouseY;
			
			//check for path validity
			if (_map.validatePath(new Point(sx, sy), new Point(tx, ty))) {
				_goodPathSound.play();
				
				var speed:Number = .06;
				
				moveMyTank(sx, sy, tx, ty, _clock.time, speed);
				
				
				var esob:EsObject = new EsObject();
				esob.setString(PluginConstants.ACTION, PluginConstants.HEADING_UPDATE);
				esob.setEsObject(PluginConstants.HEADING, formatHeading(course));
				sendToPlugin(esob);
			} else {
				_badPathSound.play(0, 0, new SoundTransform(.5));
			}
			
		}
		
		private function moveMyTank(sx:int, sy:int, tx:int, ty:int, time:Number, speed:Number):void {
			var course:Heading = _tankManager.myTank.converger.course;
			
			course.time = _clock.time;
			course.x = sx;
			course.y = sy;
			course.speed = speed;
			course.targetX = tx;
			course.targetY = ty;
			course.angle = Math.atan2(course.targetY - course.y, course.targetX - course.x) * 180 / Math.PI;
			
			var dis:Number = Math.sqrt(Math.pow(course.targetY - course.y, 2) + Math.pow(course.targetX - course.x, 2));
			
			course.targetTime = course.time + dis / course.speed;
			
			_map.target.x = course.targetX;
			_map.target.y = course.targetY;
		}
		
		/**
		 * Remove a player
		 */
		private function handleRemoveTank(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.NAME);
			
			var tank:Tank = _tankManager.tankByName(name);
			if (tank != null) {
				_tankManager.removeTank(name);
				_map.tanksHolder.removeChild(tank);
				_minimap.removeTank(tank);
			}
			refreshTankList();
			
			_chat.addEventMessage("Cowardly "+tank.playerName + " just left.");
		}
		
		/**
		 * Add a player
		 */
		private function handleAddTank(esob:EsObject):void {
			var tank:Tank = parseAndAddNewTank(esob.getEsObject(PluginConstants.ADD_TANK));
			
			refreshTankList();
			
			_chat.addEventMessage(tank.playerName + " just joined!");
		}
		
		/**
		 * Called when the server tells the client something went wrong
		 */
		private function handleError(esob:EsObject):void{
			var error:String = esob.getString(PluginConstants.ERROR);
			switch (error) {
				case PluginConstants.INVALID_HEADING_UPDATE:
					correctMyHeading(esob.getEsObject(PluginConstants.HEADING));
					break;
				default:
					trace("Error not handled: " + error);
			}
		}
		
		/**
		 * Create a room with the DigGamePlugin plugin
		 */
		private function joinGame():void {
			
			var qjr:QuickJoinGameRequest = new QuickJoinGameRequest();
			qjr.setGameType(PluginConstants.PLUGIN_NAME);
			qjr.setZoneName("GameZone");
			
			var esob:EsObject = new EsObject();
			esob.setEsObject(PluginConstants.MAP, _mapData);
			
			qjr.setGameDetails(esob);
			_es.send(qjr);
		}
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
		public function set clock(value:Clock):void {
			_clock = value;
		}
		
		public function set mapData(value:EsObject):void {
			_mapData = value;
		}
		
	}
	
}