package com.gamebook.world.furniture {
	import com.gamebook.renderer.item.Item;
	import com.gamebook.renderer.item.ItemDefinition;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Furniture {
		
		private var _furnitureDefinition:FurnitureDefinition;
		private var _item:Item;
		private var _isInWorld:Boolean;
		private var _entryId:int;
		
		public function Furniture() {
			
		}
		
		public function get furnitureDefinition():FurnitureDefinition { return _furnitureDefinition; }
		
		public function set furnitureDefinition(value:FurnitureDefinition):void {
			_furnitureDefinition = value;
		}
		
		public function get item():Item { return _item; }
		
		public function set item(value:Item):void {
			_item = value;
		}
		
		public function get isInWorld():Boolean { return _isInWorld; }
		
		public function set isInWorld(value:Boolean):void {
			_isInWorld = value;
		}
		
		public function get entryId():int { return _entryId; }
		
		public function set entryId(value:int):void {
			_entryId = value;
		}
		
	}
	
}