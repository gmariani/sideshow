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

	import cv.TempoLite;
	import cv.managers.UpdateManager;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import fl.controls.Button;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Point;
	
	public class AboutMediator extends MovieClip {
		
		private var um:UpdateManager;
		private var w:NativeWindow;
		
		public function AboutMediator() {
			um = UpdateManager.instance;
			
			txtMessage.embedFonts = true;
			txtMessage.autoSize = TextFieldAutoSize.CENTER;
			txtMessage.htmlText = "Version : <b>" + um.currentVersion + "</b><br><br>© 2011 Gabriel Mariani<br>UI based on (now defunct) Sasami2K<br>Based on <a href='http://blog.coursevector.com/tempolite'><u>TempoLite v" + TempoLite.VERSION + "</u></a><br><br><a href='http://blog.coursevector.com/sideshow'><u>http://blog.coursevector.com/sideshow</u></a>";
			
			btnOk.y = txtMessage.y + txtMessage.textHeight + 15;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			mcEmblem.rotationX = 0;
			TweenMax.to(mcEmblem, 5, { rotationY:360, loop:true, ease:Linear.easeNone } );
			
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
			w.visible = false;
		}
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			
			w = new NativeWindow(winArgs);
			w.title = "About Course Vector SideShow";
			w.width = 325;
			w.height = 220;
			w.stage.align = StageAlign.TOP_LEFT;
			w.stage.scaleMode = StageScaleMode.NO_SCALE;
			w.stage.addChild(this);
			w.stage.root.transform.perspectiveProjection.projectionCenter = new Point(mcEmblem.x, mcEmblem.y);
		}
	}
}