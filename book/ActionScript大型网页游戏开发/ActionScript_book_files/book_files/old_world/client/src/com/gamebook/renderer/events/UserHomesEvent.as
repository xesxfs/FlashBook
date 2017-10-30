package com.gamebook.renderer.events {
    
    import com.gamebook.renderer.item.Item;
    import flash.events.Event;
    
    /**
     * This event class is used to define action based in the user homes environment.
     * 
     * @author Matt Bolt
     */
    public class UserHomesEvent extends Event {
        
        //--------------------------------------------------------------------------
        //
        //  Event Types
        //
        //--------------------------------------------------------------------------
        
        /**
         * This event fires when the user chooses to exit the user home.
         * 
         * @eventType exitHomes
         */
        public static const EXIT_HOMES:String = "exitHomes";
        
        /**
         * This event fires when the user toggles user home's "Edit Mode".
         * 
         * @eventType editModeToggle
         */
        public static const EDIT_MODE_TOGGLE:String = "editModeToggle";
        
        /**
         * This event fires when an item is selected from the list ui.
         * 
         * @eventType itemSelected
         */
        public static const ITEM_SELECTED:String = "itemSelected";
        
        /**
         * This event fires when an item is recycled (placed back into inventory from
         * the world).
         * 
         * @eventType itemRecycled
         */
        public static const ITEM_RECYCLED:String = "itemRecycled";
        
        //--------------------------------------------------------------------------
        //
        //  Private Data
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         * user homes item.
         */
        private var _item:Item;
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         * Constructor.
         *
         * @param type The event type; indicates the action that caused the event.
         * 
         * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Specifies whether the behavior associated with 
         * the event can be prevented.
         */
        public function UserHomesEvent(type:String, item:Item = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
            super(type, bubbles, cancelable);
            _item = item;
        } 
        
        //--------------------------------------------------------------------------
        //
        //  Override Methods: Event
        //
        //--------------------------------------------------------------------------
        
        /**
         * @inheritDoc
         */
        public override function clone():Event { 
            return new UserHomesEvent(type, _item, bubbles, cancelable);
        } 
        
        /**
         * @inheritDoc
         */
        public override function toString():String { 
            return formatToString("UserHomesEvent", "type", "item", "bubbles", "cancelable", "eventPhase"); 
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         * The item associated with the user homes event.
         */
        public function get item():Item {
            return _item;
        }
    }
    
}
