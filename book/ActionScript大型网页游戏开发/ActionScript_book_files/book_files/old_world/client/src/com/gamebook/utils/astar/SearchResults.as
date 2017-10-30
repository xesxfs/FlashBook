package com.gamebook.utils.astar {
	/**
	 * This class is used to represent the results of an A* search. If the search was successful, then getIsSuccess() returns true and getPath() returns the most optimal path.
	 */
	public class SearchResults {
		private var isSuccess:Boolean;
		private var path:Path;
		/**
		 * Creates a new instance of the SearchResults class.
		 */
		public function SearchResults() {			
		}
		/**
		 * Sets the path.
		 * @param	The path.
		 */
		public function setPath(p:Path):void {
			path = p;
		}
		/**
		 * Gets the path.
		 * @return The path.
		 */
		public function getPath():Path {
			return path;
		}
		/**
		 * If the search was a success then this returns true.
		 * @return True or false.
		 */
		public function getIsSuccess():Boolean {
			return isSuccess;
		}
		/**
		 * Sets the isSuccess property.
		 * @param	True or false.
		 */
		public function setIsSuccess(val:Boolean):void {
			isSuccess = val;
		}
	}
	
}
