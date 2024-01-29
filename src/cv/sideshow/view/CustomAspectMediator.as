package cv.sideshow.view {
	
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
	import flash.text.TextFormat;
	
	public class CustomAspectMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'CustomAspectMediator';
		
		private var txtInput:TextField;
		private var w:NativeWindow;
		
		public function CustomAspectMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			txtInput = root.getChildByName("txtInput") as TextField;
			txtInput.restrict = "0123456789:";
			txtInput.border = true;
			txtInput.borderColor = 0x888D90;
			var tf:TextFormat = txtInput.defaultTextFormat;
			tf.indent = 5;
			txtInput.defaultTextFormat = tf;
			
			var btnOk:Button = root.getChildByName("btnOk") as Button;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			var btnCancel:Button = root.getChildByName("btnCancel") as Button;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
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
			return [ApplicationFacade.CUSTOM_SHOW];
		}
		
		override public function handleNotification(note:INotification):void {
			switch(note.getName()) {
				case ApplicationFacade.CUSTOM_SHOW :
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
			var regex:RegExp = /([0-9]+):([0-9]+)/g;
			var o:Object = regex.exec(txtInput.text);
			if (o) {
				sendNotification(ApplicationFacade.SELECT_CUSTOM);
				sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, true);
				sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO, {width:o[1], height:o[2]});
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
			w.stage.addChild(root);
		}
	}
}