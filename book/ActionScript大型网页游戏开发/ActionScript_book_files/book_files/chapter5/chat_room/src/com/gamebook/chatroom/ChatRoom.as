﻿package com.gamebook.chatroom {
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.event.PrivateMessageEvent;
	import com.electrotank.electroserver4.message.event.PublicMessageEvent;
	import com.electrotank.electroserver4.message.event.UserListUpdateEvent;
	import com.electrotank.electroserver4.message.event.ZoneUpdateEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.LeaveRoomRequest;
	import com.electrotank.electroserver4.message.request.PrivateMessageRequest;
	import com.electrotank.electroserver4.message.request.PublicMessageRequest;
	import com.electrotank.electroserver4.room.Room;
	import com.electrotank.electroserver4.user.User;
	import com.electrotank.electroserver4.zone.Zone;
	
	//application imports
	import com.gamebook.chatroom.ui.CreateRoomScreen;
	import com.gamebook.chatroom.ui.PopuupBackground;
	import com.gamebook.chatroom.ui.TextLabel;
	
	//Flash component imports
	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.TextArea;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	
	//Flash imports
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ChatRoom extends MovieClip{
		
		//ElectroServer instance
		private var _es:ElectroServer;
		
		//room you are in
		private var _room:Room;
		
		//UI components
		private var _userList:List;
		private var _roomList:List;
		private var _history:TextArea;
		private var _message:TextInput;
		private var _createRoom:Button;
		private var _send:Button;
		
		//chat room label
		private var _chatRoomLabel:TextLabel;
		
		//screen used to allow a user to create a screen
		private var _createRoomScreen:CreateRoomScreen;
		
		public function ChatRoom() {
			
		}
		
		public function initialize():void {
			//add ElectroServer listeners
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.addEventListener(MessageType.PrivateMessageEvent, "onPrivateMessageEvent", this);
			_es.addEventListener(MessageType.UserListUpdateEvent, "onUserListUpdatedEvent", this);
			_es.addEventListener(MessageType.ZoneUpdateEvent, "onZoneUpdateEvent", this);
			
			//build UI elements
			buildUIElements();
			
			//join a default room
			joinRoom("Lobby");
		}[Embed(source="../../../../lib/chat_assets.swc", symbol="Button_selectedUpSkin")]
		
		/**
		 * Called when a user name in the list is selected
		 */
		private function onUserSelected(e:Event):void {
			if (_userList.selectedItem != null) {
				
				//grab the User object off of the list item
				var user:User = _userList.selectedItem.data as User;
				
				//add private message syntax to the message entry field
				_message.text = "/" + user.getUserName() + ": ";
			}
		}
		
		/**
		 * Called when a room in the list is selected
		 */
		private function onRoomSelected(e:Event):void {
			if (_roomList.selectedItem != null) {
				
				//grab the Room object off of the list item
				var room:Room = _roomList.selectedItem.data as Room;
				
				//if you are not already in this room, join it
				if (room != _room) {
					joinRoom(room.getRoomName());
				}
			}
		}
		
		/**
		 * Called when the send button is clicked
		 */
		private function onSendClick(e:MouseEvent):void {
			
			//if there is text to send, then proceed
			if (_message.text.length > 0) {
				
				//get the message to send
				var msg:String = _message.text;
				
				//check to see if it is a public or private message
				if (msg.charAt(0) == "/" && msg.indexOf(":") != -1) {
					//private message
					
					//parse the message to get who it is meant to go to
					var to:String = msg.substr(1, msg.indexOf(":") - 1);
					
					//parse the message to get the message content and strip out the 'to' value
					msg = msg.substr(msg.indexOf(":")+2);
					
					//create the request object
					var prmr:PrivateMessageRequest = new PrivateMessageRequest();
					prmr.setUserNames([to]);
					prmr.setMessage(msg);
					
					//send it
					_es.send(prmr);
					
				} else {
					//public message
					
					//create the request object
					var pmr:PublicMessageRequest = new PublicMessageRequest();
					pmr.setMessage(_message.text);
					pmr.setRoomId(_room.getRoomId());
					pmr.setZoneId(_room.getZoneId());
					
					//send it
					_es.send(pmr);
				}
				
				//clear the message input field
				_message.text = "";
				
				//give the message field focus
				stage.focus = _message;
			}
		}
		
		/**
		 * Called when the create game room button is clicked
		 */
		private function onCreateRoomClicked(e:MouseEvent):void {
			
			//if the create game room screen doesn't yet exist, then proceed
			if (_createRoomScreen == null) {
				
				//create and position the screen
				_createRoomScreen = new CreateRoomScreen();
				_createRoomScreen.x = 400 - _createRoomScreen.width / 2;
				_createRoomScreen.y = 300 - _createRoomScreen.height / 2;
				addChild(_createRoomScreen);
				
				//listen for the OK event
				_createRoomScreen.addEventListener(CreateRoomScreen.OK, onCreateRoomSubmit);
				
			}
		}
		
		/**
		 * Called as a result of the OK event in the create game room screen
		 */
		private function onCreateRoomSubmit(e:Event):void {
			
			//create/join the name specified
			joinRoom(_createRoomScreen.roomName);
			
			//remove it
			_createRoomScreen.removeEventListener(CreateRoomScreen.OK, onCreateRoomSubmit);
			removeChild(_createRoomScreen);
			_createRoomScreen = null;
		}
		
		/**
		 * Attempt to create or join the room specified
		 */
		private function joinRoom(roomName:String):void {
			
			//if currently in a room, leave the room
			if (_room != null) {
				//create the request
				var lrr:LeaveRoomRequest = new LeaveRoomRequest();
				lrr.setRoomId(_room.getRoomId());
				lrr.setZoneId(_room.getZoneId());
				
				//send it
				_es.send(lrr);
			}
			
			//create the request
			var crr:CreateRoomRequest = new CreateRoomRequest();
			crr.setRoomName(roomName);
			crr.setZoneName("chat");
			
			//send it
			_es.send(crr);
		}
		
		/**
		 * Called when the server says you joined a room
		 */
		public function onJoinRoomEvent(e:JoinRoomEvent):void {
			
			//the room you joined
			_room = e.room;
			
			//update the display to say the name of the room
			_chatRoomLabel.label_txt.text = e.room.getRoomName();
			
			//refresh the lists
			refreshUserList();
			refresRoomList();
		}
		
		/**
		 * Called when you receive a chat message from the room you are in
		 */
		public function onPublicMessageEvent(e:PublicMessageEvent):void {
			
			//add a chat message to the history field
			_history.appendText(e.getUserName() + ": " + e.getMessage() + "\n");
		}
		
		/**
		 * Called when you receive a chat message from another user
		 */
		public function onPrivateMessageEvent(e:PrivateMessageEvent):void {
			
			//add a chat message to the history field
			_history.appendText("[private] "+e.getUserName() + ": " + e.getMessage() + "\n");
		}
		
		/**
		 * This is called when the user list for the room youa re in changes
		 */
		public function onUserListUpdatedEvent(e:UserListUpdateEvent):void {
			refreshUserList();
		}
		
		/**
		 * Used to refresh the names in the user list
		 */
		private function refreshUserList():void {
			//get the user list
			var users:Array = _room.getUsers();
			
			//create a new data provider for the list component
			var dp:DataProvider = new DataProvider();
			
			//loop through the user list and add each user to the data provider
			for (var i:int = 0; i < users.length;++i) {
				var user:User = users[i];
				dp.addItem( { label:user.getUserName(), data:user} );
			}
			
			//tell the component to use this data
			_userList.dataProvider = dp;
		}
		
		/**
		 * Used to refresh the names in the room list
		 */
		private function refresRoomList():void {
			//get the zone
			var zone:Zone = _es.getZoneManager().getZoneById(_room.getZoneId());
			
			//get the room list
			var rooms:Array = zone.getRooms();
			
			//create a new data provider for the list component
			var dp:DataProvider = new DataProvider();
			
			//loop through the rooom list and add each room to the data provider
			for (var i:int = 0; i < rooms.length;++i) {
				var room:Room = rooms[i];
				dp.addItem( { label:room.getRoomName(), data:room} );
			}
			
			//tell the component to use this data
			_roomList.dataProvider = dp;
		}
		
		/**
		 * Called when the server says that information about the rooms in your zone has changes
		 */
		public function onZoneUpdateEvent(e:ZoneUpdateEvent):void {
			refresRoomList();
		}
		
		/**
		 * Add all of the user interface elements
		 */
		private function buildUIElements():void{
			
			//background of the chat history area
			var bg1:PopuupBackground = new PopuupBackground();
			bg1.x = 30;
			bg1.y = 142;
			bg1.width = 428;
			bg1.height = 328;
			addChild(bg1);
			
			//background of the user list area
			var bg2:PopuupBackground = new PopuupBackground();
			bg2.x = 493;
			bg2.y = 142;
			bg2.width = 260;
			bg2.height = 150;
			addChild(bg2);
			
			//background of the room list area
			var bg3:PopuupBackground = new PopuupBackground();
			bg3.x = 493;
			bg3.y = 295;
			bg3.width = 260;
			bg3.height = 176;
			addChild(bg3);
			
			//text label in the chat history area
			var txt1:TextLabel = new TextLabel();
			txt1.label_txt.text = "Chat";
			txt1.x = 220;
			txt1.y = 160;
			addChild(txt1);
			_chatRoomLabel = txt1;
			
			//text label in the user list area
			var txt2:TextLabel = new TextLabel();
			txt2.label_txt.text = "Users";
			txt2.x = 620;
			txt2.y = 160;
			addChild(txt2);
			
			//text label in the room list area
			var txt3:TextLabel = new TextLabel();
			txt3.label_txt.text = "Rooms";
			txt3.x = 625;
			txt3.y = 312;
			addChild(txt3);
			
			//history TextArea component used to show the chat log
			_history = new TextArea();
			_history.editable = false;
			_history.x = 50;
			_history.y = 181;
			_history.width = 389;
			_history.height = 207;
			addChild(_history);
			
			//used to allow users to enter new chat messages
			_message = new TextInput();
			_message.x = 50;
			_message.y = 400;
			_message.width = 390;
			addChild(_message);
			
			//used to send a chat message
			_send = new Button();
			_send.label = "send";
			_send.x = 340;
			_send.y = 430;
			addChild(_send);
			_send.addEventListener(MouseEvent.CLICK, onSendClick);
			
			//used to display the user list
			_userList = new List();
			_userList.x = 513;
			_userList.y = 170;
			_userList.width = 222;
			_userList.height = 103;
			_userList.addEventListener(Event.CHANGE, onUserSelected);
			addChild(_userList);
			
			//used to display the room list
			_roomList = new List();
			_roomList.x = 513;
			_roomList.y = 323;
			_roomList.width = 222;
			_roomList.height = 103;
			_roomList.addEventListener(Event.CHANGE, onRoomSelected);
			addChild(_roomList);
			
			//used to launch the create room screen
			_createRoom = new Button();
			_createRoom.addEventListener(MouseEvent.CLICK, onCreateRoomClicked);
			_createRoom.x = 634;
			_createRoom.y = 431;
			_createRoom.label = "Create Room";
			addChild(_createRoom);
			
		}
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
	}
	
}