package com.gamebook.world.screens {	
	import com.gamebook.ui.buttons.CloseButton;
	import com.gamebook.ui.buttons.HomeButton;	
	import com.gamebook.ui.buttons.RemoveButton;
	import com.gamebook.utils.assetsloader.Asset;
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.constants.AssetType;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderEvent;	
	import com.gamebook.world.avatar.Avatar;
	import com.gamebook.world.events.BuddyListEvent;
	import com.gamebook.world.events.VendorEvent;
	import com.gamebook.world.furniture.FurnitureDefinition;
	import fl.controls.ScrollBarDirection;
	import fl.controls.ScrollPolicy;
	import fl.controls.TileList;
	import fl.data.DataProvider;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Tom McAvoy
	 */
	
	public class BuddyList extends Sprite {
		
		private var _tl:TileList = new TileList();				
		private var _closeButton:CloseButton = new CloseButton();
		private var _homeButton:HomeButton = new HomeButton();
		private var _removeButton:RemoveButton = new RemoveButton();
		private var _items:Array;
		private var _selectedBuddy:Avatar;
		
		
		public function BuddyList(items:Array) {			
			_items = items;
			
			_items.sortOn("isOnline", Array.DESCENDING);
			
			var dp:DataProvider = new DataProvider();
						
			for each (var a:Avatar in _items) {				
				var tile:Sprite = new Sprite();
								
				var onlineIndicator:Sprite = new Sprite();
				onlineIndicator.graphics.beginFill(a.isOnline ? 0x00FF00 : 0xFF0000);
				onlineIndicator.graphics.drawCircle(-30, 5, 5);
				onlineIndicator.graphics.endFill();
								
				tile.addChild(onlineIndicator);
				
				dp.addItem({label:a.avatarName, data:a, source:tile});	//	from TileList.swc
			}
							
			_tl.width = 225;
			_tl.height = 250;
						
			_tl.rowHeight = 30;
			_tl.columnWidth = 200;
			
			//	add a border to show off the TileList Skin
			_tl.setStyle("contentPadding", 35);
			
			//	for the cell labels
			_tl.setRendererStyle("textOverlayAlpha", 0.0);
			_tl.setRendererStyle("textPadding", 5);
			_tl.setRendererStyle("textFormat", new TextFormat("Rockwell Bold", 14, 0x7F610F));
			
			//	the "interior border" of the tiled cells -- higher values render a smaller thumbnail
			_tl.setRendererStyle("imagePadding", 5);			
						
			_tl.direction = ScrollBarDirection.VERTICAL;
			
			_tl.addEventListener(Event.CHANGE, onSelect);
			_tl.addEventListener(MouseEvent.CLICK, onClick);
			
			_tl.dataProvider = dp;
			
			addChild(_tl);
			
			_closeButton.addEventListener(MouseEvent.CLICK, onClose);
			_closeButton.x = _tl.x + _tl.width - _closeButton.width / 2;
			_closeButton.y = -_closeButton.height / 2;
			
			_removeButton.addEventListener(MouseEvent.CLICK, onRemove);
			_removeButton.x = 5;
			_removeButton.y = 5;
			addChild(_removeButton);
			disableButton(_removeButton);
			
			_homeButton.addEventListener(MouseEvent.CLICK, onInvite);
			_homeButton.x = 115;
			_homeButton.y = 5;			
			addChild(_homeButton);
			disableButton(_homeButton);
			
			addChild(_closeButton);
			
			/**
			 * more at http://www.adobe.com/devnet/flash/quickstart/tilelist_component_as3/			 
			 */ 
		}	
		
		private function onInvite(e:MouseEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent(new BuddyListEvent(BuddyListEvent.GO_TO_HOME, _selectedBuddy));
		}
		
		private function onRemove(e:MouseEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent(new BuddyListEvent(BuddyListEvent.BUDDY_REMOVE, _selectedBuddy));
		}
		
		public function destroy():void {
			_tl.removeEventListener(Event.CHANGE, onSelect);
			_closeButton.removeEventListener(MouseEvent.CLICK, onClose);
			_removeButton.removeEventListener(MouseEvent.CLICK, onRemove);
			_homeButton.removeEventListener(MouseEvent.CLICK, onInvite);
			
			removeChild(_tl);
			_tl = null;	
			
			removeChild(_closeButton);
			_closeButton = null;
						
			removeChild(_removeButton);
			_removeButton = null;
			
			removeChild(_homeButton);
			_homeButton = null;
			
			_items = null;
			_selectedBuddy = null;
		}
		
		private function onClose(e:MouseEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		//	seize the click to prevent it bubbling to stage as a "walk" command
		private function onClick(e:MouseEvent):void {
			e.stopImmediatePropagation();
		}
		
		private function enableButton(b:SimpleButton):void {
			b.mouseEnabled = true;
			b.alpha = 1;
		}
		
		private function disableButton(b:SimpleButton):void {
			b.mouseEnabled = false;
			b.alpha = 0.5;
		}
		
		private function onSelect(e:Event):void {
			
			var selected:Avatar = TileList(e.target).selectedItem.data;
			
			trace("selected " + selected);
			
			_selectedBuddy = selected;
			
			enableButton(_homeButton);
			enableButton(_removeButton);			
			
			dispatchEvent(new BuddyListEvent(BuddyListEvent.BUDDY_SELECTED, selected));
		}
		
	}
}