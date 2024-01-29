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

package cv.interfaces {
	
	import flash.events.IEventDispatcher;
	
	/**
	 *  Implement the IMediaPlayer interface to create a custom media player. 
	 *  A media player handles audio or video playback.
	 */
	public interface IMediaPlayer extends IEventDispatcher {
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/**
		 *  Whether media will play automatically once loaded.
		 */
		function get autoStart():Boolean;
		/** @private **/
		function set autoStart(v:Boolean):void;
		
		/**
		 * Gets the play progress percentage of the currently
		 * playing media file.
		 */
		function get currentPercent():Number;
		
		/**
		 *  Gets the pause status of the media player.
		 */
		function get paused():Boolean;
		
		/**
		 *  Gets the loading status of the media player.
		 */
		function get status():String;
		
		/**
		 *  Gets the number of bytes currently loaded.
		 */
		function get loadCurrent():uint;
		
		/**
		 *  Gets the total number of bytes for a given file
		 * being loaded.
		 */
		function get loadTotal():uint;
		
		/**
		 *  Gets or sets the volume of the media player.
		 */
		function get volume():Number;
		/** @private **/
		function set volume(n:Number):void;
		
		/**
		 *  Gets the meta data object of the current file if available.
		 */
		function get metaData():Object;
		
		/**
		 *  Gets the elapsed play time of the current file.
		 */
		function get timeCurrent():Number;
		
		/**
		 *  Gets the remaining play time of the current file.
		 */
		function get timeLeft():Number;
		
		/**
		 *  Gets the total play time of the current file.
		 */
		function get timeTotal():Number;
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Validates if the given filetype is compatible to be played with media player. 
		 *
		 * @param ext The file extension to be validated
		 * @param url The full file url if the extension is not enough
		 * 
         * @return Boolean of whether the extension was valid or not.
		 */
		function isValid(ext:String, url:String):Boolean;
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param s	The url of the file to be loaded
		 * 
		 * @see cv.events.LoadEvent.LOAD_START
		 */
		function load(item:*):void;
		
		/**
		 * Controls the pause of the audio
		 * 
		 * @default true
		 * 
		 * @param b	Whether to pause or not
		 */
		function pause(b:Boolean = true):void;
		
		/**
		 * Plays the media file, starting at the given position.
		 * 
		 * @default 0
		 * 
		 * @param pos	Position to play from
		 */
		function play(pos:int = 0):void;
		
		/**
		 * Seeks to time given in the media file.
		 * 
		 * @param n	Seconds into the file to seek to
		 */
		function seek(time:*):void;
		
		/**
		 * Seeks to the given percent in the media file.
		 * 
		 * @param n	Percent to seek to
		 */
		function seekPercent(n:Number):void;
		
		/**
		 * Stops the media file at the specified position. Sets the position given as the pause position.
		 */
		function stop():void;
		
		/**
		 * Stops the media, closes out any connections, and resets the metadata.
		 */
		function unload():void;
	}
}