package com.gamebook.world.clothing {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ClothingManager {
		
		private var _clothing:Array = [];
		private var _clothingById:Dictionary = new Dictionary();
		private var _clothingByType:Dictionary = new Dictionary();
		
		
		public function ClothingManager() {
			
		}
		
		public function addClothing(clothing:Clothing):void {
			_clothing.push(clothing);
			_clothingById[clothing.id] = clothing;
			if (_clothingByType[clothing.clothingTypeId] == null) {
				_clothingByType[clothing.clothingTypeId] = [];
			}
			_clothingByType[clothing.clothingTypeId].push(clothing);
		}
		
		public function clothingByType(typeId:int):Array {
			return _clothingByType[typeId];
		}
		
		public function clothingById(id:int):Clothing {
			return _clothingById[id];
		}
		
		public function get clothing():Array { return _clothing; }
		
	}
	
}