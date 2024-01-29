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

	import com.adobe.utils.DateUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.NativeWindowBoundsEvent;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import fl.controls.Button;
	import fl.controls.TextArea;
	
	// TODO: Parse MP3 tags

	public class MetaDataMediator extends MovieClip {
		
		private var mw:NativeWindow;
		private var strTitle:String = "";
		private var _addMiscTitle:Boolean = false;
		private var _addMiscTitle2:Boolean = false;
		private var _addMP3Title:Boolean = false;
		private var _addVideoTitle:Boolean = false;
		private var _addAudioTitle:Boolean = false;
		private var _addGeneralTitle:Boolean = false;
		private var _addYouTubeTitle:Boolean = false;
		private const arrGenres:Array = ["Blues", "Classic Rock", "Country", "Dance", "Disco",
		"Funk", "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies", "Other", "Pop", "R&B",
		"Rap", "Reggae", "Rock", "Techno", "Industrial", "Alternative", "Ska", "Death Metal", "Pranks", "Soundtrack",
		"Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk", "Fusion", "Trance", "Classical", "Instrumental", "Acid",
		"House", "Game", "Sound Clip", "Gospel", "Noise", "AlternRock", "Bass", "Soul", "Punk", "Space", 
		"Meditative", "Instrumental Pop", "Instrumental Rock", "Ethnic", "Gothic", "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk", "Eurodance", 
		"Dream", "Southern Rock", "Comedy", "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk", "Jungle", "Native American",
		"Cabaret", "New Wave", "Psychadelic", "Rave", "Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz",
		"Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock", "Folk", "Folk/Rock", "National Folk", "Swing", "Fast Fusion",
		"Bebob", "Latin", "Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", "Progressive Rock", "Psychedelic Rock", "Symphonic Rock",
		"Slow Rock", "Big Band", "Chorus", "Easy Listening", "Acoustic", "Humour", "Speech", "Chanson", "Opera", "Chamber Music", "Sonata", 
		"Symphony", "Booty Bass", "Primus", "Porn Groove", "Satire", "Slow Jam", "Club", "Tango", "Samba", 
		"Folklore", "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", "A Capella", "Euro-House", "Dance Hall"];
		
		public function MetaDataMediator() {
			
			var tf:TextFormat = new TextFormat("Helvetica LT Std");
			taMsg.setStyle("textformat", tf);
			
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//tags ID3 like tag information
		//trackinfo   Array   	  	 An array of objects containing various infomation about all the tracks in a file.
		//chapters  Array   	 Information about chapters in audiobooks.
		public function setMessage(objData:Object):void {
			var i:String;
			var s:String;
			var arr:Array;
			var o:Object;
			_addMiscTitle = false;
			_addMiscTitle2 = false;
			_addMP3Title = false;
			_addVideoTitle = false;
			_addAudioTitle = false;
			_addGeneralTitle = false;
			_addYouTubeTitle = false;
			
			taMsg.htmlText = "<b>-- File Name --</b><br>";
			taMsg.htmlText += "<b>" + strTitle + "</b><br>";
			
			// General
			if(objData.width) taMsg.htmlText += addGeneralTitle() + "<b>Width</b> : " + objData.width + "<br>";
			if(objData.height) taMsg.htmlText += addGeneralTitle() + "<b>Height</b> : " + objData.height + "<br>";
			if(objData.createdby) taMsg.htmlText += addGeneralTitle() + "<b>Created By</b> : " + objData.createdby + "<br>";
			if(objData.creationdate) taMsg.htmlText += addGeneralTitle() + "<b>Creation Date</b> : " + objData.creationdate + "<br>";
			if(objData.lastkeyframetimestamp) taMsg.htmlText += addGeneralTitle() + "<b>Last KeyFrame TimeStamp</b> : " + objData.lastkeyframetimestamp + "<br>";
			if(objData.duration) taMsg.htmlText += addGeneralTitle() + "<b>Duration</b> : " + convertTime(objData.duration) + "<br>";
			if(objData.canSeekToEnd) taMsg.htmlText += addGeneralTitle() + "<b>Can Seek to End</b> : " + objData.canSeekToEnd + "<br>";
			if(objData.avcprofile) taMsg.htmlText += addGeneralTitle() + "<b>AVC Profile</b> : " + objData.avcprofile + "<br>";
			if(objData.avclevel) {
				s = objData.avclevel;
				arr = s.split("");
				s = arr[0];
				if (arr.length > 1) s += "." + arr[1];
				taMsg.htmlText += addGeneralTitle() + "<b>AVC Level</b> : " + s + "<br>";
			}
			if(objData.aacaot) taMsg.htmlText += addGeneralTitle() + "<b>AAC Audio Object Type</b> : " + objData.aacaot + "<br>";
			if (objData.moovposition) taMsg.htmlText += addGeneralTitle() + "<b>MOOV Position</b> : " + objData.moovposition + "<br>";
			if (objData.datasize) taMsg.htmlText += addGeneralTitle() + "<b>Data Size</b> : " + objData.datasize + "<br>";
			if (objData.filesize) taMsg.htmlText += addGeneralTitle() + "<b>File Size</b> : " + objData.filesize + "<br>";
			if (objData.hasOwnProperty("creator")) taMsg.htmlText += addGeneralTitle() + "<b>Creator</b> : " + objData["creator"] + "<br>";
			if (objData.hasOwnProperty("haskeyframes")) taMsg.htmlText += addGeneralTitle() + "<b>Has KeyFrames</b> : " + objData["haskeyframes"] + "<br>";
			if (objData.hasOwnProperty("hasmetadata")) taMsg.htmlText += addGeneralTitle() + "<b>Has Metadata</b> : " + objData["hasmetadata"] + "<br>";
			if (objData.hasOwnProperty("lastkeyframelocation")) taMsg.htmlText += addGeneralTitle() + "<b>Last Keyframe Location</b> : " + objData["lastkeyframelocation"] + "<br>";
			if (objData.hasOwnProperty("lastkeyframetimestamp")) taMsg.htmlText += addGeneralTitle() + "<b>Last Keyframe Timestamp</b> : " + convertTime(objData["lastkeyframetimestamp"]) + "<br>";
			if (objData.hasOwnProperty("metadatacreator")) taMsg.htmlText += addGeneralTitle() + "<b>Metadata Creator</b> : " + objData["metadatacreator"] + "<br>";
			if (objData.hasOwnProperty("xtradata")) taMsg.htmlText += addGeneralTitle() + "<b>Extra Data</b> : " + objData["xtradata"] + "<br>";
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
					o = objData.trackinfo[i];
					if(o.timescale) s += " - Timescale : " + o.timescale + "<br>";
					if(o.length) s += " - Length : " + o.length + "<br>";
					if(o.language) s += " - Language : " + o.language + "<br>";
					if (o.sampledescription) {
						var s2:String = "<br>";
						for (i in o.sampledescription[0]) {
							s2 += "   - " + i + " : " + o.sampledescription[0][i] + "<br>";
						}
						s += " - Sample Description : " + s2 + "<br>";
					}
				}
				taMsg.htmlText += addGeneralTitle() + "<b>Track Info</b> : " + s;
			}
			
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
			
			if(objData.audiocodecid) taMsg.htmlText += addAudioTitle() + "<b>Audio Codec Id</b> : " + objData.audiocodecid + "<br>";
			if(objData.audiocodecid) taMsg.htmlText += addAudioTitle() + "<b>Audio Codec Name</b> : " + strAudCodec + "<br>";
			if(objData.audiodelay) taMsg.htmlText += addAudioTitle() + "<b>Audio Delay</b> : " + objData.audiodelay + "<br>";
			if(objData.audiodatarate) taMsg.htmlText += addAudioTitle() + "<b>Audio Data Rate</b> : " + objData.audiodatarate + " Kbps<br>";
			if(objData.audiochannels) taMsg.htmlText += addAudioTitle() + "<b>Audio Channels</b> : " + objData.audiochannels + "<br>";
			if(objData.audiosamplerate) taMsg.htmlText += addAudioTitle() + "<b>Audio Sample Rate</b> : " + (objData.audiosamplerate / 1000) + " Khz<br>";
			if(objData.audiosize) taMsg.htmlText += addAudioTitle() + "<b>Audio Data Size</b> : " + (objData.audiosize / 1024) + " KB<br>";
			
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
			if(objData.videocodecid) taMsg.htmlText += addVideoTitle() + "<b>Video Codec Id</b> : " + objData.videocodecid + "<br>";
			if(objData.videocodecid) taMsg.htmlText += addVideoTitle() + "<b>Video Codec Name</b> : " + strVidCodec + "<br>";
			if (objData.videodatarate) taMsg.htmlText += addVideoTitle() + "<b>Video Data Rate</b> : " + objData.videodatarate + " Kbps<br>";
			if(objData.videosize) taMsg.htmlText += addAudioTitle() + "<b>Video Data Size</b> : " + (objData.videosize / 1024) + " KB<br>";
			if(objData.framerate || objData.videoframerate) taMsg.htmlText += addVideoTitle() + "<b>Frame Rate</b> : " + (objData.framerate || Number(objData.videoframerate).toFixed(2)) + " fps<br>";
			if(objData.seekpoints) {
				s = "<br>";
				for (i in objData.seekpoints) {
					// time, offset
					s += " - " + convertTime(objData.seekpoints[i].time) + "<br>";
				}
				taMsg.htmlText += addVideoTitle() + "<b>Seek Points</b> : " + s + "<br>";
			}
			if(objData.hasOwnProperty("keyframes")) {
				s = "<br>";
				for (i in objData.keyframes.times) {
					s += " - Time: " + convertTime(objData.keyframes.times[i]) + " / Frame: " + objData.keyframes.filepositions[i] + "<br>";
				}
				taMsg.htmlText += addVideoTitle() + "<b>Keyframes</b> : " + s;
			}
			if (objData.hasOwnProperty("cuePoints")) {
				s = "<br>";
				for (i in objData.cuePoints) {
					/*
					type
					name
					time
					parameters
					*/
					o = objData.cuePoints[i];
					if(o.type) s += " - Type : " + o.type + "<br>";
					if(o.name) s += " - Name : " + o.name + "<br>";
					if(o.time) s += " - Time : " + convertTime(o.time) + "<br>";
					if(o.parameters) s += " - Parameters : " + o.parameters + "<br>";
					s += "<br>";
				}
				taMsg.htmlText += addVideoTitle() + "<b>Cue Points</b> : " + s + "<br>";
			}
			
			// MPEG-4 Tags
			if(objData.tags) {
				taMsg.htmlText += "<br><b>-- iTunes Tags --</b><br>";
				
				if (objData.tags.hasOwnProperty("©alb")) taMsg.htmlText += "<b>(©alb) Album</b> : " + objData.tags["©alb"] + "<br>";
				if (objData.tags.hasOwnProperty("©art")) taMsg.htmlText += "<b>(©art) Artist</b> : " + objData.tags["©art"] + "<br>";
				if (objData.tags.hasOwnProperty("aART")) taMsg.htmlText += "<b>(aART) Album Artist</b> : " + objData.tags["aART"] + "<br>";
				if (objData.tags.hasOwnProperty("©ART")) taMsg.htmlText += "<b>(©ART) Album Artist</b> : " + objData.tags["©ART"] + "<br>";
				if (objData.tags.hasOwnProperty("©cmt")) taMsg.htmlText += "<b>(©cmt) Comment</b> : " + objData.tags["©cmt"] + "<br>";
				if (objData.tags.hasOwnProperty("©day")) taMsg.htmlText += "<b>(©day) Year</b> : " + getDate(objData.tags["©day"]) + "<br>";
				if (objData.tags.hasOwnProperty("©nam")) taMsg.htmlText += "<b>(©nam) Title</b> : " + objData.tags["©nam"] + "<br>";
				if (objData.tags.hasOwnProperty("©gen")) taMsg.htmlText += "<b>(©gen) Genre</b> : " + objData.tags["©gen"] + "<br>";
				if (objData.tags.hasOwnProperty("gnre")) {
					var strGenre:String = arrGenres[Number(objData.tags["gnre"]) - 1] || "Unknown";
					taMsg.htmlText += "<b>(gnre) Genre</b> : " + strGenre + "<br>";
				}
				if (objData.tags.hasOwnProperty("trkn")) {
					arr = String(objData.tags["trkn"]).split(",");
					taMsg.htmlText += "<b>(trkn) Track number</b> : " + arr[0] + " of " + (arr[1] || "?") + "<br>";
				}
				if (objData.tags.hasOwnProperty("disk")) {
					arr = String(objData.tags["disk"]).split(",");
					taMsg.htmlText += "<b>(disk) Disk number</b> : " + arr[0] + " of " + (arr[1] || "?") + "<br>";
				}
				if (objData.tags.hasOwnProperty("©wrt")) taMsg.htmlText += "<b>(©wrt) Composer</b> : " + objData.tags["©wrt"] + "<br>";
				if (objData.tags.hasOwnProperty("©too")) taMsg.htmlText += "<b>(©too) Encoder</b> : " + objData.tags["©too"] + "<br>";
				if (objData.tags.hasOwnProperty("tmpo")) taMsg.htmlText += "<b>(tmpo) BPM</b> : " + objData.tags["tmpo"] + "<br>";
				if (objData.tags.hasOwnProperty("cprt")) taMsg.htmlText += "<b>(cprt) Copyright</b> : " + objData.tags["cprt"] + "<br>";
				if (objData.tags.hasOwnProperty("cpil")) taMsg.htmlText += "<b>(cpil) Compilation</b> : " + ((objData.tags["cpil"]) ? "True" : "False") + "<br>";
				if (objData.tags.hasOwnProperty("covr")) {
					// TODO: Convert to image and embed in textfield (jpeg/png)
					var n:uint = 0;
					// Count how many images are in it
					for (i in objData.tags["covr"]) {
						n++;
					}
					taMsg.htmlText += "<b>(covr) Artwork</b> : " + n + " piece" + ((n > 1) ? "s" : "") + " of artwork" + "<br>";
				}
				if (objData.tags.hasOwnProperty("rtng")) taMsg.htmlText += "<b>(rtng) Rating/Advisory</b> : " + getRating(objData.tags["rtng"]) + "<br>";
				if (objData.tags.hasOwnProperty("©grp")) taMsg.htmlText += "<b>(©grp) Grouping</b> : " + objData.tags["©grp"] + "<br>";
				if (objData.tags.hasOwnProperty("stik")) taMsg.htmlText += "<b>(stik) Content Type</b> : " + getContentType(uint(objData.tags["stik"])) + "<br>";
				if (objData.tags.hasOwnProperty("pcst")) taMsg.htmlText += "<b>(pcst) Podcast</b> : " + objData.tags["pcst"] + "<br>";
				if (objData.tags.hasOwnProperty("catg")) taMsg.htmlText += "<b>(catg) Category</b> : " + objData.tags["catg"] + "<br>";
				if (objData.tags.hasOwnProperty("keyw")) taMsg.htmlText += "<b>(keyw) Keyword</b> : " + objData.tags["keyw"] + "<br>";
				if (objData.tags.hasOwnProperty("purl")) taMsg.htmlText += "<b>(purl) Podcast URL</b> : " + objData.tags["purl"] + "<br>";
				if (objData.tags.hasOwnProperty("egid")) taMsg.htmlText += "<b>(egid) Episode Global Unique ID</b> : " + objData.tags["egid"] + "<br>";
				if (objData.tags.hasOwnProperty("desc")) taMsg.htmlText += "<b>(desc) Description</b> : " + objData.tags["desc"] + "<br>";
				if (objData.tags.hasOwnProperty("©lyr")) taMsg.htmlText += "<b>(©lyr) Lyrics</b> : " + objData.tags["©lyr"] + "<br>";
				if (objData.tags.hasOwnProperty("tvnn")) taMsg.htmlText += "<b>(tvnn) TV Network Name</b> : " + objData.tags["tvnn"] + "<br>";
				if (objData.tags.hasOwnProperty("tvsh")) taMsg.htmlText += "<b>(tvsh) TV Show Name</b> : " + objData.tags["tvsh"] + "<br>";
				if (objData.tags.hasOwnProperty("tven")) taMsg.htmlText += "<b>(tven) TV Episode Number</b> : " + objData.tags["tven"] + "<br>";
				if (objData.tags.hasOwnProperty("tvsn")) taMsg.htmlText += "<b>(tvsn) TV Season</b> : " + objData.tags["tvsn"] + "<br>";
				if (objData.tags.hasOwnProperty("tves")) taMsg.htmlText += "<b>(tves) TV Episode</b> : " + objData.tags["tves"] + "<br>";
				if (objData.tags.hasOwnProperty("perf")) taMsg.htmlText += "<b>(perf) Performer</b> : " + objData.tags["perf"] + "<br>";
				if (objData.tags.hasOwnProperty("purd")) taMsg.htmlText += "<b>(purd) Purchase Date</b> : " + getDate(objData.tags["purd"]) + "<br>";
				if (objData.tags.hasOwnProperty("pgap")) taMsg.htmlText += "<b>(pgap) Gapless Playback</b> : " + ((objData.tags["pgap"]) ? "Insert Gap" : "No Gap") + "<br>";
				if (objData.tags.hasOwnProperty("apID")) taMsg.htmlText += "<b>(apID) Apple Store ID</b> : " + objData.tags["apID"] + "<br>";
				if (objData.tags.hasOwnProperty("akID")) taMsg.htmlText += "<b>akID</b> : " + objData.tags["akID"] + "<br>";
				if (objData.tags.hasOwnProperty("atID")) taMsg.htmlText += "<b>atID</b> : " + objData.tags["atID"] + "<br>";
				if (objData.tags.hasOwnProperty("cnID")) taMsg.htmlText += "<b>cnID</b> : " + objData.tags["cnID"] + "<br>";
				if (objData.tags.hasOwnProperty("cmID")) taMsg.htmlText += "<b>cmID</b> : " + objData.tags["cmID"] + "<br>";
				if (objData.tags.hasOwnProperty("geID")) taMsg.htmlText += "<b>geID</b> : " + objData.tags["geID"] + "<br>";
				if (objData.tags.hasOwnProperty("plID")) taMsg.htmlText += "<b>plID</b> : " + objData.tags["plID"] + "<br>";
				if (objData.tags.hasOwnProperty("sfID")) taMsg.htmlText += "<b>(sfID) Store Front</b> : " + getStoreFront(objData.tags["sfID"]) + "<br>";
				// Reverse DNS iTunes style Atoms, unsupported so i'm skipping them
				//if (objData.tags.hasOwnProperty("----")) taMsg.htmlText += "<b>Sound Check Info</b> : " + objData.tags["----"] + "<br>";
				// Filler Atom
				//if (objData.tags.hasOwnProperty("free")) taMsg.htmlText += "<b>free</b> : " + objData.tags["free"] + "<br>";
				
				for (i in objData.tags) {
					switch(i) {
						case "©alb" :
						case "©art" :
						case "aART" :
						case "©ART" :
						case "©cmt" :
						case "©day" :
						case "©nam" :
						case "©gen" :
						case "gnre" :
						case "trkn" :
						case "disk" :
						case "©wrt" :
						case "©too" :
						case "cprt" :
						case "cpil" :
						case "covr" :
						case "rtng" :
						case "©grp" :
						case "stik" :
						case "pcst" :
						case "catg" :
						case "keyw" :
						case "purl" :
						case "egid" :
						case "desc" :
						case "©lyr" :
						case "tvnn" :
						case "tvsh" :
						case "tven" :
						case "tvsn" :
						case "tves" :
						case "purd" :
						case "pgap" :
						case "apID" :
						case "akID" :
						case "atID" :
						case "atID" :
						case "cnID" :
						case "cmID" :
						case "geID" :
						case "plID" :
						case "sfID" :
						case "free" :
						case "----" :
							break;
						default :
							taMsg.htmlText += addMiscTitle() + "<b>" + i + "</b> : " + objData.tags[i] + "<br>";
					}
				}
			}
			
			// ID3 Metadata
			if (objData.hasOwnProperty("AENC")) taMsg.htmlText += addMP3Title() + "<b>(AENC) Audio Encryption</b> : " + objData["AENC"] + "<br>";
			if (objData.hasOwnProperty("APIC")) taMsg.htmlText += addMP3Title() + "<b>(APIC) Attached Picture</b> : " + objData["APIC"] + "<br>";
			if (objData.hasOwnProperty("ASPI")) taMsg.htmlText += addMP3Title() + "<b>(ASPI) Audio Seek Point Index</b> : " + objData["ASPI"] + "<br>";
			if (objData.hasOwnProperty("COMM")) taMsg.htmlText += addMP3Title() + "<b>(COMM) Comments</b> : " + objData["COMM"] + "<br>";
			if (objData.hasOwnProperty("COMR")) taMsg.htmlText += addMP3Title() + "<b>(COMR) Commercial Frame</b> : " + objData["COMR"] + "<br>";
			if (objData.hasOwnProperty("ENCR")) taMsg.htmlText += addMP3Title() + "<b>(ENCR) Encryption Method Registration</b> : " + objData["ENCR"] + "<br>";
			if (objData.hasOwnProperty("EQU2")) taMsg.htmlText += addMP3Title() + "<b>(EQU2) Equalization (2)</b> : " + objData["EQU2"] + "<br>";
			if (objData.hasOwnProperty("ETCO")) taMsg.htmlText += addMP3Title() + "<b>(ETCO) Event Timing Codes</b> : " + objData["ETCO"] + "<br>";
			if (objData.hasOwnProperty("GEOB")) taMsg.htmlText += addMP3Title() + "<b>(GEOB) General Encapsulated Object</b> : " + objData["GEOB"] + "<br>";
			if (objData.hasOwnProperty("GRID")) taMsg.htmlText += addMP3Title() + "<b>(GRID) Group Identification Registration</b> : " + objData["GRID"] + "<br>";
			if (objData.hasOwnProperty("LINK")) taMsg.htmlText += addMP3Title() + "<b>(LINK) Linked Information</b> : " + objData["LINK"] + "<br>";
			if (objData.hasOwnProperty("MCDI")) taMsg.htmlText += addMP3Title() + "<b>(MCDI) Music CD Identifier</b> : " + objData["MCDI"] + "<br>";
			if (objData.hasOwnProperty("MLLT")) taMsg.htmlText += addMP3Title() + "<b>(MLLT) MPEG Location Lookup Table</b> : " + objData["MLLT"] + "<br>";
			if (objData.hasOwnProperty("OWNE")) taMsg.htmlText += addMP3Title() + "<b>(OWNE) Ownership Frame</b> : " + objData["OWNE"] + "<br>";
			if (objData.hasOwnProperty("PRIV")) taMsg.htmlText += addMP3Title() + "<b>(PRIV) Private Frame</b> : " + objData["PRIV"] + "<br>";
			if (objData.hasOwnProperty("PCNT")) taMsg.htmlText += addMP3Title() + "<b>(PCNT) Play Counter</b> : " + objData["PCNT"] + "<br>";
			if (objData.hasOwnProperty("POPM")) taMsg.htmlText += addMP3Title() + "<b>(POPM) Popularimeter</b> : " + objData["POPM"] + "<br>";
			if (objData.hasOwnProperty("POSS")) taMsg.htmlText += addMP3Title() + "<b>(POSS) Position Synchronization Frame</b> : " + objData["POSS"] + "<br>";
			if (objData.hasOwnProperty("RBUF")) taMsg.htmlText += addMP3Title() + "<b>(RBUF) Recommended Buffer Size</b> : " + objData["RBUF"] + "<br>";
			if (objData.hasOwnProperty("RVA2")) taMsg.htmlText += addMP3Title() + "<b>(RVA2) Relative Volume Adjustment (2)</b> : " + objData["RVA2"] + "<br>";
			if (objData.hasOwnProperty("RVRB")) taMsg.htmlText += addMP3Title() + "<b>(RVRB) Reverb</b> : " + objData["RVRB"] + "<br>";
			if (objData.hasOwnProperty("SEEK")) taMsg.htmlText += addMP3Title() + "<b>(SEEK) Seek Frame</b> : " + objData["SEEK"] + "<br>";
			if (objData.hasOwnProperty("SIGN")) taMsg.htmlText += addMP3Title() + "<b>(SIGN) Signature Frame</b> : " + objData["SIGN"] + "<br>";
			if (objData.hasOwnProperty("SYLT")) taMsg.htmlText += addMP3Title() + "<b>(SYLT) Synchronized Lyric/Text</b> : " + objData["SYLT"] + "<br>";
			if (objData.hasOwnProperty("SYTC")) taMsg.htmlText += addMP3Title() + "<b>(SYTC) Synchronized Tempo Codes</b> : " + objData["SYTC"] + "<br>";
			if (objData.hasOwnProperty("TALB")) taMsg.htmlText += addMP3Title() + "<b>(TALB) Album</b> : " + objData["TABL"] + "<br>";
			if (objData.hasOwnProperty("TBPM")) taMsg.htmlText += addMP3Title() + "<b>(TBPM) BPM (Beats Per Minute)</b> : " + objData["TBPM"] + "<br>";
			if (objData.hasOwnProperty("TCOM")) taMsg.htmlText += addMP3Title() + "<b>(TCOM) Composer</b> : " + objData["TCOM"] + "<br>";
			if (objData.hasOwnProperty("TCON")) taMsg.htmlText += addMP3Title() + "<b>(TCON) Genre</b> : " + objData["TCON"] + "<br>";
			if (objData.hasOwnProperty("TCOP")) taMsg.htmlText += addMP3Title() + "<b>(TCOP) Copyright Message</b> : " + objData["TCOP"] + "<br>";
			if (objData.hasOwnProperty("TDEN")) taMsg.htmlText += addMP3Title() + "<b>(TDEN) Encoding Date</b> : " + objData["TDEN"] + "<br>";
			if (objData.hasOwnProperty("TDLY")) taMsg.htmlText += addMP3Title() + "<b>(TDLY) Playlist Delay</b> : " + objData["TDLY"] + "<br>";
			if (objData.hasOwnProperty("TDOR")) taMsg.htmlText += addMP3Title() + "<b>(TDOR) Original Release Date</b> : " + objData["TDOR"] + "<br>";
			if (objData.hasOwnProperty("TDRC")) taMsg.htmlText += addMP3Title() + "<b>(TDRC) Recording Date</b> : " + objData["TDRC"] + "<br>";
			if (objData.hasOwnProperty("TDRL")) taMsg.htmlText += addMP3Title() + "<b>(TDRL) Release Date</b> : " + objData["TDRL"] + "<br>";
			if (objData.hasOwnProperty("TDTG")) taMsg.htmlText += addMP3Title() + "<b>(TDTG) Tagging Date</b> : " + objData["TDTG"] + "<br>";
			if (objData.hasOwnProperty("TENC")) taMsg.htmlText += addMP3Title() + "<b>(TENC) Encoded by</b> : " + objData["TENC"] + "<br>";
			if (objData.hasOwnProperty("TEXT")) taMsg.htmlText += addMP3Title() + "<b>(TEXT) Lyricist/Text writer</b> : " + objData["TEXT"] + "<br>";
			if (objData.hasOwnProperty("TFLT")) taMsg.htmlText += addMP3Title() + "<b>(TFLT) File Type</b> : " + objData["TFLT"] + "<br>";
			if (objData.hasOwnProperty("TIPL")) taMsg.htmlText += addMP3Title() + "<b>(TIPL) Involved People List</b> : " + objData["TIPL"] + "<br>";
			if (objData.hasOwnProperty("TIME")) taMsg.htmlText += addMP3Title() + "<b>(TIME) Time</b> : " + objData["TIME"] + "<br>";
			if (objData.hasOwnProperty("TIT1")) taMsg.htmlText += addMP3Title() + "<b>(TIT1) Content Group</b> : " + objData["TIT1"] + "<br>";
			if (objData.hasOwnProperty("TIT2")) taMsg.htmlText += addMP3Title() + "<b>(TIT2) Song Name</b> : " + objData["TIT2"] + "<br>";
			if (objData.hasOwnProperty("TIT3")) taMsg.htmlText += addMP3Title() + "<b>(TIT3) Subtitle/Description</b> : " + objData["TIT3"] + "<br>";
			if (objData.hasOwnProperty("TKEY")) taMsg.htmlText += addMP3Title() + "<b>(TKEY) Initial Key</b> : " + objData["TKEY"] + "<br>";
			if (objData.hasOwnProperty("TLAN")) taMsg.htmlText += addMP3Title() + "<b>(TLAN) Languages</b> : " + objData["TLAN"] + "<br>";
			if (objData.hasOwnProperty("TLEN")) taMsg.htmlText += addMP3Title() + "<b>(TLEN) Length</b> : " + objData["TLEN"] + "<br>";
			if (objData.hasOwnProperty("TMED")) taMsg.htmlText += addMP3Title() + "<b>(TMED) Media Type</b> : " + objData["TMED"] + "<br>";
			if (objData.hasOwnProperty("TMOO")) taMsg.htmlText += addMP3Title() + "<b>(TMOO) Mood</b> : " + objData["TMOO"] + "<br>";
			if (objData.hasOwnProperty("TOAL")) taMsg.htmlText += addMP3Title() + "<b>(TOAL) Original Title</b> : " + objData["TOAL"] + "<br>";
			if (objData.hasOwnProperty("TOFN")) taMsg.htmlText += addMP3Title() + "<b>(TOFN) Original File Name</b> : " + objData["TOFN"] + "<br>";
			if (objData.hasOwnProperty("TOLY")) taMsg.htmlText += addMP3Title() + "<b>(TOLY) Original Writers</b> : " + objData["TOLY"] + "<br>";
			if (objData.hasOwnProperty("TOPE")) taMsg.htmlText += addMP3Title() + "<b>(TOPE) Original Performers</b> : " + objData["TOPE"] + "<br>";
			if (objData.hasOwnProperty("TORY")) taMsg.htmlText += addMP3Title() + "<b>(TORY) Original Release Year</b> : " + objData["TORY"] + "<br>";
			if (objData.hasOwnProperty("TOWN")) taMsg.htmlText += addMP3Title() + "<b>(TOWN) File owner/licensee</b> : " + objData["TOWN"] + "<br>";
			if (objData.hasOwnProperty("TPE1")) taMsg.htmlText += addMP3Title() + "<b>(TPE1) Artist</b> : " + objData["TPE1"] + "<br>";
			if (objData.hasOwnProperty("TPE2")) taMsg.htmlText += addMP3Title() + "<b>(TPE2) Band/orchestra/accompaniment</b> : " + objData["TPE2"] + "<br>";
			if (objData.hasOwnProperty("TPE3")) taMsg.htmlText += addMP3Title() + "<b>(TPE3) Conductor/Performer</b> : " + objData["TPE3"] + "<br>";
			if (objData.hasOwnProperty("TPE4")) taMsg.htmlText += addMP3Title() + "<b>(TPE4) Modified by</b> : " + objData["TPE4"] + "<br>";
			if (objData.hasOwnProperty("TPOS")) taMsg.htmlText += addMP3Title() + "<b>(TPOS) Part of a set</b> : " + objData["TPOS"] + "<br>";
			if (objData.hasOwnProperty("TPRO")) taMsg.htmlText += addMP3Title() + "<b>(TPRO) Produced Notice</b> : " + objData["TPRO"] + "<br>";
			if (objData.hasOwnProperty("TPUB")) taMsg.htmlText += addMP3Title() + "<b>(TPUB) Publisher</b> : " + objData["TPUB"] + "<br>";
			if (objData.hasOwnProperty("TRCK")) taMsg.htmlText += addMP3Title() + "<b>(TRCK) Track</b> : " + objData["TRCK"] + "<br>";
			if (objData.hasOwnProperty("TRDA")) taMsg.htmlText += addMP3Title() + "<b>(TRDA) Recording dates</b> : " + objData["TRDA"] + "<br>";
			if (objData.hasOwnProperty("TRSN")) taMsg.htmlText += addMP3Title() + "<b>(TRSN) Internet radio station name</b> : " + objData["TRSN"] + "<br>";
			if (objData.hasOwnProperty("TRSO")) taMsg.htmlText += addMP3Title() + "<b>(TRSO) Internet radio station owner</b> : " + objData["TRSO"] + "<br>";
			if (objData.hasOwnProperty("TSOA")) taMsg.htmlText += addMP3Title() + "<b>(TSOA) Album Sort Order</b> : " + objData["TSOA"] + "<br>";
			if (objData.hasOwnProperty("TSOP")) taMsg.htmlText += addMP3Title() + "<b>(TSOP) Performer Sort Order</b> : " + objData["TSOP"] + "<br>";
			if (objData.hasOwnProperty("TSOT")) taMsg.htmlText += addMP3Title() + "<b>(TSOT) Title Sort Order</b> : " + objData["TSOT"] + "<br>";
			if (objData.hasOwnProperty("TSIZ")) taMsg.htmlText += addMP3Title() + "<b>(TSIZ) Size</b> : " + objData["TSIZ"] + "<br>";
			if (objData.hasOwnProperty("TSRC")) taMsg.htmlText += addMP3Title() + "<b>(TSRC) ISRC (International Standard Recording Code)</b> : " + objData["TSRC"] + "<br>";
			if (objData.hasOwnProperty("TSSE")) taMsg.htmlText += addMP3Title() + "<b>(TSSE) Software/hardware and settings used for encoding</b> : " + objData["TSSE"] + "<br>";
			if (objData.hasOwnProperty("TXXX")) taMsg.htmlText += addMP3Title() + "<b>(TXXX) Text Information Frame</b> : " + objData["TXXX"] + "<br>";
			if (objData.hasOwnProperty("TYER")) taMsg.htmlText += addMP3Title() + "<b>(TYER) Year</b> : " + objData["TYER"] + "<br>";
			if (objData.hasOwnProperty("UFID")) taMsg.htmlText += addMP3Title() + "<b>(UFID) Unique File Identifier</b> : " + objData["UFID"] + "<br>";
			if (objData.hasOwnProperty("USER")) taMsg.htmlText += addMP3Title() + "<b>(USER) Terms of Use</b> : " + objData["USER"] + "<br>";
			if (objData.hasOwnProperty("USLT")) taMsg.htmlText += addMP3Title() + "<b>(USLT) Unsynchronized Lyric/Text Transcription</b> : " + objData["USLT"] + "<br>";
			if (objData.hasOwnProperty("WCOM")) taMsg.htmlText += addMP3Title() + "<b>(WCOM) Commercial Information</b> : " + objData["WCOM"] + "<br>";
			if (objData.hasOwnProperty("WCOP")) taMsg.htmlText += addMP3Title() + "<b>(WCOP) Copyright Information</b> : " + objData["WCOP"] + "<br>";
			if (objData.hasOwnProperty("WOAF")) taMsg.htmlText += addMP3Title() + "<b>(WOAF) Official Audio File Webpage</b> : " + objData["WOAF"] + "<br>";
			if (objData.hasOwnProperty("WOAR")) taMsg.htmlText += addMP3Title() + "<b>(WOAR) Official Artist Webpage</b> : " + objData["WOAR"] + "<br>";
			if (objData.hasOwnProperty("WOAS")) taMsg.htmlText += addMP3Title() + "<b>(WOAS) Official Audio Source Webpage</b> : " + objData["WOAS"] + "<br>";
			if (objData.hasOwnProperty("WORS")) taMsg.htmlText += addMP3Title() + "<b>(WORS) Official Internet Radio Station Homepage</b> : " + objData["WORS"] + "<br>";
			if (objData.hasOwnProperty("WPAY")) taMsg.htmlText += addMP3Title() + "<b>(WPAY) Payment</b> : " + objData["WPAY"] + "<br>";
			if (objData.hasOwnProperty("WPUB")) taMsg.htmlText += addMP3Title() + "<b>(WPUB) Publishers Official Webpage</b> : " + objData["WPUB"] + "<br>";
			if (objData.hasOwnProperty("WXXX")) taMsg.htmlText += addMP3Title() + "<b>(WXXX) URL Link Frame</b> : " + objData["WXXX"] + "<br>";
			
			// Other
			for (i in objData) {
				switch(i) {
					case "creator" :
					case "haskeyframes" :
					case "hasmetadata" :
					case "keyframes" :
					case "times" :
					case "lastkeyframelocation" :
					case "lastkeyframetimestamp" :
					case "metadatacreator" :
					case "videocodecid" :
					case "audiocodecid" :
					case "audiochannels" :
					case "audiosamplerate" :
					case "canSeekToEnd" :
					case "datasize" :
					case "xtradata" :
					case "filesize" :
					case "creationdate" :
					case "videosize" :
					case "audiodatarate" :
					case "videodatarate" :
					case "framerate" :
					case "cuePoints" :
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
					case "tags" :
					case "AENC" :
					case "APIC" :
					case "ASPI" :
					case "COMM" :
					case "COMR" :
					case "ENCR" :
					case "EQU2" :
					case "ETCO" :
					case "GEOB" :
					case "GRID" :
					case "LINK" :
					case "MCDI" :
					case "MLLT" :
					case "OWNE" :
					case "PRIV" :
					case "PCNT" :
					case "POPM" :
					case "POSS" :
					case "RBUF" :
					case "RVA2" :
					case "RVRB" :
					case "SEEK" :
					case "SIGN" :
					case "SYLT" :
					case "SYTC" :
					case "TALB" :
					case "TBPM" :
					case "TCOM" :
					case "TCON" :
					case "TCOP" :
					case "TDEN" :
					case "TDLY" :
					case "TDOR" :
					case "TDRC" :
					case "TDRL" :
					case "TDTG" :
					case "TENC" :
					case "TEXT" :
					case "TFLT" :
					case "TIPL" :
					case "TIME" :
					case "TIT1" :
					case "TIT2" :
					case "TIT3" :
					case "TKEY" :
					case "TLAN" :
					case "TLEN" :
					case "TMED" :
					case "TMOO" :
					case "TOAL" :
					case "TOFN" :
					case "TOLY" :
					case "TOPE" :
					case "TORY" :
					case "TOWN" :
					case "TPE1" :
					case "TPE2" :
					case "TPE3" :
					case "TPE4" :
					case "TPOS" :
					case "TPRO" :
					case "TPUB" :
					case "TRCK" :
					case "TRDA" :
					case "TRSN" :
					case "TRSO" :
					case "TSOA" :
					case "TSOP" :
					case "TSOT" :
					case "TSIZ" :
					case "TSRC" :
					case "TSSE" :
					case "TXXX" :
					case "TYER" :
					case "UFID" :
					case "USER" :
					case "USLT" :
					case "WCOM" :
					case "WCOP" :
					case "WOAF" :
					case "WOAR" :
					case "WOAS" :
					case "WORS" :
					case "WPAY" :
					case "WPUB" :
					case "WXXX" :
						break;
					default :
						taMsg.htmlText += addMiscTitle2() + "<b>" + i + "</b> : " + objData[i] + "<br>";
				}
			}
			
			taMsg.validateNow();
		}
		
		public function setTitle(title:String = "Unknown"):void {
			strTitle = title;
			
			taMsg.htmlText = "<b>-- File Name --</b><br>";
			taMsg.htmlText += "<b>" + strTitle + "</b><br>";
		}
		
		public function show():void {
			if (mw.closed) createWindow();
			mw.activate();
			mw.orderToFront();
			mw.visible = true;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function createWindow():void {
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = true;
			winArgs.type = NativeWindowType.NORMAL;
			
			mw = new NativeWindow(winArgs);
			mw.title = "File Info";
			mw.addEventListener(Event.RESIZE, onWindowResize);
			mw.width = 300;
			mw.height = 300;
			mw.stage.align = StageAlign.TOP_LEFT;
			mw.stage.scaleMode = StageScaleMode.NO_SCALE;
			mw.stage.addChild(this);
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			taMsg.width = e.afterBounds.width - 9;
			taMsg.height = e.afterBounds.height - 70;
			btnOk.y = taMsg.height + 10;
			btnOk.x = (taMsg.width / 2) - (btnOk.width / 2);
		}
		
		private function addMiscTitle():String {
			if (!_addMiscTitle) {
				_addMiscTitle = true;
				return "<br><b>-- Misc Tags --</b><br>";
			}
			return "";
		}
		
		private function addMiscTitle2():String {
			if (!_addMiscTitle2) {
				_addMiscTitle2 = true;
				return "<br><b>-- Misc Info --</b><br>";
			}
			return "";
		}
		
		private function addMP3Title():String {
			if (!_addMP3Title) {
				_addMP3Title = true;
				return "<br><b>-- MP3 Tags --</b><br>";
			}
			return "";
		}
		
		private function addVideoTitle():String {
			if (!_addVideoTitle) {
				_addVideoTitle = true;
				return "<br><b>-- Video Info --</b><br>";
			}
			return "";
		}
		
		private function addAudioTitle():String {
			if (!_addAudioTitle) {
				_addAudioTitle = true;
				return "<br><b>-- Audio Info --</b><br>";
			}
			return "";
		}
		
		private function addGeneralTitle():String {
			if (!_addGeneralTitle) {
				_addGeneralTitle = true;
				return "<br><b>-- General Info --</b><br>";
			}
			return "";
		}
		
		private function addYouTubeTitle():String {
			if (!_addYouTubeTitle) {
				_addYouTubeTitle = true;
				return "<br><b>-- YouTube Info --</b><br>";
			}
			return "";
		}
		
		private function getDate(str:String):String {
			try {
				// If the date format is close, get it to the W3CDTF Format
				if (str.indexOf("T") == -1) {
					str = str.split(" ").join("T");
					str += "Z";
				}
				
				// Parse date
				var d:Date = DateUtil.parseW3CDTF(str);
				var isPM:Boolean = false;
				var h:Number = d.hours;
				if (d.hours > 12) {
					h = d.hours - 12;
					isPM = true;
				}
				var m:String = String(d.minutes);
				if (m.length < 2) {
					m = "0" + m;
				}
				
				// 8/21/2008 9:20 PM
				str = d.month + "/" + d.day + "/" + d.fullYear + " " + h + ":" + m + " " + ((isPM) ? "PM" : "AM");
			} catch (e:Error) {
				//
			} finally {
				return str;
			}
		}
		
		private function getRating(n:String):String {
			if (n == "2") {
				return "Clean Content";
			} else if (n != "0") {
				return "Explicit Content";
			} else {
				return "Inoffensive";
			}
		}
		
		private function getStoreFront(str:String):String {
			var n:Number = Number(str);
			switch(n) {
				case 143460 :
					return "Australia";
				case 143445 :
					return "Austria";
				case 143446 :
					return "Belgium";
				case 143455 :
					return "Canada";
				case 143458 :
					return "Denmark";
				case 143447 :
					return "Finland";
				case 143442 :
					return "France";
				case 143443 :
					return "Germany";
				case 143448 :
					return "Greece";
				case 143449 :
					return "Ireland";
				case 143450 :
					return "Italy";
				case 143462 :
					return "Japan";
				case 143451 :
					return "Luxembourg";
				case 143452 :
					return "Netherlands";
				case 143461 :
					return "New Zealand";
				case 143457 :
					return "Norway";
				case 143453 :
					return "Portugal";
				case 143454 :
					return "Spain";
				case 143456 :
					return "Sweden";
				case 143459 :
					return "Switzerland";
				case 143444 :
					return "United Kingdom";
				case 143441 :
					return "United States";
				default :
					return "Unknown";
			}
		}
		
		private function getContentType(n:uint):String {
			switch(n) {
				case 0 :
					return "Movie";
				case 1 :
					return "Normal";
				case 2 :
					return "Audio Book";
				case 5 :
					return "Whacked Bookmark";
				case 6 :
					return "Music Video";
				case 9 :
					return "Short Film";
				case 10 :
					return "TV Show";
				case 11 :
					return "Booklet";
				case 14 :
					return "Ringtone";
				default :
					return "Unknown";
			}
		}
		
		private function convertTime(n:Number):String {
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (int(s) < 10) s = "0" + s;
			return m + ":" + s;
		}
		
		private function onClickOk(event:MouseEvent):void {
			mw.close();
		}
	}
}