package com.gamebook.world.furniture {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class FurnitureManager {
		
		private var _furnitureDefinitions:Array = [];
		private var _furnitureDefnitionsById:Dictionary = new Dictionary();
		
		public function FurnitureManager() {
			
		}
		
		public function addFurnitureDefinition(furniture:FurnitureDefinition):void {
			_furnitureDefinitions.push(furniture);
			_furnitureDefnitionsById[furniture.id] = furniture;
		}
		
		public function furnitureDefinitionById(id:int):FurnitureDefinition {
			return _furnitureDefnitionsById[id];
		}
		
		public function get furnitureDefinitions():Array { return _furnitureDefinitions; }
		
	}
	
}