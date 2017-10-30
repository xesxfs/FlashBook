package com.gamebook.renderer.events 
{
	import com.gamebook.renderer.tile.Tile;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Bruce Branscom
	 */
	public class TileEvent extends Event
	{
		
		public static const TILE_CLICKED:String = "TILE_CLICKED";
		public static const STOPPED_ON_TILE:String = "STOPPED_ON_TILE";
		
		public var tile:Tile;
		
		private var _eventParameter:String;
		
		public function TileEvent( type:String, tile:Tile, bubbles:Boolean = false, cancelable:Boolean = false) 
		{			
			super ( type, false, false );
			this.tile = tile;			
		}
		
		public function get eventParameter():String { return _eventParameter; }
		
		public function set eventParameter(value:String):void {
			_eventParameter = value;
		}
		
	}
	
}