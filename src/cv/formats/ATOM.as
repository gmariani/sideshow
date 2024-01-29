/**
* TempoLite ©2009 Gabriel Mariani. March 30th, 2009
* Visit http://blog.coursevector.com/tempolite for documentation, updates and more free code.
*
*
* Copyright (c) 2009 Gabriel Mariani
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package cv.formats {
	
	import cv.data.PlayList;
	import cv.interfaces.IPlaylistParser;
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The ATOM class parses ATOM formatted playlist files and returns a PlayList.
     */
	public dynamic class ATOM implements IPlaylistParser {
		
		protected var mimetypes:Object = new Object();
		
		public function ATOM() {
			mimetypes["mp3"] = "mp3";
			mimetypes["audio/mpeg"] = "mp3";
			mimetypes["flv"] = "flv";
			mimetypes["video/x-flv"] = "flv";
			mimetypes["jpeg"] = "jpg";
			mimetypes["jpg"] = "jpg";
			mimetypes["image/jpeg"] = "jpg";
			mimetypes["png"] = "png";
			mimetypes["image/png"] = "png";
			mimetypes["gif"] = "gif";
			mimetypes["image/gif"] = "gif";
			mimetypes["rtmp"] = "rtmp";
			mimetypes["swf"] = "swf";
			mimetypes["application/x-shockwave-flash"] = "swf";
			mimetypes["rtmp"] = "rtmp";
			mimetypes["application/x-fcs"] = "rtmp";
			mimetypes["audio/x-m4a"] = "m4a";
			mimetypes["video/x-m4v"] = "m4v";
			mimetypes["video/H264"] = "mp4";
			mimetypes["video/3gpp"] = "3gp";
			mimetypes["video/x-3gpp2"] = "3g2";
			mimetypes["audio/x-3gpp2"] = "3g2";
		}
		
		public function isValid(ext:String, data:String):Boolean {
			var xml:XML = new XML(data);
			return (xml.namespace().uri == "http://www.w3.org/2005/Atom");
		}
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var xml:XML = new XML(data);
			
			default xml namespace = xml.namespace();
			
			//var title:String = xml.title; // Title
			
			// Get Entries
			for each (var entry:XML in xml..entry) {
				var o:Object = new Object();
				for each(var child:XML in entry.children()) {
					switch(child.localName().toLowerCase()) {
						case "author" :
							o.author = child.toString();
							break;
						case "summary" :
							o.description = child.toString();
							break;
						case "duration" :
							o.length = toSeconds(child.@value.toString()); // Defines the length of time the WMP control will render a stream.
							break;
						case "group" :
							for each (var child2:XML in child.children()) {
								switch(child2.localName().toLowerCase()) {
									case "content":
										if (!o.url && mimetypes[child2.@type.toString()]) {
											o.url = child2.@url.toString();
											o.type = child2.@type.toString();
											if (child2.@duration) o.duration = toSeconds(child2.@duration);
											if (child2.@start) o.start = toSeconds(child2.@start);
										}
										break;
									case "description":
										o.description = child.toString();
										break;
									case "thumbnail":
										if(!o.image) o.image = child.@url.toString();
										break;
									case "credit":
										o.author = child.toString();
										break;
								}
							}
							break;
						case "link" :
							if (child.@rel == "alternate") o.link = child.@href.toString();
							break;
						case "title" :
							o.title = child.toString();
							break;
						case "content":
							if (!o.url && mimetypes[child.@type.toString()]) {
								o.url = child.@url.toString();
								o.type = child.@type.toString();
								if (child.@duration) o.duration = toSeconds(child.@duration);
								if (child.@start) o.start = toSeconds(child.@start);
							}
							break;
						case "description":
							o.description = child.toString();
							break;
						case "thumbnail":
							if(!o.image) o.image = child.@url.toString();
							break;
						case "credit":
							o.author = child.toString();
							break;
					}
				}
				trace(o.url);
				p.push(o);
			}
			
			default xml namespace = new Namespace("");
			
			return p;
		}
		
		/**
		 * Converts a string version of a time format into the seconds equivalent.
		 *
		 * @param str              <String> The string to convert.
		 * @return                  <Int> The number of seconds for the given time.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Protected
		 */
		protected function toSeconds(str:String):int {
			var arr:Array = str.split(":");
			var l:uint = arr.length;
			var sl:uint = str.length;
			var n:uint = 0;
			var ll:String = str.substr( -1); // Last letter
			var sec:uint = uint(str.substr(0, sl - 2)); // Seconds
			if (ll == "s") {
				n = sec;
			} else if (ll == "m") {
				n = sec * 60;
			} else if (ll == "h") {
				n = sec * 3600;
			} else if (l > 1) {
				n = uint(arr[l - 1]);
				n += uint(arr[l - 2]) * 60;
				n += uint(arr[l - 3]) * 3600;
			} else {
				n = uint(str);
			}
			
			return isNaN(n) ? -1 : n;
		}
	}
}