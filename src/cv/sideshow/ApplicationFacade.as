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

package cv.sideshow {
	
	import flash.filesystem.File;
    import org.puremvc.as3.multicore.interfaces.IFacade;
    import org.puremvc.as3.multicore.patterns.facade.Facade;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	
	import cv.sideshow.controller.StartupCommand;
	import cv.sideshow.controller.TempoCommand;
	import cv.sideshow.controller.AppCommand;
	import cv.sideshow.controller.FileCommand;
	import cv.sideshow.controller.UpdateCommand;
	import flash.display.NativeWindow;
    
	// TODO: See about Alchemy and MPEG swc
	
    public class ApplicationFacade extends Facade implements IFacade {
		
		// Global
		public static var VERSION:String = "2.1.0";
		public static var CURRENT_FILE:File;
		public static var CURRENT_URL:Object;
		public static var HAS_FILE:Boolean = false;
		public static const GRIPPER_SIZE:uint = 10;
		public static const URL_PATH:String = "http://labs.coursevector.com/projects/sideshow/";
		
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
		public static const ON_VIDEO_BRIGHTEN:String = "ON_VIDEO_BRIGHTEN";
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
		public static const VIDEO_SET_SIZE:String = "VIDEO_SET_SIZE";
		public static const VIDEO_RESET_SIZE:String = "VIDEO_RESET_SIZE";
		
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
		
		public function ApplicationFacade(key:String) {
			super(key);	
		}
		
		/**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance(key:String):ApplicationFacade {
            if (instanceMap[key] == null) instanceMap[key] = new ApplicationFacade(key);
            return instanceMap[key] as ApplicationFacade;
        }
		
		/**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup(app:Object):void {
        	sendNotification(ApplicationFacade.STARTUP, app);
        }
		
        override protected function initializeController():void {
			super.initializeController();
			
			registerCommand(ApplicationFacade.STARTUP, 			StartupCommand);
			
			registerCommand(ApplicationFacade.ADD_FILE, 		TempoCommand);
			registerCommand(ApplicationFacade.CLOSE_FILE, 		TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_PAUSE, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_SEEK, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_MUTE, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_SHUFFLE, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_REPEAT, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_VOLUME, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_VOLUME_INCREMENT,	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_SWAP_CHANNELS,	TempoCommand);
			registerCommand(ApplicationFacade.EXITING, 			TempoCommand);
			registerCommand(ApplicationFacade.OPEN_FILE, 		TempoCommand);
			registerCommand(ApplicationFacade.OPEN_ITEM, 		TempoCommand);
			registerCommand(ApplicationFacade.OPEN_PLAYLIST, 	TempoCommand);
			registerCommand(ApplicationFacade.PLAY_FILE, 		TempoCommand);
			registerCommand(ApplicationFacade.REMOVE_FILE, 		TempoCommand);
			registerCommand(ApplicationFacade.SET_SCREEN, 		TempoCommand);
			registerCommand(ApplicationFacade.CHECK_FOR_PLAYLIST, TempoCommand);
			registerCommand(ApplicationFacade.VALIDATE_VIDEO, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_PAUSE_TOGGLE, TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_STOP, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_PREVIOUS, TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_NEXT, 	TempoCommand);
			registerCommand(ApplicationFacade.CONTROL_SEEK_RELATIVE, TempoCommand);
			
			registerCommand(ApplicationFacade.UPDATE, 			AppCommand);
			
			registerCommand(ApplicationFacade.FILE_UPDATE, 		FileCommand);
			registerCommand(ApplicationFacade.SAVE_SS, 			FileCommand);
			registerCommand(ApplicationFacade.SAVE, 			FileCommand);
			registerCommand(ApplicationFacade.OPEN, 			FileCommand);
			
			registerCommand(ApplicationFacade.UPDATE_INSTALL,	UpdateCommand);
			registerCommand(ApplicationFacade.INITIALIZED,		UpdateCommand);
        }
    }
}