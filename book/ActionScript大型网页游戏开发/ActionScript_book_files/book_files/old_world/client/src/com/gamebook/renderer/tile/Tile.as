package com.gamebook.renderer.tile {
	import com.gamebook.renderer.item.Item;
	import com.gamebook.utils.astar.INode;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Tile implements INode {
		
		private static var IDS:int = 0;
		
        /**
         * @private
         * static tile renderables
         */
        private static var _legalData:BitmapData;
        private static var _illegalData:BitmapData;
        
        /**
         * @private
         * tile bitmap
         */
        private var _tileBitmap:Bitmap = new Bitmap();
        
		private var _col:int;
		private var _row:int;
		private var _items:Array;
		private var _baseWalkability:Boolean;
		private var _basePlaceability:Boolean;
		private var _walkable:Boolean;
		private var _h:Number;
		private var _neighbors:Array;
		private var _nodeId:String;
		private var _nodeType:String;
        private var _enabled:Boolean;
		
		public function Tile() {
			++IDS;
			_nodeId = IDS.toString();
			_nodeType = "normal";
			
			_items = [];
			_baseWalkability = true;
			_basePlaceability = true;
			_walkable = true;
            _enabled = true;
         	addGridPiece();
		}
        
         /**
         * Store the BitmapData used to determine which tile type to render.
         * 
         * @param	legal BitmapData that represents a "legal" tile state.
         * 
         * @param	illegal BitmapData that represents an "illegal" tile state.
         */
        public static function setBitmapData(legal:BitmapData, illegal:BitmapData):void {
            _legalData = legal;
            _illegalData = illegal;
        }
		
		public function addItem(item:Item):void {
			_items.push(item);
            addGridPiece();
			
			determineWalkability();
		}
		
		private function addGridPiece():void
		{
			if (_legalData && _illegalData && _tileBitmap)
                _tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
		}
		
		public function fromXML(info:XML):void {
			
			_baseWalkability = info.@walkability == "false" ? false : true;
			_basePlaceability = info.@placeability == "false" ? false : true;
			if (_legalData && _illegalData && _tileBitmap)
                _tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
			
		}
		
		public function toXML():String
		{
			return "<Tile col='" + _col + "' row='" + _row + "' walkability='" + _baseWalkability + "' placeability='" + _basePlaceability + "' />";
		}
		
		public function allowsItemPlacement():Boolean {
			var allows:Boolean = _basePlaceability;
            if (!_enabled) {
                return false;
            }
			if (allows) {
				for (var i:int = 0; i < _items.length;++i) {
					var item:Item = _items[i];
					if (!item.itemDefinition.overlap) {
						allows = false;
						break;
					}
				}
			}
			return allows;
		}
		
		private function determineWalkability():void {
			var w:Boolean = _baseWalkability;
			if (w) {
				for (var i:int = 0; i < _items.length;++i) {
					var item:Item = _items[i];
					if (!item.itemDefinition.walkable) {
						w = false;
						break;
					}
				}
			}
			
			_walkable = _enabled && w;
			
		}
		
		public function removeItem(item:Item):void {
			for (var i:int = 0; i < _items.length;++i) {
				if (_items[i] == item) {
					_items.splice(i, 1);
					break;
				}
			}
            if (_legalData && _illegalData && _tileBitmap) {
                _tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
			}
			
			determineWalkability();
		}
		
		/* INTERFACE com.gamebook.utils.astar.INode */
		
		public function setHeuristic(h:Number):void{
			_h = h;
		}
		
		public function getHeuristic():Number{
			return _h;
		}
		
		public function getCol():int{
			return _col;
		}
		
		public function getRow():int{
			return _row;
		}
		
		public function setNeighbors(arr:Array):void{
			_neighbors = arr;
		}
		
		public function getNodeId():String{
			return _nodeId;
		}
		
		public function getNeighbors():Array{
			return _neighbors;
		}
		
		public function getNodeType():String{
			return _nodeType;
		}
		
		public function setNodeType(type:String):void{
			_nodeType = type;
		}
		
		public function get col():int { return _col; }
		
		public function set col(value:int):void {
			_col = value;
		}
		
		public function get row():int { return _row; }
		
		public function set row(value:int):void {
			_row = value;
		}
		
		public function get baseWalkability():Boolean { return _baseWalkability; }
		
		public function set baseWalkability(value:Boolean):void {
			_baseWalkability = value;
			  if (_legalData && _illegalData && _tileBitmap)
				_tileBitmap.bitmapData = _baseWalkability ? _legalData : _illegalData;
		}
		
		public function get walkable():Boolean { return _walkable; }
		
		public function get basePlaceability():Boolean { return _basePlaceability; }
		
		public function set basePlaceability(value:Boolean):void {
			_basePlaceability = value;
			 if (_legalData && _illegalData && _tileBitmap)
				_tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
		}
        
        public function enable():void {
            _enabled = true;
            if (_legalData && _illegalData && _tileBitmap)
				_tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
        }
        
        public function disable():void {
            _enabled = false;
            if (_legalData && _illegalData && _tileBitmap)
				_tileBitmap.bitmapData = allowsItemPlacement() ? _legalData : _illegalData;
        }
		
        /**
         * The renderable bitmap representation of the tile object.
         */
        public function get tileBitmap():Bitmap {
            return _tileBitmap;
        }
		
		public function get items():Array { return _items; }
	}
	
}
