package cv.sideshow.view {
	
	import cv.sideshow.ApplicationFacade;
	import flash.geom.Rectangle;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Stage;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.events.KeyboardEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class MenuMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'MenuMediator';
		
		private var navContextMenu:NativeMenu;
		private var rootContextMenu:NativeMenu;
		private var dictMenuItems:Dictionary = new Dictionary();
		private var app:NativeApplication = NativeApplication.nativeApplication;
		
		public function MenuMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			navContextMenu = createContextMenu();
			rootContextMenu = createRootMenu();
			
			// Mac
			if(NativeApplication.supportsDockIcon){
				DockIcon(app.icon).menu = rootContextMenu;
			}
			
			if (NativeApplication.supportsMenu) {
				app.menu.addSubmenu(rootContextMenu, "SideShow");
			}
			
			// Win
			if(NativeApplication.supportsSystemTrayIcon){
				SystemTrayIcon(app.icon).tooltip = "SideShow";
				SystemTrayIcon(app.icon).menu = rootContextMenu;
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stageHandler);
			win.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowDisplay);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get win():NativeWindow {
			return stage.nativeWindow;
		}
		
		private function get stage():Stage {
			return root.stage;
		}
		
		private function get root():MovieClip {
			return viewComponent as MovieClip;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setSeeThru(value:Boolean):void {
			dictMenuItems["See-thru window"].enabled = value;
		}
		
		public function setHasFile(b:Boolean):void {
			dictMenuItems["File Info"].enabled = b;
			dictMenuItems["Close"].enabled = b;
			dictMenuItems["Save As..."].enabled = false;
			dictMenuItems["Save ScreenShot..."].enabled = b;
			dictMenuItems["FullScreen mode"].enabled = b;
			dictMenuItems["Maximized mode"].enabled = b;
			dictMenuItems["Stop"].enabled = b;
			dictMenuItems["Shuffle"].enabled = b;
			dictMenuItems["Next Track"].enabled = b;
			dictMenuItems["Previous Track"].enabled = b;
		}
		
		public function validateVideo(o:Object):void {
			if (dictMenuItems["Half size"].checked) {
				sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:0.5 } );
			} else if (dictMenuItems["Normal size"].checked) {
				sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:1 } );
			} else if (dictMenuItems["Double size"].checked) {
				sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:2 } );
			} else if (dictMenuItems["Fit to Screen"].checked) {
				var pt:Point = NativeWindow.systemMaxSize;
				sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { width:pt.x, height:pt.y } );
			} else {
				sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:1 } );
			}
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.MENU_SHOW, 
					ApplicationFacade.ON_VIDEO_BRIGHTEN, 
					ApplicationFacade.ON_TOGGLE_FULL,
					ApplicationFacade.SELECT_CUSTOM,
					ApplicationFacade.LOAD_COMPLETE];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.MENU_SHOW :
					var o:Object = note.getBody();
					navContextMenu.display(o.stage, o.stageX, o.stageY);
					break;
				case ApplicationFacade.ON_TOGGLE_FULL :
					dictMenuItems["FullScreen mode"].checked = note.getBody() as Boolean;
					break;
				case ApplicationFacade.ON_VIDEO_BRIGHTEN :
					var brightnessAmount:int = note.getBody() as int;
					if (brightnessAmount > 1) {
						dictMenuItems["Brightness Down"].checked = false;
						dictMenuItems["Brightness Up"].checked = true;
					} else if (brightnessAmount == 0) {
						dictMenuItems["Brightness Down"].checked = false;
						dictMenuItems["Brightness Up"].checked = false;
					} else if (brightnessAmount < 0) {
						dictMenuItems["Brightness Down"].checked = true;
						dictMenuItems["Brightness Up"].checked = false;
					}
					break;
				case ApplicationFacade.SELECT_CUSTOM :
					aspectHandler(null, "Custom aspect ratio");
					break;
				case ApplicationFacade.LOAD_COMPLETE :
					dictMenuItems["Save As..."].enabled = true;
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function addItem(nm:NativeMenu, label:String, func:Function, key:String = "", keyModifier:Array = null, mnemonic:int = -1, checked:Boolean = false):NativeMenuItem {
			var mi:NativeMenuItem = nm.addItem(new NativeMenuItem(label));
			mi.addEventListener(Event.SELECT, func);
			mi.checked = checked;
			if(key != "") mi.keyEquivalent = key;
			if(keyModifier) mi.keyEquivalentModifiers = keyModifier;
			if(mnemonic >= 0) mi.mnemonicIndex = mnemonic;
			if (!dictMenuItems[label]) {
				dictMenuItems[label] = mi;
			} else {
				dictMenuItems[label + "2"] = mi;
			}
			return mi;
		}
		
		private function createAspectMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Original (0)", aspectHandler, "tab");
			addItem(nm, "TV 4:3 (1)", aspectHandler );
			addItem(nm, "Wide 16:9 (2)", aspectHandler );
			addItem(nm, "Same with Desktop (3)", aspectHandler );
			addItem(nm, "Custom aspect ratio", customHandler ); 
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Free ratio", aspectHandler, "", null, -1, true);
			
			return nm;
		}
		
		/* TESTED */
		private function createAudioMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Make it Smaller", audioHandler, "PGDN", []);
			addItem(nm, "Make it Louder", audioHandler, "PGUP", []);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Swap channels", audioHandler, "F11", []);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Discard Settings", audioHandler, "BKSP", []);
			
			return nm;
		}
		
		private function createContextMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Open...", contextHandler, "o", null, 0);
			addItem(nm, "Close", contextHandler, "w");
			addItem(nm, "Save As...", contextHandler, "S", null, 3);
			addItem(nm, "Save ScreenShot...", contextHandler, "s");
			addItem(nm, "File Info", contextHandler, "i");
			nm.addItem(new NativeMenuItem("", true));
			nm.addSubmenu(createPlaybackMenu(), "Playback");
			nm.addSubmenu(createControlMenu(), "Control options");
			nm.addSubmenu(createVideoMenu(), "Video filters");
			nm.addSubmenu(createAudioMenu(), "Audio filters");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Maintain size", contextHandler, "`", [Keyboard.ALTERNATE]);
			addItem(nm, "Half size", sizeHandler, "1", [Keyboard.ALTERNATE]);
			addItem(nm, "Normal size", sizeHandler, "2", [Keyboard.ALTERNATE], -1, true);
			addItem(nm, "Double size", sizeHandler, "3", [Keyboard.ALTERNATE]);
			addItem(nm, "Fit to Screen", sizeHandler, "4", [Keyboard.ALTERNATE]);
			addItem(nm, "FullScreen mode", contextHandler, "enter", [Keyboard.ALTERNATE], 0);
			addItem(nm, "Maximized mode", contextHandler, "ENTER", null, 8);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Exit", contextHandler, "f4", [Keyboard.ALTERNATE], 1);
			addItem(nm, "Sideshow - v" + ApplicationFacade.VERSION, contextHandler);
			
			return nm;
		}
		
		/* TESTED */
		private function createControlMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			nm.addSubmenu(createAspectMenu(), "Maintain aspect ratio");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Grow Screen", controlHandler, "=");
			addItem(nm, "Shrink Screen", controlHandler, "-");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "See-thru window", controlHandler, "a");
			addItem(nm, "Always on top", controlHandler, "T");
			addItem(nm, "Always on top while playing", controlHandler, "T", null, -1, true);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Logo Bounce Effect", controlHandler, "", null, -1, true);
			
			return nm;
		}
		
		private function createPlaybackMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Play/Pause", playbackHandler, "space", []);
			addItem(nm, "Stop", playbackHandler, "v", []);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Previous Track", playbackHandler);
			addItem(nm, "Next Track", playbackHandler);
			addItem(nm, "Simple Playlist", playbackHandler);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Rewind 30 Seconds", playbackHandler, "left", [Keyboard.SHIFT]);
			addItem(nm, "Forward 30 Seconds", playbackHandler, "right", [Keyboard.SHIFT]);
			addItem(nm, "Rewind 1 Minute", playbackHandler, "LEFT", [Keyboard.CONTROL]);
			addItem(nm, "Forward 1 Minute", playbackHandler, "RIGHT", [Keyboard.CONTROL]);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Jump to Head", playbackHandler, "home", [Keyboard.CONTROL]);
			addItem(nm, "Jump to Half", playbackHandler);
			addItem(nm, "Jump to End", playbackHandler);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Repeat", playbackHandler, "r", []);
			addItem(nm, "Shuffle", playbackHandler, "s", []);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Mute", playbackHandler, "end", [Keyboard.CONTROL]);
			
			return nm;
		}
		
		private function createRootMenu():NativeMenu {
			var menu:NativeMenu = new NativeMenu();
			
			addItem(menu, "Restore", rootHandler);
			addItem(menu, "Minimize", rootHandler);
			addItem(menu, "Maximize", rootHandler);
			addItem(menu, "Maximize", rootHandler);
			menu.addItem(new NativeMenuItem("", true));
			menu.addSubmenu(navContextMenu, "SideShow Menu");
			menu.addItem(new NativeMenuItem("", true));
			addItem(menu, "Exit", rootHandler);
			
			return menu;
		}
		
		/* TESTED */
		private function createVideoMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Brightness Down", videoHandler, "pgdn");
			addItem(nm, "Brightness Up", videoHandler, "pgup");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Negative", videoHandler, "f1");
			addItem(nm, "Soften", videoHandler, "f2");
			addItem(nm, "Sharpen", videoHandler, "f3");
			addItem(nm, "Scanlines", videoHandler, "f8");
			addItem(nm, "Flip (troubleshoot)", videoHandler, "f11");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Discard Settings", videoHandler, "bksp");
			
			return nm;
		}
		
		private function customHandler(e:Event):void {
			sendNotification(ApplicationFacade.CUSTOM_SHOW);
		}
		
		private function aspectHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			dictMenuItems["Original (0)"].checked = false;
			dictMenuItems["TV 4:3 (1)"].checked = false;
			dictMenuItems["Wide 16:9 (2)"].checked = false;
			dictMenuItems["Same with Desktop (3)"].checked = false;
			dictMenuItems["Free ratio"].checked = false;
			item.checked = true;
			
			switch(item.label) {
				case "Original (0)" :
					sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, true);
					sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO);
					break;
				case "TV 4:3 (1)" :
					sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, true);
					sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO, { width:4, height:3 } );
					break;
				case "Wide 16:9 (2)" :
					sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, true);
					sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO, { width:16, height:9 } );
					break;
				case "Same with Desktop (3)" :
					var bnds:Rectangle = getCurrentScreen().bounds;
					sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, true);
					sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO, { width:bnds.width, height:bnds.height } );
					break;
				case "Custom aspect ratio" :
					// Here to control checks
					break;
				case "Free ratio" :
					sendNotification(ApplicationFacade.VIDEO_LOCK_RATIO, false);
					break;
			}			
		}
		
		private function getCurrentScreen():Screen {
			return Screen.getScreensForRectangle(win.bounds)[0];
		}
		
		/* TESTED */
		private function audioHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Make it Smaller" :
				case "Make it Louder" :
					var dir:int = (item == dictMenuItems["Make it Louder"]) ? 1 : -1;
					sendNotification(ApplicationFacade.CONTROL_VOLUME_INCREMENT, dir);
					break;
				case "Swap channels" :
					if (item.checked) {
						sendNotification(ApplicationFacade.CONTROL_SWAP_CHANNELS, false);
					} else {
						sendNotification(ApplicationFacade.CONTROL_SWAP_CHANNELS, true);
					}
					item.checked = !item.checked;
					break;
				case "Discard Settings" :
					sendNotification(ApplicationFacade.CONTROL_VOLUME, 0.5);
					sendNotification(ApplicationFacade.CONTROL_SWAP_CHANNELS, false);
					break;
			}			
		}
		
		private function contextHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Open..." :
					sendNotification(ApplicationFacade.OPEN);
					break;
				case "Close" :
					sendNotification(ApplicationFacade.CLOSE_FILE);
					break;
				case "Save As..." :
					sendNotification(ApplicationFacade.SAVE);
					break;
				case "Save ScreenShot..." :
					sendNotification(ApplicationFacade.SAVE_SS);
					break;
				case "File Info" :
					sendNotification(ApplicationFacade.METADATA_SHOW);
					break;
				case "Maintain size" :
					sendNotification(ApplicationFacade.VIDEO_ASPECT_RATIO);
					item.checked = true;
					break;
				case "FullScreen mode" :
					if (item.checked) toggleMaximized();
					sendNotification(ApplicationFacade.TOGGLE_FULL);
					break;
				case "Maximized mode" :
					if (item.checked) sendNotification(ApplicationFacade.TOGGLE_FULL);
					toggleMaximized();
					break;
				case "Exit" :
				case "Exit2" :
					sendNotification(ApplicationFacade.EXITING);
					break;
				case "Sideshow - v" + ApplicationFacade.VERSION :
					sendNotification(ApplicationFacade.ABOUT_SHOW);
					break;
			}
		}
		
		/* TESTED */
		private function controlHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Logo Bounce Effect" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.LOGO_BOUNCE, item.checked);
					break;
				case "Grow Screen" :
					sendNotification(ApplicationFacade.GROW, 1);
					break;
				case "Shrink Screen" :
					sendNotification(ApplicationFacade.GROW, -1);
					break;
				case "See-thru window" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.UPDATE, {alpha:(item.checked) ? .5 : 1});
					break;
				case "Always on top" :
					item.checked = !item.checked;
					dictMenuItems["Always on top while playing"].checked = false;
					sendNotification(ApplicationFacade.TOGGLE_ON_TOP, {toggle:item.checked, whilePlaying:false});
					break;
				case "Always on top while playing" :
					item.checked = !item.checked;
					dictMenuItems["Always on top"].checked = false;
					sendNotification(ApplicationFacade.TOGGLE_ON_TOP, {toggle:false, whilePlaying:item.checked});
					break;
			}
		}
		
		private function playbackHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Play/Pause" :
					sendNotification(ApplicationFacade.CONTROL_PAUSE_TOGGLE);
					break;
				case "Stop" :
					sendNotification(ApplicationFacade.CONTROL_STOP);
					break;
				case "Previous Track" :
					sendNotification(ApplicationFacade.CONTROL_PREVIOUS);
					break;
				case "Next Track" :
					sendNotification(ApplicationFacade.CONTROL_NEXT);
					break;
				case "Simple Playlist" :
					sendNotification(ApplicationFacade.PLAYLIST_SHOW);
					break;
				case "Rewind 30 Seconds" :
					sendNotification(ApplicationFacade.CONTROL_SEEK_RELATIVE, -30);
					break;
				case "Forward 30 Seconds" :
					sendNotification(ApplicationFacade.CONTROL_SEEK_RELATIVE, 30);
					break;
				case "Rewind 1 Minute" :
					sendNotification(ApplicationFacade.CONTROL_SEEK_RELATIVE, -60);
					break;
				case "Forward 1 Minute" :
					sendNotification(ApplicationFacade.CONTROL_SEEK_RELATIVE, 60);
					break;
				case "Jump to Head" :
					sendNotification(ApplicationFacade.CONTROL_SEEK, .01);
					break;
				case "Jump to Half" :
					sendNotification(ApplicationFacade.CONTROL_SEEK, .5);
					break;
				case "Jump to  End" :
					sendNotification(ApplicationFacade.CONTROL_SEEK, .99);
					break;
				case "Repeat" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.CONTROL_REPEAT, (item.checked) ? "track" : "none");
					break;
				case "Shuffle" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.CONTROL_SHUFFLE, item.checked);
					break;
				case "Mute" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.CONTROL_MUTE, item.checked);
					break;
			}
		}
		
		private function rootHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Restore" :
					win.restore();
					break;
				case "Maximize" :
					win.maximize();
					break;
				case "Minimize" :
					win.minimize();
					break;
				case "Close" :
					sendNotification(ApplicationFacade.EXITING);
					break;
			}
		}
		
		private function sizeHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			dictMenuItems["Half size"].checked = false;
			dictMenuItems["Normal size"].checked = false;
			dictMenuItems["Double size"].checked = false;
			dictMenuItems["Fit to Screen"].checked = false;
			item.checked = true;
			
			switch(e.target.label) {
				case "Half size" :
					sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:0.5 } );
					break;
				case "Normal size" :
					sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:1 } );
					break;
				case "Double size" :
					sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { multiplier:2 } );
					break;
				case "Fit to Screen" :
					var pt:Point = NativeWindow.systemMaxSize;
					sendNotification(ApplicationFacade.VIDEO_SET_SIZE, { width:pt.x, height:pt.y } );
					break;
			}
		}
		
		private function stageHandler(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.SPACE :
					playbackHandler(null, "Play/Pause");
					break;
				case Keyboard.V :
					playbackHandler(null, "Stop");
					break;
				case Keyboard.O :
					if (e.ctrlKey) contextHandler(null, "Open...");
					break;
				case Keyboard.W :
					if (e.ctrlKey) contextHandler(null, "Close");
					break;
				case Keyboard.I :
					if (e.ctrlKey) contextHandler(null, "File Info");
					break;
				case Keyboard.BACKQUOTE :
					if (e.altKey) contextHandler(null, "Maintain size");
					break;
				case Keyboard.NUMBER_1 :
					if (e.altKey) sizeHandler(null, "Half size");
					break;
				case Keyboard.NUMBER_2 :
					if (e.altKey) sizeHandler(null, "Normal size");
					break;
				case Keyboard.NUMBER_3 :
					if (e.altKey) sizeHandler(null, "Double size");
					break;
				case Keyboard.NUMBER_4 :
					if (e.altKey) sizeHandler(null, "Fit to Screen");
					break;
				case Keyboard.ENTER :
					if (e.altKey) {
						contextHandler(null, "FullScreen mode");
					} else if (e.ctrlKey) {
						contextHandler(null, "Maximized mode");
					}
					break;
				case Keyboard.LEFT :
					if (e.shiftKey) {
						playbackHandler(null, "Rewind 30 Seconds");
					} else if (e.ctrlKey) {
						playbackHandler(null, "Rewind 1 Minute");
					}
					break;
				case Keyboard.RIGHT :
					if (e.shiftKey) {
						playbackHandler(null, "Forward 30 Seconds");
					} else if (e.ctrlKey) {
						playbackHandler(null, "Forward 1 Minute");
					}
					break;
				case Keyboard.HOME :
					if (e.ctrlKey) playbackHandler(null, "Jump to Head");
					break;
				case Keyboard.R :
					playbackHandler(null, "Repeat");
					break;
				case Keyboard.S :
					if (e.ctrlKey) {
						if (e.shiftKey) {
							contextHandler(null, "Save As...");
						} else {
							contextHandler(null, "Save ScreenShot...");
						}
					} else {
						playbackHandler(null, "Shuffle");
					}
					break;
				case Keyboard.END :
					if (e.ctrlKey) playbackHandler(null, "Mute");
					break;
				case Keyboard.EQUAL :
					if (e.ctrlKey) controlHandler(null, "Grow Screen");
					break;
				case Keyboard.MINUS :
					if (e.ctrlKey) controlHandler(null, "Shrink Screen");
					break;
				case Keyboard.A :
					if (e.ctrlKey) controlHandler(null, "See-thru window");
					break;
				case Keyboard.T :
					if (e.ctrlKey) {
						if (dictMenuItems["Always on top while playing"].checked) {
							controlHandler(null, "Always on top");
						} else {
							controlHandler(null, "Always on top while playing");
						}
					}
					break;
				case Keyboard.PAGE_DOWN :
					if (e.ctrlKey) {
						videoHandler(null, "Brightness Down");
					} else if (e.shiftKey) {
						audioHandler(null, "Make it Smaller");
					}
					break;
				case Keyboard.PAGE_UP :
					if (e.ctrlKey) {
						videoHandler(null, "Brightness Up");
					} else if (e.shiftKey) {
						audioHandler(null, "Make it Louder");
					}
					break;
				case Keyboard.F1 :
					if (e.ctrlKey) videoHandler(null, "Negative");
					break;
				case Keyboard.F2 :
					if (e.ctrlKey) videoHandler(null, "Soften");
					break;
				case Keyboard.F3 :
					if (e.ctrlKey) videoHandler(null, "Sharpen");
					break;
				case Keyboard.F4 :
					if (e.altKey) contextHandler(null, "Exit");
					break;
				case Keyboard.F11 :
					if (e.ctrlKey) videoHandler(null, "Flip (troubleshoot)");
					break;
				case Keyboard.BACKSPACE :
					if (e.ctrlKey) {
						audioHandler(null, "Discard Settings");
					} else {
						videoHandler(null, "Discard Settings");
					}
					break;
			}
		}
		
		/* TESTED */
		private function videoHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Brightness Down" :
				case "Brightness Up" :
					var dir:int = (item == dictMenuItems["Brightness Up"]) ? 1 : -1;
					sendNotification(ApplicationFacade.VIDEO_BRIGHTEN, dir);
					break;
				case "Negative" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.VIDEO_INVERT, item.checked);
					break;
				case "Soften" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.VIDEO_SOFTEN, item.checked);
					break;
				case "Sharpen" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.VIDEO_SHARPEN, item.checked);
					break;
				case "Scanlines" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.VIDEO_SCANLINES, item.checked);
					break;
				case "Flip (troubleshoot)" :
					item.checked = !item.checked;
					sendNotification(ApplicationFacade.VIDEO_FLIP, item.checked);
					break;
				case "Discard Settings" :
					dictMenuItems["Sharpen"].checked = false;
					dictMenuItems["Soften"].checked = false;
					dictMenuItems["Negative"].checked = false;
					dictMenuItems["Flip (troubleshoot)"].checked = false;
					dictMenuItems["Scanlines"].checked = false;
					sendNotification(ApplicationFacade.VIDEO_RESET);
					break;
			}
		}
		
		private function toggleMaximized():void {
			if (dictMenuItems["Maximized mode"].checked) {
				win.restore();
			} else {
				win.maximize();
			}
		}
		
		private function onWindowDisplay(e:NativeWindowDisplayStateEvent):void {
			switch(e.afterDisplayState) {
				case NativeWindowDisplayState.MAXIMIZED :
					dictMenuItems["Maximized mode"].checked = true;
					win.visible = true;
					win.orderToFront();
					break;
				case NativeWindowDisplayState.MINIMIZED :
					dictMenuItems["Maximized mode"].checked = false;
					win.visible = false;
					break;
				case NativeWindowDisplayState.NORMAL :
					win.visible = true;
					dictMenuItems["Maximized mode"].checked = false;
					break;
			}
		}
	}
}