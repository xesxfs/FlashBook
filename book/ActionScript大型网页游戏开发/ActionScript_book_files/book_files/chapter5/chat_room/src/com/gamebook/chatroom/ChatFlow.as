package com.gamebook.chatroom {
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.errors.Errors;
	import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	import com.gamebook.chatroom.ui.ErrorScreen;
	import com.gamebook.chatroom.ui.LoginScreen;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ChatFlow extends MovieClip{
		
		private var _es:ElectroServer;
		private var _chatRoom:ChatRoom;
		
		public function ChatFlow() {
			initialize();
		}
		
		private function initialize():void {
			
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
			_es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosed", this);
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
		 * Called when a user is connected and logged in. It creates a chat room screen.
		 */
		private function createChatRoom():void{
			_chatRoom = new ChatRoom();
			_chatRoom.es = _es;
			_chatRoom.initialize();
			addChild(_chatRoom);
		}
		
		/**
		 * This is used to display an error if one occurs
		 */
		private function showError(msg:String):void {
			var alert:ErrorScreen = new ErrorScreen(msg);
			alert.x = 300;
			alert.y = 200;
			alert.addEventListener(ErrorScreen.OK, onErrorScreenOk);
			addChild(alert);
		}
		
		/**
		 * Called as the result of an OK event on an error screen. Removes the error screen.
		 */
		private function onErrorScreenOk(e:Event):void {
			var alert:ErrorScreen = e.target as ErrorScreen;
			alert.removeEventListener(ErrorScreen.OK, onErrorScreenOk);
			removeChild(alert);
		}
		
		/**
		 * Called when a connection attempt has succeeded or failed
		 */
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
				createLoginScreen();
			} else {
				showError("Failed to connect.");
			}
		}
		
		/**
		 * Creates a screen where a user can enter a username
		 */
		private function createLoginScreen():void{
			var login:LoginScreen = new LoginScreen();
			login.x = 400 - login.width / 2;
			login.y = 300 - login.height / 2;
			addChild(login);
			
			login.addEventListener(LoginScreen.OK, onLoginSubmit);
		}
		
		/**
		 * Called as a result of the OK event on the login screen. Creates and sends a login request to the server
		 */
		private function onLoginSubmit(e:Event):void {
			var screen:LoginScreen = e.target as LoginScreen;
			
			//create the request
			var lr:LoginRequest = new LoginRequest();
			lr.setUserName(screen.username);
			
			//send it
			_es.send(lr);
			
			screen.removeEventListener(LoginScreen.OK, onLoginSubmit);
			removeChild(screen);
		}
		
		/**
		 * Called when the server responds to the login request. If successful, create the chat room screen
		 */
		public function onLoginResponse(e:LoginResponse):void {
			if (e.getAccepted()) {
				createChatRoom();
			} else {
				showError(e.getEsError().getDescription());
			}
		}
		
		public function onConnectionClosed(e:ConnectionClosedEvent):void {
			showError("Connection was closed");
		}
		
	}
	
}