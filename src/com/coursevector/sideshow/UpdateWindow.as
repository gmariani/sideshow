package com.coursevector.sideshow {
	
	import fl.controls.Button;
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
	import fl.controls.TextArea;
	
	import com.coursevector.managers.UpdateManager;
	
	public class UpdateWindow extends NativeWindow {
		
		private var sprMain:MovieClip = new UpdateScreen();
		private var txtTitle:TextField;
		private var txtVersions:TextField;
		private var taNotes:TextArea;
		private var txtMessage:TextField;
		private var btnInstall:Button;
		private var btnCancel:Button;
		private var um:UpdateManager;
		
		public function UpdateWindow():void {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			//winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			title = "Update Notification";
			this.width = 535;
			this.height = 390;
			this.addEventListener(Event.ACTIVATE, onActivate);
			
			// Init
			um = UpdateManager.instance;
			um.addEventListener(ProgressEvent.PROGRESS, onProgress);
			um.addEventListener(UpdateManager.DOWNLOAD_ERROR, onLoadError);
			um.addEventListener(UpdateManager.UPDATE_ERROR, onUpdateError);
			txtMessage = sprMain.getChildByName("txtMessage") as TextField;
			txtTitle = sprMain.getChildByName("txtTitle") as TextField;
			txtVersions = sprMain.getChildByName("txtVersions") as TextField;
			taNotes = sprMain.getChildByName("taNotes") as TextArea;
			
			btnInstall = sprMain.getChildByName("btnInstall") as Button;
			btnInstall.addEventListener(MouseEvent.CLICK, onClickInstall);
			
			btnCancel = sprMain.getChildByName("btnCancel") as Button;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprMain);
		}
		
		private function onActivate(event:Event):void {
			txtTitle.text = "Update available";
			txtMessage.text = "An updated version of " + um.currentName + " is available for download.";
			txtVersions.text = um.currentVersion + "\n" + um.remoteVersion;
			taNotes.htmlText = um.description;
			orderToFront();
		}
		
		private function setMessage(strMessage:String):void {
			txtMessage.htmlText = strMessage;
		}
		
		private function onClickCancel(event:MouseEvent):void {
			close();
		}
		
		private function onClickInstall(event:MouseEvent):void {
			btnInstall.enabled = false;
			btnCancel.enabled = false;
			txtTitle.text = "Downloading...";
			um.downloadUpdate();
		}
		
		private function onProgress(event:ProgressEvent):void {
			var percent:uint = (event.bytesLoaded / event.bytesTotal) * 100;
			txtTitle.text = "Downloading... " + Math.ceil(percent) + "%";
		}
		
		private function onLoadError(event:Event):void {
			btnCancel.enabled = true;
			txtTitle.text = "Error downloading update.";
		}
		
		private function onUpdateError(event:Event):void {
			btnCancel.enabled = true;
			txtTitle.text = "Error installing update.";
		}
	}
}