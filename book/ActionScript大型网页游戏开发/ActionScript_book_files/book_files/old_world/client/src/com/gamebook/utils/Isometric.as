package com.gamebook.utils {
	import com.gamebook.utils.geom.Coordinate;
	
	/**
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class Isometric {
		
		//angles defining the point of view
		private var theta:Number;
		private var alpha:Number;
		
		//trigonometric values stored for later use
		private var sinTheta:Number;
		private var cosTheta:Number;
		private var sinAlpha:Number;
		private var cosAlpha:Number;
		
		/**
		 * Isometric class contrustor.
		 * @param	declination value. Defaults to the most common value, which is 30.
		 */
		public function Isometric(declination:Number=30) {
			theta = declination;
			alpha = 45;
			theta *= Math.PI/180;
			alpha *= Math.PI/180;
			sinTheta = Math.sin(theta);
			cosTheta = Math.cos(theta);
			sinAlpha = Math.sin(alpha);
			cosAlpha = Math.cos(alpha);
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
			var xp:Number = xpp*cosAlpha+zpp*sinAlpha;
			var zp:Number = zpp*cosAlpha-xpp*sinAlpha;
			var x:Number = xp;
			var y:Number = yp*cosTheta-zp*sinTheta;
			return new Coordinate(x, y, 0);
		}
		
		/**
		 * Maps 2D screen coordinates into 3D coordinates. It is assumed that the target 3D y coordinate is 0.
		 * @param	screen x coordinate
		 * @param	screen y coordinate
		 * @return	Coordinate instance containig 3D x, y, and z
		 */
		public function mapToIsoWorld(screenX:Number, screenY:Number):Coordinate {
			var z:Number = (screenX/cosAlpha-screenY/(sinAlpha*sinTheta))*(1/(cosAlpha/sinAlpha+sinAlpha/cosAlpha));
			var x:Number = (1/cosAlpha)*(screenX-z*sinAlpha);
			return new Coordinate(x, 0, z);
		}
		
	}
}