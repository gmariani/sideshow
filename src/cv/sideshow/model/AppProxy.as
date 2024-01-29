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
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	
	import com.adobe.images.PNGEncoder;
	import cv.sideshow.Main;
	import cv.sideshow.view.components.MenuIcon;
	
	public class AppProxy {
		
		private var app:NativeApplication;
		private var icon:MenuIcon = new MenuIcon();
		
		public function AppProxy() {
			
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
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onExiting(event:Event):void {
			event.preventDefault();
			Main.sendNotification(Main.EXITING);
		}
		
		private function onInvoke(event:InvokeEvent):void {
			if(event.arguments.length > 0) {
				Main.sendNotification(Main.OPEN_FILE, new File(event.arguments[0]));
				
				for (var i:String in event.arguments) {
					if (i == "0") continue;
					Main.sendNotification(Main.ADD_FILE, { url:event.arguments[i].path } );
				}
			}
		}
		
		private function onIdle(e:Event):void {
			Main.sendNotification(Main.IDLE);
		}
	}
}