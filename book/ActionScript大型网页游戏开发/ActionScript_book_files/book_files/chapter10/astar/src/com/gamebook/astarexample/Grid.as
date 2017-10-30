package com.gamebook.astarexample {
	//A* specific imports
	import com.gamebook.utils.astar.Astar;
	import com.gamebook.utils.astar.INode;
	import com.gamebook.utils.astar.ISearchable;
	import com.gamebook.utils.astar.SearchResults;
	import com.gamebook.utils.astar.Path;
	import fl.controls.Button;
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	//other
	import flash.display.MovieClip;
	public class Grid extends MovieClip implements ISearchable{
		private var tiles:Array;
		private var cols:int;
		private var rows:int;
		private var startTile:Tile;
		private var goalTile:Tile;
		private var tileHolder:MovieClip;
		private var lastPath:Path;
		private var tileWidth:Number;
		private var tileHeight:Number;
		private var costs:Object;
		
		//ui
		private var myComboBox:ComboBox;
		private var myCheckBox:CheckBox;
		private var myButton:Button;
		private var myTextField:TextField;
		private var currentNodeType:String;
		private var isEditing:Boolean;

		//
		public function Grid() {
			tiles = new Array();
			costs = new Object();
		}
		
		
		public function tileClicked(e:Event):void {
			if (!isEditing) {
				if (!Tile(e.target).getIsWall()) {
					if (startTile == null) {
						startTile = Tile(e.target);
						startTile.showStartDot();
					} else if (goalTile == null) {
						goalTile = Tile(e.target);
						goalTile.showEndDot();
						search();
					} else {
						clearPath();
					}
				}
			} else if (isEditing) {
				clearPath();
				var t:Tile = Tile(e.target);
				t.setNodeType(currentNodeType);
				trace("getTile(" + t.getCol().toString() + ", " + t.getRow().toString() + ").setNodeType('" + currentNodeType + "');");
			}
		}
		
		
		private function clearPath():void {
			if (startTile != null) {
				startTile.unShowStartDot();
			}
			if (lastPath != null) {
				var path:Path = lastPath;
				for (var i:int=0;i<path.getNodes().length;++i) {
					var t:Tile = Tile(path.getNodes()[i]);
					t.unShowPath();
				}
				goalTile.unShowEndDot();
				
			}
			startTile = null;
			goalTile = null;
			lastPath = null;
		}
		
		
		public function getNodeTransitionCost(n1:INode, n2:INode):Number {
			var cost:Number = costs[n1.getNodeType() + n2.getNodeType()];
			return cost;
		}
		
		
		public function search():SearchResults {
			var startDate:Date = new Date();
			var astar:Astar = new Astar(this);
			
			var results:SearchResults = astar.search(INode(startTile), INode(goalTile));
			if (results.getIsSuccess()) {
				var path:Path = results.getPath();
				for (var i:int=0;i<path.getNodes().length;++i) {
					var t:Tile = Tile(path.getNodes()[i]);
					t.showPath();
				}
			}
			lastPath = results.getPath();
			var endDate:Date = new Date();
			var totalTime:Number = endDate.valueOf()-startDate.valueOf();
			myTextField.text = totalTime + " ms";
			return results;
		}
		
		
		private function initUI():void {
			isEditing = false;
			//combo box
			myComboBox = new ComboBox();
			var dp:DataProvider = new DataProvider();
			dp.addItem( { label:"grass" } );
			dp.addItem( { label:"wall" } );
			dp.addItem( { label:"water" } );
			dp.addItem( { label:"bridge" } );
			dp.addItem( { label:"fire" } );
			myComboBox.dataProvider = dp;
			currentNodeType = "grass";
			myComboBox.enabled = false;
			myComboBox.addEventListener(Event.CHANGE, onComboChange);
			addChild(myComboBox);
			//check box
			myCheckBox = new CheckBox();
			myCheckBox.selected = false;
			myCheckBox.label = "Edit";
			myCheckBox.x = 110;
			myCheckBox.addEventListener(Event.CHANGE, onCheckBoxChange);
			addChild(myCheckBox);
			//button
			myButton = new Button();
			myButton.label = "clear";
			myButton.enabled = false;
			myButton.x = 160;
			myButton.addEventListener(MouseEvent.CLICK, onClearClicked);
			addChild(myButton);
			//text field
			myTextField = new TextField();
			myTextField.type = TextFieldType.DYNAMIC;
			myTextField.x = 350;
			addChild(myTextField);
			
			
		}
		
		
		private function onClearClicked(e:MouseEvent):void {

			for (var i:int=0;i<cols;++i) {
				for (var j:int=0;j<rows;++j) {
					var t:Tile = getTile(i, j);
					t.setNodeType("grass");
				}
			}
			
		}
		
		
		private function onComboChange(e:Event):void {
			currentNodeType = myComboBox.selectedItem.label;
		}
		
		
		private function onCheckBoxChange(e:Event):void {
			isEditing = myCheckBox.selected;
			myComboBox.enabled = isEditing;
			myButton.enabled = isEditing;
		}
		
		
		public function initialize(numCols:int, numRows:int):void {
			initUI();
			
			costs["grassgrass"] = 1;
			costs["bridgebridge"] = 1;
			costs["bridgegrass"] = 1;
			costs["grassbridge"] = 1;
			costs["grasswall"] = 1000000;
			costs["wallgrass"] = 1000000;
			costs["bridgewall"] = 1000000;
			costs["wallbridge"] = 1000000;
			costs["watergrass"] = 1;
			costs["bridgewater"] = 10;
			costs["waterbridge"] = 1000000;
			costs["grasswater"] = 10;
			costs["waterwater"] = 1;
			costs["wallwall"] = 1000000;
			costs["firefire"] = 1000000;
			costs["firewater"] = 1;
			costs["firewall"] = 1000000;
			costs["firegrass"] = 1;
			costs["firebridge"] = 1;
			costs["waterfire"] = 1000000;
			costs["wallfire"] = 1000000;
			costs["grassfire"] = 1000000;
			costs["bridgefire"] = 1000000;
			//
			tileHolder = new MovieClip();
			addChild(tileHolder);
			cols = numCols;
			rows = numRows;
			tileWidth = 20;
			tileHeight = 20;
			var w:Number = tileWidth;
			var h:Number = tileHeight;
			for (var i:int=0;i<cols;++i) {
				tiles[i] = new Array();
				for (var j:int=0;j<rows;++j) {
					var t:Tile = new Tile(i, j);
					t.setNodeType("grass");
					t.addEventListener(Tile.CLICKED, tileClicked);
					t.x = i*w;
					t.y = 25+j*h;
					tiles[i][j] = t;
					tileHolder.addChild(t);
				}
			}
			getTile(0, 4).setNodeType("water");
			getTile(0, 5).setNodeType("water");
			getTile(1, 4).setNodeType("water");
			getTile(1, 5).setNodeType("water");
			getTile(2, 5).setNodeType("water");
			getTile(2, 6).setNodeType("water");
			getTile(3, 5).setNodeType("water");
			getTile(3, 6).setNodeType("water");
			getTile(4, 6).setNodeType("water");
			getTile(4, 7).setNodeType("water");
			getTile(5, 7).setNodeType("water");
			getTile(5, 6).setNodeType("water");
			getTile(6, 6).setNodeType("water");
			getTile(6, 7).setNodeType("water");
			getTile(7, 6).setNodeType("water");
			getTile(7, 7).setNodeType("water");
			getTile(8, 6).setNodeType("water");
			getTile(8, 7).setNodeType("water");
			getTile(9, 6).setNodeType("water");
			getTile(9, 7).setNodeType("water");
			getTile(10, 6).setNodeType("water");
			getTile(10, 7).setNodeType("water");
			getTile(11, 6).setNodeType("water");
			getTile(11, 7).setNodeType("water");
			getTile(12, 7).setNodeType("water");
			getTile(12, 8).setNodeType("water");
			getTile(13, 8).setNodeType("water");
			getTile(13, 7).setNodeType("water");
			getTile(14, 7).setNodeType("water");
			getTile(14, 8).setNodeType("water");
			getTile(15, 8).setNodeType("water");
			getTile(15, 9).setNodeType("water");
			getTile(16, 8).setNodeType("water");
			getTile(16, 9).setNodeType("water");
			getTile(17, 8).setNodeType("water");
			getTile(17, 7).setNodeType("water");
			getTile(19, 7).setNodeType("water");
			getTile(19, 8).setNodeType("water");
			getTile(18, 7).setNodeType("water");
			getTile(18, 8).setNodeType("water");
			getTile(9, 5).setNodeType("bridge");
			getTile(10, 5).setNodeType("bridge");
			getTile(9, 6).setNodeType("bridge");
			getTile(10, 6).setNodeType("bridge");
			getTile(9, 7).setNodeType("bridge");
			getTile(10, 7).setNodeType("bridge");
			getTile(9, 8).setNodeType("bridge");
			getTile(10, 8).setNodeType("bridge");
			getTile(13, 12).setNodeType('fire');
			getTile(14, 12).setNodeType('fire');
			getTile(13, 13).setNodeType('fire');
			getTile(14, 13).setNodeType('fire');
			getTile(13, 14).setNodeType('fire');
			getTile(14, 14).setNodeType('fire');
			getTile(15, 12).setNodeType('fire');
			getTile(15, 13).setNodeType('fire');
			getTile(0, 10).setNodeType('wall');
			getTile(1, 10).setNodeType('wall');
			getTile(2, 10).setNodeType('wall');
			getTile(2, 11).setNodeType('wall');
			getTile(2, 12).setNodeType('wall');
			getTile(2, 14).setNodeType('wall');
			getTile(1, 14).setNodeType('wall');
			getTile(0, 14).setNodeType('wall');
			getTile(1, 12).setNodeType('wall');
			getTile(7, 1).setNodeType('wall');
			getTile(7, 2).setNodeType('wall');
			getTile(8, 2).setNodeType('wall');
			getTile(9, 2).setNodeType('wall');
			getTile(11, 2).setNodeType('wall');
			getTile(12, 2).setNodeType('wall');
			getTile(13, 2).setNodeType('wall');
			getTile(13, 1).setNodeType('wall');			
			//startTile = getTile(5, 8);
			//goalTile = getTile(12, 8);
			//search();
			
		}
		
		
		public function getNode(col:int, row:int):INode {
			return getTile(col, row);
		}
		public function getTile(col:int, row:int):Tile {
			return tiles[col][row];
		}
		public function getCols():int {
			return cols;
		}
		public function getRows():int {
			return rows;
		}
	}
	
}
