package com.gamebook.ui.homes {

    import com.gamebook.renderer.events.UserHomesEvent;
    import com.gamebook.renderer.item.Item;
    import com.gamebook.utils.DisplayObjectUtil;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.utils.getQualifiedClassName;
    
    /// Embed the UI resources
    [Embed(source='/assets/ui/homes-inventory.swf', symbol='HomesInventory')]

    /**
     * This class represents the User Homes Item Listing.
     * 
     * @author Matt Bolt
     */
    public class UserHomesItemList extends MovieClip {

        //--------------------------------------------------------------------------
        //
        //  Private Data
        //
        //--------------------------------------------------------------------------

        // Layer 1
        public var titleText:TextField;
        public var scrollDown:SimpleButton;
        public var scrollUp:SimpleButton;
        public var scrollThumb:SimpleButton;
        private var _scrolling:Boolean = false;
        private var _stageReference:Stage;
        
        private var _tiles:Sprite = new Sprite();
        private var _tileMask:Sprite = new Sprite();
        private var _list:Array = [];
        private var _cx:Number = -1;
        private var _cy:Number = -1;

        private static var thumbY:Number;
        private static var thumbHeight:Number;
        private static var globalDataTag:int = 500;
        
        private static const TOP_LEFT:Point = new Point(22, 38);
        private static const WIDTH_PAD:Number = 65;
        private static const HEIGHT_PAD:Number = 62;
        

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        /**
         * <code>UserHomesItemList</code> Constructor.
         */
        public function UserHomesItemList() {
            
            // Add Dragable Area for the Title Bar TextField
            titleText.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            
            // Set Tile Mask Position
            _tileMask.x = TOP_LEFT.x;
            _tileMask.y = TOP_LEFT.y;
            
            // Draw the Mask Fill
            with (_tileMask.graphics) {
                beginFill(0xFF0000, 1);
                drawRect(0, 0, WIDTH_PAD * 4, HEIGHT_PAD * 3);
                endFill();
            }
            
            // Add the Tiles Sprite and the Mask
            addChild(_tiles);
            addChild(_tileMask);
            
            // Set the mask for the tiles and disable the mouse
            _tiles.mask = _tileMask;
            _tiles.mouseEnabled = false;
            
            // Set Static Thumb Values
            scrollThumb.y = thumbY = 60.9;
            scrollThumb.height = thumbHeight = 128.5;
            
            // Add Scroll Listener
            scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, onScroll);
            
            // Add Stage Listener for Movement and Removal
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        /**
         * @private
         * scroll handler
         */
        private function onStageMouseUp(e:MouseEvent):void {
            if (_scrolling) {
                _scrolling = false;
            }
        }
        
        /**
         * @private
         * scroll handler
         */
        private function onScroll(e:MouseEvent):void {
            var shouldScroll:Boolean = scrollThumb.height != thumbHeight || scrollThumb.y != thumbY;
            if (!shouldScroll) {
                _scrolling = false;
                return;
            }
            if (!_scrolling) {
                _scrolling = true;
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //--------------------------------------------------------------------------

        /**
         * Adds an item to the inventory list.
         */
        public function add(item:Item):void {
            if (!item) {
                trace('Item is NULL');
                return;
            }
            
            // Use the File as the Item Name
            var itemName:String = item.itemDefinition.file;
            
            // Clone the Item Image for a Thumbnail
            var itemClone:BitmapData = item.itemDefinition.bitmapData.clone();
            var cloneBitmap:Bitmap = new Bitmap(itemClone);
            var itemData:Object = { id: globalDataTag++, name: itemName, item: item, thumb: cloneBitmap }
            
            // Create new Tile Object => Pass Item Data
            var itmTile:UserHomesItemTile = new UserHomesItemTile(itemData);
            
            // Determine Best Fit
            var i:int = _list.push(itmTile) - 1;
            itmTile.x = TOP_LEFT.x + (i % 4) * WIDTH_PAD;
            itmTile.y = TOP_LEFT.y + (i % 4 == 0 ? ++_cy : _cy) * HEIGHT_PAD;
            
            // Add Click Listener for "Homes Item Selection"
            itmTile.addEventListener(MouseEvent.CLICK, onTileClick);
            
            // Add to the List
            _tiles.addChild(itmTile);
            
        }
        
        /**
         * @private
         * item selection handler
         */
        private function onTileClick(e:MouseEvent):void {
            
            // Stop Event from Progagating
            e.stopImmediatePropagation();
            e.stopPropagation();
            
            // Set tile and remove listener
            var tile:UserHomesItemTile = UserHomesItemTile(e.target);
            tile.removeEventListener(MouseEvent.CLICK, onTileClick);
            
            // Pull item data from tile
            var item:Item = tile.item;
            dispatchEvent(new UserHomesEvent(UserHomesEvent.ITEM_SELECTED, item));
            
            // Remove from List
            remove(item);
            
        }

        /**
         * Removes an item from the inventory list.
         */
        public function remove(item:Item):void {
            if (indexOf(item) == -1)
                return;
            _list.splice(indexOf(item), 1);
            redrawList();
        }
        
        /**
         * This function clears all items from the list.
         */
        public function clearAll():void {
             // Clear List and Counters
            _cy = -1;
            _list.length = 0;
            
            // Use our Display Util to clear the tile Sprite
            DisplayObjectUtil.removeAllChildren(_tiles);
            addChild(_tiles);
        }

        /**
         * @private
         * returns the index of the item holding the item data
         */
        private function indexOf(item:Item):int {
            for (var i:int = 0; i < _list.length; ++i) {
                var homeTile:UserHomesItemTile = UserHomesItemTile(_list[i]);
                if (homeTile.item === item) {
                    return i;
                }
            }
            return -1;
        }

        //--------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         * this helper function redraws the tile list
         */
        private function redrawList():void {
            
            // Make a Copy of the List and Clear
            var listCopy:Array = _list.concat();
            clearAll();
            
            // Iterate through the copy and re-add items
            for (var i:int = 0; i < listCopy.length; ++i) {
                add(UserHomesItemTile(listCopy[i]).item);
            }
            
            // Reset Scroller to the Base Position
            var pt:Point = localToGlobal(new Point(0, 0));
            updateScroller(pt.x, pt.y);
            
        }

        //--------------------------------------------------------------------------
        //
        //  Event Handlers
        //
        //--------------------------------------------------------------------------

        /**
         * @private
         * mouse down: drag handler
         */
        private function onMouseDown(e:MouseEvent):void {
            e.stopPropagation();
            e.stopImmediatePropagation();
            titleText.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            titleText.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            titleText.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            startDrag();
        }

        /**
         * @private
         * mouse move: drag handler
         */
        private function onMouseMove(e:MouseEvent):void {
            if (!e.buttonDown)
                onMouseUp();
        }

        /**
         * @private
         * mouse up: drag handler.
         */
        private function onMouseUp(e:MouseEvent = null):void {
            e.stopPropagation();
            e.stopImmediatePropagation();
            titleText.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            titleText.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            titleText.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stopDrag();
        }
        
        /**
         * @private
         * stage add handler
         */
        private function onAddedToStage(e:Event):void {
            _stageReference = stage;
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            addEventListener(Event.REMOVED_FROM_STAGE, onStageRemoved);
        }
        
        private function onStageRemoved(e:Event):void {
            removeEventListener(Event.REMOVED_FROM_STAGE, onStageRemoved);
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            _stageReference.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            _stageReference.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
            _stageReference = null;
        }
        
        /**
         * @private
         * scroll handler
         */
        private function onStageMouseMove(e:MouseEvent):void {
            var shouldScroll:Boolean = scrollThumb.height != thumbHeight || scrollThumb.y != thumbY;
            if (!shouldScroll) {
                _scrolling = false;
                return;
            }
            if (_scrolling) {
                updateScroller(e.stageX, e.stageY);
            } 
        }
        
        /**
         * @private
         * updates the scroller
         */
        private function updateScroller(ptX:Number, ptY:Number):void {
            var diffH:Number = thumbHeight - scrollThumb.height;
            var diffY:Number = thumbY - scrollThumb.y;
            diffH = diffH < 0 ? -diffH : diffH;
            diffY = diffY < 0 ? -diffY : diffY;
            
            if (diffH < 2 && diffY < 2) {
                _scrolling = false;
                return;
            }
            
            scrollThumb.y = globalToLocal(new Point(ptX, ptY)).y;
            if (scrollThumb.y > thumbY + thumbHeight) {
                scrollThumb.y = thumbY + thumbHeight;
                _tiles.y = -_tiles.height + _tileMask.height;
            } else if (scrollThumb.y + scrollThumb.height < thumbY + thumbHeight) {
                scrollThumb.y = thumbY + thumbHeight - scrollThumb.height;
                _tiles.y = 0;
            } else {
                var perc:Number = 1 - (scrollThumb.y / (thumbY + thumbHeight));
                _tiles.y = (perc * _tiles.height) - _tileMask.height;
            }
        }
    }

}
