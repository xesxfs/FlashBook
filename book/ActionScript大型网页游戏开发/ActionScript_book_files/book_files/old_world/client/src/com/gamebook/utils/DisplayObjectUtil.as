////////////////////////////////////////////////////////////////////////////////
//
//  ELECTROTANK INC.
//  Copyright© 2009 Electrotank, Inc.
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package com.gamebook.utils {
	
    import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
    import flash.display.Shape;
	
	/**
	 * Utilities to help cleanup flash api objects.
	 *
	 * @author Matt Bolt, Electrotank© 2009
	 */
	public class DisplayObjectUtil {
		
		//--------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Recursively destroys a <code>DisplayObject</code> or <code>DisplayObjectContainer</code>. Since
         * we can't change the display list while the it's recursing (can lead to remove illegal index
         * errors), we'll populate an <code>Array</code> of these objects and remove them once they're
         * all collected.
		 *
		 * @param	obj <code>DisplayObject</code> to destroy.
         *
         * @return  void
		 */
		public static function removeAllChildren(displayObject:DisplayObject):void {
            reverseWalkDisplayObjects(displayObject, function(dispObj:DisplayObject):void {
                if (dispObj) {
                    if (dispObj is MovieClip)
                        MovieClip(dispObj).stop();
                    if (dispObj is Bitmap && Bitmap(dispObj).bitmapData)
                        Bitmap(dispObj).bitmapData.dispose();
                    if (dispObj is Shape && Shape(dispObj).graphics)
                        Shape(dispObj).graphics.clear();
                    if (dispObj.parent)
                        dispObj.parent.removeChild(dispObj);
                }
            });
		}
        
        /**
         * This function recursively calls a callback function on each <code>DisplayObject</code>
         * within the display list provided.
         *
         * @param   displayObject The <code>DisplayObject</code> to recursively call the <code>callbackFunction</code>
         * upon.
         *
         * @param   callbackFunction The <code>Function</code> to apply to each <code>DisplayObject</code>
         */
        public static function walkDisplayObjects(displayObject:DisplayObject, callbackFunction:Function):void {
            callbackFunction(displayObject)
            if (displayObject is DisplayObjectContainer) {
                var n:int = DisplayObjectContainer(displayObject).numChildren;
                for (var i:int = 0; i < n; i++) {
                    var child:DisplayObject = DisplayObjectContainer(displayObject).getChildAt(i);
                    walkDisplayObjects(child, callbackFunction);
                }
            }
        }
        
        /**
         * This function recursively calls a callback function on each <code>DisplayObject</code>
         * within the display list provided.
         *
         * @param   displayObject The <code>DisplayObject</code> to recursively call the <code>callbackFunction</code>
         * upon.
         *
         * @param   callbackFunction The <code>Function</code> to apply to each <code>DisplayObject</code>
         */
        public static function reverseWalkDisplayObjects(displayObject:DisplayObject, callbackFunction:Function):void {
            callbackFunction(displayObject)
            if (displayObject is DisplayObjectContainer) {
                var n:int = DisplayObjectContainer(displayObject).numChildren;
                for (var i:int = n - 1; i >= 0; i--) {
                    var child:DisplayObject = DisplayObjectContainer(displayObject).getChildAt(i);
                    reverseWalkDisplayObjects(child, callbackFunction);
                }
            }
        }

	}
}
