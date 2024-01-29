////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2008 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/**
 * Facade of the NetStream and NetConnection classes
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

package cv.sideshow.model {
	
	import cv.media.ImagePlayer;
	import cv.media.NetStreamPlayer;
	import cv.media.RTMPPlayer;
	import cv.media.SoundPlayer;
	import flash.events.IOErrorEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import cv.TempoLite;
	import cv.events.LoadEvent;
	import cv.events.PlayProgressEvent;
	import cv.events.MetaDataEvent;
	import cv.sideshow.Main;
	import cv.managers.UpdateManager;
	
	import fl.data.DataProvider;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.media.Video;
	import flash.net.SharedObject;
	
	public class TempoProxy {
		
		private var nsPlayer:NetStreamPlayer = new NetStreamPlayer();
		private var rtmpPlayer:RTMPPlayer = new RTMPPlayer();
		private var imgPlayer:ImagePlayer = new ImagePlayer();
		private var sndPlayer:SoundPlayer = new SoundPlayer();
		private var tempo:TempoLite = new TempoLite([nsPlayer, rtmpPlayer, imgPlayer, sndPlayer]);
		private var soList:SharedObject = SharedObject.getLocal("SideShow");
		private var _isMute:Boolean = false;
		private var prevVolume:Number = 1;
		
		public function TempoProxy() {
			
			tempo.addEventListener(LoadEvent.LOAD_START, tempoHandler, false, 0, true);
			tempo.addEventListener(LoadEvent.LOAD_PROGRESS, tempoHandler, false, 0, true);
			tempo.addEventListener(LoadEvent.LOAD_COMPLETE, tempoHandler, false, 0, true);
			tempo.addEventListener(PlayProgressEvent.PLAY_START, tempoHandler, false, 0, true);
			tempo.addEventListener(PlayProgressEvent.PLAY_PROGRESS, tempoHandler, false, 0, true);
			tempo.addEventListener(PlayProgressEvent.PLAY_COMPLETE, tempoHandler, false, 0, true);
			tempo.addEventListener(PlayProgressEvent.STATUS, tempoHandler, false, 0, true);
			tempo.addEventListener(MetaDataEvent.METADATA, tempoHandler, false, 0, true);
			tempo.addEventListener(TempoLite.REFRESH_PLAYLIST, tempoHandler);
			tempo.addEventListener(TempoLite.NEW_PLAYLIST, tempoHandler);
			tempo.repeat = TempoLite.REPEAT_NONE;
			tempo.autoStart = true;
			tempo.debug = true;
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get volume():Number {
			return tempo.volume;
		}
		
		public function set volume(value:Number):void {
			tempo.volume = value;
			Main.sendNotification(Main.VOLUME_UPDATE, tempo.volume);
		}
		
		public function get repeat():String {
			return tempo.repeat;
		}
		
		public function set repeat(value:String):void {
			tempo.repeat = value;
		}
		
		public function get shuffle():Boolean {
			return tempo.shuffle;
		}
		
		public function set shuffle(value:Boolean):void {
			tempo.shuffle = value;
		}
		
		public function get isPause():Boolean {
			return tempo.paused;
		}
		
		public function get isMute():Boolean {
			return _isMute;
		}
		
		public function set isMute(value:Boolean):void {
			_isMute = value;
			if (_isMute) {
				prevVolume = this.volume;
				this.volume = 0;
			} else {
				this.volume = prevVolume;
			}
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function addItem(item:Object):void {
			tempo.addItem(item);
		}
		
		public function checkIfPlayList():void {
			if (soList.data.playlist) {
				var arrPlayList:Array = soList.data.playlist as Array;
				for each(var item:Object in arrPlayList) {
					if(item["data"]) addItem(item["data"]);
				}
			}
		}
		
		public function clearList():void {
			// Delete saved playlist
			soList.clear();
			
			tempo.clearItems();
			Main.sendNotification(Main.PLAYLIST_UPDATE, tempo.list);
		}
		
		public function closeFile():void {
			tempo.stop();
			tempo.unload();
		}
		 
		// BUG: Shuffle is broken
		public function getNext():Object {
			var o:Object;
			if (!tempo.shuffle) {
				o = tempo.list.getNext();
			} else {
				o = tempo.listShuffled.getNext();
				tempo.list.index = o.index; // TypeError: Error #1009: Cannot access a property or method of a null object reference.
				o = tempo.list.getCurrent();
			}
			return o;
		}
		
		public function getPrevious():Object {
			var o:Object;
			if (!tempo.shuffle) {
				o = tempo.list.getPrevious();
			} else {
				o = tempo.listShuffled.getPrevious();
				tempo.list.index = o.index;
				o = tempo.list.getCurrent();
			}
			return o;
		}
		
		public function isAudio(f:File):Boolean {
			if(f && f.exists) {
				switch(f.extension) {
					case "flv" :
					case "mp4" :
					case "m4v" :
					case "3gp" :
					case "mov" :
					case "f4v" : 
					case "f4p" :
					case "f4b" :
						return false;
						break;
					case "mp3" :
					case "m4a" :
					case "f4a" :
						return true;
						break;
					default :
						return false;
				}
			} else {
				return false;
			}
		}
		
		public function isAudioURL(ext:String):Boolean {
			switch(ext) {
				case "flv" :
				case "mp4" :
				case "m4v" :
				case "3gp" :
				case "mov" :
				case "f4v" : 
				case "f4p" :
				case "f4b" :
					return false;
					break;
				case "mp3" :
				case "m4a" :
				case "f4a" :
					return true;
					break;
				default :
					return false;
			}
		}
		
		public function loadMedia(item:Object):void {
			tempo.load(item);
		}
		
		public function loadPlayList(url:String):void {
			tempo.loadPlayList(url);
		}
		
		public function pause(bool:Boolean):void {
			tempo.pause(bool);
			updatePause();
		}
		
		public function play():void {
			tempo.play();
			updatePause();
		}
		
		public function playItem(index:int):void {
			tempo.playItem(index);
			updatePause();
		}
		
		public function removeItem(index:int):void {
			tempo.removeItem(index);
		}
		
		public function seekRelative(time:Number):void {
			tempo.seek(String(time));
			updateProgress();
			updatePause();
		}
		
		public function seekPercent(percent:Number):void {
			tempo.seekPercent(percent);
			updateProgress();
			updatePause();
		}
		
		public function setVideoScreen(vid:Video):void {
			nsPlayer.video = vid;
		}
		
		public function stop():void {
			tempo.stop();
			updateProgress();
			updatePause();
		}
		
		public function swapChannels(bool:Boolean):void {
			if (bool) {
				sndPlayer.rightToLeft = nsPlayer.rightToLeft = rtmpPlayer.rightToLeft = 1;
				sndPlayer.rightToRight = nsPlayer.rightToRight = rtmpPlayer.rightToRight = 0;
				sndPlayer.leftToLeft = nsPlayer.leftToLeft = rtmpPlayer.leftToLeft = 0;
				sndPlayer.leftToRight = nsPlayer.leftToRight = rtmpPlayer.leftToRight = 1;
			} else {
				sndPlayer.rightToLeft = nsPlayer.rightToLeft = rtmpPlayer.rightToLeft = 0;
				sndPlayer.rightToRight = nsPlayer.rightToRight = rtmpPlayer.rightToRight = 1;
				sndPlayer.leftToLeft = nsPlayer.leftToLeft = rtmpPlayer.leftToLeft = 1;
				sndPlayer.leftToRight = nsPlayer.leftToRight = rtmpPlayer.leftToRight = 0;
			}
		}
		
		public function validateFormat(f:File):Boolean {
			if(f.exists) {
				switch(f.extension) {
					case "flv" :
					case "mp4" :
					case "m4v" :
					case "3gp" :
					case "mov" :
					case "f4v" : 
					case "f4p" :
					case "f4b" :
						return true;
						break;
					case "mp3" :
					case "m4a" :
					case "f4a" :
						return true;
						break;
					default :
						return false;
				}
			} else {
				return false;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function tempoHandler(e:Event):void {
			var o:Object;
			
			switch(e.type) {
				case PlayProgressEvent.PLAY_START :
					Main.sendNotification(Main.PLAY_START);
					Main.sendNotification(Main.VOLUME_UPDATE, tempo.volume);
					
					if(Main.CURRENT_FILE) {
						if (Main.CURRENT_FILE.exists && !isAudio(Main.CURRENT_FILE)) {
							Main.sendNotification(Main.VALIDATE_VIDEO);
						} else {
							Main.sendNotification(Main.RESET_SIZE);
						}
					} else if (Main.CURRENT_URL) {
						if (!isAudioURL(Main.CURRENT_URL.extension)) {
							Main.sendNotification(Main.VALIDATE_VIDEO);
						} else {
							Main.sendNotification(Main.RESET_SIZE);
						}
					}
					break;
				case PlayProgressEvent.PLAY_PROGRESS :
					updateProgress();
					break;
				case PlayProgressEvent.PLAY_COMPLETE :
					tempo.pause(true);
					tempo.seekPercent(0);
					Main.sendNotification(Main.PLAY_COMPLETE);
					updateProgress();
					break;
				case LoadEvent.LOAD_COMPLETE :
					if(!Main.CURRENT_FILE) {
						var loader:URLLoader = new URLLoader();
						loader.dataFormat = URLLoaderDataFormat.BINARY;
						loader.addEventListener(Event.COMPLETE, urlLoadHandler, false, 0, true);
						loader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadHandler, false, 0, true);
						loader.load(new URLRequest(Main.CURRENT_URL.name));
					} else {
						Main.sendNotification(Main.LOAD_COMPLETE, (tempo.loadCurrent / tempo.loadTotal));
					}
				case LoadEvent.LOAD_START :
				case LoadEvent.LOAD_PROGRESS :
					//trace("tempo load", tempo.loadCurrent / tempo.loadTotal);
					Main.sendNotification(Main.LOAD_PROGRESS, (tempo.loadCurrent / tempo.loadTotal));
					break;
				case MetaDataEvent.METADATA :
					o = tempo.metaData;
					Main.sendNotification(Main.METADATA, o);
					Main.sendNotification(Main.PLAYLIST_UPDATE, tempo.list);
					if (o.hasOwnProperty("framerate")) Main.sendNotification(Main.VALIDATE_VIDEO, o);
					break;
				case TempoLite.REFRESH_PLAYLIST :
				case TempoLite.NEW_PLAYLIST :
					// Save playlist to memory
					soList.data.playlist = tempo.list.toDataProvider().toArray();
					try{
						soList.flush();
					} catch (e:Error) {
						// Couldn't flush, ignore
						trace("TempoProxy::NEW_PLAYLIST - " + e);
					}
					
					Main.sendNotification(Main.PLAYLIST_UPDATE, tempo.list);
					break;
				case PlayProgressEvent.STATUS :
					Main.sendNotification(Main.PLAYLIST_UPDATE, tempo.list);
					Main.sendNotification(Main.CHANGE);
					updateProgress();
					updatePause();
					break;
			}
		}
		// BUG: Works but WAY too slow. need to be able to pull from the flash cache or the video that's already loaded
		// loads twice
		private function urlLoadHandler(event:Event):void {
			if (event.type == IOErrorEvent.IO_ERROR) {
				trace("TempoProxy::urlLoadHandler - Error : Unable to get file from server.");
			} else {
				Main.CURRENT_FILE = File.createTempFile();
				var loader:URLLoader = event.target as URLLoader;
				var fs:FileStream = new FileStream();
				fs.open(Main.CURRENT_FILE, FileMode.WRITE);
				fs.writeBytes(loader.data, 0, loader.bytesTotal);
				fs.close();
				Main.sendNotification(Main.LOAD_COMPLETE, (tempo.loadCurrent / tempo.loadTotal));
			}
		}
		
		private function updateProgress():void {
			Main.sendNotification(Main.PLAY_PROGRESS, {isPause:tempo.paused, currentPercent:tempo.currentPercent, currentTime:TempoLite.timeToString(tempo.timeCurrent), totalTime:TempoLite.timeToString(tempo.timeTotal)});
		}
		
		private function updatePause():void {
			if(!tempo.paused) {
				Main.sendNotification(Main.PAUSE_UPDATE, tempo.paused);
			} else {
				Main.sendNotification(Main.PAUSE_UPDATE, true);
			}
		}
	}
}