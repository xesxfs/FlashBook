package com.gamebook.utils.astar {
	/**
	 * A tile that will work with the A* search needs to implment INode. It can extend this class for convenience, which already implements INode.
	 */
	public class Node implements INode{
		private var heuristic:Number;
		private var neighbors:Array;
		private var col:int;
		private var row:int;
		private var nodeType:String;
		private var nodeId:String;
		public function Node() {			
		}
		public function setNodeId(nodeId:String):void {
			this.nodeId = nodeId;
		}
		public function getNodeId():String {
			return nodeId;
		}
		public function setNodeType(type:String):void {
			nodeType = type;
		}
		public function getNodeType():String {
			return nodeType;
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
		public function setNeighbors(arr:Array):void {
			neighbors = arr;
		}
		public function getNeighbors():Array {
			return neighbors;
		}
		public function setHeuristic(h:Number):void {
			heuristic = h;
		}
		public function getHeuristic():Number {
			return heuristic;
		}
		
	}
	
}
