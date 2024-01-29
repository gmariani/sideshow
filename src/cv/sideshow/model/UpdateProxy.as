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
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import cv.sideshow.ApplicationFacade;
	import cv.managers.UpdateManager;
	
	import flash.events.ProgressEvent;
	import flash.events.Event;
	
	public class UpdateProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'UpdateProxy';
		
		private var um:UpdateManager;
		
		public function UpdateProxy() {
            super(NAME);
			
			um = UpdateManager.instance;
			um.addEventListener(ProgressEvent.PROGRESS, onProgress);
			um.addEventListener(UpdateManager.NONE_AVAILABLE, updateHandler);
			um.addEventListener(UpdateManager.DOWNLOAD_START, updateHandler);
			um.addEventListener(UpdateManager.CHECK_FOR_UPDATE, updateHandler);
			um.addEventListener(UpdateManager.DOWNLOAD_ERROR, updateHandler);
			um.addEventListener(UpdateManager.UPDATE_ERROR, updateHandler);
			um.addEventListener(UpdateManager.AVAILABLE, updateHandler);
			um.updateURL = ApplicationFacade.URL_PATH + "update.xml";
			
			ApplicationFacade.VERSION = this.version;
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
			sendNotification(ApplicationFacade.UPDATE_PROGRESS, {bytesLoaded:event.bytesLoaded, bytesTotal:event.bytesTotal} );
		}
		
		private function updateHandler(e:Event):void {
			switch(e.type) {
				case UpdateManager.AVAILABLE :
					sendNotification(ApplicationFacade.UPDATE_AVAIL, {currentName:um.currentName, currentVersion:um.currentVersion, remoteVersion:um.remoteVersion, description:um.description});
					break;
				/*case UpdateManager.CHECK_FOR_UPDATE :
					sendNotification(ApplicationFacade.UPDATE_CHECKING);
					break;
				case UpdateManager.DOWNLOAD_START :
					sendNotification(ApplicationFacade.UPDATE_DOWNLOAD);
					break;*/
				case UpdateManager.DOWNLOAD_ERROR :
					sendNotification(ApplicationFacade.UPDATE_LOAD_ERROR);
					break;
				/*case UpdateManager.NONE_AVAILABLE :
					sendNotification(ApplicationFacade.UPDATE_NONE_AVAIL);
					break;*/
				case UpdateManager.UPDATE_ERROR :
					sendNotification(ApplicationFacade.UPDATE_ERROR);
					break;
			}
		}
	}
}