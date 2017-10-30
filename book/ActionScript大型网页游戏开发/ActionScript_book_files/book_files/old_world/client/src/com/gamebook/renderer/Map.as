package com.gamebook.renderer {
	import com.gamebook.renderer.events.AvatarEvent;
	import com.gamebook.renderer.events.ItemInteractionEvent;
	import com.gamebook.renderer.events.TileEvent;
	import com.gamebook.renderer.item.Item;
	import com.gamebook.renderer.item.ItemManager;
	import com.gamebook.renderer.tile.Tile;
	import com.gamebook.renderer.tile.WayPoint;
	import com.gamebook.utils.astar.INode;
	import com.gamebook.utils.astar.ISearchable;
	import com.gamebook.utils.Isometric;
	import com.gamebook.utils.network.clock.Clock;
	import com.gamebook.utils.TileAssetsUtil;
	import com.gamebook.utils.assetsloader.Asset;
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetEvent;
	import com.gamebook.utils.geom.Coordinate;
	import com.gamebook.world.avatar.Avatar;
	import com.gamebook.world.avatar.AvatarManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Map extends Sprite implements ISearchable {
		
		public static const READY:String = "ready";
		
        /**
         * @private
         * renderable grid
         */
        private var _renderGrid:Sprite = new Sprite();
        
        private var coord:Coordinate;
        
		private var _grid:Array;
        private var _cols:int;
		private var _rows:int;
        
		private var _background:Background;
		protected var _draggleLayer:Sprite;
		
		private var _sortables:Array;
		
		//width of tile in 3D
		private var _tileWidth:Number;
		
		//height of tile in 3D
		private var _tileHeight:Number;
		
		private var _ground:Sprite;
		private var _itemManager:ItemManager;
		
		//AssetsLoader instance used to load the map xml
		private var _asl:AssetsLoader;
		
		private var _iso:Isometric;
		private var _tileWidthOnScreen:int;
		private var _tileHeightOnScreen:int;
		
        // width & height of a grid cell prior to rotation
        private var _cellWidth:Number = Math.sqrt(2048);
        
		private var _isEditable:Boolean;
        private var _isHome:Boolean;
		
		private var _itemBeingDragged:Item;
		
		private var _baseDirectory:String = "";
		
		private var _avatarManager:AvatarManager;
		private var _clock:Clock;
		private var _topLayer:Sprite;
		
		public function Map( isHome:Boolean = false, baseDirectory:String = "" ) {
            _iso = new Isometric();
            _isHome = isHome;
            this._baseDirectory = baseDirectory;
            Tile.setBitmapData(TileAssetsUtil.LEGAL_TILE_DATA, TileAssetsUtil.ILLEGAL_TILE_DATA);
		}
		
		private function buildMap():void {
			
			_isEditable = false;
			
			_sortables = [];
			
			_avatarManager = new AvatarManager();
			
			//when mapped to the screen the tile makes a diamond of these dimensions
			_tileWidthOnScreen = 64;
			_tileHeightOnScreen = 32;
			
			//figure out the width of the tile in 3D space
			_tileWidth = _iso.mapToIsoWorld(64, 0).x;
			
			//the tile is a square in 3D space so the height matches the width
			_tileHeight = _tileWidth;
			
			//add background
			addChild(_background);
            
            _renderGrid.visible = false;
            addChild( _renderGrid );
            
			//add ground - all items and avatars get added to this
			_ground = new Sprite();
			addChild(_ground);
			
			//add display object that will contain an item while it is being dragged
			_draggleLayer = new Sprite();
			addChild(_draggleLayer);
			
			_topLayer = new Sprite();
			addChild(_topLayer);
			
			//add items to the grid
			addItemsToGrid();
			
			addEventListener(Event.ENTER_FRAME, run);
			
			dispatchEvent(new Event(READY));
		}
		
		private function run(e:Event):void {
			moveAvatars();
			
			sortMovableItems();
			
			moveScreen();
		}
		
		private function moveScreen():void {
			if (_avatarManager.me) {
				x = 400 - _avatarManager.me.x;
				y = 300 - _avatarManager.me.y;
			}
		}
		
		private function moveAvatars():void{
			for each (var avatar:Avatar in _avatarManager.avatars) {
				if (avatar.state == Avatar.WALKING) {
					stepAvatar(avatar);
				}
				avatar.run();
			}
		}
		
		private function stepAvatar(avatar:Avatar):void{
			var time:Number = _clock.time;
			var wp:WayPoint;
			var ind:int = avatar.wayPointIndex;
			
			//is it time for the next way point?
			if (ind < avatar.wayPoints.length - 1) {
				wp = avatar.wayPoints[ind + 1];
				if (time > wp.time) {
					avatar.wayPointIndex = ind + 1;
					ind = ind +1;
				}
			}
			
			//current way point
			wp = avatar.wayPoints[ind];
			
			var x:Number;
			var y:Number = 0;
			var z:Number;
			
			//position in isometric space
			x = _tileWidth * wp.tile.col;
			z = _tileHeight * wp.tile.row;
			
			var elapsed:Number = _clock.time - wp.time;
				
			if (ind == avatar.wayPoints.length - 1) {
				avatar.changeState(Avatar.IDLE);
				checkForOnStopEvent();
			} else {
				x += elapsed * avatar.walkSpeed * avatar.cosAngle;
				z += elapsed * avatar.walkSpeed * avatar.sinAngle;
			}
			
			var coord:Coordinate = _iso.mapToScreen(x, y, -z);
			avatar.x = coord.x;
			avatar.y = coord.y;
		}
		
		private function checkForOnStopEvent():void{
			var tile:Tile = getTile(_avatarManager.me.col, _avatarManager.me.row);
			
			for (var i:int = 0; i < tile.items.length;++i) {
				var itm:Item = tile.items[i];
				if (itm.onStopEvent != null) {
					var evt:TileEvent = new TileEvent(TileEvent.STOPPED_ON_TILE, tile);
					evt.eventParameter = itm.onStopEvent;
					
					dispatchEvent(evt);
				}
			}
		}
		
		public function addAvatar(avatar:Avatar):void {
			if (!_avatarManager.doesAvatarExist(avatar.avatarName)) {
				_avatarManager.addAvatar(avatar);
				
				avatar.col = 8;
				avatar.row = 8;
				
				placeSortableItem(avatar, false);
				
				_topLayer.addChild(avatar.chatBubble);
				_topLayer.addChild(avatar.namePlate);
			}
		}
		
		public function removeAvatar(name:String):void {
			
			var avatar:Avatar = _avatarManager.avatarByName(name);
			_ground.removeChild(avatar);
			
			_topLayer.removeChild(avatar.chatBubble);
			_topLayer.removeChild(avatar.namePlate);
			
			_avatarManager.removeAvatar(name);
			
		}
		
		public function walkAvatar(name:String, time:Number, tiles:Array):void {
			var avatar:Avatar = _avatarManager.avatarByName(name);
			
			var wpIndex:int = 0;
			
			var wayPoints:Array = [];
			for (var i:int = 0; i < tiles.length;++i) {
				var tile:Tile = tiles[i];
				var dis:Number;
				if (i != 0) {
					dis = getDistance(tile, tiles[i - 1]);
					time += dis / avatar.walkSpeed;
				}
				
				var wp:WayPoint = new WayPoint();
				wp.time = Math.round(time);
				wp.tile = tile;
				
				if (_clock.time > wp.time) {
					wpIndex = i;
				}
				
				wayPoints.push(wp);
			}
			
			avatar.walk(wayPoints);
			avatar.wayPointIndex = wpIndex;
		}
		
		public function getDistance(t1:Tile, t2:Tile):Number {
			var dis:Number = Math.sqrt(Math.pow((t1.col - t2.col) * _tileWidth, 2) + Math.pow((t1.row - t2.row) * _tileHeight, 2));
			return dis;
		}
				
		/**
		 * This function is called just once after the map xml is loaded
		 */
		private function addItemsToGrid():void {
			for (var i:int = 0; i < _itemManager.items.length;++i) {
				var item:Item = _itemManager.items[i];
				placeItem(item);
			}
			
			sortAllItems();
			sortAllItems();
		}
		
		/**
		 * Sorts all sortable items.
		 */
		private function sortAllItems():void {
			var list:Array = _sortables.slice(0);
			
			_sortables = [];
			
			for (var i:int = 0; i < list.length;++i) {
				var nsi:ISortable = list[i];
				
				var added:Boolean = false;
				for (var j:int = 0; j < _sortables.length;++j ) {
					var si:ISortable = _sortables[j];
					if (nsi.col <= si.col + si.cols - 1 && nsi.row <= si.row + si.rows - 1) {
						_sortables.splice(j, 0, nsi);
						added = true;
						break;
					}
				}
				if (!added) {
					_sortables.push(nsi);
				}
			}
			
			for (i = 0; i < _sortables.length;++i) {
				var disp:DisplayObject = _sortables[i] as DisplayObject;
				_ground.addChildAt(disp, i);
			}
		}
		
		/**
		 * Sorts all sortable items.
		 */
		private function sortMovableItems():void {
			var list:Array = _sortables.slice(0);
			var moving_arr:Array = _avatarManager.avatars;
			
			for (var i:int = 0; i < moving_arr.length;++i) {
				var nsi:ISortable = moving_arr[i];
				var added:Boolean = false;
				for (var j:int = 0; j < list.length;++j ) {
					var si:ISortable = list[j];
					
					if (nsi.col <= si.col + si.cols - 1 && nsi.row <= si.row + si.rows - 1) {
						list.splice(j, 0, nsi);
						added = true;
						break;
					}
				}
				if (!added) {
					list.push(nsi);
				}
			}
			
			for (i = 0; i < list.length;++i) {
				var disp:DisplayObject = list[i] as DisplayObject;
				_ground.addChildAt(disp, i);
			}
		}
		
		/**
		 * Places and item into the map
		 * @param	Item to be placed
		 */
		public function placeItem(item:Item):void {
			
			placeSortableItem(item);
			
			//tell all the tiles the item is touching about the item. tell the item about all the tiles.
			for (var i:int = item.col;i < item.col + item.itemDefinition.cols; ++i) {
				for (var j:int = item.row;j < item.row + item.itemDefinition.rows; ++j) {
					var t:Tile = getTile(i, j);
					t.addItem(item);
					item.addTile(t);
				}
			}
		}
		
		private function placeSortableItem(sortable:ISortable, insert:Boolean = true):void{
			//add to display list
			_ground.addChild(sortable as DisplayObject);
			
			if (insert) {
				//add to sortable items list
				_sortables.push(sortable);
			}
			
			//find 3D coordinates
			var iso_x:Number = sortable.col * _tileWidth;
			var iso_z:Number = -sortable.row * _tileHeight;
			
			//map 3D coordinates to the screen
			var screenCoord:Coordinate = _iso.mapToScreen(iso_x, 0, iso_z);
			
			//update display object with screen coordinates
			(sortable as DisplayObject).x = screenCoord.x;
			(sortable as DisplayObject).y = screenCoord.y;
		}
		
		/**
		 * Removes item from the map
		 * @param	Item to be removed
		 */
		public function removeItem(item:Item):void {
			var i:int;
			if ( !_sortables ) return;
			//remove from sortable items list
			for (i = 0; i < _sortables.length;++i) {
				if (_sortables[i] == item) {
					_sortables.splice(i, 1);
					break;
				}
			}
			
			//remove the item from the display list
            if (_ground && item && _ground.contains(item)) {
                _ground.removeChild(item);
            }
			
			stopDraggingItem();
					
			//remove a reference to the item on all of the tiles it was touching. remove all the tile references from the item.
			for (i = item.tiles.length - 1; i >= 0;--i) {
				var t:Tile = item.tiles[i];
				item.removeTile(t);
				
				t.removeItem(item);
			}
			
			//try { itemManager.removeItem( item ); } catch( e:Error ){ };
			itemManager.removeItem( item ); 
		}
		
		/**
		 * Takes a mouse click and checks it against all items. The item with the highest display order that was clicked on wins and is dispatched in an event.
		 * @param	x position
		 * @param	y position
		 */
		private function boardInteractedWith(tx:int, ty:int):void {
			if (isEditable) {
				for (var i:int = _sortables.length - 1; i >= 0;--i) {
					var si:ISortable = _sortables[i];
					if (si as Item) {
						if (Item(si).isInteractive && Item(si).checkPointCollision(tx - Item(si).x, ty - Item(si).y)) {
							
							var event:ItemInteractionEvent = new ItemInteractionEvent( ItemInteractionEvent.ITEM_SELECTED );
							event.item = Item(si);
							
							dispatchEvent(event);
							break;
						}
					}
				}
			}
			
			var avatarClicked:Boolean = false;
			for each (var avatar:Avatar in _avatarManager.avatars) {
				if (avatar.checkPointCollision(tx-avatar.x, ty-avatar.y)) {
					avatarClicked = true;
					var ae:AvatarEvent = new AvatarEvent(AvatarEvent.AVATAR_CLICKED);
					ae.avatar = avatar;
					dispatchEvent(ae);
				}
			}
			
			var clickedTile:Tile = getTileFromScreenCoordinates( tx, ty );
			
			if( clickedTile && !avatarClicked) {
				dispatchEvent( new TileEvent( TileEvent.TILE_CLICKED, clickedTile, true ) );
			}
		}	
		
		/**
		 * Starts dragging an item that exists but is *not in the world*
		 * @param	The item to be dragged
		 */
		public function startDraggingItem(item:Item):void {
			if (_itemBeingDragged == null) {
				_itemBeingDragged = item;
				if( _draggleLayer )
					_draggleLayer.addChild(_itemBeingDragged);
				
				dragItem();
			} else {
				trace("Error: tried to start dragging an item when another is already being dragged.");
			}
		}
		
		/**
		 * Stops dragging the item currently being dragged
		 */
		public function stopDraggingItem():void {
            if (_itemBeingDragged && _itemBeingDragged.parent)
                _itemBeingDragged.parent.removeChild(_itemBeingDragged);
			_itemBeingDragged = null;
		}
		
		/**
		 * updates the position of the item currently being dragged
		 */
		private function dragItem():void {
			_itemBeingDragged.x = mouseX;
			_itemBeingDragged.y = mouseY-_tileHeightOnScreen/2;
		}
		
		/**
		 * Attempt to place an item in the world that is not already in the world based on screen x/y pixel coordinates. If all tiles that it would take up exist and are marked as !overlap, then it succeeds and an event is dispatched.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	returns true if placed successfully
		 */
		public function attemptPlaceItem(tx:int, ty:int):Boolean {
			var tile:Tile = getTileFromScreenCoordinates(tx, ty);
			var placed:Boolean = false;
			if (tile != null && placementTest(tile, _itemBeingDragged)) {
				var item:Item = _itemBeingDragged;
				item.col = tile.col;
				item.row = tile.row;
				
				stopDraggingItem();
				
				placeItem(item);
				
				itemManager.addItem( item );
				
				sortAllItems();
				
				placed = true;
				
				var event:ItemInteractionEvent = new ItemInteractionEvent(ItemInteractionEvent.ITEM_PLACED);
				event.item = item;
				dispatchEvent(event);
			}
			return placed;
		}
		
		/**
		 * Checks to see if the item can be placed on that tile. It takes into account all tiles in the span of the item.
		 * @param	The tile that the item could be placed on
		 * @param	The item to be placed
		 * @return	returns true if it is a valid placement
		 */
		public function placementTest(tile:Tile, item:Item):Boolean {
			var valid:Boolean = true;
			
			for (var i:int = tile.col; i < tile.col + item.cols;++i) {
				for (var j:int = tile.row; j < tile.row + item.rows;++j) {
					var t:Tile = getTile(i, j);
					if (t == null || !t.allowsItemPlacement()) {
						valid = false;
						break;
					}
				}
			}
			
			return valid;
		}
		
		/**
		 * Returns a tile based on screen coordinates. Null is returned if the position is invalid.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	the tile found at those coordinates, or null
		 */
		public function getTileFromScreenCoordinates(tx:int, ty:int):Tile {
			var coord:Coordinate = _iso.mapToIsoWorld(tx, ty);
			var col:int = Math.floor(coord.x / _tileWidth);
			var row:int = Math.floor( -coord.z / _tileHeight);
			
			return getTile(col, row);
		}
		
		/**
		 * Creates all tiles needed based on the size of the world
		 */
		private function createGrid():void {
			
			//number of columns in the entire map
			_cols = _background.cols;
			
			//number of rows in the entire map
			_rows = _background.rows;
			
			_grid = [];
			
            var coord:Coordinate;
			for (var i:int = 0; i < _cols;++i) {
				_grid[i] = [];
				for (var j:int = 0; j < _rows;++j) {
					var t:Tile = new Tile();
					t.col = i;
					t.row = j;
                    coord = _iso.mapToScreen(i * _cellWidth, 0, -j * _cellWidth);
                    t.tileBitmap.x = coord.x - 32;
                    t.tileBitmap.y = coord.y;
                    _renderGrid.addChild(t.tileBitmap);
					_grid[i][j] = t;
				}
			}
			_renderGrid.y = _background.y;
            _renderGrid.alpha = 0.4;
            _renderGrid.visible = false;
		}
		
		
		private function parseTileXML(info:XML):void {
			for each (var tile_xml:XML in info.Tiles.Tile) {
				var col:int = int(tile_xml.@col);
				var row:int = int(tile_xml.@row);
				
				var t:Tile = getTile(col, row);
				t.fromXML(tile_xml);
			}
		}
		
		/**
		 * Returns the tile based on column and row
		 * @param	column
		 * @param	row
		 * @return	the tile or null
		 */
		public function getTile(col:int, row:int):Tile {
			if (col < _cols && col >=0 && row < _rows && row >=0 ) {
				return _grid[col][row];
			} else {
				return null;
			}
		}
		
		/**
		 * Loads a map used to show
		 * @param	url of the map xml file
		 */
		public function loadMap(url:String):void {
			_asl = new AssetsLoader();
			var asset:Asset = _asl.loadAsset(url, AssetType.TEXT);
			_asl.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
			
		}
		
		
		private function onAssetComplete(e:AssetEvent):void {
			if (e.success) {
				var xml:XML = new XML(e.asset.data);
				fromXML(xml);
			} else {
				throw new Error("Failed to load map xml from: " + e.asset.url);
			}
		}
		
		public function fromXML(info:XML):void {
			_background = new Background();
			_background.addEventListener(Background.DONE_LOADING, onDoneLoading);
			_background.baseDirectory = _baseDirectory + "assets/";
			_background.fromXML(info);
			
			_itemManager = new ItemManager();
			_itemManager.addEventListener(ItemManager.DONE_LOADING, onDoneLoading);
			_itemManager.baseDirectory = _baseDirectory + "assets/";
			_itemManager.fromXML(info);
			
			//build default grid layout
			createGrid();
			
			//change tile flags
			parseTileXML(info);
			
		}
		
		public function toXML():XML	{
			var xmlString:String = "";
			xmlString += "<map>\n";
			
			//Background
			xmlString += _background.toXML() + "\n";
			
			//Item definitions and instances
			xmlString += _itemManager.toXML();
			
			//Tiles
			xmlString += getTileXML();
			
			xmlString += "</map>";
			
			return XML( xmlString );
		}
		
		private function getTileXML():String{
			var numRows:int = rows;
			var numCols:int = columns;
			
			var tilesXML:String = "";
			
			tilesXML += "<Tiles>\n";
			
			for ( var r:int = 0; r < numRows; r++ )	{				
				for ( var c:int = 0; c < numCols; c++ )	{
					var tile:Tile = getTile( c, r );
					
					if ( !tile ) continue;
					
					//If the tile does not have the default settings then add its xml
					if ( !tile.baseWalkability || !tile.basePlaceability )
						tilesXML += "\t" + tile.toXML() + "\n";					
				}			
			}			
			tilesXML += "</Tiles>\n";
			
			return tilesXML;
		}
		
		public function toggleGrid():void {
			_renderGrid.visible = !_renderGrid.visible;
		}
		
		public function showGrid():void	{
			_renderGrid.visible = true;
		}
		
		public function hideGrid():void	{
			_renderGrid.visible = false;
		}
		
		private function onDoneLoading(e:Event):void {
			if (_background.ready && _itemManager.ready) {
				//clean up listeners
				_itemManager.removeEventListener(ItemManager.DONE_LOADING, onDoneLoading);
				_background.removeEventListener(Background.DONE_LOADING, onDoneLoading);
				buildMap();
			}
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, run);
			try {
				stage.removeEventListener(MouseEvent.CLICK, onClick);
			} catch (e:Error){
				
			}
			
			
		}
		
		public function get itemManager():ItemManager {	return _itemManager; }
		
		public function get isEditable():Boolean { return _isEditable; }
		
		public function set isEditable(value:Boolean):void {
			_isEditable = value;
			stage.addEventListener(MouseEvent.CLICK, onClick);
			if (_isEditable) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
			}
		}			
		
		private function mouseMoved(e:MouseEvent):void {
			if (isEditable && _itemBeingDragged != null) {
				dragItem();
			}
		}
		
		private function onClick(e:MouseEvent):void {
            e.stopImmediatePropagation();
            e.stopPropagation();
			if (_itemBeingDragged == null) {
				boardInteractedWith(mouseX, mouseY);
			} else if (_itemBeingDragged != null) {
				attemptPlaceItem(mouseX, mouseY);
			}
		}      
		
		/* INTERFACE com.gamebook.utils.astar.ISearchable */
		
		public function getCols():int{
			return _cols;
		}
		
		public function getRows():int{
			return _rows;
		}
		
		public function getNode(col:int, row:int):INode{
			return getTile(col, row);
		}
		
		public function getNodeTransitionCost(n1:INode, n2:INode):Number {
			var cost:Number = 1;
			if (!Tile(n1).walkable || !Tile(n2).walkable) {
				cost = 100000;
			}
			return cost;
		}
        		
        public function get columns():int {
            return _cols;
        }
        
        public function get rows():int {
            return _rows;
        }
		
        public function get iso():Isometric {
            return _iso;
        }
        
        public function get background():Background {
            return _background;
        }
		
		public function get avatarManager():AvatarManager { return _avatarManager; }
		
		public function get clock():Clock { return _clock; }
		
		public function set clock(value:Clock):void {
			_clock = value;
		}
        
        public function get itemBeingDragged():Item {
            return _itemBeingDragged;
        }
		
	}
	
}
