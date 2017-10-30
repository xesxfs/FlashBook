package com.gamebook.syncexample {
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.event.PublicMessageEvent;
	import com.electrotank.electroserver4.message.event.UserListUpdateEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.PublicMessageRequest;
	import com.electrotank.electroserver4.room.Room;
	import com.gamebook.syncexample.guy.Guy;
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import com.gamebook.utils.network.clock.Clock;
	import com.gamebook.utils.network.movement.Heading;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ArrowKeyExample extends MovieClip {
		
		private var _es:ElectroServer;
		private var _clock:Clock;
		private var _room:Room;
		
		private var _guys:Array;
		private var _guysByName:Dictionary;
		
		private var _lastTimeSent:Number;
		
		private var _myGuy:Guy;
		private var _okToSend:Boolean;
		
		private var _keyManager:KeyManager;
		private var _left:KeyCombo;
		private var _right:KeyCombo;
		private var _up:KeyCombo;
		private var _down:KeyCombo;
		
		
		public function ArrowKeyExample() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		}
		
		private function onAddedToStage(e:Event):void {
			
			_keyManager = new KeyManager();
			stage.addChild(_keyManager);

			_left = _keyManager.createKeyCombo(Key.LEFT);
			_right = _keyManager.createKeyCombo(Key.RIGHT);
			_up = _keyManager.createKeyCombo(Key.UP);
			_down = _keyManager.createKeyCombo(Key.DOWN);
		}
		
		
		public function initialize():void {
			
			_okToSend = false;
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.addEventListener(MessageType.UserListUpdateEvent, "onUserListUpdateEvent", this);
			
			var crr:CreateRoomRequest = new CreateRoomRequest();
			crr.setRoomName("Guy");
			crr.setZoneName("Guy");
			_es.send(crr);
			
			_guys = [];
			_guysByName = new Dictionary();
			
			_lastTimeSent = -1;
			
			
			
			
		}
		
		private function enterFrame(e:Event):void {
			checkKeys();
			
			//updateHeading();
			
			moveGuys();
			
			if (_clock.time - _lastTimeSent > 250) {
				sendUpdate();
			}
			
			
		}
		
		private function checkKeys():void{
			var xdir:int = _left.getComboActivated() ? -1 : ( _right.getComboActivated() ? 1 : 0);
			var ydir:int = _up.getComboActivated() ? -1 : ( _down.getComboActivated() ? 1 : 0);
			
			moveGuy(xdir, ydir);
		}
		
		
		private function moveGuy(xdir:int = 0, ydir:int = 0):void {
			
			//if i'm in a room and my guy isn't accelating
			if (_okToSend && !_myGuy.converger.course.isAccelerating) {
				
				//if the key input is directing my guy in a new direction
				if (xdir != _myGuy.lastXDir || ydir != _myGuy.lastYDir) {
					_myGuy.lastXDir = xdir;
					_myGuy.lastYDir = ydir;
					
					var ang_rad:Number = Math.atan2(ydir, xdir);
					var ang:Number = ang_rad * 180 / Math.PI;
					var sp:Number = .07;
					
					//run this to update the view because we may copy some info out of it below
					_myGuy.run();
					
					//the true course of the guy
					var course:Heading = _myGuy.converger.course;
					
					if (xdir == 0 && ydir == 0) {
						//if there is no key input
						
						if (course.speed > 0) {
							//if you are actually moving, then decelerate
							course.endSpeed = 0;
							course.accelTime = 500;
							course.time = _clock.time;
							course.x = _myGuy.converger.view.x;
							course.y = _myGuy.converger.view.y;
							
							sendUpdate();
						}
						
					} else {
						
						if (course.speed == 0) {
							//if you are not already moving, then accelerate
							course.angle = ang;
							course.endSpeed = sp;
							course.accelTime = 350;
							course.time = _clock.time;
							
							sendUpdate();
						} else {
							//if you are already moving, then just update the heading
							course.angle = ang;
							course.speed = sp;
							course.x = _myGuy.x;
							course.y = _myGuy.y;
							course.time = _clock.time;
						}
					}
				}
			}
		}
		
		private function moveGuys():void{
			for (var i:int = 0; i < _guys.length;++i) {
				var guy:Guy = _guys[i];
				guy.run();
			}
		}
		
		private function updateHeading():void {
			if (_myGuy != null && _okToSend && !_myGuy.converger.course.isAccelerating) {
				var ang_rad:Number = Math.atan2(mouseY - _myGuy.y, mouseX - _myGuy.x);
				var ang:Number = ang_rad * 180 / Math.PI;
				var sp:Number = .09;
				
				_myGuy.run();
				var course:Heading = _myGuy.converger.course;
				course.angle = ang;
				//course.speed = sp;
				course.x = _myGuy.x;
				course.y = _myGuy.y;
				course.time = _clock.time;
			}
			
		}
		
		private function sendUpdate():void{
			if (_okToSend && _myGuy.converger.course.time > _lastTimeSent && (_myGuy.converger.course.isAccelerating || _myGuy.converger.course.speed > 0)) {
				_lastTimeSent = _myGuy.converger.course.time;
				
				
				var esob:EsObject = new EsObject();
				esob.setString(PluginConstants.ACTION, PluginConstants.UPDATE_HEADING);
				
				var heading:EsObject = formatHeading(_myGuy.converger.course);
				
				esob.setEsObject(PluginConstants.HEADING, heading);
				
				var pmr:PublicMessageRequest = new PublicMessageRequest();
				pmr.setEsObject(esob);
				pmr.setMessage("");
				pmr.setRoomId(_room.getRoomId());
				pmr.setZoneId(_room.getZoneId());
				
				_es.send(pmr);
			}
		}
		
		private function formatHeading(heading:Heading):EsObject{
			var esob:EsObject = new EsObject();
			
			esob.setNumber(PluginConstants.X, heading.x);
			esob.setNumber(PluginConstants.Y, heading.y);
			esob.setNumber(PluginConstants.SPEED, heading.speed);
			esob.setNumber(PluginConstants.ANGLE, heading.angle);
			esob.setNumber(PluginConstants.TIME, heading.time);
			esob.setNumber(PluginConstants.ACCEL_TIME, heading.accelTime);
			esob.setNumber(PluginConstants.END_SPEED, heading.endSpeed);
			esob.setString(PluginConstants.NAME, _myGuy.playerName);
			
			return esob;
		}
		
		public function onPublicMessageEvent(e:PublicMessageEvent):void {
			var esob:EsObject = e.getEsObject();
			var action:String = esob.getString(PluginConstants.ACTION);
			switch (action) {
				case PluginConstants.UPDATE_HEADING:
					handleUpdateHeading(esob);
					break;
			}
		}
		
		private function handleUpdateHeading(esob:EsObject):void{
			var ob:EsObject = esob.getEsObject(PluginConstants.HEADING);
			var name:String = ob.getString(PluginConstants.NAME);
			var x:Number = ob.getNumber(PluginConstants.X);
			var y:Number = ob.getNumber(PluginConstants.Y);
			var angle:Number = ob.getNumber(PluginConstants.ANGLE);
			var time:Number = ob.getNumber(PluginConstants.TIME);
			var speed:Number = ob.getNumber(PluginConstants.SPEED);
			var accelTime:Number = ob.getNumber(PluginConstants.ACCEL_TIME);
			var endSpeed:Number = ob.getNumber(PluginConstants.END_SPEED);
			
			if (name == _myGuy.playerName) {
				name = "my_mirror";
			}
			//_myGuy.alpha = 0;
			
			var guy:Guy = _guysByName[name];
			if (guy == null) {
				guy = new Guy();
				guy.playerName = name;
				guy.converger.course.x = x;
				guy.converger.course.y = y;
				addGuy(guy);
				
				if (guy.playerName == "my_mirror") {
					guy.alpha = .5;
					
				}
			}
			
			if (!guy.isMe) {
			
				var path:Heading = new Heading();
				path.x = x;
				path.y = y;
				path.speed = speed;
				path.time = time;
				path.angle = angle;
				path.accelTime = accelTime;
				path.endSpeed = endSpeed;
				
				guy.converger.debug = true;
				guy.converger.intercept(path);
			}
			
		}
		
		/**
		 * In this particular example, only use the user list event to remove Guys
		 */
		public function onUserListUpdateEvent(e:UserListUpdateEvent):void {
			if (e.getActionId() == UserListUpdateEvent.DeleteUser) {
				var guy:Guy = _guysByName[e.getUserName()];
				
				if (guy != null) {
					removeChild(guy);
					
					_guysByName[guy.playerName] = null;
					for (var i:int = 0; i < _guys.length;++i) {
						if (_guys[i] == guy) {
							_guys.splice(i, 1);
							break;
						}
					}
				}
			}
		}
		
		public function onJoinRoomEvent(e:JoinRoomEvent):void {
			_room = e.room;
			
			_okToSend = true;
			
			var guy:Guy = new Guy();
			guy.playerName = _es.getUserManager().getMe().getUserName();
			
			_myGuy = guy;
			_myGuy.converger.course.x = 100;
			_myGuy.converger.course.y = 200;
			_myGuy.converger.course.speed = 0;
			
			//_myGuy.converger.debug = true;
			
			addGuy(guy);
			
			
			
		}
		
		private function addGuy(guy:Guy):void {
			_guys.push(guy);
			_guysByName[guy.playerName] = guy;
			
			guy.converger.clock = _clock;
			
			guy.isMe = guy.playerName == _es.getUserManager().getMe().getUserName();
			
			guy.run();
			
			addChild(guy);
		}
		
		public function set clock(value:Clock):void {
			_clock = value;
		}
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
	}
	
}