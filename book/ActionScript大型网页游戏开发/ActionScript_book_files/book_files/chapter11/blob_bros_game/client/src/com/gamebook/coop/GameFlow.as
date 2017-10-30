package com.gamebook.coop {
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	
	//Flash imports
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class GameFlow extends Sprite {
		
		private var _es:ElectroServer;
		private var _coopGame:CoopGame;
		
		/**
		 * Constructor
		 */
		public function GameFlow() {
			initialize();
		}
		
		/**
		 * Initialize by loading in the server settings and setting up an
		 * instance of Electroserver.
		 */
		public function initialize():void {
			//load the server connection settings
			var loader:URLLoader = new URLLoader(new URLRequest("server.xml"));
			loader.addEventListener(Event.COMPLETE, onFileLoaded);
			
			//create a new ElectroServer instance
			_es = new ElectroServer();
			
			//set the protocol to binary
			_es.setProtocol(Protocol.BINARY);
			
			//add event listeners
			_es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
			_es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
			_es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosedEvent", this);
		}
		
		/**
		 * Called when the file loads
		 */
		private function onFileLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var server:XML = new XML(loader.data);
			
			//grab the ip and port from the XML
			var ip:String = server.connection.@ip;
			var port:Number = Number(server.connection.@port);
			
			//connect to ElectroServer
			_es.createConnection(ip, port);
		}
		
		/**
		 * Called when a connection has been established or fails
		 */
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
				trace("Connected to server");
				
				//build the request
				var lr:LoginRequest = new LoginRequest();
				lr.setUserName("player" + Math.round(1000 * Math.random()));
				
				//send it
				_es.send(lr);
			} else {
				trace("Error connecting to the server");
			}
		}
		
		/**
		 * Called when the server responds to a login request.
		 */
		public function onLoginResponse(e:LoginResponse):void {
			if (e.getAccepted()) {
				trace("logged in");
				
				//create the CoopGame and add it to the screen
				_coopGame = new CoopGame();
				_coopGame.es = _es;
				_coopGame.initialize();
				addChild(_coopGame);
				
			} else {
				trace("Error logging in");
			}
		}
		
		/**
		 * This is called when the connection closes
		 */
		public function onConnectionClosedEvent(e:ConnectionClosedEvent):void {
			trace("Connection closed.");
		}
	}
	
}