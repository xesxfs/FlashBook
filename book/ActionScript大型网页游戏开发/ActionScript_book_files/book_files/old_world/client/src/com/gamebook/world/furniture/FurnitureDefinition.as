package com.gamebook.world.furniture {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class FurnitureDefinition {
		
		private var _name:String;
		private var _fileName:String;
		private var _cost:int;
		private var _id:int;
		
		
		public function FurnitureDefinition() {
			
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
		
		public function get id():int { return _id; }
		
		public function set id(value:int):void {
			_id = value;
		}
		
	}
	
}