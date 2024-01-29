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
	 * The SMIL class parses SMIL formatted playlist files and returns a playlist.
	 * 
	 * Some logic is copied from the NCManager which is part of the FLVPlayback component.
     */
	// TODO: Decide which format to support, FLVPLayback's or JWPlayer's
	public dynamic class SMIL extends PlayList implements IPlaylistParser {
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var xml:XML = new XML(data);
			
			default xml namespace = xml.namespace();
			
			var node:XML;
			var streamHost:String;
			if (xml.head.length() > 0) {
				node = xml.head[0];
				if (nodemeta.length() > 0) {
					if (node.meta.@base.length() > 0) {
						streamHost = node.meta.@base.toString();
					}
				}
			}
			
			// Get Entries
			node = xml.body[0];
			var child:XML = node.*[0];
			var childName:String = child.localName();
			switch (childName) {
				case "switch":
					for (var i:String in child.*) {
						var child2:XML = child.*[i];
						if (child2.nodeKind() != "element") continue;
						switch (child2.localName()) {
							case "video":
							case "audio":
							case "img":
							case "ref":
								p.push(parseVideo(child2));
								break;
							default:
								break;
						}
					}
					break;
				case "video":
				case "audio":
				case "img":
				case "ref":
					p.push(parseVideo(child));
					break;
				default:
					throw new Error("URL: \"" + _url + "\" Tag " + childName + " not supported in " + node.localName() + " tag.");
					break;
			}
			
			default xml namespace = new Namespace("");
			
			return p;
		}
		
		public static function isValid(ext:String, data:String):Boolean {
			var xml:XML = new XML(data);
			return (xml.localName().toLowerCase() == "smil");
		}
		
		protected function parseVideo(node:XML):Object {
			var obj:Object = new Object();
			if (node.@src.length() > 0) obj.url = node.@src.toString();
			if (node.@alt.length() > 0) obj.description = node.@alt.toString();
			if (node.@title.length() > 0) obj.title = node.@title.toString();
			if (node.@["system-bitrate"].length() > 0) obj.bitrate = int(node.@["system-bitrate"].toString());
			if (node.@dur.length() > 0) obj.length = parseTime(node.@dur.toString()); // Duration
			if (streamHost) obj.streamHost = streamHost;
			return obj;
		}
		
		protected function parseTime(timeStr:String):Number {
			var results:Object = /^((\d+):)?(\d+):((\d+)(.\d+)?)$/.exec(timeStr);
			if (results == null) {
				var numSecs:Number = Number(timeStr);
				if (isNaN(numSecs) || numSecs < 0) {
					throw new Error("Invalid dur value: " + timeStr);
				}
				return numSecs;
			} else {
				var t:Number = 0;
				t += (uint(results[2]) * 60 * 60);
				t += (uint(results[3]) * 60);
				t += (Number(results[4]));
				return t;
			}
		}
	}
}