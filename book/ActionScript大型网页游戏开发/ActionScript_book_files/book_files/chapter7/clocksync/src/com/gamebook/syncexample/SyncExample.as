package com.gamebook.syncexample {
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.errors.Errors;
	import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
	import com.electrotank.electroserver4.message.event.ConnectionEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.LoginRequest;
	import com.electrotank.electroserver4.message.response.LoginResponse;
	import com.gamebook.utils.network.clock.Clock;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class SyncExample extends MovieClip{
		
		private var _es:ElectroServer;
		private var _clock:Clock;
		
		public function SyncExample() {
			initialize();
		}
		
		/**
		 * This function creates a new Clock instance and tells it to synchronize with the server
		 */
		private function synchronize():void {
			
			//create and configure the Clock instance
			_clock = new Clock(_es, "TimeStampPlugin");
			_clock.start();
			
			//listen for when it is done synchronizing
			_clock.addEventListener(Clock.CLOCK_READY, onClockReady);
		}
		
		/**
		 * This function is called when the server time has been determined
		 */
		private function onClockReady(e:Event):void {
			trace("latency: " + _clock.latency);
			trace("server time: " + _clock.time);
		}
		
		private function initialize():void{
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
		
		public function onConnectionEvent(e:ConnectionEvent):void {
			if (e.getAccepted()) {
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
				
				synchronize();
				
			} else {
				trace("Error logging in");
			}
		}
		
	}
	
}