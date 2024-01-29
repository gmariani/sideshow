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
	 * The B4S class parses B4S formatted playlist files and returns a PlayList.
	 * B4S is a proprietary XML-based format introduced in Winamp version 3.
     */
	public class B4S implements IPlaylistParser {
		
		public function isValid(ext:String, data:String):Boolean {
			if (ext != "b4s" ) return false;
			
			var xml:XML = new XML(data);
			return (xml.localName() == "WinampXML");
		}
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var xml:XML = new XML(data);
			
			default xml namespace = xml.namespace();
			
			// PlayList label
			//var strLabel:String = xml.@label;
			//var nNumOfEntries:String = xml.@num_entries;
			
			// Get Entries
			for each (var entry:XML in xml..entry) {
				p.push({title:entry.Name, length:entry.Length, url:entry.@Playstring});
			}
			
			default xml namespace = new Namespace("");
			
			return p;
		}
	}
}