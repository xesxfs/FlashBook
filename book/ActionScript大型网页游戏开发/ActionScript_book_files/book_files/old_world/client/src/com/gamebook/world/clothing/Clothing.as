package com.gamebook.world.clothing {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Clothing {
		
		private var _clothingTypeId:int;
		private var _id:int;
		private var _name:String;
		private var _fileName:String;
		private var _cost:int;
		
		public function Clothing() {
			
		}
		
		public function get clothingTypeId():int { return _clothingTypeId; }
		
		public function set clothingTypeId(value:int):void {
			_clothingTypeId = value;
		}
		
		public function get id():int { return _id; }
		
		public function set id(value:int):void {
			_id = value;
		}
		
		public function get name():String { return _name; }
		
		public function set name(value:String):void {
			_name = value;
		}
		
		public function get fileName():String { return _fileName; }
		
		public function set fileName(value:String):void {
			_fileName = value;
		}
		
		public function get cost():int { return _cost; }
		
		public function set cost(value:int):void {
			_cost = value;
		}
		
	}
	
}