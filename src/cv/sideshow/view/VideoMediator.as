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
	
	import cv.util.ScaleUtil;
	import cv.sideshow.Main;
	
	import com.greensock.TweenLite;
	
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
	import flash.display.NativeWindow;
	
	public class VideoMediator {
		
		public var origWidth:Number = 0;
		public var origHeight:Number = 0;
		public var isRatioLocked:Boolean = false;
		
		private var _screen:Video;
		private var brightnessAmount:int = 0;
		private var objFilters:Object = {};
		private var ratioWidth:Number;
		private var ratioHeight:Number;
		private var pbScanLines:Shader;
		
		private const BRIGHT_SIZE:uint = 20;
		
		public function VideoMediator(videoRef:Video) {
			_screen = videoRef;
			screen.smoothing = true;
			screen.alpha = 0;
			
			var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete); 
            loader.load(new URLRequest("scanLines.pbj"));
			
			Main.sendNotification(Main.SET_SCREEN, screen);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get win():NativeWindow {
			return screen.stage.nativeWindow;
		}
		
		public function get screen():Video {
			return _screen;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function brighten(dir:int):int {
			brightnessAmount += (BRIGHT_SIZE * dir);
			applyFilter(new ColorMatrixFilter(getBrightness(brightnessAmount)), "bright");
			return brightnessAmount;
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
			objFilters = {};
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
			Main.sendNotification(Main.VIDEO_ASPECT_RATIO);
		}
		
		public function resetSize():void {
			screen.y = 0;
			screen.x = 0;
			screen.width = origWidth = 340;
			screen.height = origHeight = 250;
			
			if (isRatioLocked) {
				ScaleUtil.toAspectRatio(screen, ratioWidth, ratioHeight);
				ScaleUtil.scaleHeight(screen, origWidth);
				if (screen.height > origHeight) ScaleUtil.scaleWidth(screen, origHeight);
			}
		}
		
		public function setSize(width:Number = -1, height:Number = -1, multiplier:Number = 1, isFull:Boolean = false):void {
			var newW:Number = !isNaN(width) ? width : origWidth;
			var newH:Number = !isNaN(height) ? height : origHeight;
			multiplier = isNaN(multiplier) ? 1 : multiplier;
			newW *= multiplier;
			newH *= multiplier;
			
			if (isFull) return;
			
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
		
		public function setAspectRatio(width:Number = -1, height:Number = -1):void {
			ratioWidth = width != -1 ? width : origWidth;
			ratioHeight = height != -1 ? height : origHeight;
			
			//Main.sendNotification(Main.SET_SIZE, { width:screen.width, height:screen.height } );
			Main.sendNotification(Main.SET_SIZE, { width:ratioWidth, height:ratioHeight } );
		}
		
		public function hide():void {
			if (Main.HAS_FILE) TweenLite.to(screen, .5, { alpha:0 } );
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
			var loader:URLLoader = event.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onLoadComplete); 
			pbScanLines = new Shader(loader.data); 
		}
		
		private function removeFilter(index:String):void {
			objFilters[index] = undefined;
			updateFilters();
		}
		
		private function updateFilters():void {
			var arrFilters:Array = [];
			for (var i:String in objFilters) {
				if (objFilters[i] != undefined) {
					arrFilters.push(objFilters[i]);
				}
			}
			screen.filters = arrFilters;
		}
	}
}