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
	
	import com.greensock.TweenLite;
	
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.SliderEvent; 
	
	import cv.sideshow.Main;
	import cv.controls.Slider;

	public class FrameMediator extends MovieClip {
		
		private var btnRewind:SimpleButton;
		private var btnPause:SimpleButton;
		private var btnPlay:SimpleButton;
		private var playhead_slider:Slider;
		private var volume_slider:Slider;
		private var mcTack:MovieClip;
		private var alwaysShow:Boolean = false;
		
		public function FrameMediator() {
			
			// Init Frame
			this.visible = false;
			this.alpha = 0;
			this.mouseEnabled = false;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Init Header
			mcTack = mcHeader.mcTack;
			mcTack.addEventListener(MouseEvent.CLICK, onClickTack);
			mcHeader.txtTime.autoSize = TextFieldAutoSize.RIGHT;
			
			// Init Controls
			mcControls.x = Main.GRIPPER_SIZE;
			
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
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setTitle(title:String = "Unknown"):void {
			mcHeader.txtPath.text = title;
		}
		
		public function onExit():void {
			TweenLite.to(this, .5, { autoAlpha:0 } );
		}
		
		public function hide():void {
			if (Main.HAS_FILE && alwaysShow) {
				//
			} else {
				TweenLite.to(this, .5, { autoAlpha:0 } );
			}
		}
		
		public function show():void {
			if (Main.HAS_FILE && alwaysShow) {
				TweenLite.to(this, .5, { autoAlpha:1 } );
			} else {
				TweenLite.to(this, .5, { autoAlpha:(Main.HAS_FILE) ? 1 : 0 } );
			}
		}
		
		public function updateVolume(value:Number):void {
			volume_slider.value = value;
		}
		
		public function updatePause(value:Boolean):void {
			if (value) {
				btnPlay.visible = true;
				btnPause.visible = false;
			} else {
				btnPlay.visible = false;
				btnPause.visible = true;
			}
		}
		
		public function updateProgress(percent:Number, time:String, totalTime:String):void {
			playhead_slider.value = percent;
			mcHeader.txtTime.text = time.slice(0, -4) + "/" + totalTime.slice(0, -4);
		}
		
		public function updateLoadProgress(value:Number):void {
			playhead_slider.loadValue = value;
		}
		
		public function setSize(w:Number, h:Number):void {
			
			// Position Header
			mcHeader.mcBG.width = w;
			mcHeader.txtTime.x = mcHeader.mcBG.width - mcHeader.txtTime.width - 15;
			mcHeader.txtPath.width = mcHeader.txtTime.x - mcHeader.txtPath.x - 15;
			
			// Position Controls
			mcControls.y = h - (mcControls.height + Main.GRIPPER_SIZE);
			
			w -= (Main.GRIPPER_SIZE * 2);
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
		}
        
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onEnterFrame(e:Event):void {
			if (!mcControls.hitTestPoint(stage.mouseX, stage.mouseY) && !mcHeader.hitTestPoint(stage.mouseX, stage.mouseY)) {
				Main.sendNotification(Main.HIDE_FRAME);
			} else {
				Main.sendNotification(Main.SHOW_FRAME);
			}
		}
		
		private function onChangePlay(e:SliderEvent):void {
			Main.sendNotification(Main.CONTROL_SEEK, playhead_slider.value);
		}
		
		private function onChangeVolume(e:SliderEvent):void {
			Main.sendNotification(Main.CONTROL_VOLUME, volume_slider.value);
		}
		
		private function onClickTack(e:MouseEvent):void {
			if (mcTack.rotation == 0) {
				alwaysShow = true;
				mcTack.rotation = -90;
				if(Main.HAS_FILE) TweenLite.to(this, .5, { autoAlpha:1 } );
			} else {
				alwaysShow = false;
				mcTack.rotation = 0;
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			var btn:SimpleButton = e.currentTarget as SimpleButton;
			switch(btn) {
				case btnPlay :
					Main.sendNotification(Main.CONTROL_PAUSE, false);
					break;
				case btnPause: 
					Main.sendNotification(Main.CONTROL_PAUSE, true);
					break;
				case btnRewind :
					Main.sendNotification(Main.CONTROL_SEEK, .001);
					break;
			}
		}
	}
}