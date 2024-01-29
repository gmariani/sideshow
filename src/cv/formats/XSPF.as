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
	 * The XSPF class parses XSPF formatted playlist files and returns a PlayList.
	 * 
	 * Read XSPF PlayLists
	 * 
	 * MIME Type: application/xspf+xml
	 */
	public dynamic class XSPF implements IPlaylistParser {
		
		public function isValid(ext:String, data:String):Boolean {
			if (ext != "xml" ) return false;
			
			var xml:XML = new XML(data);
			return (xml.localName().toLowerCase() == "playlist");
		}
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var xml:XML = new XML(data);
			
			default xml namespace = xml.namespace();
			
			//var version:String = xml.@version; // Version
			//var title:String = xml.title; // Title
			
			// Get Entries
			for each (var track:XML in xml..track) {
				var o:Object = new Object();
				for each(var child:XML in track.children()) {
					switch(child.localName().toLowerCase()) {
						case "creator" :
							o.author = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;
						case "description" :
							o.description = child.toString(); // A human-readable title for the playlist. xspf:playlist elements MAY contain exactly one.
							break;
						case "duration" :
							o.length = child.toString(); // The time to render a resource, in milliseconds.
							if (o.length) o.length = -1;
							break;
						case "location" :
							o.url = child.toString();
							break;
						case "info" :
							o.link = child.toString();
							break;
						case "image" :
							o.image = child.toString();
							break;
						case "title" :
							o.title = child.toString();
							break;
						case "meta" :
							// image, type
							o[child.@rel] = child.toString();
							break;
					}
				}
				p.push(o);
			}
			
			default xml namespace = new Namespace("");
			
			return p;
		}
	}
}