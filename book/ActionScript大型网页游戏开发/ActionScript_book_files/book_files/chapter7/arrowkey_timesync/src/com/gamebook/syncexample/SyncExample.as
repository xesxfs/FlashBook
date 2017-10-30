﻿package com.gamebook.syncexample {
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
		
		public function SyncExample() {
			initialize();
		}
		
		private function test():void {
			
			var ts:Clock = new Clock(_es, "TimeStampPlugin");
			ts.start();
			
			ts.addEventListener(Clock.CLOCK_READY, onClockReady);
			
		}
		
		private function onClockReady(e:Event):void {
			var sc:Clock = e.target as Clock;
			
			var ke:ArrowKeyExample = new ArrowKeyExample();
			ke.es = _es;
			ke.clock = sc;
			ke.initialize();
			
			addChild(ke);
			
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
				
				test();
				
			} else {
				trace("Error logging in");
			}
		}
		
	}
	
}