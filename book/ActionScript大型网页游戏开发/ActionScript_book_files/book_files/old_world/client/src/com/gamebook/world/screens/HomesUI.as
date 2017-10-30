package com.gamebook.world.screens {
    
    import com.gamebook.renderer.events.UserHomesEvent;
    import com.gamebook.renderer.Map;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    
    /// Embed User Homes UI
    [Embed(source='/assets/assets.swf', symbol='HomeBottomUI')]
    
    /**
     * This class represents the bottom ui toolbar for user homes.
     * 
     * @author Matt Bolt
     */
    public class HomesUI extends MovieClip {

        //-----------------------------
        //  Constructor
        //-----------------------------
        
        /**
         * Creates a new HomesUI instance.
         */
        public function HomesUI() {
            editButton.addEventListener(MouseEvent.CLICK, onEditClick);
            recycleButton.addEventListener(MouseEvent.CLICK, onRecycleClick);
        }
        
        //-----------------------------
        //  Mouse Event Handlers
        //-----------------------------
        
        /**
         * @private
         * recycle button click handler
         */
        private function onRecycleClick(e:MouseEvent):void {
            // Stop Event from Progagating
            e.stopImmediatePropagation();
            e.stopPropagation();
            // Dispatch
            dispatchEvent(new UserHomesEvent(UserHomesEvent.ITEM_RECYCLED));
        }
        
        /**
         * @private
         * edit button click handler
         */
        private function onEditClick(e:MouseEvent):void {
            // Stop Event from Progagating
            e.stopImmediatePropagation();
            e.stopPropagation();
            // Dispatch
            dispatchEvent(new UserHomesEvent(UserHomesEvent.EDIT_MODE_TOGGLE));
        }
        
        //-----------------------------
        //  Properties
        //-----------------------------
        
        /**
         * Edit Home Button
         */
        public var editButton:SimpleButton;
        
        /**
         * Recycle Item Button
         */
        public var recycleButton:SimpleButton;
        
    }
    
}
