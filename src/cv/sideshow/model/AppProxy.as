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
	
	import flash.filesystem.File;
	import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	
	import com.adobe.images.PNGEncoder;
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.view.components.MenuIcon;
	
	public class AppProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'AppProxy';
		
		private var app:NativeApplication;
		private var icon:MenuIcon = new MenuIcon();
		
		public function AppProxy() {
			super(NAME);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			app = NativeApplication.nativeApplication;
			app.addEventListener(Event.EXITING, onExiting);
			app.autoExit = true;
			
			//Set the system tray or dock icon image
			icon.addEventListener(Event.COMPLETE,function():void{
				app.icon.bitmaps = icon.bitmaps;
			});
			icon.loadImages();
			
			app.idleThreshold = 5; // seconds
			app.addEventListener(Event.USER_IDLE, onIdle);
			app.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onExiting(event:Event):void {
			event.preventDefault();
			sendNotification(ApplicationFacade.EXITING);
		}
		
		private function onInvoke(event:InvokeEvent):void {
			if(event.arguments.length > 0) {
				sendNotification(ApplicationFacade.OPEN_FILE, new File(event.arguments[0]));
				
				for (var i:String in event.arguments) {
					if (i == "0") continue;
					sendNotification(ApplicationFacade.ADD_FILE, { url:event.arguments[i].path } );
				}
			}
		}
		
		private function onIdle(e:Event):void {
			sendNotification(ApplicationFacade.IDLE);
		}
	}
}