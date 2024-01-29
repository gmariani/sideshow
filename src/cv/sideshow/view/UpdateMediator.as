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
/**
* ...
* @author Gabriel Mariani
* @version 0.1
*/

package cv.sideshow.view {

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import cv.sideshow.ApplicationFacade;
	import cv.managers.UpdateManager;
	
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

	public class UpdateMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'UpdateMediator';
		
		private var uw:NativeWindow;
		private var txtTitle:TextField;
		private var txtVersions:TextField;
		private var taNotes:TextArea;
		private var txtMessage:TextField;
		private var btnInstall:Button;
		private var btnCancel:Button;
		private var um:UpdateManager;
		
		public function UpdateMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			um = UpdateManager.instance;
			
			txtMessage = root.getChildByName("txtMessage") as TextField;
			txtTitle = root.getChildByName("txtTitle") as TextField;
			txtVersions = root.getChildByName("txtVersions") as TextField;
			taNotes = root.getChildByName("taNotes") as TextArea;
			
			btnInstall = root.getChildByName("btnInstall") as Button;
			btnInstall.addEventListener(MouseEvent.CLICK, onClickInstall);
			
			btnCancel = root.getChildByName("btnCancel") as Button;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
			txtTitle.text = "Update Available";
			txtTitle.mouseEnabled = false;
			
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
			return [ApplicationFacade.UPDATE_AVAIL, ApplicationFacade.UPDATE_PROGRESS, ApplicationFacade.UPDATE_ERROR, ApplicationFacade.UPDATE_LOAD_ERROR];
		}
		
		override public function handleNotification(note:INotification):void {
			switch(note.getName()) {
				case ApplicationFacade.UPDATE_AVAIL :
					var o:Object = note.getBody();
					txtMessage.text = "An updated version of " + o.currentName + " is available for download.";
					txtVersions.text = o.currentVersion + "\n" + o.remoteVersion;
					taNotes.htmlText = o.description;
					
					if (uw.closed) createWindow();
					uw.activate();
					uw.orderToFront();
					uw.visible = true;
					break;
				case ApplicationFacade.UPDATE_PROGRESS :
					setProgress(note.getBody());
					break;
				case ApplicationFacade.UPDATE_ERROR :
					updateError();
					break;
				case ApplicationFacade.UPDATE_LOAD_ERROR :
					loadError();
					break;
			}
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
			uw.stage.addChild(root);
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
		
		private function onClickCancel(event:MouseEvent):void {
			uw.close();
		}
		
		private function onClickInstall(event:MouseEvent):void {
			btnInstall.enabled = false;
			btnCancel.enabled = false;
			txtTitle.text = "Downloading...";
			sendNotification(ApplicationFacade.UPDATE_INSTALL);
		}
	}
}