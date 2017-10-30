package com.gamebook.utils.astar {
	/**
	 * This class is used to sort the paths in the queue by priority.
	 */
	public class PriorityQueue {
		private var items:Array;
		/**
		 * Creates a new instance of the PriorityQueue class.
		 */
		public function PriorityQueue() {
			items = new Array();
		}
		/**
		 * Gets the next item off of the queue.
		 * @return The highest priority item.
		 */
		public function getNextItem():Path {
			var p:Path = Path(items.shift());
			return p;
		}
		/**
		 * Checks to see if there is anything in the queue.
		 * @return True or false.
		 */
		public function hasNextItem():Boolean {
			return items.length > 0;
		}
		/**
		 * Adds a path to the queue.
		 * @param	The path to add.
		 */
		public function enqueue(p:Path):void {
			var val:Number = p.getF();
			var added:Boolean = false;
			for (var i:int=0;i<items.length;++i) {
				var curr:Path = Path(items[i]);
				if (val < curr.getF()) {
					items.splice(i, 0, p);
					added = true;
					break;
				}
			}
			if (!added) {
				items.push(p);
			}
		}
	}
	
}
