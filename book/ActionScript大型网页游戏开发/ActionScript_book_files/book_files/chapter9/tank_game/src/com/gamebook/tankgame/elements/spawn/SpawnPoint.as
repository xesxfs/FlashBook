package com.gamebook.tankgame.elements.spawn {
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.gamebook.tankgame.PluginConstants;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class SpawnPoint extends MovieClip{
		
		public function SpawnPoint() {
			mouseChildren = false;
		}
		
		public function getEsObject():EsObject {
			var esob:EsObject = new EsObject();
			esob.setInteger(PluginConstants.X, int(x));
			esob.setInteger(PluginConstants.Y, int(y));
			return esob;
		}
		
	}
	
}