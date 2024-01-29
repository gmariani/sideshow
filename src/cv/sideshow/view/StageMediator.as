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
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.Clipboard;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.desktop.NativeDragActions;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowResize;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	
	import com.greensock.TweenLite;

	import cv.sideshow.Main;
	import cv.sideshow.view.FrameMediator;
	
	public class StageMediator {
		
		private const GROW_SIZE:uint = 25;
		
		public var appAlpha:Number = 1;
		public var isInitialized:Boolean = false;
		public var doLogoBounce:Boolean = true;
		
		private var sprHit:Sprite;
		private var sprBack:Sprite;
		private var isOnTopWhilePlaying:Boolean = true;
		private var txtError:TextField;
		private var isFullScreen:Boolean = false;
		private var normalScreenRect:Rectangle;
		private var mcLogo:MovieClip;
		private var isResizing:Boolean = false;
		private var pbShake:Shader;
		private var pbWave:Shader;
		private var pbZoom:Shader;
		private var objPixelBender:Object = new Object();
		private var isAudio:Boolean = false;
		private var doOnStartUp:Boolean = false;
		private var root:MovieClip;
		
		public function StageMediator(rootRef:MovieClip) {
			root = rootRef;
			
			// Init Window
			win.title = "SideShow";
			win.activate();
			win.addEventListener(Event.RESIZE, onWindowResize);
			win.minSize = new Point(100, 100);
			win.maxSize = new Point(2000, 2000);
			win.visible = true;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			root.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage);
			stage.addEventListener(MouseEvent.MOUSE_UP, hitHandler);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenRedraw);
			
			// BG
			sprBack = root.getChildByName("sprBack") as Sprite;
			sprBack.alpha = 0;
			
			// Logo
			mcLogo = root.getChildByName("mcLogo") as MovieClip;
			mcLogo.alpha = 0;
			
			// Error
			txtError = mcLogo.getChildByName("txtError") as TextField;
			txtError.alpha = 0;
			
			// Create Hit Area / Init Drag
			sprHit = new Sprite();
			sprHit.name = 'sprHit';
			sprHit.alpha = 0;
			sprHit.useHandCursor = false;
			sprHit.doubleClickEnabled = true;
			sprHit.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, 	dragHandler);
			sprHit.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, 	dragHandler);
			sprHit.addEventListener(MouseEvent.CONTEXT_MENU, 			hitHandler);
			sprHit.addEventListener(MouseEvent.MOUSE_DOWN, 				hitHandler);
			sprHit.addEventListener(MouseEvent.MOUSE_UP, 				hitHandler);
			sprHit.addEventListener(MouseEvent.MOUSE_WHEEL, 			hitHandler);
			sprHit.addEventListener(MouseEvent.DOUBLE_CLICK, 			hitHandler);
			sprHit.addEventListener(MouseEvent.MOUSE_MOVE, 				hitHandler);
			root.addChild(sprHit);
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.load(new URLRequest("shake.pbj"));
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete2);
			loader.load(new URLRequest("waves.pbj"));
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete3); 
			loader.load(new URLRequest("zoomBlur.pbj"));
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get stage():Stage {
			return root.stage;
		}
		
		public function get win():NativeWindow {
			return root.stage.nativeWindow;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function validateSetOnTop(bool:Boolean = false):void {
			if (isOnTopWhilePlaying) setOnTop(bool);
		}
		
		public function updateMouse():void {
			if (stage.displayState != StageDisplayState.NORMAL) Mouse.hide();
		}
		
		public function grow(value:int):void {
			var ratio:Number;
			var amount:Number = GROW_SIZE * value;
			var newWidth:Number = win.width + amount;
			var newHeight:Number = win.height + amount;
			if (win.width > win.height) {
				ratio = (newWidth / win.width);
			} else {
				ratio = (newHeight / win.height);
			}
			
			TweenLite.to(win, .5, { width:(win.width * ratio), height:(win.height * ratio) } );
		}
		
		public function setSize(width:Number, height:Number):void {
			sprHit.graphics.clear();
			sprHit.graphics.beginFill(0xFF00FF, 0.5);
			sprHit.graphics.drawRect(0, 0, width, height);
			sprHit.graphics.endFill();
			
			mcLogo.width = width - 1;
			mcLogo.height = height - 1;
			
			sprBack.width = width;
			sprBack.height = height;
			
			win.removeEventListener(Event.RESIZE, onWindowResize);
			win.width = width;
			win.height = height;
			
			win.addEventListener(Event.RESIZE, onWindowResize);
			
			stage.fullScreenSourceRect = new Rectangle(0, 0, win.width, win.height);
		}
		
		public function hide():void {
			endPixelBender();
			objPixelBender.transition = 1;
			TweenLite.to(objPixelBender, 1.2, { transition:0, onUpdate:updateWaves, onComplete:NativeApplication.nativeApplication.exit } );
		}
		
		public function toggleFull():void {
			if (Main.HAS_FILE) {
				if (stage.displayState == StageDisplayState.NORMAL) {
					isFullScreen = true;
					Main.sendNotification(Main.VIDEO_ASPECT_RATIO);
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				} else {
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		public function toggleOnTop(value:Boolean, whilePlaying:Boolean):void {
			setOnTop(value);
			isOnTopWhilePlaying = whilePlaying;
		}
		
		public function updatePlayProgress(isPlaying:Boolean):void {
			// If audio, show some effects
			if(isAudio && doLogoBounce) {
				var bytes:ByteArray = new ByteArray();
				
				SoundMixer.computeSpectrum(bytes, false, 0);
				var l:uint = 256;
				var combined:Number = 0;
				for(var i:int = 0; i < l; i++) {
					var n:Number = bytes.readFloat();
					bytes.position = bytes.position + 1020;
					var n2:Number = bytes.readFloat();
					bytes.position = bytes.position - 1024;
					combined += (n + n2) / 2;
				}
				combined /= l;
				combined *= 10;
				if (combined < 0) combined = 0;
				
				objPixelBender.transition = combined / 2;
				updateZoom(mcLogo.mcLogo);
			} else {
				mcLogo.mcLogo.filters = [];
			}
			
			validateSetOnTop(isPlaying);
		}
		
		public function closeFile():void {
			validateSetOnTop(false);
			stage.displayState = StageDisplayState.NORMAL;
			mcLogo.mcLogo.filters = [];
		}
		
		public function audioMode():void {
			isAudio = true;
			TweenLite.to(sprBack, .5, { autoAlpha:0 } );
			TweenLite.to(mcLogo, .5, { autoAlpha:appAlpha } );
			Main.sendNotification(Main.RESET_SIZE);
		}
		
		public function videoMode():void {
			isAudio = false;
			TweenLite.to(sprBack, .5, { autoAlpha:appAlpha } );
			TweenLite.to(mcLogo, .5, { autoAlpha:0 } );
		}
		
		public function defaultMode():void {
			if (!doOnStartUp) {
				objPixelBender.transition = 0;
				TweenLite.to(objPixelBender, 1.2, { transition:1, onUpdate:updateWaves, onComplete:endPixelBender } );
				doOnStartUp = true;
			}
			isAudio = false;
			TweenLite.to(sprBack, .5, { autoAlpha:0} );
			TweenLite.to(mcLogo, .5, { autoAlpha:appAlpha } );
		}
		
		public function showError(type:String):void {
			switch(type) {
				case "format" :
					txtError.text = "Invalid file format";
					break;
				case "exists" :
					txtError.text = "File cannot be found";
					break;
			}
			
			objPixelBender.transition = 0;
			TweenLite.to(objPixelBender, 1, { transition:1, onUpdate:updateShake, onComplete:endPixelBender } );
			TweenLite.to(txtError, .5, { alpha:1 } );
		}
		
		public function hideError():void {
			TweenLite.to(txtError, .5, { alpha:0 } );
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function dragHandler(e:NativeDragEvent):void {
			var cb:Clipboard = e.clipboard;
			switch(e.type) {
				case NativeDragEvent.NATIVE_DRAG_ENTER :
					if(cb.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
						NativeDragManager.dropAction = NativeDragActions.LINK;
						NativeDragManager.acceptDragDrop(stage);
					} else {
						trace("StageMediator : Unrecognized format");
					}
					break;
				case NativeDragEvent.NATIVE_DRAG_DROP :
					var arr:Array = cb.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_ONLY) as Array;
					Main.sendNotification(Main.OPEN_FILE, arr.shift());
					for (var i:uint = 0; i < arr.length; i++) {
						Main.sendNotification(Main.ADD_FILE, { url:arr[i].url } );
					}
					break;
			}
		}
		
		private function endPixelBender():void {
			root.filters = [];
		}
		
		private function hitHandler(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.CONTEXT_MENU :
					Main.sendNotification(Main.MENU_SHOW, { stage:stage, stageX:e.stageX, stageY:e.stageY } );
					break;
				case MouseEvent.MOUSE_DOWN :
					isResizing = true;
					if (stage.mouseX >= 0 && stage.mouseX <= Main.GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= Main.GRIPPER_SIZE)	{
						win.startResize(NativeWindowResize.TOP_LEFT);
					} else if (stage.mouseX <= win.width && stage.mouseX >= win.width - Main.GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= Main.GRIPPER_SIZE) {
						win.startResize(NativeWindowResize.TOP_RIGHT);
					} else if (stage.mouseX >= 0 && stage.mouseX <= Main.GRIPPER_SIZE && stage.mouseY <= win.height && stage.mouseY >= win.height - Main.GRIPPER_SIZE) {
						win.startResize(NativeWindowResize.BOTTOM_LEFT);
					} else if (stage.mouseX <= win.width && stage.mouseX >= win.width - Main.GRIPPER_SIZE && stage.mouseY <= win.height && stage.mouseY >= win.height - Main.GRIPPER_SIZE) {
						win.startResize(NativeWindowResize.BOTTOM_RIGHT);
					} else if (stage.mouseX >= 0 && stage.mouseX <= Main.GRIPPER_SIZE) {
						win.startResize(NativeWindowResize.LEFT);
					} else if (stage.mouseX >= win.width - Main.GRIPPER_SIZE && stage.mouseX <= win.width) {
						win.startResize(NativeWindowResize.RIGHT);
					} else if (stage.mouseY >= 0 && stage.mouseY <= Main.GRIPPER_SIZE) {
						win.startResize(NativeWindowResize.TOP);
					} else if (stage.mouseY >= win.height - Main.GRIPPER_SIZE && stage.mouseY <= win.height) {
						win.startResize(NativeWindowResize.BOTTOM);
					} else {
						isResizing = false;
						win.startMove();
					}
					break;
				case MouseEvent.MOUSE_UP :
					if (!isFullScreen && isResizing) Main.sendNotification(Main.SET_SIZE, { width:win.width, height:win.height } );
					break;
				case MouseEvent.MOUSE_WHEEL :
					appAlpha += e.delta / 100
					appAlpha = Math.max(.1, Math.min(1, appAlpha));
					Main.sendNotification(Main.UPDATE, {alpha:appAlpha} );
					break;
				case MouseEvent.MOUSE_MOVE :
					Mouse.show();
					break;
				case MouseEvent.DOUBLE_CLICK :
					Main.sendNotification(Main.TOGGLE_FULL);
					break;
			}
		}
		
		private function onLoadComplete(event:Event):void { 
			pbShake = new Shader(event.target.data); 
		}
		
		private function onLoadComplete2(event:Event):void { 
			pbWave = new Shader(event.target.data);
			isInitialized = true;
			Main.sendNotification(Main.UPDATE);
		}
		
		private function onLoadComplete3(event:Event):void { 
			pbZoom = new Shader(event.target.data); 
		}
		
		private function onFullScreenRedraw(event:FullScreenEvent):void {
			Main.sendNotification(Main.ON_TOGGLE_FULL, event.fullScreen);
			if (!event.fullScreen) isFullScreen = false;
		}
		
		private function onMouseLeaveStage(e:Event):void {
			Main.sendNotification(Main.HIDE_FRAME);
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			if (!isFullScreen) Main.sendNotification(Main.SET_SIZE, { width:e.afterBounds.width, height:e.afterBounds.height } );
		}
		
		private function setOnTop(value:Boolean):void {
			if(!win.closed) win.alwaysInFront = value;
		}
		
		private function updateShake(target:DisplayObject = null):void {
			if (!target) target = root;
            pbShake.data.width.value[0] = target.width;
            pbShake.data.height.value[0] = target.height;
            pbShake.data.transition.value[0] = objPixelBender.transition;
            pbShake.data.weight.value[0] = 0.9;
            pbShake.data.waves.value[0] = 2;
			target.filters = [new ShaderFilter(pbShake)];
		}
		
		private function updateWaves(target:DisplayObject = null):void {
			if (!target) target = root;
            pbWave.data.width.value[0] = target.width;
            pbWave.data.height.value[0] = target.height;
            pbWave.data.transition.value[0] = objPixelBender.transition;
            pbWave.data.weight.value[0] = 0.9;
            pbWave.data.waves.value[0] = 2;
			target.filters = [new ShaderFilter(pbWave)];
		}
		
		private function updateZoom(target:DisplayObject = null):void {
			if (!target) target = root;
            pbZoom.data.amount.value[0] = objPixelBender.transition; // 0 - 0.5
            pbZoom.data.center.value[0] = target.width / 2;
            pbZoom.data.center.value[1] = target.height / 2;
			target.filters = [new ShaderFilter(pbZoom)];
		}
	}
}