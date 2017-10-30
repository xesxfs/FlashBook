package com.gamebook.coop {
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	
	/**
	 * Handle loading and playing sounds.
	 * @author Mike Bowen - bowen@electrotank.com
	 */
	public class SoundManager {
		
		public static const ARE_YOU_READY:String	= "are_you_ready";
		public static const LASER_BEAM:String		= "laser_beam";
		public static const LEVER:String			= "lever";
		public static const GATE:String				= "gate";
		public static const DESTROY_TOWER:String	= "destroy_tower";
		public static const SAVE_POINT:String		= "save_point";
		public static const SPAWN:String			= "spawn";
		public static const STRAIN:String			= "strain";
		public static const DEATH:String			= "death";
		public static const VICTORY:String			= "victory";
		public static const GAME_OVER:String		= "game_over";
		public static const MOVE_ROCK:String		= "move_rock";
		
		private static var _instance:SoundManager;
		private var _sounds:Array;
		private var _soundTransform:SoundTransform;
		
		private var _soundBackGroundMusic:Sound;
		private var _soundAreYouReady:Sound;
		private var _soundLaserBeam:Sound;
		private var _soundLever:Sound;
		private var _soundGate:Sound;
		private var _soundDestoryTower:Sound;
		private var _soundSavePoint:Sound;
		private var _soundSpawn:Sound;
		private var _soundStrain:Sound;
		private var _soundDeath:Sound;
		private var _soundVictory:Sound;
		private var _soundGameOver:Sound;
		private var _soundMoveRock:Sound;
		
		public function SoundManager(lock:Class) {
			if (lock != SingletonLock) {
				throw new Error("SoundManager is a singleton. Use SoundManager.instance instead.");
			}
		}
		
		public static function get instance():SoundManager {
			if (!_instance) {
				_instance = new SoundManager(SingletonLock);
			}
			
			return _instance;
		}
		
		public function initialize():void {
			
			_sounds = new Array();
			
			_soundBackGroundMusic = new Sound();
			_soundBackGroundMusic.load(new URLRequest("sounds/backGroundMusic.mp3"));
			
			_soundAreYouReady = new Sound();
			_soundAreYouReady.load(new URLRequest("sounds/areYouReady.mp3"));
			_sounds[ARE_YOU_READY] = _soundAreYouReady;
			
			_soundLaserBeam = new Sound();
			_soundLaserBeam.load(new URLRequest("sounds/laserBeam.mp3"));
			_sounds[LASER_BEAM] = _soundLaserBeam;
			
			_soundLever = new Sound();
			_soundLever.load(new URLRequest("sounds/lever.mp3"));
			_sounds[LEVER] = _soundLever;
			
			_soundGate = new Sound();
			_soundGate.load(new URLRequest("sounds/electricGate.mp3"));
			_sounds[GATE] = _soundGate;
			
			_soundDestoryTower = new Sound();
			_soundDestoryTower.load(new URLRequest("sounds/towerDestroy.mp3"));
			_sounds[DESTROY_TOWER] = _soundDestoryTower;
			
			_soundSavePoint = new Sound();
			_soundSavePoint.load(new URLRequest("sounds/savePoint.mp3"));
			_sounds[SAVE_POINT] = _soundSavePoint;
			
			_soundSpawn = new Sound();
			_soundSpawn.load(new URLRequest("sounds/yo.mp3"));
			_sounds[SPAWN] = _soundSpawn;
			
			_soundStrain = new Sound();
			_soundStrain.load(new URLRequest("sounds/moan.mp3"));
			_sounds[STRAIN] = _soundStrain;
			
			_soundDeath = new Sound();
			_soundDeath.load(new URLRequest("sounds/death.mp3"));
			_sounds[DEATH] = _soundDeath;
			
			_soundVictory = new Sound();
			_soundVictory.load(new URLRequest("sounds/victory.mp3"));
			_sounds[VICTORY] = _soundVictory;
			
			_soundGameOver = new Sound();
			_soundGameOver.load(new URLRequest("sounds/gameOver.mp3"));
			_sounds[GAME_OVER] = _soundGameOver;
			
			_soundMoveRock = new Sound();
			_soundMoveRock.load(new URLRequest("sounds/moveRock.mp3"));
			_sounds[MOVE_ROCK] = _soundMoveRock;
			
			// play some mellow bg music
			_soundTransform = new SoundTransform(0.4);
			_soundBackGroundMusic.play(0, 9999, _soundTransform);
		}
		
		public function playSound(sound:String):void {
			_sounds[sound].play(0, 0, _soundTransform);
		}
		
		public function stopAll():void {
			SoundMixer.stopAll();
		}
	}
	
}

class SingletonLock {}