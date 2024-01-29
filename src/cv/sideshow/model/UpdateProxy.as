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

package cv.sideshow.model {
	
	import cv.sideshow.Main;
	import cv.managers.UpdateManager;
	
	import flash.events.ProgressEvent;
	import flash.events.Event;
	
	public class UpdateProxy {
		
		private var um:UpdateManager;
		
		public function UpdateProxy() {
			
			um = UpdateManager.instance;
			um.addEventListener(ProgressEvent.PROGRESS, onProgress);
			um.addEventListener(UpdateManager.NONE_AVAILABLE, updateHandler);
			um.addEventListener(UpdateManager.DOWNLOAD_START, updateHandler);
			um.addEventListener(UpdateManager.CHECK_FOR_UPDATE, updateHandler);
			um.addEventListener(UpdateManager.DOWNLOAD_ERROR, updateHandler);
			um.addEventListener(UpdateManager.UPDATE_ERROR, updateHandler);
			um.addEventListener(UpdateManager.AVAILABLE, updateHandler);
			um.updateURL = Main.URL_PATH + "update.xml";
			
			Main.VERSION = this.version;
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get version():String {
			return um.currentVersion;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function update():void {
			um.downloadUpdate();
		}
		
		public function check():void {
			um.checkNow();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onProgress(event:ProgressEvent):void {
			Main.sendNotification(Main.UPDATE_PROGRESS, {bytesLoaded:event.bytesLoaded, bytesTotal:event.bytesTotal} );
		}
		
		private function updateHandler(e:Event):void {
			switch(e.type) {
				case UpdateManager.AVAILABLE :
					Main.sendNotification(Main.UPDATE_AVAIL, {currentName:um.currentName, currentVersion:um.currentVersion, remoteVersion:um.remoteVersion, description:um.description});
					break;
				/*case UpdateManager.CHECK_FOR_UPDATE :
					Main.sendNotification(Main.UPDATE_CHECKING);
					break;
				case UpdateManager.DOWNLOAD_START :
					Main.sendNotification(Main.UPDATE_DOWNLOAD);
					break;*/
				case UpdateManager.DOWNLOAD_ERROR :
					Main.sendNotification(Main.UPDATE_LOAD_ERROR);
					break;
				/*case UpdateManager.NONE_AVAILABLE :
					Main.sendNotification(Main.UPDATE_NONE_AVAIL);
					break;*/
				case UpdateManager.UPDATE_ERROR :
					Main.sendNotification(Main.UPDATE_ERROR);
					break;
			}
		}
	}
}