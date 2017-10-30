package com.gamebook.coop.grid {
	
	import com.gamebook.coop.elements.LaserTower;
	import com.gamebook.coop.elements.Rock;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Tile')]
	public class Tile extends MovieClip {
		
		private var _column:int;
		private var _row:int;
		private var _width:int;
		private var _height:int;
		private var _isWalkable:Boolean;
		private var _trigger:int = -1;
		private var _isSavePoint:Boolean = false;
		private var _isGoalPoint:Boolean = false;
		private var _hasRock:Boolean = false;
		private var _currentRock:Rock;
		private var _hasTower:Boolean = false;
		private var _currentTower:LaserTower;
		
		
		/**
		 * Constructor
		 */
		public function Tile(column:int, row:int, width:int, height:int, isWalkable:Boolean=true) {
			_column = column;
			_row = row;
			_width = width;
			_height = height;
			_isWalkable = isWalkable;
			
			//initGraphics(); // for testing, uncomment this line and comment out the Embeded tag
		}
		
		
		private function initGraphics():void {
			var color:Number = 0xcccccc;
			if ( !_isWalkable ) color = 0xff0033;
			
			graphics.clear();
			graphics.lineStyle(1, 0x000000);
			graphics.beginFill(color);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		
		public function get column():int				{ return _column; }
		public function get row():int					{ return _row; }
		public function get isWalkable():Boolean		{ return _isWalkable; }
		public function get trigger():int				{ return _trigger; }
		public function get isSavePoint():Boolean		{ return _isSavePoint; }
		public function get isGoalPoint():Boolean		{ return _isGoalPoint; }
		public function get hasRock():Boolean			{ return _hasRock; }
		public function get currentRock():Rock			{ return _currentRock; }
		public function get hasTower():Boolean			{ return _hasTower; }
		public function get currentTower():LaserTower	{ return _currentTower; }
		
		public function set isWalkable(val:Boolean):void		{ _isWalkable = val; initGraphics();  }
		public function set trigger(val:int):void				{ _trigger = val; }
		public function set isSavePoint(val:Boolean):void		{ _isSavePoint = val; }
		public function set isGoalPoint(val:Boolean):void		{ _isGoalPoint = val; }
		public function set hasRock(val:Boolean):void			{ _hasRock = val; }
		public function set currentRock(val:Rock):void			{ _currentRock = val; }
		public function set hasTower(val:Boolean):void			{ _hasTower = val; }
		public function set currentTower(val:LaserTower):void	{ _currentTower = val; }
	}
	
}