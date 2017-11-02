package  {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	public class flappybird extends MovieClip {
		private var gamebg:MovieClip;
		private var gamebf:MovieClip;
		private var mainpl:MovieClip;
		private var gamereadypl:MovieClip;
		private var scorepanel:MovieClip;
		private var gamelosepl:MovieClip;
		private var fbird:MovieClip;
		
		private var replaybu:SimpleButton;
		protected var piperList:Vector.<Piper>;
		
		private var saygamepl:TextField = new TextField();
		private var scoremark:TextField= new TextField();
		private var textfont:TextFormat = new TextFormat();
		 
		private var scormakrnumber:Number = 0;
		private var gamestartmakr:Boolean = false;
		
		private var creatpipermark:int = 120;
		private var flybirdsu:Sound;
		private var passpipersu:Sound;
		private var loseflysu:Sound;
		
	    
		private var droptimermark:int = 0;
		
		public function flappybird() {
			gameinit();
		}
				
		private function gameinit():void {
			gamebg = new Background();
			gamebg.x = 0;
			gamebg.y = 0;
			addChild(gamebg);
			
			gamebf = new Backfloor();
			gamebf.x = 0;
			gamebf.y = 540;
			addChild(gamebf);

			fbird = new Bird();
			fbird.x = 80;
			fbird.y = 280;
			addChild(fbird);
			
			mainpl = new Mainpanel();
			mainpl.x = 200;
			mainpl.y = 120;
			addChild(mainpl);
			
			gamereadypl = new Getready();
			gamereadypl.x = 200;
			gamereadypl.y = 200;
			addChild(gamereadypl);
			
			saygamepl.textColor=0xFFFFFF;
			saygamepl.text = "Pass Mouse To Fly!"+"\n"+"Make by wuwu";
			saygamepl.width=250;
			saygamepl.x = 90;
			saygamepl.y = 350;
			textfont.size = 25;
			textfont.align = "center";
			textfont.font = "Rockwell";
			saygamepl.setTextFormat(textfont);
			addChild(saygamepl);
			
			stage.addEventListener(MouseEvent.CLICK, flybird);
		}
		
		private function flybird(e:MouseEvent):void 
		{

			if (!gamestartmakr) {		
				 gameready();
				 gamestartmakr = true; 
				}
			fbird.rotation = 0;
			droptimermark = 30;
			flybirdsu = new Flysound();	
			flybirdsu.play();
			

		}
		
		private function gameready():void {
			removeChild(saygamepl);
			removeChild(gamereadypl);
			removeChild(mainpl);
			
			scoremark.textColor=0xFFFFFF;
			scoremark.text = ""+scormakrnumber;
			scoremark.x = 150;
			scoremark.y =30;
			textfont.size = 40;
			textfont.font = "Rockwell Extra Bold"
			scoremark.setTextFormat(textfont);
			addChild(scoremark);
			
			piperList= new Vector.<Piper>();

			stage.addEventListener(Event.ENTER_FRAME, gamerun);
			
		}
		
		private function gamerun(e:Event):void 
		{	
		
			if(gamestartmakr){
		       dropbird();	
			   movebackfloor();
			   creatpiper();
			   movepiper();
			   checkhit();	
			}
			
		}
		
		private function checkhit():void 
		{
			if (fbird.hitTestObject(gamebf)) {
				gamestartmakr = false; 
				gamelose();
				}
			
			for each (var temperpiper:Piper in piperList){
			    
				if (fbird.hitTestObject(temperpiper)){
                    gamestartmakr = false; 
					gamelose();
				}		
			}	
		}
		
	
		private function dropbird():void 
		{
			droptimermark--;
			if (droptimermark > 0) {
				fbird.y -= droptimermark/8;
				fbird.rotation--;
			}
			else {
				if(fbird.rotation<90){
				   fbird.rotation+=45;
				}
				fbird.y += -droptimermark/2;
				}
		}
		
		private function movebackfloor():void 
		{
			gamebf.x--;
            if (gamebf.x == stage.stageWidth - gamebf.width) {
			    gamebf.x = 0;	
			}
		}
		
		private function creatpiper():void 
		{
			creatpipermark--;
			var piperspeed:int = 0;
			var piperspace:int = 0;
			if (scormakrnumber < 10) {
				piperspeed=2
				piperspace = 150;
				}else if (scormakrnumber < 20) {
					piperspeed = 2.5;
					piperspace = 100;
					}else if (scormakrnumber < 30) {
						piperspeed = 3;
						piperspace = 80;	
						}else {
						   piperspeed = 4;
						   piperspace = 60;	
							}
			
			if (creatpipermark==0){
			    var temppiper1:MovieClip = new Piper(piperspeed);	
				temppiper1.x = 2*stage.stageWidth;
			    temppiper1.y = Math.floor(50 - Math.random() * 300);
				addChild(temppiper1);
				piperList.push(temppiper1);		
				
				var temppiper2:MovieClip = new Piper(piperspeed);	
				temppiper2.x = 2*stage.stageWidth;
			    temppiper2.y = temppiper1.y + temppiper2.height + Math.floor(piperspace + Math.random() * 50);
				addChild(temppiper2);
				piperList.push(temppiper2);
				
				creatpipermark = 120;
                var  index:int = gamebf.parent.numChildren - 1;
			    gamebf.parent.setChildIndex(gamebf, index);
			   
			}
		}

		private function movepiper():void 
		{
			for each (var temppiper:Piper in piperList) {
				temppiper.x -= temppiper.speed;
				if (temppiper.x + temppiper.width < 0) {
					removeChild(temppiper);
					piperList.splice(piperList.indexOf(temppiper),1);	
				}
				
				if ( (!temppiper.passflybird)&&((temppiper.x + temppiper.width / 2) < fbird.x)){
			    	passpipersu = new Passsound();
				    passpipersu.play();
				    temppiper.passflybird = true;	
				    scormakrnumber+=0.5;
				    scoremark.text = "" + scormakrnumber;
				    scoremark.setTextFormat(textfont);	
				}
			}
		}
		
		private function gamelose():void 
		{
		    gamelosepl = new Gameover();
		    gamelosepl.x = 200;
		    gamelosepl.y = 180;
		    addChild(gamelosepl);
		
		    scorepanel = new Scorepanel();
		    scorepanel.x = 200;
		    scorepanel.y = 310;
		    addChild(scorepanel);
		
		    scoremark.textColor = 0xFF9900;
		    scoremark.x = 150;
		    scoremark.y = 285;
		    var  index:int = scoremark.parent.numChildren - 1;
		    scoremark.parent.setChildIndex(scoremark, index);
		
		    replaybu = new Rete();
		    replaybu.x = 200;
		    replaybu.y = 350;
		    addChild(replaybu);
		
		    loseflysu = new Losesound();
		    loseflysu.play();	
		
		    stage.removeEventListener(Event.ENTER_FRAME, gamerun);
		    stage.removeEventListener(MouseEvent.CLICK, flybird);
		    replaybu.addEventListener(MouseEvent.MOUSE_DOWN, gamereplay);
		}
		
		private function gamereplay(e:MouseEvent):void 
		{
		    
			replaybu.removeEventListener(MouseEvent.CLICK, gamereplay);
		    removeChild(replaybu);  
		    removeChild(gamelosepl);	  
		    removeChild(scorepanel); 	  
		    removeChild(scoremark);  
		    removeChild(fbird); 	  
		    removeChild(gamebf);	   
		    removeChild(gamebg);  
			
		    for each (var temperpiper:Piper in piperList) {  
			    removeChild(temperpiper);
				piperList.splice(piperList.indexOf(temperpiper),1);  
		    }		
			scormakrnumber = 0;
			gameinit();		
		}
			
	}
	
}
