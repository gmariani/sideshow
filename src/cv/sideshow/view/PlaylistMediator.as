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
/**
* TODO: Show download progress on streaming video
*/

package cv.sideshow.view {

	import cv.sideshow.Main;
	import cv.data.PlayList;
	
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.events.ListEvent;
	
	import flash.display.AVM1Movie;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.System;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.KeyboardEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;

	public class PlaylistMediator extends MovieClip {
		
		private var pw:NativeWindow;
		private var fileDir:File = File.desktopDirectory;
		private var filePL:File = File.desktopDirectory;
		private var currentItem:Object;
		private var addFileMenuItem:NativeMenuItem;
		private var addDirMenuItem:NativeMenuItem;
		private var addURLMenuItem:NativeMenuItem;
		private var openPlayListMenuItem:NativeMenuItem;
		private var savePlayListMenuItem:NativeMenuItem;
		private var closeMenuItem:NativeMenuItem;
		private var useHighQuality:Boolean = true;
		
		public function PlaylistMediator() {
			
			fileDir.addEventListener(Event.SELECT, onSelection);
			fileDir.addEventListener(FileListEvent.SELECT_MULTIPLE, onSelectionMultiple);
			
			filePL.addEventListener(Event.SELECT, onSelectionPlayList);
			
			var col:DataGridColumn;
			col = grid.addColumn("Index");
			col.width = 40;
			col = grid.addColumn("Name");
			col.width = 200;
			col = grid.addColumn("Duration");
			col.width = 50;
			col = grid.addColumn("URL");
			col.width = 100;
			grid.addEventListener(Event.CHANGE, onFocusItem);
			grid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onPlayItem);
			grid.addEventListener(KeyboardEvent.KEY_DOWN, onKeysDown);
			grid.allowMultipleSelection = false;
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setURL(url:String, quality:Boolean, fileType:String):void {
			useHighQuality = quality;
			if(url.indexOf("http://www.youtube.com/watch") > -1) {
				getFLVURL(url);
			} else {
				Main.sendNotification(Main.ADD_FILE, { url:url, extOverride:fileType} );
			}
		}
		
		public function show():void {
			if (pw.closed) createWindow();
			pw.activate();
			pw.orderToFront();
			pw.visible = true;
		}
		
		public function updateList(list:PlayList):void {
			grid.removeAll();
			var arr:Array = list.toDataProvider().toArray();
			for (var i:String in arr) {
				grid.addItem( { Index:uint(i), Name:unescape(arr[i].label), Duration:convertTime(arr[i].data.length), URL:arr[i].data.url } );
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = true;
			winArgs.minimizable = true;
			winArgs.resizable = true;
			winArgs.type = NativeWindowType.NORMAL;
			
			pw = new NativeWindow(winArgs);
			pw.title = "Playlist";
			pw.width = 500;
			pw.height = 300;
			pw.addEventListener(Event.CLOSING, closeHandler);
			pw.addEventListener(Event.RESIZE, onWindowResize);
			
			if (NativeApplication.supportsMenu) {
				NativeApplication.nativeApplication.menu.addSubmenuAt(createManageMenu(), 1, "Playlist");
			} else {
				pw.menu = createMenu();
			}
			
			pw.stage.align = StageAlign.TOP_LEFT;
			pw.stage.scaleMode = StageScaleMode.NO_SCALE;
			pw.stage.addChild(this);
		}
		
		private function onSelectionPlayList(event:Event):void {
			var f:File = event.target as File;
			Main.sendNotification(Main.OPEN_PLAYLIST, f.url );
		}
		
		private function onSelection(e:Event):void {
			var f:File = e.target as File;
			if (f.isDirectory) {
				addMultiple(f.getDirectoryListing());
			} else {
				Main.sendNotification(Main.OPEN_FILE, f);
			}
		}
		
		private function onSelectionMultiple(event:FileListEvent):void {
			addMultiple(event.files);
		}
		
		private function addMultiple(arr:Array):void {
			for (var i:uint = 0; i < arr.length; i++) {
				Main.sendNotification(Main.ADD_FILE, { url:arr[i].url } );
			}
		}
		
		private function closeHandler(event:Event):void {
			event.preventDefault();
			pw.visible = false;
		}
		
		private function convertTime(n:Number):String {
			if (n < 0) return "00:00";
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (int(s) < 10) s = "0" + s;
			return m + ":" + s;
		}
		
		private function createMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			nm.addSubmenu(createManageMenu(), "Manage");
			return nm;
		}
		
		private function createManageMenu():NativeMenu {
			var nm:NativeMenu = new NativeMenu();
			addFileMenuItem = nm.addItem(new NativeMenuItem("Add File"));
				addFileMenuItem.addEventListener(Event.SELECT, onAddFile);
			addDirMenuItem = nm.addItem(new NativeMenuItem("Add Directory"));
				addDirMenuItem.addEventListener(Event.SELECT, onAddDir);
			addURLMenuItem = nm.addItem(new NativeMenuItem("Add URL"));
				addURLMenuItem.addEventListener(Event.SELECT, onAddURL);
				
			nm.addItem(new NativeMenuItem("", true));
			
			openPlayListMenuItem = nm.addItem(new NativeMenuItem("Open Playlist..."));
				openPlayListMenuItem.addEventListener(Event.SELECT, onOpen);
			savePlayListMenuItem = nm.addItem(new NativeMenuItem("Save Playlist..."));
				savePlayListMenuItem.enabled = false;
				savePlayListMenuItem.addEventListener(Event.SELECT, onSave);
			
			if (!NativeApplication.supportsMenu) {
				nm.addItem(new NativeMenuItem("", true));
				
				closeMenuItem = nm.addItem(new NativeMenuItem("Close"));
					closeMenuItem.addEventListener(Event.SELECT, onClose);
			}
			
			return nm;
		}
		
		private function onKeysDown(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.DELETE :
					if (currentItem) {
						Main.sendNotification(Main.REMOVE_FILE, currentItem.Index );
					}
					break;
			}
		}
		
		private function onFocusItem(event:Event):void {
			currentItem = grid.selectedItem;
		}
		
		private function onPlayItem(event:ListEvent):void {
			currentItem = event.item;
			Main.sendNotification(Main.OPEN_ITEM, { url:currentItem.URL, index:currentItem.Index } );
		}
		
		private function onAddFile(event:Event):void {
			fileDir.browseForOpenMultiple("Select a video");
		}
		
		private function onAddDir(event:Event):void {
			fileDir.browseForDirectory("Select a directory");
		}
		
		private function onAddURL(event:Event):void {
			Main.sendNotification(Main.URL_SHOW);
		}
		
		 private function getFLVURL(youtubeURL:String):void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, youtubeHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, youtubeHandler, false, 0, true);
			loader.load(new URLRequest(youtubeURL));
		}
		
		private function youtubeHandler(e:Event):void {
			if (e.type == Event.COMPLETE) {
				var loader:URLLoader = e.currentTarget as URLLoader;
				
				// Get the "t" parameter
				var regex:RegExp = /"t": "(.*?)"/;
				var result:Array = loader.data.match(regex);
				if (result.length < 2) {
					trace("Error parsing YouTube page: Couldn't get 't' parameter");
					return;
				}
				var param_t:String = result[1];
				
				// Get the "video_id" parameter
				regex = /"video_id": "(.*?)"/;
				result = loader.data.match(regex);
				if (result.length < 2) {
					trace("Error parsing YouTube page: Couldn't get 'video_id' parameter");
					return;
				}
				var param_video_id:String = result[1];
				
				// Get the "length_seconds" parameter
				regex = /"length_seconds": "(.*?)"/;
				result = loader.data.match(regex);
				if (result.length < 2) {
					trace("Error parsing YouTube page: Couldn't get 'length_seconds' parameter");
					return;
				}
				var param_length_seconds:int = int(result[1]);
				
				// Get the "rec_title" parameter
				regex = /'VIDEO_TITLE': '(.*?)'/;
				result = loader.data.match(regex);
				if (result.length < 2) {
					trace("Error parsing YouTube page: Couldn't get 'VIDEO_TITLE' parameter");
					return;
				}
				var param_rec_title:String = result[1];
				
				// Construct URL
				var flvURL:String = "http://www.youtube.com/get_video.php?";
				flvURL += "video_id=" + param_video_id;
				flvURL += "&t=" + param_t;
				var ext:String = "flv";
				if(useHighQuality) {
					// Set "format" to 18 for the HQ version
					// default / flv
					// fmt=18 / mp4
					flvURL += "&fmt=18";
					ext = "mp4";
				}
				
				trace("Here's the FLV URL: " + flvURL);
				Main.sendNotification(Main.ADD_FILE, { url:flvURL, extOverride:ext, title:param_rec_title, length:param_length_seconds } );
			} else {
				trace("Couldn't download YouTube url: " + IOErrorEvent(e));
			}
		}
		
		private function onOpen(event:Event):void {
			var allFilter:FileFilter = new FileFilter("All Files", "*.*;");
			var docFilter:FileFilter = new FileFilter("Playlists", "*.b4s;*.pls;*.asx;*.xspf;*.m3u");
			filePL.browseForOpen("Select a playlsit", [allFilter, docFilter]);
		}
		
		private function onSave(event:Event):void {
			// TODO: Actually save playlists
			Main.sendNotification(Main.SAVE_PLAYLIST);
		}
		
		private function onClose(event:Event):void {
			pw.visible = false;
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			grid.x = 0;
			grid.y = 0;
			grid.height = e.afterBounds.height;
			grid.width = e.afterBounds.width - 5;
		}
	}
}