package com.gamebook.tankgame.elements.items {
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.tankgame.PluginConstants;
	import com.gamebook.utils.geom.LineSegment;
	import com.gamebook.utils.geom.LineSegmentCollection;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Item extends MovieClip{
		
		private var _isObstacle:Boolean = true;
		private var _isHittable:Boolean = true;
		private var _decal:String;
		private var _hitWidth:int;
		private var _hitHeight:int
		private var _lineSegmentCollection:LineSegmentCollection;
		
		public function Item() {
			mouseChildren = false;
			cacheAsBitmap = true;
		}
		
		public function determineLineSegmentCollection():void {
			_lineSegmentCollection = new LineSegmentCollection();
			
			var top:LineSegment = new LineSegment(new Point(x, y), new Point(x+_hitWidth, y));
			var bottom:LineSegment = new LineSegment(new Point(x, y+_hitHeight), new Point(x+_hitWidth, y+_hitHeight));
			var left:LineSegment = new LineSegment(new Point(x, y), new Point(x, y+_hitHeight));
			var right:LineSegment = new LineSegment(new Point(x + _hitWidth, y), new Point(x + _hitWidth, y + _hitHeight));
			
			_lineSegmentCollection.addLineSegment(top);
			_lineSegmentCollection.addLineSegment(bottom);
			_lineSegmentCollection.addLineSegment(left);
			_lineSegmentCollection.addLineSegment(right);
		}
		
		public function getEsObject():EsObject{
			var esob:EsObject = new EsObject();

			esob.setString(PluginConstants.DECAL, decal);
			esob.setInteger(PluginConstants.X, int(x));
			esob.setInteger(PluginConstants.Y, int(y));
			esob.setInteger(PluginConstants.WIDTH, hitWidth);
			esob.setInteger(PluginConstants.HEIGHT, hitHeight);
			esob.setBoolean(PluginConstants.OBSTACLE, isObstacle);
			esob.setBoolean(PluginConstants.HITTABLE, isHittable);
			
			return esob;
		}
		
		
		/* INTERFACE com.gamebook.tankgame.elements.items.IItem */
		
		public function get isObstacle():Boolean{
			return _isObstacle
		}
		
		public function get isHittable():Boolean{
			return _isHittable
		}
		
		public function get hitWidth():int{
			return _hitWidth;
		}
		
		public function get hitHeight():int{
			return _hitHeight;
		}
		
		public function get decal():String{
			return _decal;
		}
		
		public function set isObstacle(value:Boolean):void{
			_isObstacle = value;
		}
		
		public function set isHittable(value:Boolean):void{
			_isHittable = value;
		}
		
		public function set hitWidth(w:int):void{
			_hitWidth = w;
		}
		
		public function set hitHeight(h:int):void{
			_hitHeight = h;
		}
		
		public function set decal(value:String):void{
			_decal = value;
		}
		
		public function get lineSegmentCollection():LineSegmentCollection { return _lineSegmentCollection; }
	}
	
}