package com.gamebook.astarexample {
	import com.gamebook.utils.astar.INode;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	[Embed(source='../../../assets/Astar.swf', symbol='Tile')]
	public class Tile extends MovieClip implements INode {
		//events
		static public var CLICKED:String = "clicked";
		//normal properties
		//A* properties
		private var heuristic:Number;
		private var col:int;
		private var row:int;
		private var neighbors:Array;
		private var nodeId:String;
		private var nodeType:String;
		
		
		public var endDot_mc:MovieClip;
		public var startDot_mc:MovieClip;
		public var pathColor_mc:MovieClip;
		public var terrain_mc:MovieClip;
		
		public function Tile(c:int, r:int) {
			col = c;
			row = r;
			nodeId = c.toString() + "_" + r.toString();
			terrain_mc.stop();
			terrain_mc.mouseEnabled = false;
			terrain_mc.mouseChildren = false;
			
			reset();
			addEventListener(MouseEvent.CLICK, clicked);
		}
		public function getIsWall():Boolean {
			return nodeType == "wall";
		}
		private function clicked(e:MouseEvent):void {
			dispatchEvent(new Event(CLICKED));
		}
		public function reset():void {
			pathColor_mc.visible = false;
			startDot_mc.visible = false;
			endDot_mc.visible = false;
		}
		public function showPath():void {
			pathColor_mc.visible = true;
		}
		public function unShowPath():void {
			pathColor_mc.visible = false;
		}
		public function unShowEndDot():void {
			endDot_mc.visible = false;
		}
		public function showEndDot():void {
			endDot_mc.visible = true;
		}
		public function unShowStartDot():void {
			startDot_mc.visible = false;
		}
		public function showStartDot():void {
			startDot_mc.visible = true;
		}
		public function setNodeType(type:String):void {
			nodeType = type;
			terrain_mc.gotoAndStop(nodeType);
		}
		public function getNodeType():String {
			return nodeType;
		}
		public function getNodeId():String {
			return nodeId;
		}
		public function setNeighbors(arr:Array):void {
			neighbors = arr;
		}
		public function getNeighbors():Array {
			return neighbors;
		}
		public function setCol(num:int):void {
			col = num;
		}
		public function getCol():int {
			return col;
		}
		public function setRow(num:int):void {
			row = num;
		}
		public function getRow():int {
			return row;
		}
		public function setHeuristic(h:Number):void {
			heuristic = h;
		}
		public function getHeuristic():Number {
			return heuristic;
		}
	}
}
