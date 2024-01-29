////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2011 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package cv.sideshow {
	
	import com.greensock.TweenLite;
	
	import cv.events.PVCEvent;
	import cv.data.PlayList;
	import cv.sideshow.Main;
	import cv.sideshow.model.AppProxy;
	import cv.sideshow.model.FileProxy;
	import cv.sideshow.model.TempoProxy;
	import cv.sideshow.model.UpdateProxy;
	import cv.sideshow.view.AboutMediator;
	import cv.sideshow.view.CustomAspectMediator;
	import cv.sideshow.view.FrameMediator;
	import cv.sideshow.view.MenuMediator;
	import cv.sideshow.view.MetaDataMediator;
	import cv.sideshow.view.PlaylistMediator;
	import cv.sideshow.view.StageMediator;
	import cv.sideshow.view.UpdateMediator;
	import cv.sideshow.view.URLMediator;
	import cv.sideshow.view.VideoMediator;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.NativeWindowResize;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.display.NativeWindow;
	
    public class Main extends MovieClip {
		
		// Event Constants //
		
		public static const STARTUP:String = "STARTUP";
		public static const INITIALIZED:String = "INITIALIZED";
		public static const FILE_UPDATE:String = "FILE_UPDATE";
		public static const EXITING:String = "EXITING";
		public static const UPDATE:String = "UPDATE";
		
		// AppProxy
		public static const IDLE:String = "IDLE";
		
		// FileProxy
		public static const OPEN:String = "OPEN";
		public static const SAVE:String = "SAVE";
		public static const SAVE_SS:String = "SAVE_SS";
		
		// TempoProxy
		public static const CONTROL_PREVIOUS:String = "CONTROL_PREVIOUS";
		public static const CONTROL_NEXT:String = "CONTROL_NEXT";
		public static const CONTROL_VOLUME:String = "CONTROL_VOLUME";
		public static const CONTROL_PLAY:String = "CONTROL_PLAY";
		public static const CONTROL_PAUSE:String = "CONTROL_PAUSE";
		public static const CONTROL_PAUSE_TOGGLE:String = "CONTROL_PAUSE_TOGGLE";
		public static const CONTROL_STOP:String = "CONTROL_STOP";
		public static const CONTROL_REWIND:String = "CONTROL_REWIND";
		public static const CONTROL_SEEK:String = "CONTROL_SEEK";
		public static const CONTROL_SEEK_RELATIVE:String = "CONTROL_SEEK_RELATIVE";
		public static const CONTROL_REPEAT:String = "CONTROL_REPEAT";
		public static const CONTROL_SHUFFLE:String = "CONTROL_SHUFFLE";
		public static const CONTROL_SWAP_CHANNELS:String = "CONTROL_SWAP_CHANNELS";
		public static const CONTROL_MUTE:String = "CONTROL_MUTE";
		public static const CHANGE:String = "CHANGE";
		public static const CHECK_FOR_PLAYLIST:String = "CHECK_FOR_PLAYLIST";
		public static const METADATA:String = "METADATA";
		public static const PAUSE_UPDATE:String = "PAUSE_UPDATE";
		public static const PLAYLIST_UPDATE:String = "PLAYLIST_UPDATE";
		public static const PLAY_START:String = "PLAY_START";
		public static const PLAY_PROGRESS:String = "PLAY_PROGRESS";
		public static const LOAD_PROGRESS:String = "LOAD_PROGRESS";
		public static const LOAD_COMPLETE:String = "LOAD_COMPLETE";
		public static const PLAY_COMPLETE:String = "PLAY_COMPLETE";
		
		// PlaylistMediator
		public static const CLOSE_FILE:String = "CLOSE_FILE";
		public static const PLAY_FILE:String = "PLAY_FILE";
		public static const REMOVE_FILE:String = "REMOVE_FILE";
		public static const OPEN_PLAYLIST:String = "OPEN_PLAYLIST";
		public static const SAVE_PLAYLIST:String = "SAVE_PLAYLIST";
		public static const OPEN_FILE:String = "OPEN_FILE";
		public static const OPEN_ITEM:String = "OPEN_ITEM";
		public static const ADD_FILE:String = "ADD_FILE";
		
		public static const PLAYLIST_SHOW:String = "PLAYLIST_SHOW";
		public static const PLAYLIST_URL:String = "PLAYLIST_URL";
		
		// StageMediator
		public static const SET_SIZE:String = "SET_SIZE";
		public static const RESET_SIZE:String = "RESET_SIZE";
		public static const GROW:String = "GROW";
		public static const ON_TOGGLE_FULL:String = "ON_TOGGLE_FULL";
		public static const TOGGLE_FULL:String = "TOGGLE_FULL";
		public static const TOGGLE_ON_TOP:String = "TOGGLE_ON_TOP";
		
		// MenuMediator
		public static const CONTROL_VOLUME_INCREMENT:String = "VOLUME_INCREMENT";
		public static const MENU_SHOW:String = "MENU_SHOW";
		public static const VALIDATE_VIDEO:String = "VALIDATE_VIDEO";
		public static const LOGO_BOUNCE:String = "LOGO_BOUNCE";
		
		// VideoMediator
		public static const SET_SCREEN:String = "SET_SCREEN";
		public static const VIDEO_BRIGHTEN:String = "VIDEO_BRIGHTEN";
		public static const VIDEO_INVERT:String = "VIDEO_INVERT";
		public static const VIDEO_SOFTEN:String = "VIDEO_SOFTEN";
		public static const VIDEO_SHARPEN:String = "VIDEO_SHARPEN";
		public static const VIDEO_SCANLINES:String = "VIDEO_SCANLINES";
		public static const VIDEO_FLIP:String = "VIDEO_FLIP";
		public static const VIDEO_RESET:String = "VIDEO_RESET";
		public static const VIDEO_ASPECT_RATIO:String = "VIDEO_ASPECT_RATIO";
		public static const VIDEO_LOCK_RATIO:String = "VIDEO_LOCK_RATIO";
		public static const VIDEO_UNLOCK_RATIO:String = "VIDEO_UNLOCK_RATIO";
		
		// FrameMediator
		public static const VOLUME_UPDATE:String = "VOLUME_UPDATE";
		public static const HIDE_FRAME:String = "HIDE_FRAME";
		public static const SHOW_FRAME:String = "SHOW_FRAME";
		
		// MetaDataMediator
		public static const METADATA_SHOW:String = "METADATA_SHOW";
		
		// CustomAspectMediator
		public static const CUSTOM_SHOW:String = "CUSTOM_SHOW";
		public static const SELECT_CUSTOM:String = "SELECT_CUSTOM";
		
		// AboutMediator
		public static const ABOUT_SHOW:String = "ABOUT_SHOW";
		
		// URLMediator
		public static const URL_SHOW:String = "URL_SHOW";
		
		// UpdateProxy / UpdateMediator
		public static const UPDATE_AVAIL:String = "UPDATE_AVAIL";
		public static const UPDATE_CHECK:String = "UPDATE_CHECK";
		public static const UPDATE_INSTALL:String = "UPDATE_INSTALL";
		public static const UPDATE_LOAD_ERROR:String = "UPDATE_LOAD_ERROR";
		public static const UPDATE_ERROR:String = "UPDATE_ERROR";
		public static const UPDATE_PROGRESS:String = "UPDATE_PROGRESS";
		
		// End Event Constants //
		
		// Global
		public static var VERSION:String = "3.0.0";
		public static var CURRENT_FILE:File;
		public static var CURRENT_URL:Object;
		public static var HAS_FILE:Boolean = false;
		
		public static const GRIPPER_SIZE:uint = 10;
		public static const URL_PATH:String = "http://blog.coursevector.com/sideshow/";
		private static var _facade:Main;
		
		private var uP:UpdateProxy;
		private var aP:AppProxy;
		private var fP:FileProxy;
		private var tP:TempoProxy;
		
		private var fM:FrameMediator;
		private var urlM:URLMediator;
		private var uM:UpdateMediator;
		private var aM:AboutMediator;
		private var caM:CustomAspectMediator;
		private var mM:MenuMediator;
		private var mdM:MetaDataMediator;
		private var plM:PlaylistMediator;
		private var vM:VideoMediator;
		private var sM:StageMediator;
		
		public function Main() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void {
			_facade = this;
			
			//--------------------------------------
			//  Controller
			//--------------------------------------
			
			addEventListener(Main.ADD_FILE, 				tempoCommand);
			addEventListener(Main.CLOSE_FILE, 				tempoCommand);
			addEventListener(Main.CONTROL_PAUSE, 			tempoCommand);
			addEventListener(Main.CONTROL_SEEK, 			tempoCommand);
			addEventListener(Main.CONTROL_MUTE, 			tempoCommand);
			addEventListener(Main.CONTROL_SHUFFLE, 			tempoCommand);
			addEventListener(Main.CONTROL_REPEAT, 			tempoCommand);
			addEventListener(Main.CONTROL_VOLUME, 			tempoCommand);
			addEventListener(Main.CONTROL_VOLUME_INCREMENT, tempoCommand);
			addEventListener(Main.CONTROL_SWAP_CHANNELS,	tempoCommand);
			addEventListener(Main.EXITING, 					tempoCommand);
			addEventListener(Main.OPEN_FILE, 				tempoCommand);
			addEventListener(Main.OPEN_ITEM, 				tempoCommand);
			addEventListener(Main.OPEN_PLAYLIST, 			tempoCommand);
			addEventListener(Main.PLAY_FILE, 				tempoCommand);
			addEventListener(Main.REMOVE_FILE, 				tempoCommand);
			addEventListener(Main.SET_SCREEN, 				tempoCommand);
			addEventListener(Main.CHECK_FOR_PLAYLIST, 		tempoCommand);
			addEventListener(Main.VALIDATE_VIDEO, 			tempoCommand);
			addEventListener(Main.CONTROL_PAUSE_TOGGLE, 	tempoCommand);
			addEventListener(Main.CONTROL_STOP, 			tempoCommand);
			addEventListener(Main.CONTROL_PREVIOUS, 		tempoCommand);
			addEventListener(Main.CONTROL_NEXT, 			tempoCommand);
			addEventListener(Main.CONTROL_SEEK_RELATIVE, 	tempoCommand);
			
			addEventListener(Main.UPDATE, 					appCommand);
			
			addEventListener(Main.FILE_UPDATE, 				fileCommand);
			addEventListener(Main.SAVE_SS, 					fileCommand);
			addEventListener(Main.SAVE, 					fileCommand);
			addEventListener(Main.OPEN, 					fileCommand);
			
			addEventListener(Main.UPDATE_INSTALL,			updateCommand);
			addEventListener(Main.INITIALIZED,				updateCommand);
			addEventListener(Main.UPDATE_AVAIL,				updateCommand);
			addEventListener(Main.UPDATE_PROGRESS,			updateCommand);
			addEventListener(Main.UPDATE_ERROR,				updateCommand);
			addEventListener(Main.UPDATE_LOAD_ERROR,		updateCommand);
			
			addEventListener(Main.URL_SHOW,					urlCommand);
			
			addEventListener(Main.PLAYLIST_UPDATE,			playlistCommand);
			addEventListener(Main.PLAYLIST_SHOW,			playlistCommand);
			addEventListener(Main.PLAYLIST_URL,				playlistCommand);
			
			addEventListener(Main.EXITING, 					videoCommand);
			addEventListener(Main.VIDEO_ASPECT_RATIO, 		videoCommand);
			addEventListener(Main.VIDEO_LOCK_RATIO, 		videoCommand);
			addEventListener(Main.VIDEO_BRIGHTEN, 			videoCommand);
			addEventListener(Main.VIDEO_INVERT, 			videoCommand);
			addEventListener(Main.VIDEO_SOFTEN, 			videoCommand);
			addEventListener(Main.VIDEO_SHARPEN, 			videoCommand);
			addEventListener(Main.VIDEO_SCANLINES, 			videoCommand);
			addEventListener(Main.VIDEO_FLIP, 				videoCommand);
			addEventListener(Main.VIDEO_RESET, 				videoCommand);
			
			addEventListener(Main.METADATA, 				metadataCommand);
			addEventListener(Main.METADATA_SHOW, 			metadataCommand);
			
			addEventListener(Main.MENU_SHOW, 				menuCommand);
			addEventListener(Main.ON_TOGGLE_FULL, 			menuCommand);
			addEventListener(Main.SELECT_CUSTOM, 			menuCommand);
			addEventListener(Main.LOAD_COMPLETE, 			menuCommand);
			
			addEventListener(Main.TOGGLE_FULL, 				stageCommand);
			addEventListener(Main.TOGGLE_ON_TOP, 			stageCommand);
			addEventListener(Main.GROW, 					stageCommand);
			addEventListener(Main.PLAY_PROGRESS, 			stageCommand);
			addEventListener(Main.PLAY_COMPLETE, 			stageCommand);
			addEventListener(Main.SET_SIZE, 				stageCommand);
			addEventListener(Main.RESET_SIZE, 				stageCommand);
			addEventListener(Main.IDLE, 					stageCommand);
			addEventListener(Main.CHANGE, 					stageCommand);
			addEventListener(Main.LOGO_BOUNCE, 				stageCommand);
			addEventListener(Main.EXITING, 					stageCommand);
			
			addEventListener(Main.LOAD_PROGRESS, 			frameCommand);
			addEventListener(Main.PLAY_PROGRESS, 			frameCommand);
			addEventListener(Main.VOLUME_UPDATE, 			frameCommand);
			addEventListener(Main.PAUSE_UPDATE, 			frameCommand);
			addEventListener(Main.HIDE_FRAME, 				frameCommand);
			addEventListener(Main.SHOW_FRAME, 				frameCommand);
			addEventListener(Main.EXITING, 					frameCommand);
			
			addEventListener(Main.ABOUT_SHOW, 				aboutCommand);
			
			addEventListener(Main.CUSTOM_SHOW, 				customCommand);
			
			//--------------------------------------
			//  Model
			//--------------------------------------
			
			uP = new UpdateProxy();
			aP = new AppProxy();
			fP = new FileProxy();
			tP = new TempoProxy();
			
			//--------------------------------------
			//  View
			//--------------------------------------
			
			
			plM = new PlaylistMediator();
			mdM = new MetaDataMediator();
			uM = new UpdateMediator();
			aM = new AboutMediator();
			urlM = new URLMediator();
			caM = new CustomAspectMediator();
			mM = new MenuMediator(stage);
			vM = new VideoMediator(vidScreen as Video);
			sM = new StageMediator(this);
			fM = mcFrame as FrameMediator;
			this.addChild(mcFrame);
			
			// Startup
			
			sendNotification(Main.UPDATE);
			sendNotification(Main.FILE_UPDATE, {hasFile:false});
			sendNotification(Main.RESET_SIZE);
			sendNotification(Main.CHECK_FOR_PLAYLIST);
			sendNotification(Main.INITIALIZED);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public static function sendNotification(notificationName:String, body:Object=null, type:String=null):void {
			_facade.dispatchEvent(new PVCEvent(notificationName, body, type));
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function stageCommand(note:PVCEvent):void {
			var o:Object = note.getBody();
			var w:Number;
			var h:Number;
			
			switch (note.getName()) {
				case Main.LOGO_BOUNCE :
					sM.doLogoBounce = note.getBody() as Boolean;
					break;
				case Main.CHANGE :
					sM.validateSetOnTop(false);
					break;
				case Main.TOGGLE_FULL :
					sM.toggleFull();
					break;
				case Main.TOGGLE_ON_TOP :
					sM.toggleOnTop(o.toggle, Boolean(o.whilePlaying));
					break;
				case Main.IDLE :
					sM.updateMouse();
					break;
				case Main.GROW :
					sM.grow(note.getBody() as int);
					break;
				case Main.PLAY_PROGRESS :
					sM.updatePlayProgress(!tP.isPause);
					break;
				case Main.PLAY_COMPLETE :
					if (tP.repeat == 'track') {
						tP.pause(false);
					} else {
						sM.validateSetOnTop(false);
					}
					break;
				case Main.EXITING :
					sM.hide();
					break;
				case Main.SET_SIZE :
					vM.setSize(o.width, o.height, o.multiplier, o.isFull);
					w = vM.screen.width;
					h = vM.screen.height;
					sM.setSize(w, h);
					fM.setSize(w, h);
					break;
				case Main.RESET_SIZE :
					vM.resetSize();
					w = vM.origWidth;
					h = vM.origHeight;
					sM.setSize(w, h);
					fM.setSize(w, h);
					break;
			}
		}
		
		private function frameCommand(note:PVCEvent):void {
			switch (note.getName())	{
				case Main.VOLUME_UPDATE :
					fM.updateVolume(note.getBody() as Number);
					break;
				case Main.PAUSE_UPDATE :
					fM.updatePause(note.getBody() as Boolean);
					break;
				case Main.EXITING :
					fM.onExit();
					break;
				case Main.HIDE_FRAME :
					fM.hide();
					break;
				case Main.SHOW_FRAME :
					fM.show();
					break;
				case Main.PLAY_PROGRESS :
					var o:Object = note.getBody();
					fM.updateProgress(o.currentPercent, o.currentTime, o.totalTime);
					break;
				case Main.LOAD_PROGRESS :
					fM.updateLoadProgress(note.getBody() as Number);
					break;
			}
		}
		
		private function aboutCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.ABOUT_SHOW :
					aM.show();
					break;
			}
		}
		
		private function customCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.CUSTOM_SHOW :
					caM.show();
					break;
			}
		}
		
		private function menuCommand(note:PVCEvent):void {
			switch (note.getName())	{
				case Main.MENU_SHOW :
					var o:Object = note.getBody();
					mM.show(o.stage, o.stageX, o.stageY);
					break;
				case Main.ON_TOGGLE_FULL :
					mM.setFullScreenMode(note.getBody() as Boolean);
					break;
				case Main.SELECT_CUSTOM :
					mM.aspectHandler(null, "Custom aspect ratio");
					break;
				case Main.LOAD_COMPLETE :
					mM.setSaveAs(true);
					break;
			}
		}
		
		private function metadataCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.METADATA :
					mdM.setMessage(note.getBody());
					break;
				case Main.METADATA_SHOW :
					mdM.show();
					break;
			}
		}
		
		private function videoCommand(note:PVCEvent):void {
	var o:Object = note.getBody() || {};
			var w:Number;
			var h:Number;
			switch (note.getName())	{
				case Main.VIDEO_LOCK_RATIO :
					vM.isRatioLocked = note.getBody() as Boolean;
					break;
				case Main.VIDEO_ASPECT_RATIO :
					vM.setAspectRatio(o.width, o.height);
					break;
				case Main.VIDEO_BRIGHTEN :
					var brightnessAmount:int = vM.brighten(note.getBody() as int);
					mM.updateBrightness(brightnessAmount);
					break;
				case Main.VIDEO_INVERT :
					vM.invert(note.getBody() as Boolean);
					break;
				case Main.VIDEO_SOFTEN :
					vM.soften(note.getBody() as Boolean);
					break;
				case Main.VIDEO_SHARPEN :
					vM.sharpen(note.getBody() as Boolean);
					break;
				case Main.VIDEO_SCANLINES :
					vM.scanLines(note.getBody() as Boolean);
					break;
				case Main.VIDEO_FLIP :
					vM.flip(note.getBody() as Boolean);
					break;
				case Main.VIDEO_RESET :
					vM.reset();
					break;
				case Main.EXITING :
					vM.hide();
					break;
			}
		}
		
		private function playlistCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.PLAYLIST_UPDATE :
					plM.updateList(note.getBody() as PlayList);
					break;
				case Main.PLAYLIST_SHOW :
					plM.show();
					break;
				case Main.PLAYLIST_URL :
					var o:Object = note.getBody();
					plM.setURL(o.url, o.quality as Boolean, o.fileType);
					break;
			}
		}
		
		private function urlCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.URL_SHOW :
					urlM.show();
					break;
			}
		}
		
		private function appCommand(note:PVCEvent):void {
			var o:Object = note.getBody() as Object;
			
			switch(note.getName()) {
				case Main.UPDATE :
					if (o && o.hasOwnProperty("alpha")) sM.appAlpha = o.alpha;
					
					if (Main.HAS_FILE) {
						if(Main.CURRENT_FILE) {
							if(Main.CURRENT_FILE.exists) {
								if (tP.validateFormat(Main.CURRENT_FILE)) {
									if (!tP.isAudio(Main.CURRENT_FILE)) {
										sM.videoMode();
										TweenLite.to(vM.screen, .5, { autoAlpha:sM.appAlpha } );
									} else {
										sM.audioMode();
										TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
									}
								} else {
									sM.showError("format");
								}
							} else {
								sM.showError("exists");
							}
						} else if (!Main.CURRENT_FILE && Main.CURRENT_URL) {
							if (!tP.isAudioURL(Main.CURRENT_URL.extension)) {
								sM.videoMode();
								TweenLite.to(vM.screen, .5, { autoAlpha:sM.appAlpha } );
							} else {
								sM.audioMode();
								TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
							}
						}
					} else {
						if(sM.isInitialized) sM.defaultMode();
						TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
					}
					break;
			}
		}
		
		private function fileCommand(note:PVCEvent):void {
			var o:Object = note.getBody() as Object;
			
			switch(note.getName()) {
				case Main.FILE_UPDATE :
					Main.HAS_FILE = o.hasFile;
					mM.setHasFile(o.hasFile);
					
					if (o.hasFile) {
						fM.setTitle(o.name);
						mdM.setTitle(o.name);
					} else {
						mdM.setTitle();
					}
					sendNotification(Main.SHOW_FRAME);
					break;
				case Main.OPEN :
					fP.browseForOpen();
					break;
				case Main.SAVE :
					fP.browseForSave();
					break;
				case Main.SAVE_SS :
					var bmd:BitmapData = vM.getBitMapData();
					sendNotification(Main.CONTROL_PAUSE, true);
					fP.browseForSaveSS(bmd);
					sM.validateSetOnTop(false);
					break;
			}
		}
		
		private function updateCommand(note:PVCEvent):void {
			switch(note.getName()) {
				case Main.INITIALIZED :
				case Main.UPDATE_CHECK :
					uP.check();
					break;
				case Main.UPDATE_INSTALL :
					uP.update();
					break;
				case Main.UPDATE_AVAIL :
					uM.show(note.getBody());
					break;
				case Main.UPDATE_PROGRESS :
					uM.setProgress(note.getBody());
					break;
				case Main.UPDATE_ERROR :
					uM.updateError();
					break;
				case Main.UPDATE_LOAD_ERROR :
					uM.loadError();
					break;
			}
		}
		
		private function tempoCommand(note:PVCEvent):void {
			var o:Object = note.getBody();
			var f:File;
			
			switch(note.getName()) {
				case Main.VALIDATE_VIDEO :
					vM.validateVideo(o);
					mM.validateVideo(o);
					break;
				case Main.OPEN_FILE :
					f = note.getBody() as File;
					Main.CURRENT_FILE = f;
					Main.CURRENT_URL = null;
					sM.hideError();
					
					if(f.exists) {
						if (tP.validateFormat(f)) {
							sendNotification(Main.FILE_UPDATE, {hasFile:true, name:f.name});
							sendNotification(Main.UPDATE);
							tP.loadMedia({url:f.url});
						} else {
							sM.showError("format");
							sendNotification(Main.CLOSE_FILE);
						}
					} else {
						sM.showError("exists");
						sendNotification(Main.CLOSE_FILE);
					}
					break;
				case Main.ADD_FILE :
					tP.addItem(note.getBody());
					break;
				case Main.OPEN_ITEM :
					if (o) {
						if (String(o.url).indexOf("http://") > -1) {
							Main.CURRENT_FILE = null;
							Main.CURRENT_URL = {name:o.url, extension:o.extOverride};
							sM.hideError();
							sendNotification(Main.FILE_UPDATE, { hasFile:true, name:o.url } );
							sendNotification(Main.UPDATE);
							tP.playItem(o.index);
						} else {
							try {
								f = new File(o.url);
							} catch (e:Error) {
								sM.showError("exists");
								sendNotification(Main.CLOSE_FILE);
								break;
							}
							
							Main.CURRENT_FILE = f;
							Main.CURRENT_URL = null;
							sM.hideError();
							
							if(f.exists) {
								if (tP.validateFormat(f)) {
									sendNotification(Main.FILE_UPDATE, { hasFile:true, name:f.name } );
									sendNotification(Main.UPDATE);
									tP.playItem(o.index);
								} else {
									sM.showError("format");
									sendNotification(Main.CLOSE_FILE);
								}
							} else {
								sM.showError("exists");
								sendNotification(Main.CLOSE_FILE);
							}
						}
					}
					break;
				case Main.CHECK_FOR_PLAYLIST :
					tP.checkIfPlayList();
					break;
				case Main.CLOSE_FILE :
					sM.closeFile();
					tP.closeFile();
					tP.clearList();
					sendNotification(Main.FILE_UPDATE, {hasFile:false});
					sendNotification(Main.UPDATE);
					sendNotification(Main.RESET_SIZE);
					break;
				case Main.REMOVE_FILE :
					tP.removeItem(note.getBody() as int);
					break;
				case Main.OPEN_PLAYLIST :
					tP.loadPlayList(note.getBody() as String);
					break;
				case Main.CONTROL_VOLUME :
					tP.volume = note.getBody() as Number;
					if (tP.isMute) {
						tP.isMute = false;
						mM.setMute(false);
					}
					break;
				case Main.CONTROL_VOLUME_INCREMENT :
					tP.volume += .1 * int(note.getBody());
					break;
				case Main.SET_SCREEN :
					tP.setVideoScreen(note.getBody() as Video);
					break;
				case Main.EXITING :
					TweenLite.to(tP, .5, { volume:0 } );
					break;
				case Main.CONTROL_PAUSE_TOGGLE :
					tP.pause(!tP.isPause);
					break;
				case Main.CONTROL_PAUSE :
					var b:Boolean = note.getBody() as Boolean;
					if (tP.isPause == true && b == false) {
						tP.pause(false);
					} else if (tP.isPause == false && b == true) {
						tP.pause(true);
					} else {
						tP.play();
					}
					break;
				case Main.CONTROL_PLAY :
					tP.play();
					break;
				case Main.CONTROL_STOP :
					tP.stop();
					sM.validateSetOnTop(false);
					break;
				case Main.CONTROL_NEXT :
					sendNotification(Main.OPEN_ITEM, tP.getNext());
					break;
				case Main.CONTROL_PREVIOUS :
					sendNotification(Main.OPEN_ITEM, tP.getPrevious());
					break;
				case Main.CONTROL_SEEK :
					tP.seekPercent(note.getBody() as Number);
					break;
				case Main.CONTROL_SEEK_RELATIVE :
					tP.seekRelative(note.getBody() as Number);
					break;
				case Main.CONTROL_REPEAT :
					tP.repeat = note.getBody() as String;
					break;
				case Main.CONTROL_MUTE :
					tP.isMute = note.getBody() as Boolean;
					break;
				case Main.CONTROL_SHUFFLE :
					tP.shuffle = note.getBody() as Boolean;
					break;
				case Main.CONTROL_SWAP_CHANNELS :
					tP.swapChannels(note.getBody() as Boolean);
					break;
			}
		}
    }
}