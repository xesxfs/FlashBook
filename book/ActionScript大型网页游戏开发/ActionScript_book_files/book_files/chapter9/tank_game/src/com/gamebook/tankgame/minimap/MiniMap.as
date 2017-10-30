package com.gamebook.tankgame.minimap {
	import com.gamebook.tankgame.tank.Tank;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class MiniMap extends MovieClip {
		
		private var _bitmap:Bitmap;
		
		private var _scale:Number;
		
		private var _dotsByTank:Dictionary;
		private var _tanks:Array;
		
		public function MiniMap() {
		}
		
		public function initialize(bd:BitmapData):void {
			
			_dotsByTank = new Dictionary();
			_tanks = [];
			
			_bitmap = new Bitmap(bd, "auto", true);
			_bitmap.width = 100;
			_bitmap.scaleY = _bitmap.scaleX;
			_bitmap.filters = [new DropShadowFilter()];
			addChild(_bitmap);
			
			_scale = 100 / 1600;
		}
		
		public function run():void {
			for (var i:int = 0; i < _tanks.length;++i) {
				position(_tanks[i]);
			}
		}
		
		public function addTank(tank:Tank):void {
			var dot:Dot = new Dot();
			addChild(dot);
			
			dot.gotoAndStop(tank.isMe ? 2 : 1);
			
			if (tank.playerName == "my_mirror") {
				dot.visible = false;
			}
			
			_dotsByTank[tank] = dot;
			_tanks.push(tank);
			
			position(tank);
		}
		
		private function position(tank:Tank):void{
			var dot:Dot = _dotsByTank[tank];
			dot.x = tank.x * _scale;
			dot.y = tank.y * _scale;
		}
		
		public function removeTank(tank:Tank):void {
			removeChild(_dotsByTank[tank] as Dot);
			_dotsByTank[tank] = null;
			for (var i:int = 0; i < _tanks.length;++i) {
				if (_tanks[i] == tank) {
					_tanks.splice(i, 1);
					break;
				}
			}
		}
		
	}
	
}