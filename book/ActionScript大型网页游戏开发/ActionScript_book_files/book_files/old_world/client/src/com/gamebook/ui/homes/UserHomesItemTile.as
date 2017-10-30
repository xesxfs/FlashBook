////////////////////////////////////////////////////////////////////////////////
//
//  ELECTROTANK INC.
//  Copyright© 2009 Electrotank, Inc.
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package com.gamebook.ui.homes {

    import com.gamebook.renderer.item.Item;
    import com.gamebook.utils.DisplayObjectUtil;
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    [Embed(source='/assets/ui/homes-inventory.swf', symbol='ListTile')]

    /**
     * This class
     * @author Matt Bolt, Electrotank© 2009
     */
    public class UserHomesItemTile extends MovieClip {

        //--------------------------------------------------------------------------
        //
        //  Private Data
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         * item data
         */
        private var _itemData:Object;
        
        /**
         * @private
         * item
         */
        private var _item:Item;
        
        /**
         * @private
         * tile id
         */
        private var _id:int;
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         * <code>UserHomesItemTile</code> Constructor.
         */
        public function UserHomesItemTile(itemData:Object) {
            
            // Set Properties
            _id = itemData.id;
            _itemData = itemData;
            _item = _itemData.item;
            
            // Collect Dimensional Info and Remove
            var w:Number = thumbnail.width;
            var h:Number = thumbnail.height;
            var tx:Number = thumbnail.x;
            var ty:Number = thumbnail.y;
            removeChild(thumbnail);
            
            // Create a new Clip, Add the Thumbnail, and Scale
            thumbnail = new MovieClip();
            thumbnail.addChild(_itemData.thumb);
            thumbnail.x = tx;
            thumbnail.y = ty;
            thumbnail.width = w;
            thumbnail.height = h;
            thumbnail.cacheAsBitmap = true;
            thumbnail.mouseEnabled = false;
            
            // Re-add new Thumbnail image
            addChild(thumbnail);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         * This function dispose of all data associated with this inventory tile object.
         */
        public function dispose():void {
            DisplayObjectUtil.removeAllChildren(thumbnail);
            if (_itemData) {
                if (_itemData.hasOwnProperty('item'))
                    delete _itemData['item'];
                if (_itemData.hasOwnProperty('name'))
                    delete _itemData['name'];
                if (_itemData.hasOwnProperty('id'))
                    delete _itemData['id'];
                if (_itemData.hasOwnProperty('thumb'))
                    delete _itemData['thumb'];
            }
            _itemData = null;
            _item = null;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Public Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         * The thumbnail of the item.
         */
        public var thumbnail:MovieClip;
        
        /**
         * Global Identifier
         */
        public function get id():int {
            return _id;
        }
        
        /**
         * The item contained in this ui piece.
         */
        public function get item():Item {
            return _item;
        }
        
        /**
         * The item tile's item data.
         */
        public function get itemData():Object {
            return _itemData;
        }
        
    }

}
