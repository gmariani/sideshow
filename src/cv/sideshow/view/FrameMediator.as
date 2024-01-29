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
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.SliderEvent; 
	
	import gs.TweenLite;
	import cv.sideshow.ApplicationFacade;
	import cv.controls.Slider;

	public class FrameMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'FrameMediator';
		
		private var btnRewind:SimpleButton;
		private var btnPause:SimpleButton;
		private var btnPlay:SimpleButton;
		private var playhead_slider:Slider;
		private var volume_slider:Slider;
		private var mcHeader:MovieClip;
		private var mcControls:MovieClip;
		private var mcTack:MovieClip;
		private var alwaysShow:Boolean = false;
		
		public function FrameMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			// Init Frame
			root.visible = false;
			root.alpha = 0;
			root.mouseEnabled = false;
			root.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addChild(root);
			
			// Init Header
			mcHeader = root.getChildByName("mcHeader") as MovieClip;
			mcTack = mcHeader.mcTack;
			mcTack.addEventListener(MouseEvent.CLICK, onClickTack);
			mcHeader.txtTime.autoSize = TextFieldAutoSize.RIGHT;
			mcHeader.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			// Init Controls
			mcControls = root.getChildByName("mcControls") as MovieClip;
			mcControls.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			mcControls.x = ApplicationFacade.GRIPPER_SIZE;
			
			btnPlay = mcControls.getChildByName("btnPlay") as SimpleButton;
			btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			btnPlay.visible = false;
			
			btnPause = mcControls.getChildByName("btnPause") as SimpleButton;
            btnPause.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			
			btnRewind = mcControls.getChildByName("btnRewind") as SimpleButton;
			btnRewind.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			
			playhead_slider = mcControls.getChildByName("playhead_slider") as Slider;
			playhead_slider.value = 0;
			playhead_slider.addEventListener(SliderEvent.CHANGE, onChangePlay);
			
			volume_slider = mcControls.getChildByName("volume_slider") as Slider;
			volume_slider.value = 0;
			volume_slider.liveDragging = true;
			volume_slider.addEventListener(SliderEvent.CHANGE, onChangeVolume);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get stage():Stage {
			return root.stage as Stage;
		}
		
		private function get root():MovieClip {
			return viewComponent as MovieClip;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setTitle(title:String = "Unknown"):void {
			mcHeader.txtPath.text = title;
		}
        
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.SET_SIZE,
					ApplicationFacade.LOAD_PROGRESS, 
					ApplicationFacade.PLAY_PROGRESS, 
					ApplicationFacade.VOLUME_UPDATE, 
					ApplicationFacade.PAUSE_UPDATE, 
					ApplicationFacade.HIDE_FRAME, 
					ApplicationFacade.SHOW_FRAME, 
					ApplicationFacade.EXITING ];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.VOLUME_UPDATE :
					volume_slider.value = note.getBody() as Number;
					break;
				case ApplicationFacade.PAUSE_UPDATE :
					if (note.getBody() as Boolean) {
						btnPlay.visible = true;
						btnPause.visible = false;
					} else {
						btnPlay.visible = false;
						btnPause.visible = true;
					}
					break;
				case ApplicationFacade.SET_SIZE :
					var w:Number = note.getBody().width;
					var h:Number = note.getBody().height;
					
					// Position Header
					mcHeader.mcBG.width = w;
					mcHeader.txtTime.x = mcHeader.mcBG.width - mcHeader.txtTime.width - 15;
					mcHeader.txtPath.width = mcHeader.txtTime.x - mcHeader.txtPath.x - 15;
					
					// Position Controls
					mcControls.y = h - (mcControls.height + ApplicationFacade.GRIPPER_SIZE);
					
					w -= (ApplicationFacade.GRIPPER_SIZE * 2);
					mcControls.mcBG.width = w - (btnPlay.width + btnRewind.width + mcControls.mcVolumeBG.width);
					mcControls.mcVolumeBG.x = mcControls.mcBG.width + mcControls.mcBG.x;
					volume_slider.x = mcControls.mcVolumeBG.x + 10;
					
					var g:Graphics = playhead_slider.sprTrack.graphics;
					g.clear();
					g.lineStyle(0.25, 0x460046);
					g.beginFill(0xB900B9, 1);
					g.drawRect(0, 0, mcControls.mcBG.width - 20, 10);
					g.endFill();
					
					g = playhead_slider.sprLoad.graphics;
					g.clear();
					g.beginFill(0xFF00FF, 0.5);
					g.drawRect(0, 0, mcControls.mcBG.width - 20, 10);
					g.endFill();
					
					g = playhead_slider.sprProgress.graphics;
					g.clear();
					g.lineStyle(0.25, 0x460046);
					g.beginFill(0xFF00FF, 1);
					g.drawRect(0, 0, mcControls.mcBG.width - 20, 10);
					g.endFill();
					break;
				case ApplicationFacade.EXITING :
					TweenLite.to(root, .5, { autoAlpha:0 } );
					break;
				case ApplicationFacade.HIDE_FRAME :
					if (ApplicationFacade.HAS_FILE && alwaysShow) {
						//
					} else {
						TweenLite.to(root, .5, { autoAlpha:0 } );
					}
					break;
				case ApplicationFacade.SHOW_FRAME :
					if (ApplicationFacade.HAS_FILE && alwaysShow) {
						TweenLite.to(root, .5, { autoAlpha:1 } );
					} else {
						TweenLite.to(root, .5, { autoAlpha:(ApplicationFacade.HAS_FILE) ? 1 : 0 } );
					}
					break;
				case ApplicationFacade.PLAY_PROGRESS :
					var o:Object = note.getBody();
					playhead_slider.value = o.currentPercent;
					mcHeader.txtTime.text = o.currentTime.slice(0, -4) + "/" + o.totalTime.slice(0, -4);
					break;
				case ApplicationFacade.LOAD_PROGRESS :
					playhead_slider.loadValue = note.getBody() as Number;
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onEnterFrame(e:Event):void {
			if (!mcControls.hitTestPoint(stage.mouseX, stage.mouseY) && !mcHeader.hitTestPoint(stage.mouseX, stage.mouseY)) {
				sendNotification(ApplicationFacade.HIDE_FRAME);
			}
		}
		
		private function onChangePlay(e:SliderEvent):void {
			sendNotification(ApplicationFacade.CONTROL_SEEK, playhead_slider.value);
		}
		
		private function onChangeVolume(e:SliderEvent):void {
			sendNotification(ApplicationFacade.CONTROL_VOLUME, volume_slider.value);
		}
		
		private function onClickTack(e:MouseEvent):void {
			if (mcTack.rotation == 0) {
				alwaysShow = true;
				mcTack.rotation = -90;
				if(ApplicationFacade.HAS_FILE) TweenLite.to(root, .5, { autoAlpha:1 } );
			} else {
				alwaysShow = false;
				mcTack.rotation = 0;
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			var btn:SimpleButton = e.currentTarget as SimpleButton;
			switch(btn) {
				case btnPlay :
					sendNotification(ApplicationFacade.CONTROL_PAUSE, false);
					break;
				case btnPause: 
					sendNotification(ApplicationFacade.CONTROL_PAUSE, true);
					break;
				case btnRewind :
					sendNotification(ApplicationFacade.CONTROL_SEEK, .001);
					break;
			}
		}
		
		private function onMouseOver(e:MouseEvent):void {
			sendNotification(ApplicationFacade.SHOW_FRAME);
		}
	}
}