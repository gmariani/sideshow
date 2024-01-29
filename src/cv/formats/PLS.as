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
	 * The PLS class parses PLS formatted playlist files and returns a PlayList.
	 * A proprietary format used for playing Shoutcast and Icecast 
	 * streams. The syntax of a PLS file is the same syntax as a Windows 
	 * .ini file and was probably chosen because of support in the Windows API.
     */
	public class PLS implements IPlaylistParser {
		
		protected var regex:RegExp;
		protected var file:String;
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			
			// Get number of entries
			file = data;
			regex = /NumberOfEntries(\w*)=\d/g;
			var l:int = regExec();
			
			// Go through each entry
			for (var i:int = 1; i <= l; i++) {
				var o:Object = new Object();
				regex = new RegExp("File" + i + "=(.*)");
				o.url = regExec();
				regex = new RegExp("Title" + i + "=(.*)");
				o.title = regExec();
				regex = new RegExp("Length" + i + "=(.*)");
				o.length = regExec();
				p.push(o);
			}
			
			return p;
		}
		
		public function isValid(ext:String, data:String):Boolean {
			return (ext == "pls");
		}
		
		protected function regExec():* {
			return regex.exec(file)[0].split("=")[1];
		}
	}
}