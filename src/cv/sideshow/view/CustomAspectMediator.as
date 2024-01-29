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
	
	import fl.controls.Button;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class CustomAspectMediator extends MovieClip {
		
		private var w:NativeWindow;
		
		public function CustomAspectMediator() {
			
			txtInput.restrict = "0123456789:";
			txtInput.border = true;
			txtInput.borderColor = 0x888D90;
			var tf:TextFormat = txtInput.defaultTextFormat;
			tf.indent = 5;
			txtInput.defaultTextFormat = tf;
			
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
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
			var regex:RegExp = /([0-9]+):([0-9]+)/g;
			var o:Object = regex.exec(txtInput.text);
			if (o) {
				Main.sendNotification(Main.SELECT_CUSTOM);
				Main.sendNotification(Main.VIDEO_LOCK_RATIO, true);
				Main.sendNotification(Main.VIDEO_ASPECT_RATIO, {width:o[1], height:o[2]});
			}
			onClickCancel();
		}
		
		private function onClickCancel(event:MouseEvent = null):void {
			w.visible = false;
		}
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = false;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			
			w = new NativeWindow(winArgs);
			w.title = "Enter Custom Aspect Ratio";
			w.width = 275;
			w.height = 130;
			w.stage.align = StageAlign.TOP_LEFT;
			w.stage.scaleMode = StageScaleMode.NO_SCALE;
			w.stage.addChild(this);
		}
	}
}