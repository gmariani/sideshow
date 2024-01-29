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

package cv.media {
	
	import cv.events.LoadEvent;
	import cv.events.MetaDataEvent;
	import cv.events.PlayProgressEvent;
	import cv.interfaces.IMediaPlayer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	//--------------------------------------
    //  Events
    //--------------------------------------
	
	/**
	 * Dispatched when the media file has completed loading
	 *
	 * @eventType cv.events.LoadEvent.LOAD_COMPLETE
	 */
	[Event(name = "loadComplete", type = "cv.events.LoadEvent")]
	
	/**
	 * Dispatched as a media file is loaded
	 *
	 * @eventType cv.events.LoadEvent.LOAD_PROGRESS
	 */
	[Event(name = "loadProgress", type = "flash.events.ProgressEvent")]
	
	/**
	 * Dispatched as a media file begins loading
	 *
	 * @eventType cv.event.LoadEvent.LOAD_START
	 */
	[Event(name = "loadStart", type = "cv.events.LoadEvent")]
	
	/**
	 * Dispatched after images loads. Contains height and width of image.
	 *
	 * @eventType cv.events.MetaDataEvent.METADATA
	 */
	[Event(name = "metadata", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched as a media file finishes playing
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_COMPLETE
	 */
	[Event(name = "playComplete", type = "cv.events.PlayProgressEvent")]
	
	/**
	 * Dispatched as a media file is playing
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_PROGRESS
	 */
	[Event(name="playProgress", type="cv.events.PlayProgressEvent")]
	
	/**
	 * Dispatched once as a media file first begins to play
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_START
	 */
	[Event(name = "playStart", type = "cv.events.PlayProgressEvent")]
	
	/**
	 * Dispatched when status has been updated.
	 *
	 * @eventType cv.events.PlayProgressEvent.STATUS
	 */
	[Event(name = "status", type = "flash.events.Event")]

	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 1.0.4<br>
	 * <h3>Date:</h3> 5/04/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * The ImagePlayer class is a facade for controlling loading, and playing
	 * of images.
	 * <hr>
	 * <ul>
	 * <li>1.0.4
	 * <ul>
	 * 		<li>Re-dispatches any error events</li>
	 * </ul>
	 * </li>
	 * <li>1.0.3
	 * <ul>
	 * 		<li>currentPercent is now a number from 0 - 1</li>
	 * 		<li>seekPercent is now accepts a number from 0 - 1</li>
	 * </ul>
	 * </li>
	 * <li>1.0.2
	 * <ul>
	 * 		<li>Tweaked how load complete reports</li>
	 * 		<li>loadCurrent and loadTotal are now uints and more accurate</li>
	 * </ul>
	 * </li>
	 * <li>1.0.1
	 * <ul>
	 * 		<li>Changed how PLAY_START and autoStart is handled. autoStart is no longer overwritten and will pause before any audio is heard.</li>
	 * 		<li>Handles autostart and PLAY_START better. Also has a new status of STARTED to differentiate between when autoStart and the first play().</li>
	 * 		<li>Added autoRewind prop. If set, it will rewind after PLAY_COMPLETE so the play button can be used to resume.</li>
	 * </ul>
	 * </li>
	 * <li>1.0.0
	 * <ul>
	 * 		<li>Refactored release</li>
	 * </ul>
	 * </li>
	 * </ul>
     */
    public class ImagePlayer extends Sprite implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "1.0.4";
		
		/**
		 * Will automatically call stop (rewind) after playing complete. If disabled, this will pause
		 * the player instead.
		 */
		public var autoRewind:Boolean = false;
		
		/**
		 * Enables/Disables debug traces
		 */
		public var debug:Boolean = false;
		
		protected var _autoStart:Boolean = true;
		protected var sendOnce:Boolean = false;
		protected var skipOnce:Boolean = false;
		protected var _loadCurrent:uint;
		protected var _loadTotal:uint;
		protected var _metaData:Object;
		protected var _timeTotal:Number;
		protected var _volume:Number;
		protected var _paused:Boolean = false;
		protected var _status:String = PlayProgressEvent.UNLOADED;
		protected var arrFileTypes:Array = ["png", "jpg", "gif"]; // swf?
		protected var ldr:Loader = new Loader();
		protected var pausePosition:int = 0;
		protected var position:int = 0;
		protected var playInterval:uint;
		protected var strURL:String;
		
		public function ImagePlayer() {
			this.addChild(ldr);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/** 
		 * Whether media will play automatically once loaded.
		 * 
		 * @default true
		 */
		public function get autoStart():Boolean { return _autoStart; }
		/** @private **/
		public function set autoStart(v:Boolean):void { _autoStart = v; }
		
		/** 
		 * Gets the current play progress in terms of percent
		 */
		public function get currentPercent():Number { return (position / timeTotal) }
		
		/** 
		 * Gets the current load progress in terms of bytes
		 */
		public function get loadCurrent():uint { return _loadCurrent ? _loadCurrent : 0 }
		
		/** 
		 * Gets the total size to be loaded in terms of bytes
		 */
		public function get loadTotal():uint { return _loadTotal ? _loadTotal : 0 }
		
		/** 
		 * Gets the metadata if available for the currently playing audio file
		 */
		public function get metaData():Object { return _metaData }
		
		/**
		 * Returns the pause status of the player.
		 */
		public function get paused():Boolean { return _paused }
		
		/**
		 * Returns the load status of the player.
		 */
		public function get status():String { return _status }
		
		/** 
		 * Gets the elapsed play time in milliseconds
		 */
		public function get timeCurrent():Number { return position }
		
		/** 
		 * Gets the remaining play time in milliseconds
		 */
		public function get timeLeft():Number { return timeTotal - position }
		
		/** 
		 * Gets the total play time in milliseconds
		 */
		public function get timeTotal():Number { return _timeTotal }
		
		/** 
		 * Gets or sets the current volume, from 0 - 1
		 */
		public function get volume():Number { return _volume }
		/** @private **/
		public function set volume(n:Number):void { _volume = Math.max(0, Math.min(1, n)); }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Validates if the given filetype is compatible to be played with ImagePlayer.
		 * The acceptable file types are :
		 * <ul>
		 * <li>png</li>
		 * <li>jpg</li>
		 * <li>gif</li>
		 * </ul>
		 * 
		 * @param ext The file extension to be validated
		 * @param url The full file url if the extension is not enough
		 * 
		 * @return Boolean of whether the extension was valid or not.
		 */
		public function isValid(ext:String, url:String):Boolean {
			var i:uint = arrFileTypes.length;
			while (i--) {
				if (arrFileTypes[i] == ext) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param s	The url of the file to be loaded
		 * 
		 * @see cv.events.LoadEvent.LOAD_START
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function load(item:*):void {
			var s:String = item as String;
			if (s == "" || s == null) {
				trace2("ImagePlayer - Error : Must enter a url to load a file");
				return;
			}
			
			unload();
			
			strURL = unescape(s);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, imageHandler, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			ldr.load(new URLRequest(strURL));
			
			_timeTotal = 10000; // Default
			pausePosition = 0;
			position = 0;
			setStatus(PlayProgressEvent.LOADING);
			sendOnce = false;
			skipOnce = false;
			
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_START, false, false, strURL, this, timeTotal));
		}
		
		/**
		 * Pauses the media
		 * 
		 * @default true
		 * @param b	Whether to pause or toggle it off
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function pause(b:Boolean = true):void {
			_paused = b;
			
			if (b) {
				stop();
				pausePosition = position;
			} else {
				play(pausePosition);
			}
			
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Starts playback at the given position.
		 * 
		 * @default 0
		 * @param pos	Position to play from
		 */
		public function play(pos:int = 0):void {
			if (_paused) {
				if (_status != PlayProgressEvent.LOADING) {
					if (pos == 0 && pausePosition != 0) pos = pausePosition;
					_paused = false;
					pausePosition = 0;
					position = pos;
					
					if (!autoStart) {
						pause(true);
						skipOnce = true;
						return;
					} else if(!sendOnce) {
						dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_START, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
						sendOnce = true;
						setStatus(PlayProgressEvent.STARTED);
					}
					
					playInterval = setInterval(timeHandler, 100);
				}
			}
		}
		
		/**
		 * Seeks to time given.
		 * 
		 * @param n	Seconds into the audio to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seek(time:*):void {
			var n:Number = Math.max(0, Math.min(timeTotal, Number(time) * 1000));
			if (!this.paused) {
				pausePosition = 0;
				position = n;
			} else {
				pausePosition = n;
			}
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Seeks to the given percent
		 * 
		 * @param n	Percent to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seekPercent(n:Number):void {
			seek((n * timeTotal) / 1000);
		}
		
		/**
		 * Stops the image at the specified position. Sets the position given 
		 * as the pause position.
		 */
		public function stop():void {
			_paused = true;
			pausePosition = 0;
			position = 0;
			clearInterval(playInterval);
		}
		
		/**
		 * Unloads the image and resets the metadata.
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function unload():void {
			if(ldr.contentLoaderInfo.bytesLoaded != ldr.contentLoaderInfo.bytesTotal) {
				ldr.close();
			} else {
				ldr.unload();
			}
			stop();
			setStatus(PlayProgressEvent.UNLOADED);
			_metaData = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		protected function errorHandler(e:ErrorEvent):void {
			trace2("ImagePlayer - Error : " + e.text);
			dispatchEvent(e.clone());
		}
		
		protected function imageHandler(e:Event):void {
			_loadCurrent = ldr.contentLoaderInfo.bytesLoaded;
			_loadTotal = ldr.contentLoaderInfo.bytesTotal;
			_metaData = { height:e.target.height, width:e.target.width };
			setStatus(PlayProgressEvent.LOADED);
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_COMPLETE, false, false, strURL, this, timeTotal));
			dispatchEvent(new MetaDataEvent(MetaDataEvent.METADATA, false, false, _metaData));
			play();
		}
		
		protected function progressHandler(e:ProgressEvent):void {
			_loadCurrent = e.bytesLoaded;
			_loadTotal = e.bytesTotal;
			dispatchEvent(new ProgressEvent(LoadEvent.LOAD_PROGRESS, false, false, e.bytesLoaded, e.bytesTotal));
		}
		
		protected function setStatus(str:String):void {
			_status = str;
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		protected function timeHandler():void {
			position += 100;
			if (position >= _timeTotal && _timeTotal > 0) {
				if (autoRewind) {
					stop();
				} else {
					pause(true);
				}
				dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_COMPLETE, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
			} else if (_timeTotal > 0) {
				dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
			}
		}
		
		protected function trace2(...arguements):void {
			if (debug) trace(arguements);
		}
	}
}