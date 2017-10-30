package com.gamebook.world {
	
	//Flash imports
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.event.BuddyStatusUpdatedEvent;
	import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
	import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	import com.electrotank.electroserver4.message.request.PluginRequest;
	import com.electrotank.electroserver4.message.response.GenericErrorResponse;
	import com.gamebook.utils.network.clock.Clock;
	import com.gamebook.world.avatar.Avatar;
	import com.gamebook.world.avatar.AvatarManager;
	import com.gamebook.world.clothing.Clothing;
	import com.gamebook.world.clothing.ClothingManager;
	import com.gamebook.world.furniture.FurnitureDefinition;
	import com.gamebook.world.furniture.FurnitureManager;
	import com.gamebook.world.screens.AvatarCustomizationScreen;
	import com.gamebook.world.screens.IntroScreen;
	import com.gamebook.world.screens.Popup;
	import com.gamebook.world.screens.RegistrationScreen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	
	/**
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class GameFlow extends Sprite {
		
		private var GUEST:String = "guest";
		private var AVATAR:String = "avatar";
		
		//ElectroServer class instance
		private var _es:ElectroServer;
		
		private var _clothingManager:ClothingManager = new ClothingManager();
		private var _furnitureManager:FurnitureManager = new FurnitureManager();
		private var _serverInfoLoader:URLLoader;
		private var _ip:String;
		private var _port:Number;
		private var _introScreen:IntroScreen;
		private var _loginType:String;
		private var _registrationScreen:RegistrationScreen;
		private var _myAvatar:Avatar;
		private var _avatarCustomizationScreen:AvatarCustomizationScreen;
		private var _isRegistering:Boolean = false;
		private var _world:World;
		private var _clock:Clock;
		private var _buddyList:AvatarManager;
        private var _lastDestination:String;
		
		public function GameFlow():void {
			initialize();
		}
		
		private function initialize():void {
			//load the server connection settings
			var loader:URLLoader = new URLLoader(new URLRequest("server.xml"));
			loader.addEventListener(Event.COMPLETE, onServerInfoLoaded);
			_serverInfoLoader = loader;
			
			
			_buddyList = new AvatarManager();
		}
		
		/**
		 * Called when the file loads
		 */
		private function onServerInfoLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var server:XML = new XML(loader.data);
			
			//grab the ip and port from the XML
			_ip = server.connection.@ip;
			_port = Number(server.connection.@port);
			
			//connect to ElectroServer
			cleanAndConnect();
		}

		private function cleanAndConnect():void {
			cleanElectroServer();
			
			//create new ElectroServer instance for use in communicating with the server
			_es = new ElectroServer();
			
			//add listeners
			_es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
			_es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
			_es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
			_es.addEventListener(MessageType.GenericErrorResponse, "onGenericErrorResponse", this);
			_es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosedEvent", this);
			_es.addEventListener(MessageType.BuddyStatusUpdatedEvent, "onBuddyStatusUpdatedEvent", this);
			
			//set the message protocol to binary
			_es.setProtocol(Protocol.BINARY);
			
			//set the connection information
			_es.createConnection(_ip, _port);
			
		}
		
		public function onBuddyStatusUpdatedEvent(e:BuddyStatusUpdatedEvent):void {
			var name:String = e.getUserName();
			var isOnline:Boolean = e.getActionId() == BuddyStatusUpdatedEvent.LoggedIn;
			
			if (_buddyList.avatarByName(name) != null) {
				_buddyList.avatarByName(name).isOnline = isOnline;
			}
		}
		
		public function onConnectionClosedEvent(e:ConnectionClosedEvent):void {
			showPopup("Connection lost");
		}
		
		private function cleanElectroServer():void{
			if (_es != null) {
				_es.removeEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
				_es.removeEventListener(MessageType.LoginResponse, "onLoginResponse", this);
				_es.removeEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
				_es.removeEventListener(MessageType.GenericErrorResponse, "onGenericErrorResponse", this);
				_es.removeEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosedEvent", this);
				_es.removeEventListener(MessageType.BuddyStatusUpdatedEvent, "onBuddyStatusUpdatedEvent", this);
				_es.close();
				_es = null;
			}
		}
		
		public function onGenericErrorResponse(e:GenericErrorResponse):void {
			trace(e.getErrorType().getDescription());
		}
		
		public function onPluginMessageEvent(e:PluginMessageEvent):void {
			if (e.getPluginName() == "WorldPlugin") {
				if (_isRegistering) {
					_isRegistering = false;
					
					if (e.getEsObject().getString(PluginConstants.RESPONSE) == PluginConstants.SUCCESS) {
						showPopup("Successfully created!");
						
						_registrationScreen.removeEventListener(RegistrationScreen.CREATE_AVATAR, onCreateAvatar);
						removeChild(_registrationScreen);
						_registrationScreen = null;
						
						cleanAndConnect();
					} else {
						showPopup("Error registering. Name already in use.");
					}
					
					
				} else {
					var esob:EsObject = e.getEsObject();
					var action:String = esob.getString(PluginConstants.ACTION);
					switch (action) {
						case PluginConstants.LOAD_BUDDIES:
							handleLoadBuddies(esob);
							break;
					}
				}
				
			}
			
		}
		
		private function handleLoadBuddies(esob:EsObject):void{
			var list:Array = esob.getEsObjectArray(PluginConstants.BUDDY_LIST);
			for each (var buddyOb:EsObject in list) {
				var avatar:Avatar = new Avatar();
				avatar.avatarName = buddyOb.getString(PluginConstants.BUDDY_NAME);
				avatar.avatarId = buddyOb.getInteger(PluginConstants.BUDDY_ID);
				avatar.isOnline = buddyOb.getBoolean(PluginConstants.LOGGED_IN);
				
				_buddyList.addAvatar(avatar);
			}
		}
		
		
		/**
		 * Event handler used to capture a login response
		 */
		public function onLoginResponse(e:LoginResponse):void {
			if (e.getAccepted()) {
				
				var esob:EsObject = e.getEsObject();

				removeIntroScreen();
				
				switch (_loginType) {
					case GUEST:
						createRegistrationScreen();
						break;
					case AVATAR:
						syncClocks();
					
						parseClothing(esob.getEsObjectArray(PluginConstants.AVATAR_CLOTHING));
						parseFurnitureItems(esob.getEsObjectArray(PluginConstants.FURNITURE));
						_myAvatar = parseAvatar(esob.getEsObject(PluginConstants.AVATAR));
						
						loadBuddies();
						
						createAvatarCustomizationScreen();
						
						break;
				}
				
			} else {
				trace("Login failed. Reason: " + e.getEsError().getDescription());
				showPopup("Login failed");
				removeIntroScreen();
				cleanAndConnect();
			}
		}
		
		
		private function loadBuddies():void {
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.LOAD_BUDDIES);
			
			sendToWorldPlugin(esob);
		}
		
		private function sendToWorldPlugin(esob:EsObject):void {
			var pr:PluginRequest = new PluginRequest();
			pr.setPluginName("WorldPlugin");
			pr.setEsObject(esob);
			
			_es.send(pr);
		}
		
		private function syncClocks():void{
			_clock = new Clock(_es, "TimeStampPlugin");
			_clock.start();
			
			_clock.addEventListener(Clock.CLOCK_READY, onClockReady);
		}
		
		private function onClockReady(e:Event):void {
			_avatarCustomizationScreen.enableEnterWorldButton();
		}
		
		private function removeIntroScreen():void {
			if (_introScreen != null) {
				_introScreen.removeEventListener(IntroScreen.LOGIN_AVATAR, onLoginAvatar);
				_introScreen.removeEventListener(IntroScreen.LOGIN_GUEST, onLoginGuest);
				_introScreen.destroy();;
				removeChild(_introScreen);
				_introScreen = null;
			}
		}
		
		private function createAvatarCustomizationScreen():void{
			_avatarCustomizationScreen = new AvatarCustomizationScreen(_myAvatar);
			_avatarCustomizationScreen.addEventListener(AvatarCustomizationScreen.ENTER_WORLD, onEnterWorldClicked);
			_avatarCustomizationScreen.es = _es;
			addChild(_avatarCustomizationScreen);
		}
		
		private function onEnterWorldClicked(e:Event):void {
			removeAvatarCustomizationScreen();
            _lastDestination = "data/inn.xml";
			createWorld(_lastDestination);
		}
		
		private function createWorld(url:String, home:Boolean=false, owner:String=null):void{
			_world = new World();
			_world.addEventListener(World.TELEPORT, onTeleport);
			_world.addEventListener(World.GO_TO_HOME, onGoToHome);
            _world.addEventListener(World.BACK_TO_WORLD, onBackToWorld);
			_world.es = _es;
			_world.clock = _clock;
			_world.clothingManager = _clothingManager;
			_world.furnitureManager = _furnitureManager;
			_world.buddyList = _buddyList;
			_world.initialize(url, home, owner);
			
			addChild(_world);
		}
        
        private function onBackToWorld(e:Event):void {
            removeWorld();
            createWorld(_lastDestination);
        }
		
		private function onGoToHome(e:Event):void {
			var destination:String = _world.destination;
			var owner:String = _world.owner;
			removeWorld();
			createWorld(destination, true, owner);
		}
		
		private function onTeleport(e:Event):void {
			_lastDestination = _world.destination;
            removeWorld();
			createWorld(_lastDestination);
		}
		
		private function removeWorld():void {
			_world.removeEventListener(World.TELEPORT, onTeleport);
			_world.removeEventListener(World.GO_TO_HOME, onGoToHome);
			_world.destroy();
			removeChild(_world);
			_world = null;
		}
		
		private function removeAvatarCustomizationScreen():void {
			if (_avatarCustomizationScreen != null) {
				_avatarCustomizationScreen.removeEventListener(AvatarCustomizationScreen.ENTER_WORLD, onEnterWorldClicked);
				removeChild(_avatarCustomizationScreen);
				_avatarCustomizationScreen = null;
			}
		}
		
		private function createRegistrationScreen():void{
			_registrationScreen = new RegistrationScreen();
			_registrationScreen.addEventListener(RegistrationScreen.CREATE_AVATAR, onCreateAvatar);
			addChild(_registrationScreen);
		}
		
		public function showPopup(msg:String):void {
			var popup:Popup = new Popup(msg);
			popup.addEventListener(Popup.OK, onPopupOk);
			popup.x = 300;
			popup.y = 150;
			addChild(popup);
		}
		
		private function onPopupOk(e:Event):void {
			var popup:Popup = e.target as Popup;
			popup.removeEventListener(Popup.OK, onPopupOk);
			removeChild(popup);
		}
		
		private function onCreateAvatar(e:Event):void {
			
			var pr:PluginRequest = new PluginRequest();
			pr.setPluginName("WorldPlugin");
			
			
			var esob:EsObject = new EsObject();
			
			esob.setString(PluginConstants.ACTION, PluginConstants.CREATE_AVATAR);
			
			esob.setString(PluginConstants.AVATAR_NAME, _registrationScreen.name_txt.text);
			esob.setString(PluginConstants.AVATAR_PASSWORD, _registrationScreen.password_txt.text);
			esob.setInteger(PluginConstants.HAIR, _registrationScreen.hairTypeId);
			esob.setString(PluginConstants.GENDER, _registrationScreen.gender);
			
			
			pr.setEsObject(esob);
			
			_es.send(pr);
			
			_isRegistering = true;
		}
		
		private function parseFurnitureItems(items:Array):void{
			for (var i:int = 0; i < items.length;++i) {
				var furni:FurnitureDefinition = new FurnitureDefinition();
				
				var furniOb:EsObject = items[i];
				furni.name = furniOb.getString(PluginConstants.FURNITURE_NAME);
				furni.fileName = furniOb.getString(PluginConstants.FURNITURE_FILE_NAME);
				furni.id = furniOb.getInteger(PluginConstants.FURNITURE_ID);
				furni.cost = furniOb.getInteger(PluginConstants.FURNITURE_COST);
				
				_furnitureManager.addFurnitureDefinition(furni);
			}
		}
		
		private function parseClothing(list:Array):void{
			
			for (var i:int = 0; i < list.length;++i) {
				var clothing:Clothing = new Clothing();
				
				var clothingOb:EsObject = list[i];
				clothing.name = clothingOb.getString(PluginConstants.CLOTHING_NAME);
				clothing.fileName = clothingOb.getString(PluginConstants.CLOTHING_FILE_NAME);
				clothing.id = clothingOb.getInteger(PluginConstants.CLOTHING_ID);
				clothing.cost = clothingOb.getInteger(PluginConstants.CLOTHING_COST);
				clothing.clothingTypeId = clothingOb.getInteger(PluginConstants.CLOTHING_TYPE_ID);
				
				_clothingManager.addClothing(clothing);
				
			}
			
		}
		
		public function parseAvatar(esob:EsObject):Avatar {
			var avatar:Avatar = new Avatar();
			
			avatar.avatarName = esob.getString(PluginConstants.AVATAR_NAME);
			avatar.gender = esob.getString(PluginConstants.GENDER);
			avatar.money = esob.getInteger(PluginConstants.MONEY);
			avatar.avatarId = esob.getInteger(PluginConstants.AVATAR_ID);
			
			//what it is wearing
			var topId:int = esob.getInteger(PluginConstants.TOP);
			var bottomId:int = esob.getInteger(PluginConstants.BOTTOM);
			var hairId:int = esob.getInteger(PluginConstants.HAIR);
			var shoesId:int = esob.getInteger(PluginConstants.SHOES);
			
			avatar.top = _clothingManager.clothingById(topId);
			avatar.bottom = _clothingManager.clothingById(bottomId);
			avatar.hair = _clothingManager.clothingById(hairId);
			avatar.shoes = _clothingManager.clothingById(shoesId);
			
			var clothingArr:Array = esob.getIntegerArray(PluginConstants.CLOTHING);
			var ownedClothing:Array = [];
			for (var i:int = 0; i < clothingArr.length;++i) {
				var id:int = clothingArr[i];
				var clothing:Clothing = _clothingManager.clothingById(id);
				ownedClothing.push(clothing);
			}
			
			avatar.ownedClothing = ownedClothing;
			
			return avatar;
		}
		
		/**
		 * Event handler used to capture the result of a connection attempt
		 */
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
				
				_introScreen = new IntroScreen();
				_introScreen.addEventListener(IntroScreen.LOGIN_AVATAR, onLoginAvatar);
				_introScreen.addEventListener(IntroScreen.LOGIN_GUEST, onLoginGuest);
				addChildAt(_introScreen, 0);
				
			} else {
				trace("Connection failed. Reason: " + e.getEsError().getDescription());
			}
		}
		
		private function onLoginGuest(e:Event):void {
			_loginType = GUEST;
			
			var lr:LoginRequest = new LoginRequest();
			lr.setUserName("guest");
			
			_es.send(lr);
		}
		
		private function onLoginAvatar(e:Event):void {
			_loginType = AVATAR;
			
			var lr:LoginRequest = new LoginRequest();
			lr.setUserName(_introScreen.login_txt.text);
			lr.setPassword(_introScreen.password_txt.text);
			
			_es.send(lr);
		}
		
		
	}
	
}
