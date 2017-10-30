package com.gamebook.tankgame {
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.errors.Errors;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.event.CompositePluginMessageEvent;
	import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	import com.gamebook.utils.network.clock.Clock;
	import flash.xml.XMLDocument;
	
	//Flash imports
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class GameFlow extends MovieClip{
		
		private var _es:ElectroServer;
		private var _tankGame:TankGame;
		private var _serverInfoLoader:URLLoader;
		private var _mapLoader:URLLoader;
		private var _mapData:EsObject;
		private var _clock:Clock;
		private var _clockReady:Boolean = false;
		private var _loginScreen:LoginScreen;
		
		public function GameFlow() {
			initialize();
		}
		
		private function initialize():void{
			//load the server connection settings
			var loader:URLLoader = new URLLoader(new URLRequest("server.xml"));
			loader.addEventListener(Event.COMPLETE, onServerInfoLoaded);
			_serverInfoLoader = loader;
			
			//load the server connection settings
			loader = new URLLoader(new URLRequest("map.xml"));
			loader.addEventListener(Event.COMPLETE, onMapLoaded);
			_mapLoader = loader;
			
			//create a new ElectroServer instance
			_es = new ElectroServer();
			
			//set the protocol to binary
			_es.setProtocol(Protocol.BINARY);
			
			//add event listeners
			_es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
			_es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
			_es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosedEvent", this);
		}
		
		private function initClock():void {
			
			var ts:Clock = new Clock(_es, "TimeStampPlugin");
			ts.start();
			
			ts.addEventListener(Clock.CLOCK_READY, onClockReady);
			
			_clock = ts;
		}
		
		private function onClockReady(e:Event):void {
			_clockReady = true;
			
			if (_mapData != null) {
				startGame();
			}
			
			_loginScreen.destroy();
			removeChild(_loginScreen);
			_loginScreen = null;
		}
		
		private function startGame():void {
			//create the TankGame and add it to the screen
			_tankGame = new TankGame();
			_tankGame.es = _es;
			_tankGame.clock = _clock;
			_tankGame.mapData = _mapData;
			_tankGame.initialize();
			addChild(_tankGame);
			
		}
		
		/**
		 * Called when the file loads
		 */
		private function onServerInfoLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var server:XML = new XML(loader.data);
			
			//grab the ip and port from the XML
			var ip:String = server.connection.@ip;
			var port:Number = Number(server.connection.@port);
			
			//connect to ElectroServer
			_es.createConnection(ip, port);
		}
		
		private function onMapLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var mapInfo:XMLDocument = new XMLDocument();
			mapInfo.ignoreWhite = true;
			mapInfo.parseXML(loader.data);
			
			var esob:EsObject = new EsObject();
			esob.fromXML(mapInfo.firstChild);
			_mapData = esob;
			
			if (_clockReady) {
				startGame();
			}
		}
		
		/**
		 * Called when a connection has been established or fails
		 */
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
				var lgs:LoginScreen = new LoginScreen();
				lgs.addEventListener(LoginScreen.SUBMIT_CLICKED, onLoginClicked);
				addChild(lgs);
				
				_loginScreen = lgs;
				
			} else {
				trace("Error connecting to the server");
			}
		}
		
		private function onLoginClicked(e:Event):void {
			var screen:LoginScreen = _loginScreen;
			
			var name:String = screen.name_txt.text;
			
			screen.removeEventListener(LoginScreen.SUBMIT_CLICKED, onLoginClicked);
			
			//build the request
			var lr:LoginRequest = new LoginRequest();
			lr.setUserName(name);
			
			//send it
			_es.send(lr);
		}
		
		/**
		 * Called when the server responds to a login request.
		 */
		public function onLoginResponse(e:LoginResponse):void {
			if (e.getAccepted()) {
				
				initClock();
				
			} else {
				trace("Error logging in");
			}
		}
		
		/**
		 * This is called when the connection closes
		 */
		public function onConnectionClosedEvent(e:ConnectionClosedEvent):void {
			addChild(new ConnectionLost());
		}
		
	}
	
}