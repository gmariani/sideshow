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

package cv.sideshow.view {

	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import cv.sideshow.ApplicationFacade;
	
	import fl.controls.Button;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class URLMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'URLMediator';
		
		private var tiURL:TextInput;
		private var cbFileType:ComboBox;
		private var cbQuality:CheckBox;
		private var txtMessage:TextField;
		private var txtOpen:TextField;
		private var txtFile:TextField;
		private var txtYoutube:TextField;
		private var mcEmblem:MovieClip;
		private var btnOk:Button;
		private var btnCancel:Button;
		private var w:NativeWindow;
		
		public function URLMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			tiURL = root.getChildByName("tiURL") as TextInput;
			cbFileType = root.getChildByName("cbFileType") as ComboBox;
			cbQuality = root.getChildByName("cbQuality") as CheckBox;
			
			txtMessage = root.getChildByName("txtMessage") as TextField;
			txtMessage.embedFonts = true;
			
			txtOpen = root.getChildByName("txtOpen") as TextField;
			txtOpen.embedFonts = true;
			
			txtFile = root.getChildByName("txtFile") as TextField;
			txtFile.embedFonts = true;
			
			txtYoutube = root.getChildByName("txtYoutube") as TextField;
			txtYoutube.embedFonts = true;
			
			btnOk = root.getChildByName("btnOk") as Button;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk, false, 0, true);
			
			btnCancel = root.getChildByName("btnCancel") as Button;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel, false, 0, true);
			
			mcEmblem = root.getChildByName("mcEmblem") as MovieClip;
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get root():MovieClip {
			return viewComponent as MovieClip;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.URL_SHOW];
		}
		
		override public function handleNotification(note:INotification):void {
			switch(note.getName()) {
				case ApplicationFacade.URL_SHOW :
					if (w.closed) createWindow();
					w.activate();
					w.orderToFront();
					w.visible = true;
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onClickOk(event:MouseEvent):void {
			sendNotification(ApplicationFacade.PLAYLIST_URL, {url:tiURL.text, fileType:cbFileType.selectedLabel, quality:cbQuality.selected} );
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
			w.stage.addChild(root);
		}
	}
}