package com.gamebook.renderer.item {
	import com.gamebook.renderer.events.ItemInteractionEvent;
	import com.gamebook.utils.assetsloader.AssetsLoader;
	import com.gamebook.utils.assetsloader.events.AssetsLoaderEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class ItemManager extends EventDispatcher{
		
		public static const DONE_LOADING:String = "doneLoading";
		
		private var _itemDefinitionById:Dictionary;
		private var _itemDefinitions:Array;
		private var _items:Array
		private var _ready:Boolean;
		private var _baseDirectory:String;
		private var _info:XML;
		
		private var _asl:AssetsLoader;
		
		public function ItemManager() {
			_itemDefinitionById = new Dictionary();
			_itemDefinitions = [];
			_items = [];
		}
		
		public function fromXML(info:XML):void {
			_info = info;
			
			_asl = new AssetsLoader();
			_asl.addEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, onAssetsComplete);
			
			for each (var itm_def:XML in info.ItemDefinitions.ItemDefinition) {
				var itemDef:ItemDefinition = new ItemDefinition();
				itemDef.asl = _asl;
				itemDef.baseDirectory = _baseDirectory
				itemDef.fromXML(itm_def);
								
				addItemDefinition(itemDef);
			}
			
			//dispatch complete event if there are no items
			if ( _itemDefinitions.length == 0 )
				dispatchCompleteEvent();
			
		}
		
		public function toXML():String
		{
			var usedDefinitions:Array = [];
										
			//Build the items
			var itemsXML:String = "<Items>\n";
			var l:int = _items.length;
			for ( var c:int = 0; c < l; c++ ) {			
				var tempItem:Item = _items[c];
				if ( tempItem )	{
					//Keep track of what definitions are being used
					if ( usedDefinitions.indexOf( tempItem.itemDefinition ) == -1 ) {
						usedDefinitions.push( tempItem.itemDefinition );
					}
						
					itemsXML += "\t" + tempItem.toXMl();
				}			
			}
			
			itemsXML += "</Items>\n";

			//Build the ItemDefinitions
			var defXML:String = "<ItemDefinitions>\n";
			
			l = usedDefinitions.length;
			for ( c= 0; c < l; c++ ) {
				var itemDef:ItemDefinition = usedDefinitions[c];
				if ( itemDef )	{
					defXML += "\t" + itemDef.toXML() + "\n";
				}			
			}
			
			defXML += "</ItemDefinitions>\n";
									
			return 	defXML + itemsXML;	
		}
		
		public function addItemDefinition(itemDef:ItemDefinition):void {
			
			//Make sure the definition has not already been added
			if ( _itemDefinitionById[ itemDef.id ] ) return;
			
			_itemDefinitionById[itemDef.id] = itemDef;
			_itemDefinitions.push(itemDef);
		}
		
		public function removeItemDefinition(itemDef:ItemDefinition):void {
			for (var i:int = 0; i < _itemDefinitions.length;++i) {
				if (_itemDefinitions[i] == itemDef) {
					_itemDefinitions.splice(i, 1);
					break;
				}
			}
			_itemDefinitionById[itemDef.id] = null;
		}
		
		private function parseItems(info:XML):void {
			for each (var itm_xml:XML in info.Items.Item) {
				var item:Item = new Item();
				item.fromXML(itm_xml);
				
				var def:ItemDefinition = _itemDefinitionById[item.source];
				if (def == null) {
					throw new Error("Item referencing invalid item definition in XML. source=" + item.source);
				}
				item.itemDefinition = def;
				
				
				
				addItem(item);				
			}			
		}
		
		public function addItem(item:Item):void{
			_items.push(item);
			
			item.guideTile.visible = false;
			if (item.onClickEvent != null) {
				item.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				item.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				item.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		private function onClick(e:MouseEvent):void {
			e.stopPropagation();
			
			var iee:ItemInteractionEvent = new ItemInteractionEvent(ItemInteractionEvent.ITEM_CLICKED);
			iee.item = e.target as Item;
			dispatchEvent(iee);
		}
		
		private function onMouseOut(e:MouseEvent):void {
			var itm:Item = e.target as Item;
			itm.filters = [];
		}
		
		private function onMouseOver(e:MouseEvent):void {
			var itm:Item = e.target as Item;
			itm.filters = [new GlowFilter(0x009900)];
		}
		
		public function removeItem(item:Item):void {
			for (var i:int = 0; i < _items.length;++i) {
				if (_items[i] == item) {
					_items.splice(i, 1);
					break;
				}
			}
		}
		
		public function itemDefinitionById(id:String):ItemDefinition {
			return _itemDefinitionById[id];
		}
		
		private function onAssetsComplete(e:AssetsLoaderEvent):void {
			if (e.success) {
				
				parseItems(_info);
				
				dispatchCompleteEvent();
				
				
			} else {
				trace("failed to load all assets");
			}
		}
		
		private function dispatchCompleteEvent():void
		{
			_ready = true;
			
			//clean up
			_info = null;
			_asl.removeEventListener(AssetsLoaderEvent.ASSETS_COMPLETE, onAssetsComplete);
			_asl = null;
			
			dispatchEvent(new Event(DONE_LOADING));
		}
		
		public function get ready():Boolean { return _ready; }
		
		public function set baseDirectory(value:String):void {
			_baseDirectory = value;
		}
		
		public function get items():Array { return _items; }
		
		public function get itemDefinitions():Array { return _itemDefinitions; }
		
	}
	
}