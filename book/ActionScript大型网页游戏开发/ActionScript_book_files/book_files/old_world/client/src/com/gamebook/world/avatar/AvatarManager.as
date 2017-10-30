package com.gamebook.world.avatar {
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Jobe Makar - jobe@electrotank.com
	 */
	public class AvatarManager {
		
		private var _avatars:Array = [];
		private var _avatarsByName:Dictionary = new Dictionary();
		private var _me:Avatar;
		
		public function AvatarManager() {
			
		}
		
		public function removeAvatar(name:String):void {
			for (var i:int = 0; i < _avatars.length;++i) {
				if (_avatars[i].avatarName == name) {
					_avatars.splice(i, 1);
					break;
				}
			}
			_avatarsByName[name] = null;
		}
		
		public function doesAvatarExist(name:String):Boolean {
			return _avatarsByName[name] != null;
		}
		
		public function addAvatar(avatar:Avatar):void {
			_avatars.push(avatar);
			_avatarsByName[avatar.avatarName] = avatar;
			if (avatar.isMe) {
				_me = avatar;
			}
		}
		
		public function avatarByName(name:String):Avatar {
			return _avatarsByName[name];
		}
		
		public function get avatars():Array { return _avatars; }
		
		public function get me():Avatar { return _me; }
		
		
		
	}
	
}