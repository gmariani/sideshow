package com.coursevector.sideshow {
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.SliderEvent; 
    
    public class Controls extends MovieClip {
		
		//public const PLAY:String = "play";
		//public const PAUSE:String = "pause";
		//public const REWIND:String = "rewind";
		
		//private var btnRewind:SimpleButton;
		//private var btnPause:SimpleButton;
		//private var btnPlay:SimpleButton;
		//private var mcPlayHead:MovieClip;
		
		private var isSeeking:Boolean = false;
		
        public function Controls():void {
            btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, onClickPlay);
			btnPlay.visible = false;
            btnPause.addEventListener(MouseEvent.MOUSE_DOWN, onClickPause);
			btnRewind.addEventListener(MouseEvent.MOUSE_DOWN, onClickRewind);
			
			playhead_slider.maximum = 1;
			playhead_slider.minimum = 0;
			playhead_slider.snapInterval = 0.01;
			playhead_slider.value = 0;
			playhead_slider.addEventListener(SliderEvent.THUMB_PRESS, playheadHandler);
			playhead_slider.addEventListener(SliderEvent.THUMB_RELEASE, playheadHandler);
			playhead_slider.addEventListener(SliderEvent.THUMB_DRAG, playheadHandler);
			playhead_slider.addEventListener(SliderEvent.CHANGE, playheadHandler);
			
			volume_slider.maximum = 1;
			volume_slider.minimum = 0;
			volume_slider.snapInterval = 0.01;
			volume_slider.value = 0;
			volume_slider.liveDragging = true;
			volume_slider.addEventListener(SliderEvent.THUMB_PRESS, volumedHandler);
			volume_slider.addEventListener(SliderEvent.THUMB_RELEASE, volumedHandler);
			volume_slider.addEventListener(SliderEvent.THUMB_DRAG, volumedHandler);
			volume_slider.addEventListener(SliderEvent.CHANGE, volumedHandler);
        }
		
		public function set trackPosition(n:Number):void {
			playhead_slider.value = n;
		}
		
		public function get trackPosition():Number {
			return playhead_slider.value;
		}
		
		public function set volume(n:Number):void {
			volume_slider.value = n;
		}
		
		public function get volume():Number {
			return volume_slider.value;
		}
		
		public function showPlay():void {
			btnPlay.visible = true;
			btnPause.visible = false;
		}
		
		public function showPause():void {
			btnPlay.visible = false;
			btnPause.visible = true;
		}
        
        public function setWidth(value:Number):void {
			mcBG.width = value - (btnPlay.width + btnRewind.width + mcVolumeBG.width);
			mcVolumeBG.x = mcBG.width + mcBG.x;
			volume_slider.x = mcVolumeBG.x + 10;
			
			var sprTrack:MovieClip = playhead_slider.getChildByName("sprTrack") as MovieClip;
			var tg:Graphics = sprTrack.graphics;
			tg.clear();
			tg.lineStyle(0.25, 0x460046);
			tg.beginFill(0xB900B9, 1);
			tg.drawRect(0, 0, mcBG.width - 20, 10);
			tg.endFill();
			
			var sprProgress:MovieClip = playhead_slider.getChildByName("sprProgress") as MovieClip;
			var pg:Graphics = sprProgress.graphics;
			pg.clear();
			pg.lineStyle(0.25, 0x460046);
			pg.beginFill(0xFF00FF, 1);
			pg.drawRect(0, 0, mcBG.width - 20, 10);
			pg.endFill();
		}
		
		private function playheadHandler(e:SliderEvent):void {
			switch(e.type) {
				case SliderEvent.THUMB_PRESS :
					isSeeking = true;
					break;
				case SliderEvent.THUMB_RELEASE :
					isSeeking = false;
					break;
				case SliderEvent.THUMB_DRAG : 
					break;
				case SliderEvent.CHANGE :
					dispatchEvent(new Event("seek"));
					break;
			}
		}
		
		private function volumedHandler(e:SliderEvent):void {
			switch(e.type) {
				case SliderEvent.THUMB_PRESS :
					//isSeeking = true;
					break;
				case SliderEvent.THUMB_RELEASE :
					//isSeeking = false;
					break;
				case SliderEvent.THUMB_DRAG : 
					break;
				case SliderEvent.CHANGE :
					dispatchEvent(new Event("volume"));
					break;
			}
		}
		
		private function onClickPlay(e:MouseEvent):void {
			dispatchEvent(new Event("play"));
			showPause();
		}
		
		private function onClickPause(e:MouseEvent):void {
			dispatchEvent(new Event("pause"));
			showPlay();
		}
		
		private function onClickRewind(e:MouseEvent):void {
			dispatchEvent(new Event("rewind"));
		}
    }
}