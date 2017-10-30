package com.gamebook.tankgame {
	import com.gamebook.tankgame.editor.MapEditor;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class EditorMain extends MovieClip {
		
		public function EditorMain() {
			var editor:MapEditor = new MapEditor();
			addChild(editor);
		}
		
	}
	
}