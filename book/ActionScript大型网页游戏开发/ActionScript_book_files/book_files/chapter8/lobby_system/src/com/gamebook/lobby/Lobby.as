package com.gamebook.lobby {
	
	//ElectroServer imports
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.SearchCriteria;
	import com.electrotank.electroserver4.entities.ServerGame;
	import com.electrotank.electroserver4.errors.Errors;
	import com.electrotank.electroserver4.errors.EsError;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.event.LeaveRoomEvent;
	import com.electrotank.electroserver4.message.event.PrivateMessageEvent;
	import com.electrotank.electroserver4.message.event.PublicMessageEvent;
	import com.electrotank.electroserver4.message.event.UserListUpdateEvent;
	import com.electrotank.electroserver4.message.event.ZoneUpdateEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.FindGamesRequest;
	import com.electrotank.electroserver4.message.request.JoinGameRequest;
	import com.electrotank.electroserver4.message.request.LeaveRoomRequest;
	import com.electrotank.electroserver4.message.request.PrivateMessageRequest;
	import com.electrotank.electroserver4.message.request.PublicMessageRequest;
	import com.electrotank.electroserver4.message.request.QuickJoinGameRequest;
	import com.electrotank.electroserver4.message.response.CreateOrJoinGameResponse;
	import com.electrotank.electroserver4.message.response.FindGamesResponse;
	import com.electrotank.electroserver4.message.response.GenericErrorResponse;
	import com.electrotank.electroserver4.room.Room;
	import com.electrotank.electroserver4.user.User;
	import com.electrotank.electroserver4.zone.Zone;
	import com.gamebook.dig.PluginConstants;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	//application imports
	import com.gamebook.lobby.ui.CreateRoomScreen;
	import com.gamebook.lobby.ui.PopuupBackground;
	import com.gamebook.lobby.ui.TextLabel;
	
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
	public class Lobby extends MovieClip {
		
		public static const JOINED_GAME:String = "joinedGame";
		
		//ElectroServer instance
		private var _es:ElectroServer;
		
		//room you are in
		private var _room:Room;
		
		private var _gameRoom:Room;
		
		//UI components
		private var _userList:List;
		private var _gameList:List;
		private var _history:TextArea;
		private var _message:TextInput;
		private var _joinGame:Button;
		private var _send:Button;
		
		//chat room label
		private var _chatRoomLabel:TextLabel;
		
		//screen used to allow a user to create a screen
		private var _joinGameScreen:CreateRoomScreen;
		
		private var _gameListRefreshTimer:Timer;
		private var _quickJoinGame:Button;
		private var _pendingRoomName:String;
		
		public function Lobby() {
			
		}
		
		public function initialize():void {
			//add ElectroServer listeners
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.addEventListener(MessageType.PrivateMessageEvent, "onPrivateMessageEvent", this);
			_es.addEventListener(MessageType.UserListUpdateEvent, "onUserListUpdatedEvent", this);
			_es.addEventListener(MessageType.FindGamesResponse, "onFindGamesResponse", this);
			_es.addEventListener(MessageType.GenericErrorResponse, "onGenericErrorResponse", this);
			_es.addEventListener(MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this);
			
			
			_gameListRefreshTimer = new Timer(2000);
			_gameListRefreshTimer.start();
			_gameListRefreshTimer.addEventListener(TimerEvent.TIMER, onGameListRefreshTimer);
			
			//build UI elements
			buildUIElements();
			
			//join a default room
			joinRoom("Lobby");
		}
		
		public function destroy():void {
			var lrr:LeaveRoomRequest = new LeaveRoomRequest();
			lrr.setRoomId(_room.getRoomId());
			lrr.setZoneId(_room.getZoneId());
			_es.send(lrr);
			
			_es.removeEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.removeEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.removeEventListener(MessageType.PrivateMessageEvent, "onPrivateMessageEvent", this);
			_es.removeEventListener(MessageType.UserListUpdateEvent, "onUserListUpdatedEvent", this);
			_es.removeEventListener(MessageType.FindGamesResponse, "onFindGamesResponse", this);
			_es.removeEventListener(MessageType.GenericErrorResponse, "onGenericErrorResponse", this);
			_es.removeEventListener(MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this);
			
		}
		
		private function quickJoin():void {
			_quickJoinGame.enabled = false;
			
			var qjr:QuickJoinGameRequest = new QuickJoinGameRequest();
			qjr.setGameType(PluginConstants.GAME_NAME);
			qjr.setZoneName("GameZone");
			_es.send(qjr);
		}
		
		private function joinGame(serverGame:ServerGame):void {
			var jgr:JoinGameRequest = new JoinGameRequest();
			jgr.setGameId(serverGame.getGameId());
			jgr.setGameType(PluginConstants.GAME_NAME);
			
			_es.send(jgr);
		}
		
		public function onCreateOrJoinGameResponse(e:CreateOrJoinGameResponse):void {
			if (e.getSuccessful()) {
				_gameRoom = new Room();
				_gameRoom.setRoomId(e.getRoomId());
				_gameRoom.setZoneId(e.getZoneId());
				
				dispatchEvent(new Event(JOINED_GAME));
			} else {
				_quickJoinGame.enabled = true;
				trace(e.getEsError().getDescription());
				if (e.getEsError() == Errors.GameDoesntExist) {
					trace("This game hasn't been registered with the server. Do that first.");
				}
			}
		}
		
		/**
		 * An error happened on the server because of something the client did. This captures it and traces it.
		 */
		public function onGenericErrorResponse(e:GenericErrorResponse):void {
			trace(e.getErrorType().getDescription());
		}
		
		/**
		 * Request the game list from the server
		 */
		private function onGameListRefreshTimer(e:TimerEvent):void {
			//create request
			var fgr:FindGamesRequest = new FindGamesRequest();
			
			//create search criteria that will filter the game list
			var criteria:SearchCriteria = new SearchCriteria();
			criteria.setGameType(PluginConstants.GAME_NAME);
			
			//add the search criteria to the request
			fgr.setSearchCriteria(criteria);
			
			//send it
			_es.send(fgr);
		}
		
		/**
		 * Called when a response is received for the FindGamesRequest
		 */
		public function onFindGamesResponse(e:FindGamesResponse):void {
			refresGameList(e.getGames());
		}
		
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
		 * Attempt to create or join the room specified
		 */
		private function joinRoom(roomName:String):void {
			_pendingRoomName = roomName;
			
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
			/*
			This function gets called every time you join a room, including a game. But we only want to react here if you joined a room intended for chat.
			There is another event fired when you join a game, and it is handled here: onCreateOrJoinGameResponse
			*/
			
			if (e.room.getRoomName() == _pendingRoomName) {
				//the room you joined
				_room = e.room;
				
				//update the display to say the name of the room
				_chatRoomLabel.label_txt.text = e.room.getRoomName();
				
				//refresh the lists
				refreshUserList();
			}
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
		 * Used to refresh the games in the game list
		 */
		private function refresGameList(games:Array):void {
			var lastSelectedGameId:int = -1;
			var indexToSelect:int = -1;
			if (_gameList.selectedItem != null) {
				lastSelectedGameId = ServerGame(_gameList.selectedItem.data).getGameId();
			}
			
			//create a new data provider for the list component
			var dp:DataProvider = new DataProvider();
			
			//loop through the rooom list and add each room to the data provider
			for (var i:int = 0; i < games.length;++i) {
				var game:ServerGame = games[i];
				var label:String = "Game " + game.getGameId();
				label += " [" + (game.getLocked() ? "full" : "open") + "]";
				dp.addItem( { label:label, data:game } );
				
				if (game.getGameId() == lastSelectedGameId) {
					indexToSelect = i;
				}
			}
			
			//tell the component to use this data
			_gameList.dataProvider = dp;
			
			if (indexToSelect > -1) {
				_joinGame.enabled = true;
				_gameList.selectedIndex = indexToSelect;
			} else {
				_joinGame.enabled = false;
			}
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
			
			//background of the game list area
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
			
			//text label in the game list area
			var txt3:TextLabel = new TextLabel();
			txt3.label_txt.text = "Games";
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
			
			//used to display the game list
			_gameList = new List();
			_gameList.x = 513;
			_gameList.y = 323;
			_gameList.width = 222;
			_gameList.height = 103;
			_gameList.addEventListener(Event.CHANGE, onGameSelected);
			addChild(_gameList);
			
			//used to launch the create room screen
			_joinGame = new Button();
			_joinGame.addEventListener(MouseEvent.CLICK, onJoinGameClicked);
			_joinGame.x = 634;
			_joinGame.y = 431;
			_joinGame.label = "Join Game";
			addChild(_joinGame);
			
			_joinGame.enabled = false;
			
			//used to launch the create room screen
			_quickJoinGame = new Button();
			_quickJoinGame.addEventListener(MouseEvent.CLICK, onQuickJoinClicked);
			_quickJoinGame.x = 513;
			_quickJoinGame.y = 431;
			_quickJoinGame.label = "Quick Join";
			addChild(_quickJoinGame);
			
		}
		
		private function onGameSelected(e:Event):void {
			_joinGame.enabled = true;
		}
		
		private function onJoinGameClicked(e:MouseEvent):void {
			trace(_gameList.selectedItem)
			if (_gameList.selectedItem != null) {
				var serverGame:ServerGame = _gameList.selectedItem.data as ServerGame;
				joinGame(serverGame);
			}
		}
		
		private function onQuickJoinClicked(e:MouseEvent):void {
			quickJoin();
		}
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
		public function get gameRoom():Room { return _gameRoom; }
		
	}
	
}