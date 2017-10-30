package com.gamebook.helloworld {
	
	//Flash imports
	import flash.display.Sprite;
	import flash.text.TextField;
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.event.PrivateMessageEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.request.PrivateMessageRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	
	/**
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Main extends Sprite {
		
		//ElectroServer class instance
		private var _es:ElectroServer;
		
		//text field to show log messages
		private var _logField:TextField;
		
		public function Main():void {
			initialize();
		}
		
		private function initialize():void {
			createLogField();
			
			//create new ElectroServer instance for use in communicating with the server
			_es = new ElectroServer();
			
			//add listeners
			_es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
			_es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
			_es.addEventListener(MessageType.PrivateMessageEvent, "onPrivateMessageEvent", this);
			
			//set the message protocol to binary
			_es.setProtocol(Protocol.BINARY);
			
			//set the connection information
			_es.createConnection("127.0.0.1", 9899);
			
			log("Connecting to 127.0.0.1 on port 9899...");
		}
		
		/**
		 * Creates a log field to show log messages
		 */
		private function createLogField():void{
			_logField = new TextField();
			_logField.width = 500;
			_logField.height = 250;
			_logField.x = 50;
			_logField.y = 50;
			_logField.border = true;
			addChild(_logField);
		}
		
		/**
		 * Event handler used to capture a login response
		 */
		public function onLoginResponse(e:LoginResponse):void {
			if (e.getAccepted()) {
				log("Login accepted. Logged in as " + e.getUserName());
				
				//create the request
				var pmr:PrivateMessageRequest = new PrivateMessageRequest();
				pmr.setUserNames([e.getUserName()]);
				pmr.setMessage("Hello World!");
				
				//send it
				_es.send(pmr);
				
				log("Sending myself a private message.");
			} else {
				log("Login failed. Reason: " + e.getEsError().getDescription());
			}
		}
		
		/**
		 * Event handler used to capture private messages
		 */
		public function onPrivateMessageEvent(e:PrivateMessageEvent):void {
			log("Private message received from " + e.getUserName() + ". Message: " + e.getMessage());
		}
		
		/**
		 * Event handler used to capture the result of a connection attempt
		 */
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
				log("Connection accepted.");
				
				//build the request
				var lr:LoginRequest = new LoginRequest();
				lr.setUserName("coolman" + Math.round(10000 * Math.random()));
				
				//send it
				_es.send(lr);
				
				log("Sending login request.");
			} else {
				log("Connection failed. Reason: " + e.getEsError().getDescription());
			}
		}
		
		/**
		 * Logs a message to an on-screen text field
		 */
		private function log(str:String):void {
			_logField.appendText(str + "\n");
		}
		
	}
	
}