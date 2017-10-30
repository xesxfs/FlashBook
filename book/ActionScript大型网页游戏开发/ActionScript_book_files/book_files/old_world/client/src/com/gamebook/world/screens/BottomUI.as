package com.gamebook.world.screens {
    import com.gamebook.renderer.events.UserHomesEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	[Embed(source='../../../../assets/assets.swf', symbol='BottomUI')]
	public class BottomUI extends MovieClip {
		
		public static const BUDDY_LIST_CLICKED:String = "buddyListClicked";
		public static const HOME_CLICKED:String = "homeClicked";
		
		public var buddyList_btn:SimpleButton;
		public var home_btn:SimpleButton;
		public var worldButton:SimpleButton;
		
		public function BottomUI() {
            worldButton.visible = false;
            worldButton.addEventListener(MouseEvent.CLICK, onClick);
			buddyList_btn.addEventListener(MouseEvent.CLICK, onClick);
			home_btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			e.stopPropagation();
			
			switch (e.target) {
                case worldButton:
                    dispatchEvent(new UserHomesEvent(UserHomesEvent.EXIT_HOMES));
                    break;
				case buddyList_btn:
					dispatchEvent(new Event(BUDDY_LIST_CLICKED));
					break;
				case home_btn:
					dispatchEvent(new Event(HOME_CLICKED));
					break;
			}
		}
		
	}
	
}
