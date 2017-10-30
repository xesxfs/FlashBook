package com.gamebook.isoexample {
	import com.gamebook.renderer.events.ItemInteractionEvent;
	import com.gamebook.renderer.item.Item;
	import com.gamebook.renderer.Map;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class RoomExample extends MovieClip{
		
		private var _map:Map;
		
		public function RoomExample() {
			
			_map = new Map();
			_map.addEventListener(Map.READY, onMapReady);
			_map.x = 400;
			addChild(_map);
			_map.loadMap("data/map1.xml");
		}
		
		private function onMapReady(e:Event):void {
			_map.isEditable = true;
			_map.addEventListener(ItemInteractionEvent.ITEM_SELECTED, onItemSelected);
			_map.addEventListener(ItemInteractionEvent.ITEM_PLACED, onItemPlaced);
			
			//testCreateAndAddItem();
		}
		
		private function testCreateAndAddItem():void {
			
			//create a new item
			var itm:Item = new Item();
			
			//tell it what tile should go on
			itm.col = 10;
			itm.row = 10;
			
			//tell it what type of item it is
			itm.itemDefinition = _map.itemManager.itemDefinitions[1];
			
			//add it to the item manager
			_map.itemManager.addItem(itm);
			
			//tell the map to place it
			_map.placeItem(itm);
		}
		
		private function onItemPlaced(e:ItemInteractionEvent):void {
			e.item.filters = [];
		}
		
		private function onItemSelected(e:ItemInteractionEvent):void {
			//trace("item.isInWolrd: " + e.item.isInWorld);
			_map.removeItem(e.item);
			_map.startDraggingItem(e.item);
			
			
			//trace("item.isInWolrd: " + e.item.isInWorld);
			
			e.item.filters = [new GlowFilter(0x009900)];
		}
		
	}
	
}
