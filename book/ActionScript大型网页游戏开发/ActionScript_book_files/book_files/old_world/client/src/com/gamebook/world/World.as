package com.gamebook.world {
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.message.event.BuddyStatusUpdatedEvent;
	import com.electrotank.electroserver4.message.event.JoinRoomEvent;
	import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	import com.electrotank.electroserver4.message.event.PublicMessageEvent;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.request.CreateRoomRequest;
	import com.electrotank.electroserver4.message.request.LeaveRoomRequest;
	import com.electrotank.electroserver4.message.request.PluginRequest;
	import com.electrotank.electroserver4.message.request.PublicMessageRequest;
	import com.electrotank.electroserver4.plugin.Plugin;
	import com.gamebook.renderer.events.AvatarEvent;
	import com.gamebook.renderer.events.ItemInteractionEvent;
	import com.gamebook.renderer.events.TileEvent;
    import com.gamebook.renderer.events.UserHomesEvent;
	import com.gamebook.renderer.item.Item;
	import com.gamebook.renderer.Map;
	import com.gamebook.renderer.tile.Tile;
    import com.gamebook.ui.homes.UserHomesItemList;
	import com.gamebook.utils.astar.Astar;
	import com.gamebook.utils.astar.INode;
	import com.gamebook.utils.astar.Path;
	import com.gamebook.utils.astar.SearchResults;
	import com.gamebook.utils.keymanager.Key;
	import com.gamebook.utils.keymanager.KeyCombo;
	import com.gamebook.utils.keymanager.KeyManager;
	import com.gamebook.utils.network.clock.Clock;
	import com.gamebook.world.avatar.Avatar;
	import com.gamebook.world.avatar.AvatarManager;
	import com.gamebook.world.chat.Chat;
	import com.gamebook.world.clothing.Clothing;
	import com.gamebook.world.clothing.ClothingManager;
	import com.gamebook.world.events.BuddyListEvent;
	import com.gamebook.world.events.VendorEvent;
	import com.gamebook.world.furniture.Furniture;
	import com.gamebook.world.furniture.FurnitureDefinition;
	import com.gamebook.world.furniture.FurnitureManager;
	import com.gamebook.world.screens.BottomUI;
	import com.gamebook.world.screens.BuddyConfirmationPopup;
	import com.gamebook.world.screens.BuddyList;
	import com.gamebook.world.screens.ConfirmationPopup;
    import com.gamebook.world.screens.HomesUI;
	import com.gamebook.world.screens.Popup;
	import com.gamebook.world.screens.VendorScreen;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
    import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class World extends MovieClip {
		
		public static const TELEPORT:String = "teleport";
		public static const GO_TO_HOME:String = "goToHome";
        public static const BACK_TO_WORLD:String = "backToWorld";
		
		private var _map:Map;
		private var _es:ElectroServer;
		private var _roomId:Number;
		private var _zoneId:Number;
		private var _mapUrl:String;
		private var _clothingManager:ClothingManager;
		private var _furnitureManager:FurnitureManager;
		private var _astar:Astar;
		private var _clock:Clock;
		private var _km:KeyManager;
		private var _enter:KeyCombo;
		private var _destination:String;
		
		private var _chat:Chat;
		private var _vendorScreen:VendorScreen;
		private var _confirmationPopup:ConfirmationPopup;
		private var _buddyList:AvatarManager;
		private var _bottomUI:BottomUI;
		
		private var _isHome:Boolean;
		private var _isMyHome:Boolean;
		private var _owner:String;
		
        private var _furnitureList:UserHomesItemList;
        private var _homesBottomUI:HomesUI;
        
		private var _furnitureByEntryId:Dictionary = new Dictionary();
		private var _furnitureByItem:Dictionary = new Dictionary();
		private var _furniture:Array = [];
		
		private var _buddyListUI:BuddyList;
		
		public function World() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			_km = new KeyManager();
			stage.addChild(_km);

			_enter = _km.createKeyCombo(Key.ENTER);
			_enter.addEventListener(KeyCombo.COMBO_PRESSED, onEnterKeyPressed);
		}
		
		private function onEnterKeyPressed(e:Event):void {
			attemptSendChat();
		}
		
		private function attemptSendChat():void{
			var msg:String = _chat.input_txt.text;
			if (msg.length > 0) {
				_chat.input_txt.text = "";
				
				var pmr:PublicMessageRequest = new PublicMessageRequest();
				pmr.setMessage(msg);
				pmr.setRoomId(_roomId);
				pmr.setZoneId(_zoneId);
				_es.send(pmr);
			}
		}
		
		public function initialize(url:String, home:Boolean, owner:String):void {
			_mapUrl = url;
			_isHome = home;
			_owner = owner;
			_isMyHome = _es.getUserManager().getMe().getUserName() == owner;
			
			addESListeners();
			
			_map = new Map();
			_map.addEventListener(Map.READY, onMapReady);
			_map.x = 400;
			_map.clock = _clock;
			addChild(_map);
			_map.loadMap(_mapUrl);
			
			_map.addEventListener(TileEvent.TILE_CLICKED, onTileClicked);
			_map.addEventListener(TileEvent.STOPPED_ON_TILE, onStoppedOnTile);
			_map.addEventListener(AvatarEvent.AVATAR_CLICKED, onAvatarClicked);
			
			
			_astar = new Astar(_map);
			
			addEventListener(Event.ENTER_FRAME, run);
			
			_chat = new Chat();
			_chat.x = 10;
			_chat.y = 570;
			addChild(_chat);
			
			_bottomUI = new BottomUI();
			_bottomUI.y = 550;
			_bottomUI.x = 800;
			_bottomUI.addEventListener(BottomUI.BUDDY_LIST_CLICKED, onBuddyListClicked);
			_bottomUI.addEventListener(BottomUI.HOME_CLICKED, onHomeClicked);
			addChild(_bottomUI);
		}
		
		private function onHomeClicked(e:Event):void {
			goToHome(_map.avatarManager.me.avatarName);
		}
        
		private function goToHome(who:String):void {
			_owner = who;
			_destination = "data/home.xml";
			dispatchEvent(new Event(GO_TO_HOME));
		}
		
		private function refreshBuddyList():void {
			if (_buddyListUI != null) {
				removeBuddyListUI();
				createBuddyListUI();
			}
		}
		
		private function createBuddyListUI():void {
			if (_buddyListUI == null) {
				_buddyListUI = new BuddyList(_buddyList.avatars);
				_buddyListUI.addEventListener(Event.CLOSE, closeBuddyList);
				_buddyListUI.addEventListener(BuddyListEvent.GO_TO_HOME, onGoToHome);
				_buddyListUI.addEventListener(BuddyListEvent.BUDDY_REMOVE, onBuddyRemove);
				
				_buddyListUI.x = 100;
				_buddyListUI.y = 100;
				
				addChild(_buddyListUI);
			}
		}
		
		private function onBuddyListClicked(e:Event):void {
			createBuddyListUI();
		}
		
		private function onGoToHome(e:BuddyListEvent):void {
			goToHome(e.avatar.avatarName);
		}
		
		private function onBuddyRemove(e:BuddyListEvent):void {
			removeBuddy(e.avatar);
		}
		
		private function closeBuddyList(e:Event):void {
			removeBuddyListUI();
		}
		
		private function removeBuddyListUI():void{
			_buddyListUI.removeEventListener(Event.CLOSE, closeBuddyList);
			_buddyListUI.removeEventListener(BuddyListEvent.GO_TO_HOME, onGoToHome);
			_buddyListUI.removeEventListener(BuddyListEvent.BUDDY_REMOVE, onBuddyRemove);
			
			removeChild(_buddyListUI);
			
			_buddyListUI.destroy();
			_buddyListUI = null;
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, run);
			
			_map.destroy();
			
			removeChild(_map);
			
			var lrr:LeaveRoomRequest = new LeaveRoomRequest();
			lrr.setRoomId(_roomId);
			lrr.setZoneId(_zoneId);
			_es.send(lrr);
			
			stage.removeChild(_km);
			
			removeChild(_chat);
			
			_km = null;
			
			removeESListeners();
		}
		
		private function onStoppedOnTile(e:TileEvent):void {
			var mapToLoad:String = e.eventParameter;
			
			_destination = mapToLoad;
			
			dispatchEvent(new Event(TELEPORT));
		}
		
		private function run(e:Event):void {
			
			stage.focus = _chat.input_txt;
		}
		
		private function onTileClicked(e:TileEvent):void {
            if (_map.isEditable) {
                return;
            }
			var startNode:INode = _map.getTile(_map.avatarManager.me.col, _map.avatarManager.me.row);
			var goalNode:INode = e.tile;
			
			var results:SearchResults = _astar.search(startNode, goalNode);
			if (results.getIsSuccess()) {
				sendWalkPath(results.getPath());
			}
		}
		
		public function onJoinRoomEvent(e:JoinRoomEvent):void {
			_roomId = e.getRoomId();
			_zoneId = e.getZoneId();
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.INIT_ME);
			sendToAreaPlugin(esob);
		}
		
		public function onPluginMessageEvent(e:PluginMessageEvent):void {
			var esob:EsObject = e.getEsObject();
			var action:String;
			if (e.getPluginName() == "AreaPlugin") {
				action = esob.getString(PluginConstants.ACTION);
				switch (action) {
					case PluginConstants.AVATAR_LIST:
						handleAvatarList(esob);
						break;
					case PluginConstants.AVATAR_JOINED:
						handleAvatarJoined(esob);
						break;
					case PluginConstants.AVATAR_LEFT:
						handleAvatarLeft(esob);
						break;
					case PluginConstants.WALK:
						handleWalk(esob);
						break;
					default:
						trace("Action not handled: " + action);
						trace(esob);
				}
			} else if (e.getPluginName() == "WorldPlugin") {
				action = esob.getString(PluginConstants.ACTION);
				switch (action) {
					case PluginConstants.ADD_BUDDY:
						showPopup("Buddy added");
						break;
					case PluginConstants.REMOVE_BUDDY:
						showPopup("Buddy removed");
						break;
					case PluginConstants.BUY_ITEM:
						showPopup("Item purchased");
						break;
					default:
						trace("Action not handled: " + action);
				}
			}
		}
		
		private function handleWalk(esob:EsObject):void {
			var messageType:String = esob.getString(PluginConstants.MESSAGE_TYPE);
			if (messageType == PluginConstants.MESSAGE_EVENT) {
				var name:String = esob.getString(PluginConstants.AVATAR);
				var ob:EsObject = esob.getEsObject(PluginConstants.PATH);
				handleWalkPath(name, ob);
			}
		}
		
		private function handleWalkPath(name:String, esob:EsObject):void {
			var time:Number = Number(esob.getString(PluginConstants.TIME));
			
			var points:Array = esob.getIntegerArray(PluginConstants.PATH_POINTS);
			
			var tiles:Array = [];
			for (var i:int = 0; i < points.length; i += 2) {
				var col:int = points[i];
				var row:int = points[i + 1];
				
				var tile:Tile = _map.getTile(col, row);
				
				tiles.push(tile);
			}
			
			_map.walkAvatar(name, time, tiles);
		}
		
		private function handleAvatarLeft(esob:EsObject):void{
			var name:String = esob.getString(PluginConstants.AVATAR_NAME);
			
			_map.removeAvatar(name);
		}
		
		private function handleAvatarJoined(esob:EsObject):void{
			var avatar_ob:EsObject = esob.getEsObject(PluginConstants.AVATAR);
			var avatar:Avatar = parseAvatar(avatar_ob);
			
			_map.addAvatar(avatar);
		}
		
		private function handleAvatarList(esob:EsObject):void {
			
			var avatar_arr:Array = esob.getEsObjectArray(PluginConstants.AVATARS);
			for (var i:int = 0; i < avatar_arr.length;++i) {
				var ob:EsObject = avatar_arr[i];
				var avatar:Avatar = parseAvatar(ob);
				
				_map.addAvatar(avatar);
				
				if (ob.doesPropertyExist(PluginConstants.PATH)) {
					handleWalkPath(avatar.avatarName, ob.getEsObject(PluginConstants.PATH));
				}
			}
			
			if (_isHome) {
				parseHomeFurniture(esob);
			}
			
		}
		
		private function parseHomeFurniture(esob:EsObject):void{
			var arr:Array = esob.getEsObjectArray(PluginConstants.FURNITURE_LIST);
			for each (var entry:EsObject in arr) {
				var col:int = entry.getInteger(PluginConstants.PLACEMENT_COLUMN);
				var row:int = entry.getInteger(PluginConstants.PLACEMENT_ROW);
				var inWorld:Boolean = entry.getBoolean(PluginConstants.FURNITURE_IN_WORLD);
				var entryId:int = entry.getInteger(PluginConstants.FURNITURE_ENTRY_ID);
				
				var furniDefOb:EsObject = entry.getEsObject(PluginConstants.FURNITURE_ITEM);
				var furniDefId:int = furniDefOb.getInteger(PluginConstants.FURNITURE_ID);
				var furniDef:FurnitureDefinition = _furnitureManager.furnitureDefinitionById(furniDefId);
				
				var furni:Furniture = new Furniture();
				furni.furnitureDefinition = furniDef;
				furni.entryId = entryId;
				furni.isInWorld = inWorld;
				
				var item:Item = new Item();
				item.itemDefinition = _map.itemManager.itemDefinitionById(furniDef.fileName);
				item.col = col;
				item.row = row;
				
				furni.item = item;
				
				if (inWorld) {
					_map.itemManager.addItem(item);
					_map.placeItem(item);
				}
				
				_furnitureByEntryId[entryId] = furni;
				_furnitureByItem[item] = furni;
				_furniture.push(furni);
				
			}
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
		
		private function moveFurniture(item:Item, inWorld:Boolean):void {
			var furni:Furniture = _furnitureByItem[item];
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.MOVE_FURNITURE);
			esob.setInteger(PluginConstants.FURNITURE_ENTRY_ID, furni.entryId);
			esob.setInteger(PluginConstants.PLACEMENT_ROW, item.row);
			esob.setInteger(PluginConstants.PLACEMENT_COLUMN, item.col);
			esob.setBoolean(PluginConstants.FURNITURE_IN_WORLD, inWorld);
			
			sendToAreaPlugin(esob);
		}
		
		public function onPublicMessageEvent(e:PublicMessageEvent):void {
			_map.avatarManager.avatarByName(e.getUserName()).chatBubble.showMessage(e.getMessage());
		}
		
		public function parseAvatar(esob:EsObject):Avatar {
			var avatar:Avatar = new Avatar();
			
			avatar.avatarName = esob.getString(PluginConstants.AVATAR_NAME);
			avatar.isMe = _es.getUserManager().getMe().getUserName() == avatar.avatarName;
			avatar.gender = esob.getString(PluginConstants.GENDER);
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
			
			avatar.build();
			
			return avatar;
		}
		
		
		private function sendWalkPath(path:Path):void {
			
			var path_arr:Array = [];
			
			for (var i:int = 0; i < path.getNodes().length;++i) {
				var n:INode = path.getNodes()[i];
				path_arr.push(n.getCol());
				path_arr.push(n.getRow());
			}
			
			var time:Number = _clock.time;
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.WALK);
			esob.setString(PluginConstants.TIME, time.toString());
			esob.setIntegerArray(PluginConstants.PATH_POINTS, path_arr);
			sendToAreaPlugin(esob);
			
		}
		
		private function sendToAreaPlugin(esob:EsObject):void {
			
			
			var pmr:PluginRequest = new PluginRequest();
			pmr.setEsObject(esob);
			pmr.setRoomId(_roomId);
			pmr.setZoneId(_zoneId);
			pmr.setPluginName("AreaPlugin");
			
			_es.send(pmr);
		}
		
		private function sendToWorldPlugin(esob:EsObject):void {
			var pr:PluginRequest = new PluginRequest();
			pr.setPluginName("WorldPlugin");
			pr.setEsObject(esob);
			
			_es.send(pr);
		}
		
		private function addESListeners():void{
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.addEventListener(MessageType.BuddyStatusUpdatedEvent, "onBuddyStatusUpdateEvent", this);
		}
		
		public function onBuddyStatusUpdateEvent(e:BuddyStatusUpdatedEvent):void {
			refreshBuddyList();
		}
		
		private function removeESListeners():void {
			_es.removeEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			_es.removeEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
			_es.removeEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			_es.removeEventListener(MessageType.BuddyStatusUpdatedEvent, "onBuddyStatusUpdateEvent", this);
		}
		
		private function onMapReady(e:Event):void {
            
            _map.isEditable = false;
            _map.itemManager.addEventListener(ItemInteractionEvent.ITEM_CLICKED, onItemClicked);
            
            // Check for *my* home
            if (_isMyHome) {
                
                // Alter Bottom UI "Home Buttom" => World Button
                _bottomUI.home_btn.visible = false;
                _bottomUI.worldButton.visible = true;
                _bottomUI.addEventListener(UserHomesEvent.EXIT_HOMES, onHomesExited);
                
                // Add Bottom UI for Homes
                _homesBottomUI = new HomesUI();
                _homesBottomUI.addEventListener(UserHomesEvent.EDIT_MODE_TOGGLE, onEditModeToggle);
                _homesBottomUI.addEventListener(UserHomesEvent.ITEM_RECYCLED, onItemRecycled);
                _homesBottomUI.x = 687.5;
                _homesBottomUI.y = 550;
                addChild(_homesBottomUI);
                
                // Create Furniture Selection UI
                _furnitureList = new UserHomesItemList();
                _furnitureList.addEventListener(UserHomesEvent.ITEM_SELECTED, onListItemSelected);
                _furnitureList.visible = false;
                addChild(_furnitureList);
                
                // Add Listeners to Map for in-world Item Interaction
                _map.addEventListener(ItemInteractionEvent.ITEM_SELECTED, onItemSelected);
                _map.addEventListener(ItemInteractionEvent.ITEM_PLACED, onItemPlaced);
            }
            
			joinRoom();

		}
        
        private function onItemRecycled(e:UserHomesEvent = null):void {
            var item:Item = _map.itemBeingDragged;
            if (!item) {
                return;
            }
            if (_furnitureList) {
                _furnitureList.add(item);
            }
            _map.stopDraggingItem();
            moveFurniture(item, false);
        }
        
        private function onEditModeToggle(e:UserHomesEvent = null):void {
            var me:Avatar = _map.avatarManager.avatarByName(_es.getUserManager().getMe().getUserName());
            var stopTile:Tile = _map.getTile(me.col, me.row);
            var path:Path = new Path();
            path.addNode(stopTile);
            sendWalkPath(path);
            _map.isEditable = !_map.isEditable;
            if (_map.isEditable) {
                _map.showGrid();
                for each (var furn:Furniture in _furniture) {
                    if (!furn.isInWorld) {
                        _furnitureList.add(furn.item);
                    }
                }
                _map.getTile(me.col, me.row).disable();
                _furnitureList.visible = true;
            } else {
                _map.hideGrid();
                _map.getTile(me.col, me.row).enable();
                _furnitureList.visible = false;
                _furnitureList.clearAll();
            }
        }
        
        private function onHomesExited(e:UserHomesEvent):void {
            if (_map) {
                if (_map.isEditable) {
                    if (_map.itemBeingDragged) {
                        onItemRecycled();
                    }
                    onEditModeToggle();
                }
                if (_map.itemManager) {
                    _map.itemManager.removeEventListener(ItemInteractionEvent.ITEM_CLICKED, onItemClicked);
                }
                _map.isEditable = false;
                _map.stopDraggingItem();
                _map.removeEventListener(ItemInteractionEvent.ITEM_SELECTED, onItemSelected);
                _map.removeEventListener(ItemInteractionEvent.ITEM_PLACED, onItemPlaced);
            }
            if (_bottomUI) {
                _bottomUI.home_btn.visible = true;
                _bottomUI.worldButton.visible = false;
                _bottomUI.removeEventListener(UserHomesEvent.EXIT_HOMES, onHomesExited);
            }
            if (_homesBottomUI) {
                _homesBottomUI.removeEventListener(UserHomesEvent.EDIT_MODE_TOGGLE, onEditModeToggle);
                _homesBottomUI.removeEventListener(UserHomesEvent.ITEM_RECYCLED, onItemRecycled);
                if (_homesBottomUI.parent) {
                    _homesBottomUI.parent.removeChild(_homesBottomUI);
                }
                _homesBottomUI = null;
            }
            if (_furnitureList) {
                _furnitureList.removeEventListener(UserHomesEvent.ITEM_SELECTED, onListItemSelected);
                if (_furnitureList.parent) {
                    _furnitureList.parent.removeChild(_furnitureList);
                }
                _furnitureList = null;
            }
            dispatchEvent(new Event(BACK_TO_WORLD));
        }
        
        private function onListItemSelected(e:UserHomesEvent):void {
            _map.startDraggingItem(e.item);
            e.item.filters = [new GlowFilter(0x009900)];
        }
        
        private function onItemPlaced(e:ItemInteractionEvent):void {
			e.item.filters = [];
            moveFurniture(e.item, true);
		}
		
		private function onItemSelected(e:ItemInteractionEvent):void {
			_map.removeItem(e.item);
			_map.startDraggingItem(e.item);
            
			e.item.filters = [new GlowFilter(0x009900)];
		}
       
		private function onItemClicked(e:ItemInteractionEvent):void {
			var item:Item = e.item;
			switch (item.onClickEvent) {
				case "furniture":
					showFurnitureUI();
					break;
				default:
					trace("Item click event not handled: " + item.onClickEvent);
			}
		}
		
		private function showFurnitureUI():void {					
			
			if (_vendorScreen) {
				cancelFurnitureUI(null);
			}
			
			_vendorScreen = new VendorScreen(_furnitureManager.furnitureDefinitions);
			_vendorScreen.addEventListener(Event.CLOSE, cancelFurnitureUI);
			
			_vendorScreen.addEventListener(VendorEvent.MERCHANDISE_SELECTED, confirmPurchase);
			
			_vendorScreen.x = 150;
			_vendorScreen.y = 300;
			
			addChild(_vendorScreen);
		}
		
		private function confirmPurchase(e:VendorEvent):void {					
					
			cancelFurnitureUI(null);
								
			var selection:FurnitureDefinition = FurnitureDefinition(e.data);			
			var msg:String = "Do you want to buy the\n" + selection.name + " for $" + selection.cost + "?";			
			
			_confirmationPopup = new ConfirmationPopup(selection, msg);
			_confirmationPopup.addEventListener(ConfirmationPopup.CONFIRM_NO, cancelPurchase);
			_confirmationPopup.addEventListener(ConfirmationPopup.CONFIRM_YES, makePurchase);
			
			_confirmationPopup.x = 300;
			_confirmationPopup.y = 300;
			
			addChild(_confirmationPopup);
		}
		
		private function cancelPurchase(e:Event):void {
			trace("closing popup");
			
			removeChild(_confirmationPopup);
			
			_confirmationPopup.removeEventListener(ConfirmationPopup.CONFIRM_NO, cancelPurchase);
			_confirmationPopup.removeEventListener(ConfirmationPopup.CONFIRM_YES, makePurchase);
			
			_confirmationPopup.destroy();
			_confirmationPopup = null;
		}
		
		private function cancelFurnitureUI(e:Event):void {
			removeChild(_vendorScreen);
			
			_vendorScreen.removeEventListener(VendorEvent.MERCHANDISE_SELECTED, confirmPurchase);
			
			_vendorScreen.destroy();
			_vendorScreen = null;
		}
		
		private function makePurchase(e:Event):void {
			var selection:FurnitureDefinition = FurnitureDefinition(_confirmationPopup.data);
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.BUY_ITEM);
			esob.setString(PluginConstants.ITEM_TYPE, PluginConstants.FURNITURE_ITEM_TYPE);
			esob.setInteger(PluginConstants.ITEM_ID, selection.id);
			
			sendToWorldPlugin(esob);
			
			cancelPurchase(null);
		}
		
		
		private function onAvatarClicked(e:AvatarEvent):void {
			var avatar:Avatar = e.avatar;
			
			if (!avatar.isMe) {
				var msg:String = "Add " + avatar.avatarName + " as a buddy?";
				
				var pop:BuddyConfirmationPopup = new BuddyConfirmationPopup(avatar, msg);
				
				pop.x = 300;
				pop.y = 280;
				pop.addEventListener(BuddyConfirmationPopup.CONFIRM_NO, onBuddyConfirmNo);
				pop.addEventListener(BuddyConfirmationPopup.CONFIRM_YES, onBuddyConfirmYes);
				addChild(pop);
			}
		}
		
		
		
		private function removeBuddy(avatar:Avatar):void {
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.REMOVE_BUDDY);
			esob.setInteger(PluginConstants.BUDDY_ID, avatar.avatarId);
			
			sendToWorldPlugin(esob);
			
			_buddyList.removeAvatar(avatar.avatarName);
		}
		
		private function onBuddyConfirmYes(e:Event):void {
			var pop:BuddyConfirmationPopup = e.target as BuddyConfirmationPopup;
			
			var avatar:Avatar = pop.avatar;
			
			var esob:EsObject = new EsObject();
			esob.setString(PluginConstants.ACTION, PluginConstants.ADD_BUDDY);
			esob.setInteger(PluginConstants.BUDDY_ID, avatar.avatarId);
			
			sendToWorldPlugin(esob);
			
			_buddyList.addAvatar(avatar);
			
			removeBuddyConfirmPopup(pop);
		}
		
		private function onBuddyConfirmNo(e:Event):void {
			removeBuddyConfirmPopup(e.target as BuddyConfirmationPopup);
		}
		
		private function removeBuddyConfirmPopup(pop:BuddyConfirmationPopup):void{
			pop.removeEventListener( BuddyConfirmationPopup.CONFIRM_NO, onBuddyConfirmNo);
			pop.removeEventListener( BuddyConfirmationPopup.CONFIRM_YES, onBuddyConfirmYes);
			removeChild(pop);
		}
		
		private function joinRoom():void{
			var crr:CreateRoomRequest = new CreateRoomRequest();
			crr.setRoomName(_mapUrl);
			crr.setZoneName("world zone");
			
			var pl:Plugin = new Plugin();
			pl.setPluginHandle("AreaPlugin");
			pl.setPluginName("AreaPlugin");
			pl.setExtensionName("GameBook");
			
			if (_isHome) {
				crr.setRoomName(_owner);
				pl.getData().setString(PluginConstants.ROOM_OWNER, _owner);
			}
			
			crr.setPlugins([pl]);
			
			_es.send(crr);
		}
		
		public function set clothingManager(value:ClothingManager):void {
			_clothingManager = value;
		}
		
		public function set es(value:ElectroServer):void {
			_es = value;
		}
		
		public function get clock():Clock { return _clock; }
		
		public function set clock(value:Clock):void {
			_clock = value;
		}
		
		public function get destination():String { return _destination; }
		
		public function set furnitureManager(value:FurnitureManager):void {
			_furnitureManager = value;
		}
		
		public function set buddyList(value:AvatarManager):void {
			_buddyList = value;
		}
		
		public function get owner():String { return _owner; }
		
		
	}
	
}
