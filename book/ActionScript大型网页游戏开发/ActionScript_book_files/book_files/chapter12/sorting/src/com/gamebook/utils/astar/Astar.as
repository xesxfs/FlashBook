package com.gamebook.utils.astar {
	/**
	 * This class is used to perform A* searches. Most commonly, the A* search is used for pathfinding through a tile-based map. A grid (map) to be searched using this class must implement ISearchable. The tiles on that grid must implement INode.
	 * <br><br>By default allowDiag is true, which means that diagonal paths are allowed. You can change that with the setAllowDiag method. By default, the max search time is 2000 ms. Thsi can be changed via the setMaxSearchTime method.
	 */
	public class Astar {
		private var startNode:INode;
		private var goalNode:INode;
		private var closed:Object;
		private var allowDiag:Boolean;
		private var grid:ISearchable;
		private var maxSearchTime:Number;
		/**
		 * Creates a new instance of the Astar class. 
		 */
		public function Astar(grid:ISearchable) {	
			this.grid = grid;
			setAllowDiag(true);
			setMaxSearchTime(2000);
		}
		/**
		 * Performs an A* search from one tile (INode) to another, using a grid (ISearchable). 
		 * @param	The starting INode point on the grid.
		 * @param	The target INode point on the grid.
		 * @return SearchResults class instance. If the search yielded a path then SearchResults.getIsSuccess() method returns true, and SearchResults.getPath() returns a Path instance that defines the path.
		 */
		public function search(start_node:INode, goal_node:INode):SearchResults {
			startNode = start_node;
			goalNode = goal_node;
			closed = new Object();
			var results:SearchResults = new SearchResults();
			var queue:PriorityQueue = new PriorityQueue();
			
			var path:Path = new Path();
			path.addNode(start_node);
			queue.enqueue(path);
			
			var diag:Number = Math.sqrt(2);
			
			var startTime:Date = new Date();
			
			while (queue.hasNextItem()) {
				var now:Date = new Date();
				if (now.valueOf() - startTime.valueOf() > maxSearchTime) {
					break;
				}
				var p:Path = queue.getNextItem();
				var lastNode:INode = p.getLastNode();
				if (isInClosed(lastNode)) {
					continue;
				} else if (lastNode == goalNode) {
					results.setIsSuccess(true);
					results.setPath(p);
					//trace("cost: "+p.getCost())
					//trace("f: "+p.getF())
					break;
				} else {
					closed[lastNode.getNodeId()] = true;
					var neighbors:Array = getNeighbors(lastNode);
					for (var i:int=0;i<neighbors.length;++i) {
						var t:INode = INode(neighbors[i]);
						//var h:Number = Math.abs(lastNode.getCol()-t.getCol())+Math.abs(lastNode.getRow()-t.getRow());
						var h:Number = Math.sqrt(Math.pow(goalNode.getCol()-t.getCol(), 2) + Math.pow(goalNode.getRow()-t.getRow(), 2));
						t.setHeuristic(h);
						var pp:Path = p.clone();
						pp.addNode(t);
						var cost:Number;
						if (t.getCol() == lastNode.getCol() || t.getRow() == lastNode.getRow()) {
							cost = 1;
						} else {
							cost = diag;
						}
						var costMultiplier:Number = grid.getNodeTransitionCost(lastNode, t);
						//var costMultiplier:Number = costs[lastNode.getNodeType()+t.getNodeType()];
						cost *= costMultiplier;
						pp.incrementCost(cost);
						queue.enqueue(pp);
					}
				}
			}
			
			return results;
		}
		/**
		 * Sets the maximum search time in milliseconds.
		 * @param	Time in milliseconds.
		 */
		public function setMaxSearchTime(maxSearchTime:Number):void {
			this.maxSearchTime = maxSearchTime;
		}
		/**
		 * Flags the allowDiag property to true or false. If true, then diagonal legs are allowed from one tile to the next. If false, then only vertical and horizontal are allowed.
		 * @param	allowDiag
		 */
		public function setAllowDiag(allowDiag:Boolean):void {
			this.allowDiag = allowDiag;
		}
		/**
		 * Gets the neighbor INodes of the one passed in.
		 * @private
		 * @param	The INode for which you want to know the the neighbors.
		 * @return Array of INode instances.
		 */
		private function getNeighbors(n:INode):Array {
			var arr:Array = n.getNeighbors();
			var c:int = n.getCol();
			var r:int = n.getRow();
			var max_c:int = grid.getCols();
			var max_r:int = grid.getRows();
			if (arr == null) {
				arr = new Array();
				var t:INode;
				if (c+1 < max_c) {
					t = grid.getNode(c+1, r);
					arr.push(t);
				}
				if (r+1 < max_r) {
					t = grid.getNode(c, r+1);
					arr.push(t);
				}
				if (c-1 >= 0) {
					t = grid.getNode(c-1, r);
					arr.push(t);
				}
				if (r-1 >= 0) {
					t = grid.getNode(c, r-1);
					arr.push(t);
				}
				if (allowDiag) {
					if (c-1 > 0 && r+1 < max_r) {
						t = grid.getNode(c-1, r+1);
						arr.push(t);
					}
					if (c+1 < max_c && r+1 < max_r) {
						t = grid.getNode(c+1, r+1);
						arr.push(t);
					}
					if (c-1 > 0 && r-1 > 0) {
						t = grid.getNode(c-1, r-1);
						arr.push(t);
					}
					if (c+1 < max_c && r-1 > 0) {
						t = grid.getNode(c+1, r-1);
						arr.push(t);
					}
				}
				n.setNeighbors(arr);
			}
			return arr;
		}
		/**
		 * Checks to see if the INode passed in is in the close object.
		 * @param	The INode instance to check.
		 * @return True or false.
		 */
		private function isInClosed(n:INode):Boolean {
			return closed[n.getNodeId()] != null;
		}
	}
	
}
