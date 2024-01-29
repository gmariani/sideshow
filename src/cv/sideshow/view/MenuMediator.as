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
	
	import cv.sideshow.Main;
	
	import flash.geom.Rectangle;
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
	
	public class MenuMediator {
		
		private var navContextMenu:NativeMenu;
		private var rootContextMenu:NativeMenu;
		private var dictMenuItems:Dictionary = new Dictionary();
		private var app:NativeApplication = NativeApplication.nativeApplication;
		private var win:NativeWindow;
		
		public function MenuMediator(stageRef:Stage) {
			win = stageRef.nativeWindow;
			
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
			
			stageRef.addEventListener(KeyboardEvent.KEY_DOWN, stageHandler);
			win.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowDisplay);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
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
				Main.sendNotification(Main.SET_SIZE, { multiplier:0.5 } );
			} else if (dictMenuItems["Normal size"].checked) {
				Main.sendNotification(Main.SET_SIZE, { multiplier:1 } );
			} else if (dictMenuItems["Double size"].checked) {
				Main.sendNotification(Main.SET_SIZE, { multiplier:2 } );
			} else {
				Main.sendNotification(Main.SET_SIZE, { multiplier:1 } );
			}
		}
		
		public function updateBrightness(brightnessAmount:int):void {
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
		}
		
		/* TODO: Make it so it actually locks to these ratios */
		public function aspectHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			dictMenuItems["Original (0)"].checked = false;
			dictMenuItems["TV 4:3 (1)"].checked = false;
			dictMenuItems["Wide 16:9 (2)"].checked = false;
			dictMenuItems["Same with Desktop (3)"].checked = false;
			dictMenuItems["Free ratio"].checked = false;
			item.checked = true;
			
			switch(item.label) {
				case "Original (0)" :
					Main.sendNotification(Main.VIDEO_LOCK_RATIO, true);
					Main.sendNotification(Main.VIDEO_ASPECT_RATIO);
					break;
				case "TV 4:3 (1)" :
					Main.sendNotification(Main.VIDEO_LOCK_RATIO, true);
					Main.sendNotification(Main.VIDEO_ASPECT_RATIO, { width:4, height:3 } );
					break;
				case "Wide 16:9 (2)" :
					Main.sendNotification(Main.VIDEO_LOCK_RATIO, true);
					Main.sendNotification(Main.VIDEO_ASPECT_RATIO, { width:16, height:9 } );
					break;
				case "Same with Desktop (3)" :
					var bnds:Rectangle = getCurrentScreen().visibleBounds;
					Main.sendNotification(Main.VIDEO_LOCK_RATIO, true);
					Main.sendNotification(Main.VIDEO_ASPECT_RATIO, { width:bnds.width, height:bnds.height } );
					break;
				case "Custom aspect ratio" :
					// Here to control checks
					break;
				case "Free ratio" :
					Main.sendNotification(Main.VIDEO_LOCK_RATIO, false);
					break;
			}			
		}
		
		public function show(stageRef:Stage, stageX:Number, stageY:Number):void {
			navContextMenu.display(stageRef, stageX, stageY);
		}
		
		public function setSaveAs(bool:Boolean):void {
			dictMenuItems["Save As..."].enabled = bool;
		}
		
		public function setFullScreenMode(bool:Boolean):void {
			dictMenuItems["FullScreen mode"].checked = bool;
		}
		
		public function setMute(bool:Boolean):void {
			dictMenuItems["Mute"].checked = bool;
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
			addItem(nm, "Half size", sizeHandler, "1", [Keyboard.ALTERNATE]);
			addItem(nm, "Normal size", sizeHandler, "2", [Keyboard.ALTERNATE], -1, true);
			addItem(nm, "Double size", sizeHandler, "3", [Keyboard.ALTERNATE]);
			addItem(nm, "FullScreen mode", contextHandler, "enter", [Keyboard.ALTERNATE], 0);
			addItem(nm, "Maximized mode", contextHandler, "enter", null, 8);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Exit", contextHandler, "f4", [Keyboard.ALTERNATE], 1);
			addItem(nm, "Sideshow - v" + Main.VERSION, contextHandler);
			
			return nm;
		}
		
		private function createControlMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			nm.addSubmenu(createAspectMenu(), "Maintain aspect ratio");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Grow Screen", controlHandler, "=");
			addItem(nm, "Shrink Screen", controlHandler, "-");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "See-thru window", controlHandler, "a");
			addItem(nm, "Always on top", controlHandler, "t");
			addItem(nm, "Always on top while playing", controlHandler, "t", null, -1, true);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Logo Bounce Effect", controlHandler, "", null, -1, true);
			
			return nm;
		}
		
		private function createPlaybackMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Play/Pause", playbackHandler, "space", []);
			addItem(nm, "Stop", playbackHandler, "v", []);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Previous Track", playbackHandler, "pgup", []);
			addItem(nm, "Next Track", playbackHandler, "pgdn", []);
			addItem(nm, "Simple Playlist", playbackHandler);
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Rewind 30 Seconds", playbackHandler, "left", [Keyboard.SHIFT]);
			addItem(nm, "Forward 30 Seconds", playbackHandler, "right", [Keyboard.SHIFT]);
			addItem(nm, "Rewind 1 Minute", playbackHandler, "left", [Keyboard.CONTROL]);
			addItem(nm, "Forward 1 Minute", playbackHandler, "right", [Keyboard.CONTROL]);
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
			menu.addItem(new NativeMenuItem("", true));
			menu.addSubmenu(navContextMenu, "SideShow Menu");
			menu.addItem(new NativeMenuItem("", true));
			addItem(menu, "Exit", rootHandler);
			
			return menu;
		}
		
		private function createVideoMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			
			addItem(nm, "Brightness Down", videoHandler, "pgdn");
			addItem(nm, "Brightness Up", videoHandler, "pgup");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Negative", videoHandler, "f1");
			addItem(nm, "Soften", videoHandler, "f2");
			addItem(nm, "Sharpen", videoHandler, "f3");
			addItem(nm, "Scanlines", videoHandler, "f8");
			addItem(nm, "Flip", videoHandler, "f11");
			nm.addItem(new NativeMenuItem("", true));
			addItem(nm, "Discard Settings", videoHandler, "bksp");
			
			return nm;
		}
		
		private function customHandler(e:Event):void {
			Main.sendNotification(Main.CUSTOM_SHOW);
		}
		
		private function getCurrentScreen():Screen {
			return Screen.getScreensForRectangle(win.bounds)[0];
		}
		
		private function audioHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Make it Smaller" :
				case "Make it Louder" :
					var dir:int = (item == dictMenuItems["Make it Louder"]) ? 1 : -1;
					Main.sendNotification(Main.CONTROL_VOLUME_INCREMENT, dir);
					break;
				case "Swap channels" :
					if (item.checked) {
						Main.sendNotification(Main.CONTROL_SWAP_CHANNELS, false);
					} else {
						Main.sendNotification(Main.CONTROL_SWAP_CHANNELS, true);
					}
					item.checked = !item.checked;
					break;
				case "Discard Settings" :
					Main.sendNotification(Main.CONTROL_VOLUME, 0.5);
					Main.sendNotification(Main.CONTROL_SWAP_CHANNELS, false);
					break;
			}			
		}
		
		private function contextHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Open..." :
					Main.sendNotification(Main.OPEN);
					break;
				case "Close" :
					Main.sendNotification(Main.CLOSE_FILE);
					break;
				case "Save As..." :
					Main.sendNotification(Main.SAVE);
					break;
				case "Save ScreenShot..." :
					Main.sendNotification(Main.SAVE_SS);
					break;
				case "File Info" :
					Main.sendNotification(Main.METADATA_SHOW);
					break;
				case "FullScreen mode" :
					if (dictMenuItems['Maximized mode'].checked) toggleMaximized();
					Main.sendNotification(Main.TOGGLE_FULL);
					break;
				case "Maximized mode" :
					if (dictMenuItems['FullScreen mode'].checked) Main.sendNotification(Main.TOGGLE_FULL);
					toggleMaximized();
					break;
				case "Exit" :
					Main.sendNotification(Main.EXITING);
					break;
				case "Sideshow - v" + Main.VERSION :
					Main.sendNotification(Main.ABOUT_SHOW);
					break;
			}
		}
		
		private function controlHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Logo Bounce Effect" :
					item.checked = !item.checked;
					Main.sendNotification(Main.LOGO_BOUNCE, item.checked);
					break;
				case "Grow Screen" :
					Main.sendNotification(Main.GROW, 1);
					break;
				case "Shrink Screen" :
					Main.sendNotification(Main.GROW, -1);
					break;
				case "See-thru window" :
					item.checked = !item.checked;
					Main.sendNotification(Main.UPDATE, {alpha:(item.checked) ? 0.5 : 1});
					break;
				case "Always on top" :
					item.checked = !item.checked;
					dictMenuItems["Always on top while playing"].checked = false;
					Main.sendNotification(Main.TOGGLE_ON_TOP, {toggle:item.checked, whilePlaying:false});
					break;
				case "Always on top while playing" :
					item.checked = !item.checked;
					dictMenuItems["Always on top"].checked = false;
					Main.sendNotification(Main.TOGGLE_ON_TOP, {toggle:false, whilePlaying:item.checked});
					break;
			}
		}
		
		private function playbackHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Play/Pause" :
					Main.sendNotification(Main.CONTROL_PAUSE_TOGGLE);
					break;
				case "Stop" :
					Main.sendNotification(Main.CONTROL_STOP);
					break;
				case "Previous Track" :
					Main.sendNotification(Main.CONTROL_PREVIOUS);
					break;
				case "Next Track" :
					Main.sendNotification(Main.CONTROL_NEXT);
					break;
				case "Simple Playlist" :
					Main.sendNotification(Main.PLAYLIST_SHOW);
					break;
				case "Rewind 30 Seconds" :
					Main.sendNotification(Main.CONTROL_SEEK_RELATIVE, -30);
					break;
				case "Forward 30 Seconds" :
					Main.sendNotification(Main.CONTROL_SEEK_RELATIVE, 30);
					break;
				case "Rewind 1 Minute" :
					Main.sendNotification(Main.CONTROL_SEEK_RELATIVE, -60);
					break;
				case "Forward 1 Minute" :
					Main.sendNotification(Main.CONTROL_SEEK_RELATIVE, 60);
					break;
				case "Jump to Head" :
					Main.sendNotification(Main.CONTROL_SEEK, 0);
					break;
				case "Jump to Half" :
					Main.sendNotification(Main.CONTROL_SEEK, .5);
					break;
				case "Jump to End" :
					Main.sendNotification(Main.CONTROL_SEEK, 1);
					break;
				case "Repeat" :
					item.checked = !item.checked;
					Main.sendNotification(Main.CONTROL_REPEAT, (item.checked) ? "track" : "none");
					break;
				case "Shuffle" :
					item.checked = !item.checked;
					Main.sendNotification(Main.CONTROL_SHUFFLE, item.checked);
					break;
				case "Mute" :
					item.checked = !item.checked;
					Main.sendNotification(Main.CONTROL_MUTE, item.checked);
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
				case "Exit" :
					Main.sendNotification(Main.EXITING);
					break;
			}
		}
		
		private function sizeHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			dictMenuItems["Half size"].checked = false;
			dictMenuItems["Normal size"].checked = false;
			dictMenuItems["Double size"].checked = false;
			item.checked = true;
			
			switch(item.label) {
				case "Half size" :
					Main.sendNotification(Main.SET_SIZE, { multiplier:0.5 } );
					break;
				case "Normal size" :
					Main.sendNotification(Main.SET_SIZE, { multiplier:1 } );
					break;
				case "Double size" :
					Main.sendNotification(Main.SET_SIZE, { multiplier:2 } );
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
				case Keyboard.NUMBER_1 :
					if (e.altKey) sizeHandler(null, "Half size");
					break;
				case Keyboard.NUMBER_2 :
					if (e.altKey) sizeHandler(null, "Normal size");
					break;
				case Keyboard.NUMBER_3 :
					if (e.altKey) sizeHandler(null, "Double size");
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
					} else {
						playbackHandler(null, "Next Track");
					}
					break;
				case Keyboard.PAGE_UP :
					if (e.ctrlKey) {
						videoHandler(null, "Brightness Up");
					} else if (e.shiftKey) {
						audioHandler(null, "Make it Louder");
					} else {
						playbackHandler(null, "Previous Track");
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
					if (e.ctrlKey) videoHandler(null, "Flip");
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
		
		private function videoHandler(e:Event = null, label:String = ""):void {
			var item:NativeMenuItem = (e) ? e.target as NativeMenuItem : dictMenuItems[label];
			switch(item.label) {
				case "Brightness Down" :
				case "Brightness Up" :
					var dir:int = (item == dictMenuItems["Brightness Up"]) ? 1 : -1;
					Main.sendNotification(Main.VIDEO_BRIGHTEN, dir);
					break;
				case "Negative" :
					item.checked = !item.checked;
					Main.sendNotification(Main.VIDEO_INVERT, item.checked);
					break;
				case "Soften" :
					item.checked = !item.checked;
					Main.sendNotification(Main.VIDEO_SOFTEN, item.checked);
					break;
				case "Sharpen" :
					item.checked = !item.checked;
					Main.sendNotification(Main.VIDEO_SHARPEN, item.checked);
					break;
				case "Scanlines" :
					item.checked = !item.checked;
					Main.sendNotification(Main.VIDEO_SCANLINES, item.checked);
					break;
				case "Flip" :
					item.checked = !item.checked;
					Main.sendNotification(Main.VIDEO_FLIP, item.checked);
					break;
				case "Discard Settings" :
					dictMenuItems["Sharpen"].checked = false;
					dictMenuItems["Soften"].checked = false;
					dictMenuItems["Negative"].checked = false;
					dictMenuItems["Flip"].checked = false;
					dictMenuItems["Scanlines"].checked = false;
					Main.sendNotification(Main.VIDEO_RESET);
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