package com.coursevector.sideshow {
	
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	public class MetaDataWindow extends NativeWindow {
		
		private var sprMain:MovieClip = new MetaDataScreen();
		private var taMsg:TextArea;
		private var btnOk:Button;
		
		public function MetaDataWindow():void {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			//winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			title = "File Info";
			this.width = 255;
			this.height = 290;
			
			// Init
			taMsg = sprMain.getChildByName("taMsg") as TextArea;
			
			btnOk = sprMain.getChildByName("btnOk") as Button;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprMain);
		}
		
		
		//tags ID3 like tag information
		//trackinfo   Array   	  	 An array of objects containing various infomation about all the tracks in a file.
		//chapters  Array   	 Information about chapters in audiobooks.
		public function setMessage(strName:String, objData:Object):void {
			var i:String;
			var s:String;
			taMsg.htmlText = "<b>" + strName + "</b><br><br>";
			
			// General
			if(objData.width) taMsg.htmlText += "<b>Width</b> : " + objData.width + "<br>";
			if(objData.height) taMsg.htmlText += "<b>Height</b> : " + objData.height + "<br>";
			if(objData.createdby) taMsg.htmlText += "<b>Created By</b> : " + objData.createdby + "<br>";
			if(objData.creationdate) taMsg.htmlText += "<b>Creation Date</b> : " + objData.creationdate + "<br>";
			if(objData.lastkeyframetimestamp) taMsg.htmlText += "<b>Last KeyFrame TimeStamp</b> : " + objData.lastkeyframetimestamp + "<br>";
			if (objData.duration) taMsg.htmlText += "<b>Duration</b> : " + convertTime(objData.duration) + "<br>";
			taMsg.htmlText += "<br>";
			
			// Audio
			var strAudCodec:String;
			switch(objData.audiocodecid) {
				case 0 :
					strAudCodec = "Uncompressed, platform endian";
					break;
				case 1 :
					strAudCodec = "ADPCM";
					break;
				case 2 :
					strAudCodec = "MP3";
					break;
				case 3 :
					strAudCodec = "Uncompressed, little endian";
					break;
				case 4 :
					strAudCodec = "Nellymoser 16-kHz mono";
					break;
				case 5 :
					strAudCodec = "Nellymoser 8-kHz mono";
					break;
				case 6 :
					strAudCodec = "Nellymoser";
					break;
				case 7 :
					strAudCodec = "G.711 A-law logarithmic PCM";
					break;
				case 8 :
					strAudCodec = "G.711 mu-law logarithmic PCM";
					break;
				case 10 :
				case "mp4a" :
					strAudCodec = "AAC";
					break;
				case 14 :
					strAudCodec = "MP3 8-Khz";
					break;
				case 15 :
					strAudCodec = "Device-specific sound";
					break;
				default :
					strAudCodec = "(Unknown)";
			}
			if(objData.audiocodecid) taMsg.htmlText += "<b>Audio Codec Id</b> : " + objData.audiocodecid + "<br>";
			if(objData.audiocodecid) taMsg.htmlText += "<b>Audio Codec Name</b> : " + strAudCodec + "<br>";
			if(objData.audiodelay) taMsg.htmlText += "<b>Audio Delay</b> : " + objData.audiodelay + "<br>";
			if(objData.audiodatarate) taMsg.htmlText += "<b>Audio DataRate</b> : " + objData.audiodatarate + " Kbps<br>";
			if(objData.audiochannels) taMsg.htmlText += "<b>Audio Channels</b> : " + objData.audiochannels + "<br>";
			if(objData.audiosamplerate) taMsg.htmlText += "<b>Audio SampleRate</b> : " + (objData.audiosamplerate / 1000) + " Khz<br>";
			taMsg.htmlText += "<br>";
			
			// Video
			var strVidCodec:String;
			switch(objData.videocodecid) {
				case 2 :
					strVidCodec = "Sorenson H.263";
					break;
				case 3 :
					strVidCodec = "Screen video";
					break;
				case 4 :
					strVidCodec = "On2 VP6";
					break;
				case 5 :
					strVidCodec = "On2 VP6 with transparency";
					break;
				case 6 :
					strVidCodec = "Screen video version 2";
					break;
				case 7 :
				case "avc1" :
					strVidCodec = "AVC H.264";
					break;
				default :
					strVidCodec = "(Unknown)";
			}
			if(objData.videocodecid) taMsg.htmlText += "<b>Video Codec Id</b> : " + objData.videocodecid + "<br>";
			if(objData.videocodecid) taMsg.htmlText += "<b>Video Codec Name</b> : " + strVidCodec + "<br>";
			if(objData.videodatarate) taMsg.htmlText += "<b>Video DataRate</b> : " + objData.videodatarate + " Kbps<br>";
			if(objData.framerate || objData.videoframerate) taMsg.htmlText += "<b>Framerate</b> : " + (objData.framerate || Number(objData.videoframerate).toFixed(2)) + " fps<br>";
			if (objData.seekpoints) {
				s = "<br>";
				for (i in objData.seekpoints) {
					// time, offset
					s += " - " + convertTime(objData.seekpoints[i].time) + "<br>";
				}
				taMsg.htmlText += "<b>Seek Points</b> : " + s + "<br>";
			}
			taMsg.htmlText += "<br>";
			
			// General
			if(objData.canSeekToEnd) taMsg.htmlText += "<b>Can Seek to End</b> : " + objData.canSeekToEnd + "<br>";
			if(objData.avcprofile) taMsg.htmlText += "<b>AVC Profile</b> : " + objData.avcprofile + "<br>";
			if (objData.avclevel) {
				var s2:String = objData.avclevel;
				var a:Array = s2.split("");
				s2 = a[0];
				if (a.length > 1) s2 += "." + a[1];
				taMsg.htmlText += "<b>AVC Level</b> : " + s2 + "<br>";
			}
			if(objData.aacaot) taMsg.htmlText += "<b>AAC Audio Object Type</b> : " + objData.aacaot + "<br>";
			if (objData.moovposition) taMsg.htmlText += "<b>MOOV Position</b> : " + objData.moovposition + "<br>";
			if (objData.trackinfo) {
				s = "<br>";
				for (i in objData.trackinfo) {
					/*
					timescale 24000
					length 34783749
					language und
					sampledescription [object Object]
						0 [object Object]
							sampletype avc1
						0 [object Object]
							sampletype mp4a
					*/
					var o:Object = objData.trackinfo[i];
					if(o.timescale) s += " - Timescale : " + o.timescale + "<br>";
					if(o.length) s += " - Length : " + o.length + "<br>";
					if(o.language) s += " - Language : " + o.language + "<br>";
					if(o.sampledescription) s += " - Sample Description : " + o.sampledescription + "<br>";
					s += "<br>";
				}
				taMsg.htmlText += "<b>Track Info</b> : " + s + "<br>";
			}
			taMsg.htmlText += "<br>";
			
			// Other
			for (i in objData) {
				switch(i) {
					case "videocodecid" :
					case "audiocodecid" :
					case "audiochannels" :
					case "audiosamplerate" :
					case "canSeekToEnd" :
					case "audiodatarate" :
					case "videodatarate" :
					case "framerate" :
					case "videoframerate" :
					case "audiodelay" :
					case "height" :
					case "width" :
					case "duration" :
					case "avcprofile" :
					case "moovposition" :
					case "seekpoints" :
					case "avclevel" :
					case "aacaot" :
					case "trackinfo" :
						break;
					default :
						taMsg.htmlText += "<b>" + i + "</b> : " + objData[i] + "<br>";
				}
			}
		}
		
		private function convertTime(n:Number):String {
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (int(s) < 10) s = "0" + s;
			return m + ":" + s;
		}
		
		private function onClickOk(event:MouseEvent):void {
			close();
		}
	}
}