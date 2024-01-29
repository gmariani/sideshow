package com.coursevector.sideshow {
	
	import flash.display.Sprite;
	import flash.desktop.NativeApplication;
	import com.coursevector.sideshow.Screen;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	
	public class SideShow extends Sprite {
		
		public function SideShow() {
			NativeApplication.nativeApplication.autoExit = true;
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.transparent = true;
			new Screen(winArgs);
			stage.nativeWindow.close();
		}
	}
}