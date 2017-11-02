package  {
	
	import flash.display.MovieClip;
	
	
	public class Piper extends MovieClip {
		
		//水管运动速度
		protected var _speed:Number;
		//记录是否有小鸟飞过
		public var passflybird:Boolean = false;
		
		public function Piper(speed:Number = 0) {
			this.speed = speed;
		}
		
		public function get speed():Number {
			return _speed;
		}
		
		public function set speed(value:Number):void {
			_speed = value;
		}
	}
	
}
