package com.coursevector.sideshow {
	
	import flash.system.Capabilities;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.Clipboard;
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.desktop.NativeDragActions;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.FullScreenEvent;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.FileFilter;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	
	import gs.TweenLite;
	import com.adobe.images.PNGEncoder;
	import com.coursevector.util.Scale;
	import com.coursevector.tempo.TempoLite;
	import com.coursevector.managers.UpdateManager;
	import com.coursevector.sideshow.MenuIcon;
	import com.coursevector.sideshow.Header;
	import com.coursevector.sideshow.Controls;
	import com.coursevector.sideshow.UpdateWindow;
	import com.coursevector.sideshow.AboutWindow;
	import com.coursevector.sideshow.MetaDataWindow;
	import com.coursevector.sideshow.PlaylistWindow;
	
	// Version 1.1.0
	// BUG: Fullscreen broken on mac - DONE
	// BUG: Playlist menu does shows up each time window is recreated - DONE
	// TODO: Resizable playlist window - DONE
	
	// Version 1.1.1
	// BUG: Video filters don't clear properly - DONE
	// BUG: On new file, scaling option is not maintained - DONE
	// BUG: At end of video, doesn't reset scrub/controls - DONE
	// BUG: Video scaling is done wrong, shrinking changes height faster than width - DONE
	
	// Version 1.1.3
	// BUG: AIR 1.1 Mac Menu Bug - DONE
	// BUG: AIR 1.1 Rollover menu broken - DONE
	
	// Version 1.2.0
	// TODO: Load video from web
	// TODO: Sort actually sorts playlist and not just how it looks in the playlist window
	/*
	TODO: Fix filetype association
	
	app.isSetAsDefaultApplication(extension:String):Boolean Returns true if the AIR application is currently associated with the specified file type.
		Parameters
			extension:String — A String containing the extension of the file type of interest (without the ".").
		Returns
			Boolean — true if this application is the default.
		Throws
			Error — If the extension parameter does not contain one of the file extensions declared in the application descriptor. 
	
	app.setAsDefaultApplication(extension:String):void Creates the association between the AIR application and the open action of the file type.
		Parameters
			extension:String — A String containing the extension of the file type of interest (without the ".").
		Throws
			Error — If the extension parameter does not contain one of the file extensions declared in the application descriptor.
	
	app.removeAsDefaultApplication(extension:String):void Removes the association between the AIR application and the file type.
		Parameters
			extension:String — A String containing the extension of the file type of interest (without the ".").
		Throws
			Error — If the extension parameter does not contain one of the file extensions declared in the application descriptor.
			
	app.getDefaultApplication(extension:String):String Reports the path of the application that is currently associated with the file type.
		Parameters
			extension:String — A String containing the extension of the file type of interest (without the ".").
		Returns
			String — The path of the default application. 
		Throws
			Error — If the extension parameter does not contain one of the file extensions declared in the application descriptor. 
	*/
	
	public class Screen extends NativeWindow {
		
		private var VERSION:String;
		private const GRIPPER_SIZE:uint = 10;
		private const GROW_SIZE:uint = 25;
		private const BRIGHT_SIZE:uint = 20;
		
		private var um:UpdateManager;
		private var icon:MenuIcon = new MenuIcon();	
		private var tempo:TempoLite = new TempoLite();
		private var vidScreen:Video = new Video();
		private var mcLogo:MovieClip = new Logo();
		private var controls:Controls = new Controls();
		private var header:Header = new Header();
		private var sprHit:Sprite;
		private var sprBack:Sprite;
		private var fileDir:File = File.desktopDirectory;
		private var filePL:File = File.desktopDirectory;
		private var fileSave:File = File.desktopDirectory;
		private var fileScreen:File = File.desktopDirectory.resolvePath("untitled.png");
		private var fileCurrent:File;
		private var origW:uint;
		private var origH:uint;
		private var hasFile:Boolean = false;
		private var origVidW:uint;
		private var origVidH:uint;
		private var arrSizeModes:Array = new Array();
		private var isOnTopWhilePlaying:Boolean = true;
		private var brightnessAmount:int = 0;
		private var objFilters:Object = new Object();
		private var bmd:BitmapData;
		private var appAlpha:Number = 1;
		private var app:NativeApplication = NativeApplication.nativeApplication;
		private var txtError:TextField;
		private var updateWin:UpdateWindow;
		private var aboutWin:AboutWindow;
		private var metaWin:MetaDataWindow;
		private var plWin:PlaylistWindow;
		
		private var navContextMenu:NativeMenu;
		private var rootContextMenu:NativeMenu;
		private var openMenuItem:NativeMenuItem;
		private var closeMenuItem:NativeMenuItem;
		private var saveAsMenuItem:NativeMenuItem;
		private var maintainSizeMenuItem:NativeMenuItem;
		private var halfSizeMenuItem:NativeMenuItem;
		private var normalSizeMenuItem:NativeMenuItem;
		private var doubleSizeMenuItem:NativeMenuItem;
		private var fitToScreenMenuItem:NativeMenuItem;
		private var fullScreenMenuItem:NativeMenuItem;
		private var maximizedMenuItem:NativeMenuItem;
		private var exitMenuItem:NativeMenuItem;
		private var seeThruMenuItem:NativeMenuItem;
		private var alwaysOnTopMenuItem:NativeMenuItem;
		private var alwaysOnTopPlayingMenuItem:NativeMenuItem;
		private var playPauseMenuItem:NativeMenuItem;
		private var stopMenuItem:NativeMenuItem;
		private var prevTrackMenuItem:NativeMenuItem;
		private var nextTrackMenuItem:NativeMenuItem;
		private var playlistMenuItem:NativeMenuItem;
		private var growMenuItem:NativeMenuItem;
		private var shrinkMenuItem:NativeMenuItem;
		private var flipMenuItem:NativeMenuItem;
		private var negativeMenuItem:NativeMenuItem;
		private var brightenDownMenuItem:NativeMenuItem;
		private var brightenUpMenuItem:NativeMenuItem;
		private var softenMenuItem:NativeMenuItem;
		private var sharpenMenuItem:NativeMenuItem;
		private var discardVideoFiltersMenuItem:NativeMenuItem;
		private var discardAudioFiltersMenuItem:NativeMenuItem;
		private var saveSSMenuItem:NativeMenuItem;
		private var repeatMenuItem:NativeMenuItem;
		private var shuffleMenuItem:NativeMenuItem;
		private var muteMenuItem:NativeMenuItem;
		private var smallerVolMenuItem:NativeMenuItem;
		private var louderVolMenuItem:NativeMenuItem;
		private var swapChannelsMenuItem:NativeMenuItem;
		private var ratioOriginalMenuItem:NativeMenuItem;
		private var ratioTVMenuItem:NativeMenuItem;
		private var ratioWideMenuItem:NativeMenuItem;
		private var ratioDesktopMenuItem:NativeMenuItem;
		private var ratioCustomMenuItem:NativeMenuItem;
		private var ratioFreeMenuItem:NativeMenuItem;
		private var jumpHeadMenuItem:NativeMenuItem;
		private var jumpHalfMenuItem:NativeMenuItem;
		private var jumpEndMenuItem:NativeMenuItem;
		private var back30MenuItem:NativeMenuItem;
		private var forward30MenuItem:NativeMenuItem;
		private var back1MenuItem:NativeMenuItem;
		private var forward1MenuItem:NativeMenuItem;
		private var infoMenuItem:NativeMenuItem;
		
		private var isFullScreen:Boolean = false;
		private var normalScreenRect:Rectangle;
		
		public function Screen(initOptions:NativeWindowInitOptions):void {
			super(initOptions);
			
			this.title = "SideShow";
			this.activate();
			this.addEventListener(Event.RESIZE, onWindowResize);
			this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowDisplay);
			minSize = new Point(100, 100);
			maxSize = new Point(2000, 2000);
			visible = true;
			origVidW = origW = 340;
			origVidH = origH = 250;
			
			filePL.addEventListener(Event.SELECT, onSelectionPlayList);
			fileDir.addEventListener(Event.SELECT, onSelection);
			fileDir.addEventListener(FileListEvent.SELECT_MULTIPLE, onSelectionMultiple);
			fileSave.addEventListener(Event.SELECT, saveFile);
			fileScreen.addEventListener(Event.SELECT, saveScreenShot);
			fileScreen.addEventListener(Event.CANCEL, saveScreenShot);
			
			// Init Stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenRedraw);
			
			// Create Backdrop
			sprBack = new Sprite();
			sprBack.graphics.beginFill(0x000000, 1);
			sprBack.graphics.drawRect(0, 0, 10, 10);
			sprBack.graphics.endFill();
			sprBack.alpha = 0;
			stage.addChild(sprBack);
			
			// Create Video
			vidScreen = new Video();
			vidScreen.alpha = 0;
			stage.addChild(vidScreen);
			
			// Create Logo
			mcLogo.alpha = 0;
			txtError = mcLogo.getChildByName("txtError") as TextField;
			txtError.alpha = 0;
			stage.addChild(mcLogo);
			updateDisplay();
			
			//Set the system tray or dock icon image
			icon.addEventListener(Event.COMPLETE,function():void{
				app.icon.bitmaps = icon.bitmaps;
			});
			icon.loadImages();
			
			// Init Updater
			um = UpdateManager.instance;
			VERSION = um.currentVersion;
			um.updateURL = "http://labs.coursevector.com/projects/sideshow/update.xml";
			um.addEventListener(UpdateManager.AVAILABLE, updateHandler);
			
			// Create Context Menu
			navContextMenu = createContextMenu();
			rootContextMenu = createRootMenu();
			
			// Mac
			if(NativeApplication.supportsDockIcon){
				DockIcon(app.icon).menu = rootContextMenu;
			}
			
			if (NativeApplication.supportsMenu) {
				//app.menu = rootContextMenu;
				app.menu.addSubmenu(rootContextMenu, "SideShow");
			}
			
			// Win
			if(NativeApplication.supportsSystemTrayIcon){
				SystemTrayIcon(app.icon).tooltip = "SideShow";
				SystemTrayIcon(app.icon).menu = rootContextMenu;
			}
			
			// Create Hit Area / Init Drag
			sprHit = new Sprite();
			sprHit.alpha = 0;
			sprHit.useHandCursor = false;
			sprHit.addEventListener(MouseEvent.CONTEXT_MENU, openContextMenu);
			sprHit.doubleClickEnabled = true;
			sprHit.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler);
			sprHit.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler);
			sprHit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sprHit.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			sprHit.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble);
			sprHit.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			sprHit.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addChild(sprHit);
			
			// Create Header
			header.visible = false;
			header.alpha = 0;
			header.addEventListener(MouseEvent.MOUSE_OVER, showFrame);
			stage.addChild(header);
			
			// Create Controls
			controls.visible = false;
			controls.alpha = 0;
			controls.x = GRIPPER_SIZE;
			controls.addEventListener(MouseEvent.MOUSE_OVER, showFrame);
			controls.addEventListener("play", onPlay);
			controls.addEventListener("pause", onPause);
			controls.addEventListener("rewind", onRewind);
			controls.addEventListener("seek", onSliderSeek);
			controls.addEventListener("volume", onVolumeSeek);
			controls.volume = tempo.volume;
			stage.addChild(controls);
			
			// Init Tempo
			tempo.addEventListener(TempoLite.LOAD_START, tempoHandler);
			tempo.addEventListener(TempoLite.PLAY_START, tempoHandler);
			tempo.addEventListener(TempoLite.PLAY_PROGRESS, tempoHandler);
			tempo.addEventListener(TempoLite.PLAY_COMPLETE, tempoHandler);
			tempo.addEventListener(TempoLite.VIDEO_METADATA, tempoHandler);
			tempo.addEventListener(TempoLite.AUDIO_METADATA, tempoHandler);
			tempo.addEventListener(TempoLite.REFRESH_PLAYLIST, tempoHandler);
			tempo.addEventListener(TempoLite.NEW_PLAYLIST, tempoHandler);
			tempo.addEventListener(TempoLite.CHANGE, tempoHandler);
			tempo.repeat = "none";
			tempo.autoStart = false;
			tempo.setVideoScreen(vidScreen);
			
			// Init Playlist
			initPlayList();
			
			// Init
			app.idleThreshold = 5; // seconds
			app.addEventListener(Event.USER_IDLE, onIdle);
			app.addEventListener(InvokeEvent.INVOKE, onInvoke);
			updateDimensions(origW, origH);
			updateMenu();
			um.checkNow();
		}
		
		private function updateHandler(e:Event):void {
			switch(e.type) {
				case UpdateManager.AVAILABLE :
					updateWin = new UpdateWindow();
					updateWin.activate();
					break;
			}
		}
		
		private function applyFilter(filter:BitmapFilter, index:String):void {
			objFilters[index] = filter;
			updateFilters();
		}
		
		private function brighten(amt:int):void {
			applyFilter(new ColorMatrixFilter(getBrightness(brightnessAmount)), "bright");
			
			if (brightnessAmount > 1) {
				brightenDownMenuItem.checked = false;
				brightenUpMenuItem.checked = true;
			}
			if (brightnessAmount == 0) {
				brightenDownMenuItem.checked = false;
				brightenUpMenuItem.checked = false;
			}
		}
		
		private function closeItem():void {
			if (isOnTopWhilePlaying) {
				toggleOnTop(false);
			}
			hasFile = false;
			updateMenu();
			stage.displayState = StageDisplayState.NORMAL;
			tempo.stop();
			//tempo.clearItems();
			tempo.unloadMedia();
			origVidW = origW;
			origVidH = origH;
			updateDimensions(origW, origH);
			updateDisplay();
		}
		
		private function createRootMenu():NativeMenu {
			var menu:NativeMenu = new NativeMenu();
			var restorMenuItem:NativeMenuItem = menu.addItem(new NativeMenuItem("Restore"));
			restorMenuItem.addEventListener(Event.SELECT, setWindowDisplay);
			var minMenuItem:NativeMenuItem = menu.addItem(new NativeMenuItem("Minimize"));
			minMenuItem.addEventListener(Event.SELECT, setWindowDisplay);
			var maxMenuItem:NativeMenuItem = menu.addItem(new NativeMenuItem("Maximize"));
			maxMenuItem.addEventListener(Event.SELECT, setWindowDisplay);
			
			menu.addItem(new NativeMenuItem("", true));
			
			menu.addSubmenu(navContextMenu, "SideShow Menu");
			
			menu.addItem(new NativeMenuItem("", true));
			
			
			var closeMenuItem:NativeMenuItem = menu.addItem(new NativeMenuItem("Close"));
			closeMenuItem.addEventListener(Event.SELECT, onExit);
			return menu;
		}
		
		private function createPlaybackMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			playPauseMenuItem = nm.addItem(new NativeMenuItem("Play/Pause"));
				playPauseMenuItem.keyEquivalent = "space";
				playPauseMenuItem.keyEquivalentModifiers = [];
				playPauseMenuItem.addEventListener(Event.SELECT, onPlayPause);
			stopMenuItem = nm.addItem(new NativeMenuItem("Stop"));
				stopMenuItem.keyEquivalent = "v";
				stopMenuItem.keyEquivalentModifiers = [];
				stopMenuItem.addEventListener(Event.SELECT, onStop);
				
			nm.addItem(new NativeMenuItem("", true));
			
			prevTrackMenuItem = nm.addItem(new NativeMenuItem("Previous Track"));
				prevTrackMenuItem.addEventListener(Event.SELECT, onPreviousTrack);
			nextTrackMenuItem = nm.addItem(new NativeMenuItem("Next Track"));
				nextTrackMenuItem.addEventListener(Event.SELECT, onNextTrack);
			playlistMenuItem = nm.addItem(new NativeMenuItem("Simple Playlist"));
				playlistMenuItem.addEventListener(Event.SELECT, onPlaylist);
			
			nm.addItem(new NativeMenuItem("", true));
			
			back30MenuItem = nm.addItem(new NativeMenuItem("Rewind 30 Seconds"));
				back30MenuItem.keyEquivalent = "LEFT";
				back30MenuItem.keyEquivalentModifiers = [];
				back30MenuItem.addEventListener(Event.SELECT, onSeek);
			forward30MenuItem = nm.addItem(new NativeMenuItem("Forward 30 Seconds"));
				forward30MenuItem.keyEquivalent = "RIGHT";
				forward30MenuItem.keyEquivalentModifiers = [];
				forward30MenuItem.addEventListener(Event.SELECT, onSeek);
			back1MenuItem = nm.addItem(new NativeMenuItem("Rewind 1 Minute"));
				back1MenuItem.keyEquivalent = "left";
				back1MenuItem.addEventListener(Event.SELECT, onSeek);
			forward1MenuItem = nm.addItem(new NativeMenuItem("Forward 1 Minute"));
				forward1MenuItem.keyEquivalent = "right";
				forward1MenuItem.addEventListener(Event.SELECT, onSeek);
			
			nm.addItem(new NativeMenuItem("", true));
			
			jumpHeadMenuItem = nm.addItem(new NativeMenuItem("Jump to Head"));
				jumpHeadMenuItem.keyEquivalent = "home";
				jumpHeadMenuItem.addEventListener(Event.SELECT, onSeek);
			jumpHalfMenuItem = nm.addItem(new NativeMenuItem("Jump to Half"));
				jumpHalfMenuItem.addEventListener(Event.SELECT, onSeek);
			jumpEndMenuItem = nm.addItem(new NativeMenuItem("Jump to End"));
				jumpEndMenuItem.addEventListener(Event.SELECT, onSeek);
			
			nm.addItem(new NativeMenuItem("", true));
			
			repeatMenuItem = nm.addItem(new NativeMenuItem("Repeat"));
				repeatMenuItem.keyEquivalent = "r";
				repeatMenuItem.keyEquivalentModifiers = [];
				repeatMenuItem.addEventListener(Event.SELECT, onRepeat);
			shuffleMenuItem = nm.addItem(new NativeMenuItem("Shuffle"));
				shuffleMenuItem.keyEquivalent = "s";
				shuffleMenuItem.keyEquivalentModifiers = [];
				shuffleMenuItem.addEventListener(Event.SELECT, onShuffle);
				
			nm.addItem(new NativeMenuItem("", true));
			
			muteMenuItem = nm.addItem(new NativeMenuItem("Mute"));
				muteMenuItem.keyEquivalent = "end";
				muteMenuItem.addEventListener(Event.SELECT, onMute);
			return nm;
		}
		
		private function createControlMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			nm.addSubmenu(createAspectMenu(), "Maintain aspect ratio");
			growMenuItem = nm.addItem(new NativeMenuItem("Grow Screen"));
			growMenuItem.keyEquivalent = "=";
			growMenuItem.addEventListener(Event.SELECT, onGrow);
			shrinkMenuItem = nm.addItem(new NativeMenuItem("Shrink Screen"));
			shrinkMenuItem.keyEquivalent = "-";
			shrinkMenuItem.addEventListener(Event.SELECT, onShrink);
			nm.addItem(new NativeMenuItem("", true));
			seeThruMenuItem = nm.addItem(new NativeMenuItem("See-thru window"));
			seeThruMenuItem.keyEquivalent = "a";
			seeThruMenuItem.addEventListener(Event.SELECT, onSeeThru);
			alwaysOnTopMenuItem = nm.addItem(new NativeMenuItem("Always on top"));
			alwaysOnTopMenuItem.keyEquivalent = "t";
			alwaysOnTopMenuItem.addEventListener(Event.SELECT, onAlwaysTop);
			alwaysOnTopPlayingMenuItem = nm.addItem(new NativeMenuItem("Always on top while playing"));
			alwaysOnTopPlayingMenuItem.keyEquivalent = "t";
			alwaysOnTopPlayingMenuItem.checked = true;
			alwaysOnTopPlayingMenuItem.addEventListener(Event.SELECT, onAlwaysTopPlaying);
			return nm;
		}
		
		private function createAspectMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			ratioOriginalMenuItem = nm.addItem(new NativeMenuItem("Original (0)"));
			ratioOriginalMenuItem.keyEquivalent = "tab";
			ratioTVMenuItem = nm.addItem(new NativeMenuItem("TV 4:3 (1)"));
			ratioWideMenuItem = nm.addItem(new NativeMenuItem("Wide 16:9 (2)"));
			ratioDesktopMenuItem = nm.addItem(new NativeMenuItem("Same with Desktop (3)"));
			ratioCustomMenuItem = nm.addItem(new NativeMenuItem("Custom aspect ratio"));
			nm.addItem(new NativeMenuItem("", true));
			ratioFreeMenuItem = nm.addItem(new NativeMenuItem("Free ratio"));
			return nm;
		}
		
		private function createVideoMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			brightenDownMenuItem = nm.addItem(new NativeMenuItem("Brightness Down"));
				brightenDownMenuItem.keyEquivalent = "pgdn";
				brightenDownMenuItem.addEventListener(Event.SELECT, onBrighten);
			brightenUpMenuItem = nm.addItem(new NativeMenuItem("Brightness Up"));
				brightenUpMenuItem.keyEquivalent = "pgup";
				brightenUpMenuItem.addEventListener(Event.SELECT, onBrighten);
			
			nm.addItem(new NativeMenuItem("", true));
			
			negativeMenuItem = nm.addItem(new NativeMenuItem("Negative"));
				negativeMenuItem.keyEquivalent = "f1";
				negativeMenuItem.addEventListener(Event.SELECT, onInvert);
			softenMenuItem = nm.addItem(new NativeMenuItem("Soften"));
				softenMenuItem.keyEquivalent = "f2";
				softenMenuItem.addEventListener(Event.SELECT, onSoften);
			sharpenMenuItem = nm.addItem(new NativeMenuItem("Sharpen"));
				sharpenMenuItem.keyEquivalent = "f3";
				sharpenMenuItem.addEventListener(Event.SELECT, onSharpen);
			flipMenuItem = nm.addItem(new NativeMenuItem("Flip (troubleshoot)"));
				flipMenuItem.keyEquivalent = "f11";
				flipMenuItem.addEventListener(Event.SELECT, onFlip);
			
			nm.addItem(new NativeMenuItem("", true));
			
			discardVideoFiltersMenuItem = nm.addItem(new NativeMenuItem("Discard settings"));
				discardVideoFiltersMenuItem.keyEquivalent = "bksp";
				discardVideoFiltersMenuItem.addEventListener(Event.SELECT, onResetVideo);
			
			return nm;
		}
		
		private function createAudioMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			smallerVolMenuItem = nm.addItem(new NativeMenuItem("Make it Smaller"));
				smallerVolMenuItem.keyEquivalent = "PGDN";
				smallerVolMenuItem.keyEquivalentModifiers = [];
				smallerVolMenuItem.addEventListener(Event.SELECT, onVolume);
			louderVolMenuItem = nm.addItem(new NativeMenuItem("Make it Louder"));
				louderVolMenuItem.keyEquivalent = "PGUP";
				louderVolMenuItem.keyEquivalentModifiers = [];
				louderVolMenuItem.addEventListener(Event.SELECT, onVolume);
			
			nm.addItem(new NativeMenuItem("", true));
			
			swapChannelsMenuItem = nm.addItem(new NativeMenuItem("Swap channels"));
				swapChannelsMenuItem.enabled = false;
				swapChannelsMenuItem.keyEquivalent = "F11";
				swapChannelsMenuItem.keyEquivalentModifiers = [];
			
			nm.addItem(new NativeMenuItem("", true));
			
			discardAudioFiltersMenuItem = nm.addItem(new NativeMenuItem("Discard settings"));
				discardAudioFiltersMenuItem.enabled = false;
				discardAudioFiltersMenuItem.keyEquivalent = "BKSP";
				discardAudioFiltersMenuItem.keyEquivalentModifiers = [];
			
			return nm;
		}
		
		private function createContextMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			openMenuItem = nm.addItem(new NativeMenuItem("Open..."));
				openMenuItem.keyEquivalent = "o";
				openMenuItem.addEventListener(Event.SELECT, onOpenItem);
				openMenuItem.mnemonicIndex = 0;
			closeMenuItem = nm.addItem(new NativeMenuItem("Close"));
				closeMenuItem.keyEquivalent = "w";
				closeMenuItem.addEventListener(Event.SELECT, onCloseItem);
			saveAsMenuItem = nm.addItem(new NativeMenuItem("Save As..."));
				saveAsMenuItem.keyEquivalent = "S";
				saveAsMenuItem.mnemonicIndex = 3;
				saveAsMenuItem.addEventListener(Event.SELECT, onSaveItem);
			saveSSMenuItem = nm.addItem(new NativeMenuItem("Save ScreenShot..."));
				saveSSMenuItem.keyEquivalent = "s";
				saveSSMenuItem.addEventListener(Event.SELECT, onSaveSS);
			infoMenuItem = nm.addItem(new NativeMenuItem("File Info"));
				infoMenuItem.keyEquivalent = "i";
				infoMenuItem.addEventListener(Event.SELECT, onMetaData);
			
			nm.addItem(new NativeMenuItem("", true));
			
			nm.addSubmenu(createPlaybackMenu(), "Playback");
			nm.addSubmenu(createControlMenu(), "Control options");
			nm.addSubmenu(createVideoMenu(), "Video filters");
			nm.addSubmenu(createAudioMenu(), "Audio filters");
			
			nm.addItem(new NativeMenuItem("", true));
			
			maintainSizeMenuItem = nm.addItem(new NativeMenuItem("Maintain size"));
				maintainSizeMenuItem.keyEquivalent = "`";
				maintainSizeMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				maintainSizeMenuItem.addEventListener(Event.SELECT, onMaintainSize);
			halfSizeMenuItem = nm.addItem(new NativeMenuItem("Half size"));
				halfSizeMenuItem.keyEquivalent = "1";
				halfSizeMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				halfSizeMenuItem.addEventListener(Event.SELECT, onChangeSize);
			normalSizeMenuItem = nm.addItem(new NativeMenuItem("Normal size"));
				normalSizeMenuItem.keyEquivalent = "2";
				normalSizeMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				normalSizeMenuItem.addEventListener(Event.SELECT, onChangeSize);
				normalSizeMenuItem.checked = true;
			doubleSizeMenuItem = nm.addItem(new NativeMenuItem("Double size"));
				doubleSizeMenuItem.keyEquivalent = "3";
				doubleSizeMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				doubleSizeMenuItem.addEventListener(Event.SELECT, onChangeSize);
			fitToScreenMenuItem = nm.addItem(new NativeMenuItem("Fit to Screen"));
				fitToScreenMenuItem.keyEquivalent = "4";
				fitToScreenMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				fitToScreenMenuItem.addEventListener(Event.SELECT, onChangeSize);
			fullScreenMenuItem = nm.addItem(new NativeMenuItem("FullScreen mode"));
				fullScreenMenuItem.keyEquivalent = "enter";
				fullScreenMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				fullScreenMenuItem.mnemonicIndex = 0;
				fullScreenMenuItem.addEventListener(Event.SELECT, onFullScreen);
			maximizedMenuItem = nm.addItem(new NativeMenuItem("Maximized mode"));
				maximizedMenuItem.keyEquivalent = "enter";
				maximizedMenuItem.mnemonicIndex = 8;
				maximizedMenuItem.addEventListener(Event.SELECT, onMaximized);
			arrSizeModes = [halfSizeMenuItem, normalSizeMenuItem, doubleSizeMenuItem, fitToScreenMenuItem];
			
			nm.addItem(new NativeMenuItem("", true));
			
			exitMenuItem = nm.addItem(new NativeMenuItem("Exit"));
				exitMenuItem.keyEquivalent = "f4";
				exitMenuItem.mnemonicIndex = 1;
				exitMenuItem.keyEquivalentModifiers = [Keyboard.ALTERNATE];
				exitMenuItem.addEventListener(Event.SELECT, onExit);
			var versionMenuItem:NativeMenuItem = nm.addItem(new NativeMenuItem("Sideshow - v" + VERSION));
				versionMenuItem.addEventListener(Event.SELECT, onVersion);
			
			return nm;
		}
		
		private function onVersion(e:Event):void {
			aboutWin = new AboutWindow();
			aboutWin.activate();
		}
		
		private function dragHandler(e:NativeDragEvent):void {
			switch(e.type) {
				case NativeDragEvent.NATIVE_DRAG_ENTER :
					var cb:Clipboard = e.clipboard;
					if(cb.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
						NativeDragManager.dropAction = NativeDragActions.LINK;
						NativeDragManager.acceptDragDrop(sprHit);
					} else {
						trace("Unrecognized format");
					}
					break;
				case NativeDragEvent.NATIVE_DRAG_DROP :
					var arrFiles:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_ONLY) as Array;
					fileCurrent = arrFiles[0];
					header.title = fileCurrent.name;
					openFile(fileCurrent.url);
					
					for (var i:String in arrFiles) {
						if (i == "0") continue;
						tempo.addItem( { url:arrFiles[i].url } );
					}
					break;
			}
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
		
		private function hideError():void {
			TweenLite.to(txtError, .5, { alpha:0 } );
		}
		
		private function hideFrame():void {
			TweenLite.to(controls, .5, { alpha:0 } );
			TweenLite.to(header, .5, { alpha:0 } );
		}
		
		private function initPlayList():void {
			plWin = new PlaylistWindow();
			plWin.visible = false;
			
			plWin.addEventListener("openFile", playlistHandler);
			plWin.addEventListener("openDir", playlistHandler);
			plWin.addEventListener("openURL", playlistHandler);
			plWin.addEventListener("openList", playlistHandler);
			plWin.addEventListener("playFile", playlistHandler);
			plWin.addEventListener("deleteFile", playlistHandler);
		}
		
		private function onAlwaysTop(e:Event):void {
			alwaysOnTopMenuItem.checked = !alwaysOnTopMenuItem.checked;
			alwaysOnTopPlayingMenuItem.checked = false;
			isOnTopWhilePlaying = false;
			toggleOnTop(alwaysOnTopMenuItem.checked);
		}
		
		private function onAlwaysTopPlaying(e:Event):void {
			alwaysOnTopPlayingMenuItem.checked = !alwaysOnTopPlayingMenuItem.checked;
			isOnTopWhilePlaying = alwaysOnTopPlayingMenuItem.checked;
			alwaysOnTopMenuItem.checked = false;
			toggleOnTop(false);
		}
		
		private function onBrighten(e:Event = null):void {
			var dir:int = (e.target == brightenUpMenuItem) ? 1 : -1;
			brightnessAmount += (BRIGHT_SIZE * dir);
			brighten(brightnessAmount);
		}
		
		private function onMaintainSize(e:Event):void {
			var newW:Number;
			var newH:Number;
			var xRatio:Number = this.width / origVidW;
			var yRatio:Number = this.height / origVidH;
			if (xRatio > yRatio) {
				// Scale by width
				newW = this.width;
				newH = xRatio * origVidH;
			} else {
				// Scale by height
				newW = yRatio * origVidW;
				newH = this.height;
			}
			updateDimensions(newW, newH);
			//maintainSizeMenuItem.checked = true;
		}
		
		private function onChangeSize(e:Event):void {
			var item:NativeMenuItem = e.target as NativeMenuItem;
			for (var i:String in arrSizeModes) {
				arrSizeModes[i].checked = false;
			}
			
			switch(item) {
				case halfSizeMenuItem :
					setHalfSize();
					halfSizeMenuItem.checked = true;
					break;
				case normalSizeMenuItem :
					setNormalSize();
					normalSizeMenuItem.checked = true;
					break;
				case doubleSizeMenuItem :
					setDoubleSize();
					doubleSizeMenuItem.checked = true;
					break;
				case fitToScreenMenuItem :
					setScreenSize();
					fitToScreenMenuItem.checked = true;
					break;
			}
		}
		
		private function validateVideoSize():void {
			if (halfSizeMenuItem.checked) {
				setHalfSize();
			} else if (normalSizeMenuItem.checked) {
				setNormalSize();
			} else if (doubleSizeMenuItem.checked) {
				setDoubleSize();
			} else if (fitToScreenMenuItem.checked) {
				setScreenSize();
			} else {
				setNormalSize();
			}
		}
		
		private function setHalfSize():void {
			updateDimensions(origVidW / 2, origVidH / 2);
		}
		
		private function setNormalSize():void {
			updateDimensions(origVidW, origVidH);
		}
		
		private function setDoubleSize():void {
			updateDimensions(origVidW * 2, origVidH * 2);
		}
		
		private function setScreenSize():void {
			var pt:Point = NativeWindow.systemMaxSize;
			updateDimensions(pt.x, pt.y);
		}
		
		private function onCloseItem(e:Event):void {
			closeItem();
		}
		
		private function onExit(e:Event):void {
			if (hasFile) {
				TweenLite.to(vidScreen, .5, { alpha:0, onComplete:app.exit} );
				TweenLite.to(tempo, .5, { volume:0} );
			} else {
				TweenLite.to(mcLogo, .5, { alpha:0, onComplete:app.exit} );
			}
			TweenLite.to(sprBack, .5, { alpha:0} );
			hideFrame();
		}
		
		private function onFlip(e:Event = null):void {
			vidScreen.scaleY *= -1;
			vidScreen.y = (vidScreen.scaleY < 0) ? vidScreen.height : 0;
			flipMenuItem.checked = !flipMenuItem.checked;
		}
		
		private function onFullScreen(e:Event):void {
			if (maximizedMenuItem.checked) toggleMaximized();
			toggleFullScreen();
		}
		
		private function onGrow(e:Event):void {
			var ratio:Number;
			var newWidth:Number = this.width + GROW_SIZE;
			var newHeight:Number = this.height + GROW_SIZE;
			if (this.width > this.height) {
				ratio = (newWidth / this.width);
			} else {
				ratio = (newHeight / this.height);
			}
			
			TweenLite.to(this, .5, { width:(this.width * ratio), height:(this.height * ratio) } );
		}
		
		private function onIdle(e:Event):void {
			if (stage.displayState != StageDisplayState.NORMAL) {
				Mouse.hide();
			}
		}
		
		private function onInvert(e:Event=null):void {
			if (negativeMenuItem.checked) {
				removeFilter("negative");
			} else {
				applyFilter(new ColorMatrixFilter(getNegative()), "negative");
			}
			negativeMenuItem.checked = !negativeMenuItem.checked;
		}
		
		private function onInvoke(event:InvokeEvent):void {
			if(event.arguments.length > 0) {
				fileCurrent = new File(event.arguments[0]);
				header.title = fileCurrent.name;
				openFile(fileCurrent.url);
				
				for (var i:String in event.arguments) {
					if (i == "0") continue;
					tempo.addItem( { url:event.arguments[i].path } );
				}
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.SPACE :
					onPlayPause(e);
					break;
				case Keyboard.V :
					onStop(e);
					break;
				case Keyboard.O :
					if (e.ctrlKey) {
						onOpenItem(e);
					}
					break;
				case Keyboard.W :
					if (e.ctrlKey) {
						onCloseItem(e);
					}
					break;
				case Keyboard.I :
					if (e.ctrlKey) {
						onMetaData(e);
					}
					break;
				case Keyboard.BACKQUOTE :
					if (e.altKey) {
						maintainSizeMenuItem.dispatchEvent(new Event(Event.SELECT));
					}
					break;
				case Keyboard.NUMBER_1 :
					if (e.altKey) {
						halfSizeMenuItem.dispatchEvent(new Event(Event.SELECT));
					}
					break;
				case Keyboard.NUMBER_2 :
					if (e.altKey) {
						normalSizeMenuItem.dispatchEvent(new Event(Event.SELECT));
					}
					break;
				case Keyboard.NUMBER_3 :
					if (e.altKey) {
						doubleSizeMenuItem.dispatchEvent(new Event(Event.SELECT));
					}
					break;
				case Keyboard.NUMBER_4 :
					if (e.altKey) {
						fitToScreenMenuItem.dispatchEvent(new Event(Event.SELECT));
					}
					break;
				case Keyboard.ENTER :
					if (e.altKey) {
						//fullScreenMenuItem.dispatchEvent(new Event(Event.SELECT));
						onFullScreen(e);
						/*if (maximizedMenuItem.checked) toggleMaximized();
						stage.displayState = (stage.displayState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
						fullScreenMenuItem.checked = !fullScreenMenuItem.checked;*/
					} else if (e.ctrlKey) {
						onMaximized(e);
					}
					break;
				case Keyboard.LEFT :
					if (e.shiftKey) {
						tempo.seekRelative(-30);
					} else if(e.ctrlKey) {
						tempo.seekRelative(-60);
					}
					break;
				case Keyboard.RIGHT :
					if (e.shiftKey) {
						tempo.seekRelative(30);
					} else if(e.ctrlKey) {
						tempo.seekRelative(60);
					}
					break;
				case Keyboard.HOME :
					if (e.ctrlKey) {
						onRewind();
					}
					break;
				case Keyboard.R :
					onRepeat(e);
					break;
				case Keyboard.S :
					if (e.ctrlKey) {
						if (e.shiftKey) {
							onSaveItem(e);
						} else {
							onSaveSS(e);
						}
					} else {
						onShuffle(e);
					}
					break;
				case Keyboard.END :
					if (e.ctrlKey) {
						onMute(e);
					}
					break;
				case Keyboard.EQUAL :
					if (e.ctrlKey) {
						onGrow(e);
					}
					break;
				case Keyboard.MINUS :
					if (e.ctrlKey) {
						onShrink(e);
					}
					break;
				case Keyboard.A :
					if (e.ctrlKey) {
						onSeeThru(e);
					}
					break;
				case Keyboard.T :
					if (e.ctrlKey) {
						// cycle through
						//onAlwaysTop
						//onAlwaysTopPlaying
					}
					break;
				case Keyboard.PAGE_DOWN :
					if (e.ctrlKey) {
						brightnessAmount += (BRIGHT_SIZE * -1);
						brighten(brightnessAmount);
					} else if (e.shiftKey) {
						setVolume( -1);
					}
					break;
				case Keyboard.PAGE_UP :
					if (e.ctrlKey) {
						brightnessAmount += BRIGHT_SIZE;
						brighten(brightnessAmount);
					} else if (e.shiftKey) {
						setVolume(1);
					}
					break;
				case Keyboard.F1 :
					if (e.ctrlKey) {
						onInvert(e);
					}
					break;
				case Keyboard.F2 :
					if (e.ctrlKey) {
						onSoften(e);
					}
					break;
				case Keyboard.F3 :
					if (e.ctrlKey) {
						onSharpen(e);
					}
					break;
				case Keyboard.F4 :
					if (e.altKey) {
						onExit(e);
					}
					break;
				case Keyboard.F11 :
					if (e.ctrlKey) {
						onFlip(e);
					}
					break;
				case Keyboard.BACKSPACE :
					if (e.ctrlKey) {
						onResetVideo(e);
					}
					break;
			}
		}
		
		private function onMaximized(e:Event):void {
			if (fullScreenMenuItem.checked) toggleFullScreen();
			toggleMaximized();
		}
		
		private function onMetaData(e:Event):void {
			metaWin = new MetaDataWindow();
			metaWin.setMessage(fileCurrent.name, tempo.getMetaData());
			metaWin.activate();
		}
		
		private function onMouseDown(e:Event):void {
			if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE)	{
				startResize(NativeWindowResize.TOP_LEFT);
			} else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE) {
				startResize(NativeWindowResize.TOP_RIGHT);
			} else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE) {
				startResize(NativeWindowResize.BOTTOM_LEFT);
			} else if (stage.mouseX <= this.width && stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseY <= this.height && stage.mouseY >= this.height - GRIPPER_SIZE) {
				startResize(NativeWindowResize.BOTTOM_RIGHT);
			} else if (stage.mouseX >= 0 && stage.mouseX <= GRIPPER_SIZE) {
				startResize(NativeWindowResize.LEFT);
			} else if (stage.mouseX >= this.width - GRIPPER_SIZE && stage.mouseX <= this.width) {
				startResize(NativeWindowResize.RIGHT);
			} else if (stage.mouseY >= 0 && stage.mouseY <= GRIPPER_SIZE) {
				startResize(NativeWindowResize.TOP);
			} else if (stage.mouseY >= this.height - GRIPPER_SIZE && stage.mouseY <= this.height) {
				startResize(NativeWindowResize.BOTTOM);
			} else {
				startMove();
			}
		}
		
		private function onMouseMove(e:MouseEvent):void {
			Mouse.show();
		}
		
		private function onEnterFrame(e:Event):void {
			if (!controls.hitTestPoint(stage.mouseX, stage.mouseY) && !header.hitTestPoint(stage.mouseX, stage.mouseY)) {
				hideFrame();
			}
		}
		
		private function onMouseLeaveStage(e:Event):void {
			hideFrame();
		}
		
		private function onMouseDouble(e:MouseEvent):void {
			toggleFullScreen();
		}
		
		private function onMouseWheel(e:MouseEvent):void {
			appAlpha += e.delta / 100
			appAlpha = Math.max(.1, Math.min(1, appAlpha));
			seeThruMenuItem.checked = (appAlpha < 1) ? true : false;
			updateDisplay();
		}
		
		private function onMute(e:Event):void {
			muteMenuItem.checked = !muteMenuItem.checked;
			tempo.setMute(muteMenuItem.checked);
		}
		
		private function onNextTrack(event:Event):void {
			openItem(tempo.getList().getNext());
		}
		
		private function onOpenItem(e:Event):void {
			fileDir.browseForOpen("Select a video");
		}
		
		private function onPlayPause(e:Event):void {
			tempo.pause(!tempo.isPause);
			if(tempo.isPause) controls.showPlay();
		}
		
		private function onPause(e:Event = null):void {
			controls.showPlay();
			tempo.pause(true);
		}
		
		private function onPlay(e:Event = null):void {
			controls.showPause();
			if (tempo.isPause) {
				tempo.pause(false);
			} else {
				tempo.play();
			}
		}
		
		private function onPlaylist(e:Event):void {
			plWin.activate();
		}
		
		private function onPreviousTrack(event:Event):void {
			openItem(tempo.getList().getPrevious());
		}
		
		private function onRepeat(e:Event):void {
			repeatMenuItem.checked = !repeatMenuItem.checked;
			tempo.repeat = (repeatMenuItem.checked) ? "track" : "none";
		}
		
		private function onResetVideo(e:Event):void {
			brighten(0);
			if (sharpenMenuItem.checked) onSharpen();
			if (softenMenuItem.checked) onSoften();
			if (negativeMenuItem.checked) onInvert();
			if (flipMenuItem.checked) onFlip();
			vidScreen.filters = new Array();
		}
		
		private function onSaveItem(e:Event):void {
			fileSave.browseForSave("Save Media");
		}
		
		private function onSaveSS(e:Event):void {
			bmd = new BitmapData(vidScreen.width, vidScreen.height);
			bmd.draw(vidScreen, vidScreen.transform.matrix);
			onPause();
			if (isOnTopWhilePlaying) toggleOnTop(false);
			fileScreen.browseForSave("Save ScreenShot");
		}
		
		private function onRewind(e:Event = null):void {
			tempo.seekPercent(.01);
		}
		
		private function onSeek(e:Event):void {
			switch(e.target) {
				case back30MenuItem :
					tempo.seekRelative( -30);
					break;
				case forward30MenuItem :
					tempo.seekRelative( 30);
					break;
				case back1MenuItem :
					tempo.seekRelative( -60);
					break;
				case forward1MenuItem :
					tempo.seekRelative( 60);
					break;
				case jumpHeadMenuItem :
					onRewind();
					break;
				case jumpHalfMenuItem :
					tempo.seekPercent(.5);
					break;
				case jumpEndMenuItem :
					tempo.seekPercent(.99);
					break;
			}
		}
		
		private function onSeeThru(e:Event):void {
			seeThruMenuItem.checked = !seeThruMenuItem.checked;
			appAlpha = (seeThruMenuItem.checked) ? .5 : 1;
			updateDisplay();
		}
		
		private function onSelection(e:Event):void {
			var f:File = e.target as File;
			if (f.isDirectory) {
				addMultiple(f.getDirectoryListing());
			} else {
				fileCurrent = f;
				header.title = fileCurrent.name;
				openFile(fileCurrent.url);
			}
		}
		
		private function onSelectionMultiple(event:FileListEvent):void {
			addMultiple(event.files);
		}
		
		private function onSelectionPlayList(event:Event):void {
			var f:File = event.target as File;
			tempo.loadPlayList(f.url);
		}
		
		private function addMultiple(arr:Array):void {
			for (var i:uint = 0; i < arr.length; i++) {
				tempo.addItem( { url:arr[i].url } );
			}
		}
		
		private function onSharpen(e:Event=null):void {
			if (sharpenMenuItem.checked) {
				removeFilter("sharp");
			} else {
				applyFilter(new ConvolutionFilter(3, 3, getSharpness(5), 1), "sharp");
			}
			sharpenMenuItem.checked = !sharpenMenuItem.checked;
		}
		
		private function onShrink(e:Event):void {
			var ratio:Number;
			var newWidth:Number = this.width - GROW_SIZE;
			var newHeight:Number = this.height - GROW_SIZE;
			if (this.width > this.height) {
				ratio = (newWidth / this.width);
			} else {
				ratio = (newHeight / this.height);
			}
			
			TweenLite.to(this, .5, { width:(this.width * ratio), height:(this.height * ratio) } );
		}
		
		private function onShuffle(e:Event):void {
			shuffleMenuItem.checked = !shuffleMenuItem.checked;
			tempo.shuffle = shuffleMenuItem.checked;
		}
		
		private function onSliderSeek(e:Event):void {
			tempo.seekPercent(controls.trackPosition);
		}
		
		private function onSoften(e:Event=null):void {
			if (softenMenuItem.checked) {
				removeFilter("soft");
			} else {
				applyFilter(new ConvolutionFilter(3, 3, getSoftness(1), 5), "soft");
			}
			softenMenuItem.checked = !softenMenuItem.checked;
		}
		
		private function onStop(e:Event):void {
			tempo.stop();
			if (isOnTopWhilePlaying) {
				toggleOnTop(false);
			}
		}
		
		private function onVolume(e:Event):void {
			var dir:int = (e.target == louderVolMenuItem) ? 1 : -1;
			setVolume(dir);
		}
		
		private function onVolumeSeek(e:Event):void {
			tempo.volume = controls.volume;
		}
		
		private function onWindowDisplay(e:NativeWindowDisplayStateEvent):void {
			switch(e.afterDisplayState) {
				case NativeWindowDisplayState.MAXIMIZED :
					maximizedMenuItem.checked = true;
					stage.nativeWindow.visible = true;
					stage.nativeWindow.orderToFront();
					break;
				case NativeWindowDisplayState.MINIMIZED :
					maximizedMenuItem.checked = false;
					stage.nativeWindow.visible = false;
					break;
				case NativeWindowDisplayState.NORMAL :
					stage.nativeWindow.visible = true;
					maximizedMenuItem.checked = false;
					break;
			}
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			if (!isFullScreen) {
				updateDimensions(e.afterBounds.width, e.afterBounds.height);
			}
		}
		
		private function onFullScreenRedraw(event:FullScreenEvent):void {
			fullScreenMenuItem.checked = event.fullScreen;
			if (!event.fullScreen) {
				isFullScreen = false;
				updateDimensions(normalScreenRect.width, normalScreenRect.height);
				this.x = normalScreenRect.x;
				this.y = normalScreenRect.y;
			}
		}
		
		private function openContextMenu(event:MouseEvent):void {
			navContextMenu.display(stage, event.stageX, event.stageY);
		}
		
		private function openFile(path:String):void {
			hideError();
			hasFile = true;
			updateMenu();
			if(fileCurrent.exists) {
				if (validateFormat(fileCurrent)) {
					if (isFullScreen) toggleFullScreen();
					tempo.loadMedia( { url:path } );
					updateDisplay();
				} else {
					showError("format");
					closeItem();
				}
			} else {
				showError("exists");
				closeItem();
			}
		}
		
		private function openItem(o:Object):void {
			fileCurrent = new File(o.url);
			header.title = fileCurrent.name;
			hideError();
			hasFile = true;
			updateMenu();
			if(fileCurrent.exists) {
				if (validateFormat(fileCurrent)) {
					tempo.play(o.index);
					updateDisplay();
				} else {
					showError("format");
					closeItem();
				}
			} else {
				showError("exists");
				closeItem();
			}
		}
		
		private function playlistHandler(event:Event):void {
			switch(event.type) {
				case "openFile" :
					fileDir.browseForOpenMultiple("Select a video");
					break;
				case "openDir" :
					fileDir.browseForDirectory("Select a directory");
					break;
				case "openURL" :
					//fileDir.browseForOpen("Select a directory");
					break;
				case "openList" :
					var allFilter:FileFilter = new FileFilter("All Files", "*.*;");
					var docFilter:FileFilter = new FileFilter("Playlists", "*.b4s;*.pls;*.asx;*.xspf;*.m3u");
					filePL.browseForOpen("Select a playlsit",[allFilter, docFilter]);
					break;
				case "playFile" :
					openItem({url:plWin.currentItem.URL, index:plWin.currentItem.Index});
					break;
				case "deleteFile" :
					tempo.removeItem(plWin.currentItem.Index);
					break;
			}
		}
		
		private function removeFilter(index:String):void {
			objFilters[index] = undefined;
			updateFilters();
		}
		
		private function saveFile(e:Event):void {
			fileCurrent.copyTo(fileSave);
		}
		
		private function saveScreenShot(e:Event):void {
			if(e.type == Event.SELECT) {
				var img:ByteArray = PNGEncoder.encode(bmd);
				var stream:FileStream = new FileStream();
				
				// Force PNG extension
				if (fileScreen.extension == null || fileScreen.extension.toLowerCase() != "png") {
					fileScreen.url += ".png";
				}
				stream.openAsync(fileScreen, FileMode.WRITE);
				stream.writeBytes(img);
				stream.close();
			}
			onPlay();
		}
		
		private function setVolume(dir:int):void {
			tempo.volume += .1 * dir;
		}
		
		private function setWindowDisplay(e:Event):void {
			switch(e.target.label) {
				case "Restore" :
					stage.nativeWindow.restore();
					break;
				case "Maximize" :
					stage.nativeWindow.maximize();
					break;
				case "Minimize" :
					stage.nativeWindow.minimize();
					break;
			}
		}
		
		private function showError(type:String):void {
			if (type == "format") {
				txtError.text = "Invalid file format";
			} else  if (type == "exists") {
				txtError.text = "File cannot be found";
			}
			TweenLite.to(txtError, .5, { alpha:1 } );
		}
		
		private function showFrame(e:Event = null):void {
			if(hasFile) {
				TweenLite.to(controls, .5, { autoAlpha:1 } );
				TweenLite.to(header, .5, { autoAlpha:1 } );
			} else {
				hideFrame();
			}
		}
		
		private function tempoHandler(e:Event):void {
			switch(e.type) {
				case TempoLite.PLAY_START :
					if (fileCurrent.exists && !isAudio(fileCurrent)) {
						// Sometimes metadata doesn't always fire
						origVidW = vidScreen.videoWidth;
						origVidH = vidScreen.videoHeight;
						validateVideoSize();
					} else {
						updateDimensions(origW, origH);
					}
					break;
				case TempoLite.PLAY_PROGRESS :
					if (isOnTopWhilePlaying) toggleOnTop(true);
					if (tempo.isPause) {
						controls.showPlay();
					} else {
						controls.showPause();
					}
					controls.trackPosition = tempo.getCurrentPercent() / 100;
					header.time = tempo.getTimeCurrent() + "/" + tempo.getTimeTotal();
					break;
				case TempoLite.PLAY_COMPLETE :
					if (isOnTopWhilePlaying) toggleOnTop(false);
					onRewind();
					tempo.pause(true);
					controls.showPlay();
					controls.trackPosition = 0;
					break;
				case TempoLite.LOAD_START :
					//
					break;
				case TempoLite.VIDEO_METADATA :
					var o:Object = tempo.getMetaData();
					origVidW = o.width || vidScreen.videoWidth;
					origVidH = o.height || vidScreen.videoHeight;
					validateVideoSize();
					plWin.updateList(tempo.getList());
					break;
				case TempoLite.AUDIO_METADATA :
					plWin.updateList(tempo.getList());
					break;
				case TempoLite.REFRESH_PLAYLIST :
					plWin.updateList(tempo.getList());
					break;
				case TempoLite.NEW_PLAYLIST :
					plWin.updateList(tempo.getList());
					break;
				case TempoLite.CHANGE :
					if (isOnTopWhilePlaying) toggleOnTop(false);
					break;
			}
		}
		
		private function toggleFullScreen():void {
			if (hasFile) {
				if (stage.displayState == StageDisplayState.NORMAL) {
					//var fullScreenRect:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight); // Were not returning values
					var fullScreenRect:Rectangle = new Rectangle(0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY);
					var ratio:Number = (origVidW > origVidH) ? (origVidW / fullScreenRect.width) : (origVidH / fullScreenRect.height);
					fullScreenRect.width *= ratio;
					fullScreenRect.height *= ratio;
					
					isFullScreen = true;
					normalScreenRect = new Rectangle(this.x, this.y, this.width, this.height);
					updateDimensions(fullScreenRect.width, fullScreenRect.height, true);
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				} else {
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		private function toggleMaximized():void {
			if (maximizedMenuItem.checked) {
				stage.nativeWindow.restore();
			} else {
				stage.nativeWindow.maximize();
			}
		}
		
		private function toggleOnTop(isOnTop:Boolean):void {
			if(!stage.nativeWindow.closed) stage.nativeWindow.alwaysInFront = isOnTop;
		}
		
		private function updateDimensions(w:int, h:int, isFull:Boolean = false):void {
			sprHit.graphics.clear();
			sprHit.graphics.beginFill(0xFFFFFF, 0);
			sprHit.graphics.drawRect(0, 0, w, h);
			sprHit.graphics.endFill();
			
			mcLogo.width = w - 1;
			mcLogo.height = h - 1;
			
			sprBack.width = w;
			sprBack.height = h;
			
			if (isFull) {
				var vidAspectRatio:Number = w / h;
				var origAspectRatio:Number = (origVidW / origVidH);
				
				if (origAspectRatio != vidAspectRatio) {
					if (vidAspectRatio < origAspectRatio) {
						vidScreen.width = w;
						vidScreen.height = h / origAspectRatio;
						vidScreen.y -= ((vidScreen.height - h) / 2);
					} else if (origAspectRatio > vidAspectRatio) {
						vidScreen.width = w / origAspectRatio;
						vidScreen.height = h;
						vidScreen.x -= ((vidScreen.width - w) / 2);
					}
				}
			} else {
				vidScreen.x = 0;
				vidScreen.y = 0;
				vidScreen.width = w;
				vidScreen.height = h;
			}
			
			header.setWidth(w);
			controls.setWidth(w - (GRIPPER_SIZE * 2));
			controls.y = h - (controls.height + GRIPPER_SIZE);
			
			this.width = w;
			this.height = h;
			
			stage.fullScreenSourceRect = new Rectangle(0, 0, this.width, this.height);
		}
		
		private function updateDisplay():void {
			if (hasFile) {
				if(fileCurrent.exists) {
					if (validateFormat(fileCurrent)) {
						if (!isAudio(fileCurrent)) {
							TweenLite.to(vidScreen, .5, { alpha:appAlpha } );
							TweenLite.to(sprBack, .5, { alpha:appAlpha } );
							TweenLite.to(mcLogo, .5, { alpha:0 } );
						} else {
							TweenLite.to(vidScreen, .5, { alpha:0 } );
							TweenLite.to(sprBack, .5, { alpha:0 } );
							TweenLite.to(mcLogo, .5, { alpha:appAlpha } );
							updateDimensions(origW, origH);
						}
					} else {
						showError("format");
					}
				} else {
					showError("exists");
				}
			} else {
				TweenLite.to(vidScreen, .5, { alpha:0 } );
				TweenLite.to(sprBack, .5, { alpha:0} );
				TweenLite.to(mcLogo, .5, { alpha:appAlpha } );
			}
		}
		
		private function updateFilters():void {
			var arrFilters:Array = new Array();
			for (var i:String in objFilters) {
				if (objFilters[i] != undefined) {
					arrFilters.push(objFilters[i]);
				}
			}
			vidScreen.filters = arrFilters;
		}
		
		private function updateMenu():void {
			infoMenuItem.enabled = hasFile;
			saveAsMenuItem.enabled = hasFile;
			saveSSMenuItem.enabled = hasFile;
			fullScreenMenuItem.enabled = hasFile;
			maximizedMenuItem.enabled = hasFile;
			stopMenuItem.enabled = hasFile;
			shuffleMenuItem.enabled = hasFile;
			nextTrackMenuItem.enabled = hasFile;
			prevTrackMenuItem.enabled = hasFile;
			
			if (hasFile) {
				header.visible = true;
				controls.visible = true;
			} else {
				TweenLite.to(controls, .5, { autoAlpha:0 } );
				TweenLite.to(header, .5, { autoAlpha:0 } );
			}
		}
		
		private function validateFormat(f:File):Boolean {
			if(f.exists) {
				switch(f.extension) {
					case "flv" :
					case "mp4" :
					case "m4v" :
					case "3gp" :
					case "mov" :
					case "f4v" : 
					case "f4p" :
					case "f4b" :
						return true;
						break;
					case "mp3" :
					case "m4a" :
					case "f4a" :
						return true;
						break;
					default :
						return false;
				}
			} else {
				return false;
			}
		}
		
		private function isAudio(f:File):Boolean {
			if(f && f.exists) {
				switch(f.extension) {
					case "flv" :
					case "mp4" :
					case "m4v" :
					case "3gp" :
					case "mov" :
					case "f4v" : 
					case "f4p" :
					case "f4b" :
						return false;
						break;
					case "mp3" :
					case "m4a" :
					case "f4a" :
						return true;
						break;
					default :
						return false;
				}
			} else {
				return false;
			}
		}
	}
}