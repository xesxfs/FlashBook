package com.gamebook.coop.elements {
	
	import com.gamebook.coop.grid.Tile;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * A rock that can be pushed around.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='Rock')]
	public class Rock extends MovieClip {
		
		public static const TYPE_SHARP:int	= 1;
		public static const TYPE_SHORT:int	= 2;
		public static const TYPE_TALL:int	= 3;
		
		private const ROCK_SPEED:Number = 2;
		
		public var rock1:MovieClip;
		public var rock2:MovieClip;
		public var rock3:MovieClip;
		
		private var _id:int;
		private var _currentTile:Tile;
		
		private var _isSliding:Boolean;
		private var _destX:int;
		private var _destY:int;
		private var _dirX:int;
		private var _dirY:int;
		
		/**
		 * Position the rock and set the rock type.
		 */
		public function Rock(id:int, tile:Tile, type:int) {
			
			_id = id;
			_currentTile = tile;
			
			placeOnTile();
			
			// tell the tile there is a rock on it
			_currentTile.isWalkable = false;
			_currentTile.hasRock = true;
			_currentTile.currentRock = this;
			
			showRockType(type);
		}
		
		private function placeOnTile():void {
			this.x = Math.floor(_currentTile.x + width / 2);
			this.y = Math.floor(_currentTile.y + height / 2);
		}
		
		/**
		 * Move the rock to the destination tile.
		 */
		public function move(destinationTile:Tile):void {
			
			_currentTile.isWalkable = true;
			_currentTile.hasRock = false;
			_currentTile.currentRock = null;
			
			_currentTile = destinationTile;
			
			_currentTile.isWalkable = false;
			_currentTile.hasRock = true;
			_currentTile.currentRock = this;
			
			slideIntoPlace();
		}
		
		/**
		 * Start the rock sliding.
		 */
		public function slideIntoPlace():void {
			if (!_isSliding) {
				_isSliding = true;
				_destX = Math.floor(_currentTile.x + width / 2);
				_destY = Math.floor(_currentTile.y + height / 2);
				_dirX = (_destX < this.x) ? -1 : (_destX > this.x) ? 1 : 0;
				_dirY = (_destY < this.y) ? -1 : (_destY > this.y) ? 1 : 0;
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		/**
		 * Position the rock closer to its destination.
		 */
		public function onEnterFrame(e:Event):void {
			if ( (this.x == _destX && this.y == _destY)
				|| (_dirX < 1 && this.x < _destX)
				|| (_dirX > 1 && this.x > _destX)
				|| (_dirY < 1 && this.y < _destY)
				|| (_dirY > 1 && this.y > _destY)
			) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_isSliding = false;
			} else {
				this.x += _dirX * ROCK_SPEED;
				this.y += _dirY * ROCK_SPEED;
			}
		}
		
		/**
		 * Make the correct rock clip visible based on rock type.
		 */
		private function showRockType(type:int):void {
			
			rock1.visible = false;
			rock2.visible = false;
			rock3.visible = false;
			
			switch (type) {
				case TYPE_SHARP :
					rock1.visible = true;
					break;
				case TYPE_SHORT :
					rock2.visible = true;
					break;
				case TYPE_TALL :
					rock3.visible = true;
					break;
				default :
					rock1.visible = true;
			}
		}
		
		public function get id():int			{ return _id; }
		public function get currentTile():Tile	{ return _currentTile; }
		public function get isSliding():Boolean	{ return _isSliding; }
		
		public function set currentTile(value:Tile):void { _currentTile = value; }
	}
	
}