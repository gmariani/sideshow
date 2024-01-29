
package cv.controls {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import fl.events.SliderEvent;
	import fl.events.SliderEventClickTarget;
	import fl.events.InteractionInputType;
	
	import cv.util.MathUtil;
	
	public class Slider extends MovieClip {
		
		private var _toolTip:String;
		private var _value:Number;
		private var _loadValue:Number;
		private var _isDown:Boolean = false;
		private var _isOver:Boolean = false;
		private var _disabled:Boolean = false;
		private var _liveDragging:Boolean = false;
		
		public function Slider():void {
			init();
		}
		
		private function init():void {
			mcThumb.gotoAndStop(1);
			mcThumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbPressHandler);
			sprTrack.addEventListener(MouseEvent.CLICK, trackClickHandler, false, 0, true);
			sprLoad.mouseEnabled = false;
			sprProgress.addEventListener(MouseEvent.CLICK, trackClickHandler, false, 0, true);
			value = 0;
		}
		
		public function set liveDragging(b:Boolean):void {
			_liveDragging = b;
		}
		public function get liveDragging():Boolean {
			return _liveDragging;
		}
		
		public function set toolTip(str:String):void {
			_toolTip = str;
		}
		public function get toolTip():String {
			return _toolTip;
		}
		
		public function set value(n:Number):void {
			setValue(n);
		}
		public function get value():Number {
			return _value;
		}
		
		public function set loadValue(n:Number):void {
			_loadValue = MathUtil.clamp(0, 1, n);
			sprLoad.scaleX = _loadValue;
		}
		public function get loadValue():Number {
			return _loadValue;
		}
		
		override public function set enabled(value:Boolean):void {
			if (enabled == value) return;
			this.enabled = value;
			sprTrack.enabled = mcThumb.enabled = value;
			mcThumb.visible = !value;
			sprProgress.visible = !value;
		}
		override public function get enabled():Boolean {
			return this.enabled;
		}
		
		private function setValue(val:Number, interactionType:String=null, clickTarget:String=null, keyCode:int=undefined):void {
			var oldVal:Number = _value;
			_value = MathUtil.clamp(0, 1, val);
			
			// Only dispatch if value has changed
			// Dispatch when dragging
			if (oldVal != _value && ((liveDragging && clickTarget != null) || (interactionType == InteractionInputType.KEYBOARD))) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
			}
			
			if (!_isDown) positionThumb(_value);
			if((_isDown && !liveDragging) || !_isDown) setProgress();
		}
		
		
		
		private function calculateValue():Number {
			var newValue:Number = Number(Number(sprTrack.mouseX / (sprTrack.width - mcThumb.width)).toFixed(3));
			return MathUtil.clamp(0, 1, newValue);
		}
		
		private function positionThumb(val:Number):void {
			mcThumb.x = (sprTrack.width - mcThumb.width) * val;
		}
		
		private function setProgress():void {
			sprProgress.scaleX = _value;
		}
		
		private function overHandler(e:MouseEvent):void {
			_isOver = true;
			if(!_isDown) mcThumb.gotoAndStop(2);
			dispatchEvent(new Event("SHOW_TOOLTIP", true));
		};
		
		private function outHandler(e:MouseEvent):void {
			_isOver = false;
			if(!_isDown) mcThumb.gotoAndStop(1);
			dispatchEvent(new Event("HIDE_TOOLTIP", true));
		};
		
		private function thumbDragHandler(e:MouseEvent):void {
			var newValue:Number = calculateValue();
			positionThumb(newValue);
			if (liveDragging) {
				setValue(newValue, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB);
				setProgress();
			}
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_DRAG, newValue, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		}
		
		private function thumbPressHandler(e:MouseEvent):void {
			_isDown = true;
			mcThumb.gotoAndStop(3);
			
			stage.addEventListener(MouseEvent.MOUSE_OVER, overHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_OUT, outHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbDragHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler, false, 0, true);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_PRESS, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		};
		
		private function thumbReleaseHandler(e:MouseEvent):void {
			_isDown = false;
			if (!_isOver) mcThumb.gotoAndStop(1);
			var newValue:Number = calculateValue();
			setValue(newValue, InteractionInputType.MOUSE);
			
			stage.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbDragHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, thumbReleaseHandler);
			dispatchEvent(new SliderEvent(SliderEvent.THUMB_RELEASE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
			dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
		};
		
		private function trackClickHandler(e:MouseEvent):void {
			var newValue:Number = calculateValue();
			setValue(newValue, InteractionInputType.MOUSE, SliderEventClickTarget.TRACK);
			
			if (!liveDragging) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, SliderEventClickTarget.TRACK, InteractionInputType.MOUSE));
			}
		}
	}
}