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

package cv.sideshow.model {
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.display.BitmapData;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import com.adobe.images.PNGEncoder;
	import cv.sideshow.Main;
	
	public class FileProxy {
		
		private var fileDir:File = File.desktopDirectory;
		private var fileSave:File = File.desktopDirectory;
		private var fileScreen:File = File.desktopDirectory.resolvePath("untitled.png");
		private var bmd:BitmapData;
		
		public function FileProxy() {
			
			fileDir.addEventListener(Event.SELECT, selectHandler);
			fileDir.addEventListener(FileListEvent.SELECT_MULTIPLE, selectMultipleHandler);
			fileSave.addEventListener(Event.SELECT, saveHandler);
			fileScreen.addEventListener(Event.SELECT, saveScreenShot);
			fileScreen.addEventListener(Event.CANCEL, saveScreenShot);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function browseForOpen():void {
			fileDir.browseForOpen("Select a file");
		}
		
		public function browseForSave():void {
			fileSave.browseForSave("Save Media");
		}
		
		public function browseForSaveSS(bmd:BitmapData):void {
			this.bmd = bmd;
			fileScreen.browseForSave("Save ScreenShot");
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function selectHandler(e:Event):void {
			var f:File = e.target as File;
			if (f.isDirectory) {
				addMultiple(f.getDirectoryListing());
			} else {
				Main.sendNotification(Main.OPEN_FILE, f);
			}
		}
		
		private function selectMultipleHandler(event:FileListEvent):void {
			addMultiple(event.files);
		}
		
		private function addMultiple(arr:Array):void {
			for (var i:uint = 0; i < arr.length; i++) {
				Main.sendNotification(Main.ADD_FILE, { url:arr[i].url } );
			}
		}
		
		private function saveHandler(e:Event):void {
			if (Main.CURRENT_FILE) Main.CURRENT_FILE.copyTo(fileSave);
		}
		
		private function saveScreenShot(e:Event):void {
			if(e.type == Event.SELECT) {
				var img:ByteArray = PNGEncoder.encode(bmd);
				var stream:FileStream = new FileStream();
				
				// Force PNG extension
				if (fileScreen.extension == null || fileScreen.extension.toLowerCase() != "png") {
					fileScreen.url += ".png";
				}
				stream.openAsync(fileScreen, FileMode.WRITE);
				stream.writeBytes(img);
				stream.close();
			}
			Main.sendNotification(Main.CONTROL_PAUSE, false);
		}
	}
}