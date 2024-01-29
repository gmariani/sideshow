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
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	import com.coursevector.managers.UpdateManager;
	import com.coursevector.tempo.TempoLite;
	
	public class AboutWindow extends NativeWindow {
		
		private var sprMain:MovieClip = new AboutScreen();
		private var txtMessage:TextField;
		private var btnOk:Button;
		private var um:UpdateManager;
		
		public function AboutWindow():void {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			//winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			title = "About SideShow";
			this.width = 325;
			this.height = 200;
			
			// Init
			um = UpdateManager.instance;
			txtMessage = sprMain.getChildByName("txtMessage") as TextField;
			txtMessage.htmlText = "Version " + um.currentVersion + "<br>© 2008 Gabriel Mariani<br>UI based on (now defunct) Sasami2K<br>Based on <a href='http://labs.coursevector.com/wiki/index.php5?title=TempoLite'><u>TempoLite v" + TempoLite.version + "</u></a><br><br><a href='http://labs.coursevector.com/'><u>http://labs.coursevector.com</u></a>";
			
			btnOk = sprMain.getChildByName("btnOk") as Button;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprMain);
		}
		
		private function onClickOk(event:MouseEvent):void {
			close();
		}
	}
}