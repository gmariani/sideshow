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

package cv.sideshow.view {
	
	import cv.sideshow.Main;
	//import cv.managers.UpdateManager;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import fl.controls.Button;
	import fl.controls.TextArea;

	public class UpdateMediator extends MovieClip {
		
		private var uw:NativeWindow;
		//private var um:UpdateManager;
		
		public function UpdateMediator() {
			//um = UpdateManager.instance;
			
			btnInstall.addEventListener(MouseEvent.CLICK, onClickInstall, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel, false, 0, true);
			txtTitle.text = "Update Available";
			txtTitle.mouseEnabled = false;
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function show(o:Object):void {
			txtMessage.text = "An updated version of " + o.currentName + " is available for download.";
			txtVersions.text = o.currentVersion + "\n" + o.remoteVersion;
			taNotes.htmlText = o.description;
			
			if (uw.closed) createWindow();
			uw.activate();
			uw.orderToFront();
			uw.visible = true;
		}
		
		public function setProgress(o:Object):void {
			var percent:uint = (o.bytesLoaded / o.bytesTotal) * 100;
			txtTitle.text = "Downloading... " + Math.ceil(percent) + "%";
		}
		
		public function loadError():void {
			btnCancel.enabled = true;
			txtTitle.text = "Error downloading update.";
		}
		
		public function updateError():void {
			btnCancel.enabled = true;
			txtTitle.text = "Error installing update.";
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			
			uw = new NativeWindow(winArgs);
			uw.title = "Update Available";
			uw.width = 535;
			uw.height = 430; // 390
			uw.stage.align = StageAlign.TOP_LEFT;
			uw.stage.scaleMode = StageScaleMode.NO_SCALE;
			uw.stage.addChild(this);
		}
		
		private function onClickCancel(event:MouseEvent):void {
			uw.close();
		}
		
		private function onClickInstall(event:MouseEvent):void {
			btnInstall.enabled = false;
			btnCancel.enabled = false;
			txtTitle.text = "Downloading...";
			Main.sendNotification(Main.UPDATE_INSTALL);
		}
	}
}