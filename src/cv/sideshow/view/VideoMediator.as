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
	
	import flash.display.NativeWindow;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import gs.TweenLite;
	import cv.sideshow.ApplicationFacade;
	
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.media.Video;
	import flash.desktop.NativeApplication;
	import flash.filters.ShaderFilter;
	import flash.display.Shader;
	import flash.net.URLLoader; 
	import flash.net.URLLoaderDataFormat; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import cv.util.ScaleUtil;
	
	public class VideoMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'VideoMediator';
		
		public var origWidth:Number = 0;
		public var origHeight:Number = 0;
		
		private var isRatioLocked:Boolean = false;
		private var brightnessAmount:int = 0;
		private var objFilters:Object = new Object();
		private var brightSize:uint = 20;
		private var ratioWidth:Number;
		private var ratioHeight:Number;
		private var pbScanLines:Shader;
		private var loader:URLLoader = new URLLoader();
		
		public function VideoMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			screen.smoothing = true;
			screen.alpha = 0;
			
            loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete); 
            loader.load(new URLRequest("scanLines.pbj"));
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get win():NativeWindow {
			return screen.stage.nativeWindow;
		}
		
		public function get screen():Video {
			return viewComponent as Video;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function brighten(dir:int):void {
			brightnessAmount += (brightSize * dir);
			applyFilter(new ColorMatrixFilter(getBrightness(brightnessAmount)), "bright");
		}
		
		public function flip(bool:Boolean):void {
			if (bool) {
				if(screen.scaleY > 0) screen.scaleY *= -1;
				screen.y = screen.height;
			} else {
				if(screen.scaleY < 0) screen.scaleY *= -1;
				screen.y = 0;
			}
		}
		
		public function getBitMapData():BitmapData {
			var bmd:BitmapData = new BitmapData(screen.width, screen.height);
			bmd.draw(screen, screen.transform.matrix);
			return bmd;
		}
		
		public function invert(bool:Boolean):void {
			if (bool) {
				applyFilter(new ColorMatrixFilter(getNegative()), "negative");
			} else {
				removeFilter("negative");
			}
		}
		
		public function reset():void {
			brightnessAmount = 0;
			objFilters = new Object();
			updateFilters();
			flip(false);
		}
		
		public function sharpen(bool:Boolean):void {
			if (bool) {
				applyFilter(new ConvolutionFilter(3, 3, getSharpness(5), 1), "sharp");
			} else {
				removeFilter("sharp");
			}
		}
		
		public function soften(bool:Boolean):void {
			if (bool) {
				applyFilter(new ConvolutionFilter(3, 3, getSoftness(1), 5), "soft");
			} else {
				removeFilter("soft");
			}
		}
		
		public function scanLines(bool:Boolean):void {
			if (bool) {
				applyFilter(new ShaderFilter(pbScanLines), "scanlines");
			} else {
				removeFilter("scanlines");
			}
		}
		
		public function validateVideo(o:Object):void {
			origWidth = (o && o.hasOwnProperty("width")) ? o.width : screen.videoWidth || 340;
			origHeight = (o && o.hasOwnProperty("height")) ? o.height : screen.videoHeight || 250;
			sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO);
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.EXITING, 
					ApplicationFacade.VIDEO_RESET_SIZE,
					ApplicationFacade.VIDEO_SET_SIZE,
					ApplicationFacade.VIDEO_ASPECT_RATIO,
					ApplicationFacade.VIDEO_LOCK_RATIO,
					ApplicationFacade.VIDEO_BRIGHTEN, 
					ApplicationFacade.VIDEO_INVERT, 
					ApplicationFacade.VIDEO_SOFTEN, 
					ApplicationFacade.VIDEO_SHARPEN, 
					ApplicationFacade.VIDEO_SCANLINES, 
					ApplicationFacade.VIDEO_FLIP, 
					ApplicationFacade.VIDEO_RESET];
		}
		
		override public function handleNotification(note:INotification):void {
			var newW:Number;
			var newH:Number;
			var ratio:Number;
			var o:Object = note.getBody();
			
			switch (note.getName())	{
				case ApplicationFacade.VIDEO_LOCK_RATIO :
					isRatioLocked = note.getBody() as Boolean;
					break;
				case ApplicationFacade.VIDEO_RESET_SIZE :
					screen.y = 0;
					screen.x = 0;
					screen.width = origWidth = 340;
					screen.height = origHeight = 250;
					
					if (isRatioLocked) {
						ScaleUtil.toAspectRatio(screen, ratioWidth, ratioHeight);
						ScaleUtil.scaleHeight(screen, origWidth);
						if (screen.height > origHeight) ScaleUtil.scaleWidth(screen, origHeight);
					}
					
					sendNotification(ApplicationFacade.SET_SIZE, { width:origWidth, height:origHeight } );
					break;
				case ApplicationFacade.VIDEO_SET_SIZE :
					newW = o.hasOwnProperty("width") ? o.width : origWidth;
					newH = o.hasOwnProperty("height") ? o.height : origHeight;
					var multiplier:Number = o.hasOwnProperty("multiplier") ? o.multiplier : 1;
					var isFull:Boolean = o.hasOwnProperty("isFull") ? o.isFull : false;
					newW *= multiplier;
					newH *= multiplier;
					
					if (isFull) {
						// Do nothing
					} else {
						screen.y = 0;
						screen.x = 0;
						screen.width = newW;
						screen.height = newH;
						
						if (isRatioLocked) {
							ScaleUtil.toAspectRatio(screen, ratioWidth, ratioHeight);
							ScaleUtil.scaleHeight(screen, newW);
							if (screen.height > newH) ScaleUtil.scaleWidth(screen, newH);
						}
					}
					
					sendNotification(ApplicationFacade.SET_SIZE, { width:screen.width, height:screen.height } );
					break;
				case ApplicationFacade.VIDEO_ASPECT_RATIO :
					ratioWidth = o ? o.width : origWidth;
					ratioHeight = o ? o.height : origHeight;
					
					sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { width:screen.width, height:screen.height } );
					break;
				case ApplicationFacade.VIDEO_BRIGHTEN :
					brighten(note.getBody() as int);
					sendNotification(ApplicationFacade.ON_VIDEO_BRIGHTEN, brightnessAmount);
					break;
				case ApplicationFacade.VIDEO_INVERT :
					invert(note.getBody() as Boolean);
					break;
				case ApplicationFacade.VIDEO_SOFTEN :
					soften(note.getBody() as Boolean);
					break;
				case ApplicationFacade.VIDEO_SHARPEN :
					sharpen(note.getBody() as Boolean);
					break;
				case ApplicationFacade.VIDEO_SCANLINES :
					scanLines(note.getBody() as Boolean);
					break;
				case ApplicationFacade.VIDEO_FLIP :
					flip(note.getBody() as Boolean);
					break;
				case ApplicationFacade.VIDEO_RESET :
					reset();
					break;
				case ApplicationFacade.EXITING :
					if (ApplicationFacade.HAS_FILE) {
						TweenLite.to(screen, .5, { alpha:0 } );
					}
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			sendNotification(ApplicationFacade.SET_SCREEN, screen);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function applyFilter(filter:BitmapFilter, index:String):void {
			objFilters[index] = filter;
			updateFilters();
		}
		
		private function getBrightness(n:int):Array {
			var matrix:Array = [1, 0, 0, 0, n,
								0, 1, 0, 0, n,
								0, 0, 1, 0, n,
								0, 0, 0, 1, 0];
			return matrix;
		}
		
		private function getNegative():Array {
			var matrix:Array = [-1,  0,  0, 0, 255,
								 0, -1,  0, 0, 255,
								 0,  0, -1, 0, 255,
								 0,  0,  0, 1,   0];
			return matrix;
		}
		
		private function getSharpness(n:int):Array {
			var matrix:Array = [0, -1, 0,
							   -1, n, -1,
								0, -1, 0];
			return matrix;
		}
		
		private function getSoftness(n:int):Array {
			var matrix:Array = [0, 1, 0,
							    1, n, 1,
								0, 1, 0];
			return matrix;
		}
		
		private function onLoadComplete(event:Event):void { 
			pbScanLines = new Shader(loader.data); 
		}
		
		private function removeFilter(index:String):void {
			objFilters[index] = undefined;
			updateFilters();
		}
		
		private function updateFilters():void {
			var arrFilters:Array = new Array();
			for (var i:String in objFilters) {
				if (objFilters[i] != undefined) {
					arrFilters.push(objFilters[i]);
				}
			}
			screen.filters = arrFilters;
		}
	}
}