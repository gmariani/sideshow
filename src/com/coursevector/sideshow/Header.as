package com.coursevector.sideshow {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
    
    public class Header extends MovieClip {
		
		//private var txtPath:TextField;
		//private var txtTime:TextField;
		//private var mcBG:Sprite;
		private var newFormat:TextFormat;
		
        public function Header():void {
            //
        }
		
		public function set title(value:String):void {
			//newFormat = txtPath.defaultTextFormat;
			txtPath.text = value;
			//newFormat.align = TextFormatAlign.RIGHT;
			//txtPath.setTextFormat(newFormat);
		}
		
		public function set time(value:String):void {
			txtTime.text = value;
		}
        
        public function setWidth(value:Number):void {
			mcBG.width = value;
			txtTime.x = mcBG.width - txtTime.width - 10;
			txtPath.width = mcBG.width - txtTime.width - 25;
		}
    }
}