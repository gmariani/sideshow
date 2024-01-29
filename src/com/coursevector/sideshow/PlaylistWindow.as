package com.coursevector.sideshow {
	
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.events.ListEvent;
	
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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.NativeWindowBoundsEvent;
	
	import com.coursevector.data.PlayList;
	
	public class PlaylistWindow extends NativeWindow {
		
		private var sprMain:MovieClip = new PlaylistScreen();
		private var grid:DataGrid;
		private var _currentItem:Object;
		
		private var addFileMenuItem:NativeMenuItem;
		private var addDirMenuItem:NativeMenuItem;
		private var addURLMenuItem:NativeMenuItem;
		private var openPlayListMenuItem:NativeMenuItem;
		private var savePlayListMenuItem:NativeMenuItem;
		private var closeMenuItem:NativeMenuItem;
		
		public function PlaylistWindow():void {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = true;
			winArgs.minimizable = true;
			winArgs.resizable = true;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			title = "Playlist";
			this.width = 500;
			this.height = 300;
			this.addEventListener(Event.CLOSING, closeHandler);
			this.addEventListener(Event.RESIZE, onWindowResize);
			
			// Init
			grid = sprMain.getChildByName("grid") as DataGrid;
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
			grid.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			grid.allowMultipleSelection = false;
			
			if (NativeApplication.supportsMenu) {
				NativeApplication.nativeApplication.menu.addSubmenuAt(createManageMenu(), 1, "Playlist");
			} else {
				this.menu = createMenu();
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprMain);
		}
		
		public function get currentItem():Object {
			return _currentItem;
		}
		
		public function updateList(list:PlayList):void {
			grid.removeAll();
			var arr:Array = list.toDataProvider().toArray();
			for (var i:String in arr) {
				grid.addItem( { Index:uint(i), Name:unescape(arr[i].label), Duration:convertTime(arr[i].data.length), URL:arr[i].data.url } );
			}
		}
		
		private function closeHandler(event:Event):void {
			event.preventDefault();
			this.visible = false;
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
				addURLMenuItem.enabled = false;
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
		
		private function onKeyDown(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.DELETE :
					if(_currentItem) dispatchEvent(new Event("deleteFile"));
					break;
			}
		}
		
		private function onFocusItem(event:Event):void {
			_currentItem = grid.selectedItem;
		}
		
		private function onPlayItem(event:ListEvent):void {
			_currentItem = event.item;
			dispatchEvent(new Event("playFile"));
		}
		
		private function onAddFile(event:Event):void {
			dispatchEvent(new Event("openFile"));
		}
		
		private function onAddDir(event:Event):void {
			dispatchEvent(new Event("openDir"));
		}
		
		private function onAddURL(event:Event):void {
			dispatchEvent(new Event("openURL"));
		}
		
		private function onOpen(event:Event):void {
			dispatchEvent(new Event("openList"));
		}
		
		private function onSave(event:Event):void {
			dispatchEvent(new Event("saveList"));
		}
		
		private function onClose(event:Event):void {
			this.visible = false;
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			grid.x = 10;
			grid.y = 10;
			grid.height = e.afterBounds.height - 70;
			grid.width = e.afterBounds.width - 30;
		}
	}
}