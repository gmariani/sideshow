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
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import fl.controls.Button;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class URLMediator extends MovieClip {
		
		private var w:NativeWindow;
		
		public function URLMediator() {
			txtMessage.embedFonts = true;
			txtOpen.embedFonts = true;
			txtFile.embedFonts = true;
			txtYoutube.embedFonts = true;
			
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk, false, 0, true);
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel, false, 0, true);
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function show():void {
			if (w.closed) createWindow();
			w.activate();
			w.orderToFront();
			w.visible = true;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onClickOk(event:MouseEvent):void {
			Main.sendNotification(Main.PLAYLIST_URL, {url:tiURL.text, fileType:cbFileType.selectedLabel, quality:cbQuality.selected} );
			w.visible = false;
		}
		
		private function onClickCancel(event:MouseEvent):void {
			w.visible = false;
		}
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			
			w = new NativeWindow(winArgs);
			w.title = "Add URL";
			w.width = 325;
			w.height = 240;
			w.stage.align = StageAlign.TOP_LEFT;
			w.stage.scaleMode = StageScaleMode.NO_SCALE;
			w.stage.addChild(this);
		}
	}
}