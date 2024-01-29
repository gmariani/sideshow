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
	 * The M3U class parses M3U formatted playlist files and returns a PlayList.
	 * M3U is by far the most popular playlist format, probably due 
	 * to its simplicity. It is an ad-hoc standard with no formal definition, 
	 * no canonical source, and no owner.
     */
	public class M3U implements IPlaylistParser {
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var lineBegin:int = data.indexOf("\n", data.indexOf("#EXTM3U", 0)) + 1;
			
			//Find BOF and skip it.
			var lineEnd:int = lineBegin;
			var lineCount:int = 0;
			var strLine:String = "";
			var strTitle:String = "";
			var nSeconds:int = 0;
			var l:uint = data.length;
			
			while (lineEnd != -1) {
				lineBegin = lineCount == 0 ? lineBegin : lineEnd + 1;
				// Incase there isn't a \n on the last item, compensate for it.
				if (lineBegin >= l) {
					lineEnd = -1;
				} else {
					lineEnd = data.indexOf("\n", lineEnd + 1);
					if (lineEnd < 0) lineEnd = l + 1;
				}
				strLine = data.substring(lineBegin, lineEnd - 1);
				lineCount++;
				
				if (strLine.indexOf("#EXTINF", 0) != -1) {
					nSeconds = int(strLine.substring(strLine.indexOf(":", 0) + 1, strLine.indexOf(",", 0)));
					strTitle = strLine.substring(strLine.indexOf(",", 0) + 1, strLine.length);
				} else {
					if (strLine.length > 1) {
						// Reset variables
						p.push( { title:strTitle, length:nSeconds, url:strLine } );
						strTitle = "";
						nSeconds = 0;
					}
				}
			}
			
			return p;
		}
		
		public function isValid(ext:String, data:String):Boolean {
			return (ext == "m3u");
		}
	}
}