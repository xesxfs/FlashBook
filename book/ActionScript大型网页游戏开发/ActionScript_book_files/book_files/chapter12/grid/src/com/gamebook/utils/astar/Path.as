package com.gamebook.utils.astar {
	/**
	 * This class represents a path of INodes. If a successful search is performed then SearchResults.getPath() returns the most optimal path.
	 */
	public class Path {
		private var nodes:Array;
		private var cost:Number;
		private var lastNode:INode;
		/**
		 * Creates a new instance of the Path class.
		 */
		public function Path() {
			cost = 0;
			nodes = new Array();
		}
		/**
		 * Clones the class. This is used during the search algorithm when trying to find the most optimal path.
		 * @return Path instance.
		 */
		public function clone():Path {
			var p:Path = new Path();
			p.incrementCost(cost);
			p.setNodes(nodes.slice(0));
			return p;
		}
		/**
		 * Returns the last INode in the path.
		 * @return The last INode in the path.
		 */
		public function getLastNode():INode {
			return lastNode;
		}
		/**
		 * Gets the total cost of the path. That includes the cost from the start node to this point plus the heuristic guess of how much cost from this point to the goal.
		 * @return The cost of the path plus heuristic.
		 */
		public function getF():Number {
			return getCost()+lastNode.getHeuristic();
		}
		/**
		 * Gets the cost from the start node to this point.
		 * @return The actual cost of the path to this point.
		 */
		public function getCost():Number {
			return cost;
		}
		/**
		 * Increments the cost by an amount.
		 * @param	Amount to increment the cost.
		 */
		public function incrementCost(num:Number):void {
			cost = getCost()+num;
		}
		/**
		 * Sets an initial array of INodes.
		 * @param	Array of INodes.
		 */
		public function setNodes(arr:Array):void {
			nodes = arr;
		}
		/**
		 * Adds an INode to the path.
		 * @param	The INode to add.
		 */
		public function addNode(n:INode):void {
			nodes.push(n);
			lastNode = n;
		}
		/**
		 * Gets the array of INodes.
		 * @return
		 */
		public function getNodes():Array {
			return nodes;
		}
	}
	
}
