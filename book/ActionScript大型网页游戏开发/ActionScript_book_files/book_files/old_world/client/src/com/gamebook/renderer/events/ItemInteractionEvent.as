package com.gamebook.renderer.events {
	import com.gamebook.renderer.item.Item;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ItemInteractionEvent extends Event {
		
		public static const ITEM_SELECTED:String = "itemSelected";
		public static const ITEM_PLACED:String = "itemPlaced";
		public static const ITEM_CLICKED:String = "itemClicked";
		
		
		private var _item:Item;
		
		public function ItemInteractionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			
			super ( type, false, false );
		}
		
		public function get item():Item { return _item; }
		
		public function set item(value:Item):void {
			_item = value;
		}
		
		
	}
	
}