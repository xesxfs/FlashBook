package com.gamebook.utils.geom {
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Coordinate {
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		
		public function Coordinate(x:Number = 0, y:Number = 0, z:Number = 0):void {
			_x = x;
			_y = y;
			_z = z;
		}
		
		public function get x():Number { return _x; }
		
		public function set x(value:Number):void {
			_x = value;
		}
		
		public function get y():Number { return _y; }
		
		public function set y(value:Number):void {
			_y = value;
		}
		
		public function get z():Number { return _z; }
		
		public function set z(value:Number):void {
			_z = value;
		}
		
		public function toString():String {
			return "x: " + _x.toString() + ", y: " + _y.toString() + ", z: " + _z.toString();
		}
		
	}
	
}