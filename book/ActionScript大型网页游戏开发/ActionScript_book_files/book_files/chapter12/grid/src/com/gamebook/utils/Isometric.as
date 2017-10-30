package com.gamebook.utils {
	import com.gamebook.utils.geom.Coordinate;
	
	/**
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Isometric {
		
		//trigonometric values stored for later use
		private var _sinTheta:Number;
		private var _cosTheta:Number;
		private var _sinAlpha:Number;
		private var _cosAlpha:Number;
		
		/**
		 * Isometric class contrustor.
		 * @param	declination value. Defaults to the most common value, which is 30.
		 */
		public function Isometric() {
			var theta:Number = 30;
			var alpha:Number = 45;
			theta *= Math.PI/180;
			alpha *= Math.PI/180;
			_sinTheta = Math.sin(theta);
			_cosTheta = Math.cos(theta);
			_sinAlpha = Math.sin(alpha);
			_cosAlpha = Math.cos(alpha);
		}
		
		/**
		 * Maps 3D coordinates to the 2D screen
		 * @param	x coordinate
		 * @param	y coordinate
		 * @param	z coordinate
		 * @return	Coordinate instance containig screen x and screen y
		 */
		public function mapToScreen(xpp:Number, ypp:Number, zpp:Number):Coordinate {
			var yp:Number = ypp;
			var xp:Number = xpp*_cosAlpha+zpp*_sinAlpha;
			var zp:Number = zpp*_cosAlpha-xpp*_sinAlpha;
			var x:Number = xp;
			var y:Number = yp*_cosTheta-zp*_sinTheta;
			return new Coordinate(x, y, 0);
		}
		
		/**
		 * Maps 2D screen coordinates into 3D coordinates. It is assumed that the target 3D y coordinate is 0.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	Coordinate instance containig 3D x, y, and z
		 */
		public function mapToIsoWorld(screenX:Number, screenY:Number):Coordinate {
			var z:Number = (screenX/_cosAlpha-screenY/(_sinAlpha*_sinTheta))*(1/(_cosAlpha/_sinAlpha+_sinAlpha/_cosAlpha));
			var x:Number = (1/_cosAlpha)*(screenX-z*_sinAlpha);
			return new Coordinate(x, 0, z);
		}
		
	}
}