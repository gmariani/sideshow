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
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
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
	 * Dispatched as ID3 metadata is receieved from an MP3
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
	[Event(name = "status", type = "cv.events.PlayProgressEvent")]

	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 3.0.5<br>
	 * <h3>Date:</h3> 5/04/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * The SoundPlayer class is a facade for controlling loading, and playing
	 * of MP3 files within Flash. It intelligently handles pausing, and
	 * loading.
	 * <hr>
	 * <ul>
	 * <li>3.0.5
	 * <ul>
	 * 		<li>Re-dispatches any error events</li>
	 * </ul>
	 * </li>
	 * <li>3.0.4
	 * <ul>
	 * 		<li>currentPercent is now a number from 0 - 1</li>
	 * 		<li>Updated SoundTransform handling</li>
	 * 		<li>Updated error handling and traces</li>
	 * 		<li>seekPercent is now accepts a number from 0 - 1</li>
	 * </ul>
	 * </li>
	 * <li>3.0.3
	 * <ul>
	 * 		<li>Tweaked how load complete reports</li>
	 * 		<li>loadCurrent and loadTotal are now uints and more accurate</li>
	 * </ul>
	 * </li>
	 * <li>3.0.2
	 * <ul>
	 * 		<li>Handles autostart and PLAY_START better. Also has a new status of STARTED to differentiate between when autoStart and the first play().</li>
	 * 		<li>Added autoRewind prop. If set, it will rewind after PLAY_COMPLETE so the play button can be used to resume.</li>
	 * </ul>
	 * </li>
	 * <li>3.0.1
	 * <ul>
	 * 		<li>Changed how PLAY_START and autoStart is handled. autoStart is no longer overwritten and will pause before any audio is heard.</li>
	 * </ul>
	 * </li>
	 * <li>3.0.0
	 * <ul>
	 * 		<li>Refactored release</li>
	 * </ul>
	 * </li>
	 * </ul>
     */
    public class SoundPlayer extends EventDispatcher implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "3.0.5";
		
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
		protected var _buffer:int = 1;
		protected var _loadCurrent:uint;
		protected var _loadTotal:uint;
		protected var _metaData:Object;
		protected var _volume:Number = .5;
		protected var _leftToLeft:Number = 1;
		protected var _leftToRight:Number = 0;
		protected var _rightToLeft:Number = 0;
		protected var _rightToRight:Number = 1;
		protected var _pan:Number = 0;
		protected var _paused:Boolean = false;
		protected var _status:String = PlayProgressEvent.UNLOADED;
		protected var _isReadyToPlay:Boolean = false;
		protected var pausePosition:int = 0;
		protected var playTimer:Timer = new Timer(10);
		protected var sc:SoundChannel;
		protected var snd:Sound = new Sound();
		protected var sendOnce:Boolean = false; // For dispatching the PLAY_START once
		protected var skipOnce:Boolean = false; // For dispatching handling autoStart disabled
		protected var strURL:String;
		
		public function SoundPlayer() {
			playTimer.addEventListener(TimerEvent.TIMER, soundHandler);
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
		public function set autoStart(v:Boolean):void {
			_autoStart = v;
		}
		
		/** 
		 * Gets or sets how long SoundPlayer should buffer the audio before 
		 * playing, in seconds.
		 */
		public function get buffer():int { return _buffer }
		/** @private **/
		public function set buffer(n:int):void {
			if(n < 0) n = 0;
			_buffer = n;
		}
		
		/** 
		 * Gets the current play progress in terms of percent
		 */
		public function get currentPercent():Number { return sc ? (sc.position / timeTotal) : 0 }
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left 
		 * input is played in the left speaker.
		 */
		public function get leftToLeft():Number { return _leftToLeft }
		/** @private **/
		public function set leftToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_leftToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left 
		 * input is played in the right speaker.
		 */
		public function get leftToRight():Number { return _leftToRight }
		/** @private **/
		public function set leftToRight(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_leftToRight = v;
			updateSoundTransform();
		}
		
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
		 * 
		 * -MetaData
		 * ** Flash Player 9 and later supports ID3 2.0 tags, specifically 2.3 and 2.4
		 * -IDE 2.0 tag
		 * COMM Sound.id3.comment
		 * TABL Sound.id3.album
		 * TCON Sound.id3.genre
		 * TIT2 Sound.id3.songName
		 * TPE1 Sound.id3.artist
		 * TRCK Sound.id3.track
		 * TYER Sound.id3.year
		 * 
		 * -ID3 Earlier
		 * TFLT File type
		 * TIME Time
		 * TIT1 Content group description
		 * TIT2 Title/song name/content description
		 * TIT3 Subtitle/description refinement
		 * TKEY Initial key
		 * TLAN Languages
		 * TLEN Length
		 * TMED Media type
		 * TOAL Original album/movie/show title
		 * TOFN Original filename
		 * TOLY Original lyricists/text writers
		 * TOPE Original artists/performers
		 * TORY Original release year
		 * TOWN File owner/licensee
		 * TPE1 Lead performers/soloists
		 * TPE2 Band/orchestra/accompaniment
		 * TPE3 Conductor/performer refinement
		 * TPE4 Interpreted, remixed, or otherwise modified by
		 * TPOS Part of a set
		 * TPUB Publisher
		 * TRCK Track number/position in set
		 * TRDA Recording dates
		 * TRSN Internet radio station name
		 * TRSO Internet radio station owner
		 * TSIZ Size
		 * TSRC ISRC (international standard recording code)
		 * TSSE Software/hardware and settings used for encoding
		 * TYER Year
		 * WXXX URL Link frame
		 */
		public function get metaData():Object { return _metaData }
		
		/** 
		 * The left-to-right panning of the sound, ranging from -1 (full pan 
		 * left) to 1 (full pan right). A value of 0 represents no panning 
		 * (balanced center between right and left). 
		 */
		public function get pan():Number { return _pan }
		/** @private **/
		public function set pan(n:Number):void {
			var v:Number = Math.max(-1, Math.min(1, n));
			_pan = v;
			updateSoundTransform();
		}
		
		/**
		 * Returns the pause status of the player.
		 */
		public function get paused():Boolean { return _paused }
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right 
		 * input is played in the left speaker.
		 */
		public function get rightToLeft():Number { return _rightToLeft }
		/** @private **/
		public function set rightToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_rightToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right 
		 * input is played in the right speaker.
		 */
		public function get rightToRight():Number { return _rightToRight }
		/** @private **/
		public function set rightToRight(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_rightToRight = v;
			updateSoundTransform();
		}
		
		/**
		 * Returns the load status of the player.
		 */
		public function get status():String { return _status }
		
		/** 
		 * Gets the elapsed play time in milliseconds
		 */
		public function get timeCurrent():Number { return sc ? sc.position : 0 }
		
		/** 
		 * Gets the remaining play time in milliseconds
		 */
		public function get timeLeft():Number { return sc ? timeTotal - sc.position : 0 }
		
		/** 
		 * Gets the total play time in milliseconds
		 */
		public function get timeTotal():Number { return getEstimatedLength() }
		
		/** 
		 * Gets or sets the current volume, from 0 - 1
		 */
		public function get volume():Number { return _volume }
		/** @private **/
		public function set volume(n:Number):void {
			_volume = Math.max(0, Math.min(1, n));
			updateSoundTransform();
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Validates if the given filetype is compatible to be played with SoundPlayer.
		 * The acceptable file types are :
		 * <ul>
		 * <li>mp3</li>
		 * </ul>
		 * 
		 * @param ext The file extension to be validated
		 * @param url The full file url if the extension is not enough
		 * 
		 * @return Boolean of whether the extension was valid or not.
		 */
		public function isValid(ext:String, url:String):Boolean {
			return ("mp3" == ext);
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
				trace2("SoundPlayer - load : Must enter a url to load a file");
				return;
			}
			
			unload();
			
			strURL = unescape(s);
			
			snd = new Sound();
			snd.addEventListener(Event.COMPLETE, soundHandler, false, 0, true);
			snd.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			snd.addEventListener(Event.ID3, soundHandler, false, 0, true);
			snd.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			snd.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			try {
				snd.load(new URLRequest(strURL), new SoundLoaderContext(_buffer * 1000, true));
			} catch (e:Error) {
				trace2("SoundPlayer - load : " + e.message);
				unload();
				return;
			}
			
			setStatus(PlayProgressEvent.LOADED); // Skips loading since it can 'stream'
			sendOnce = false;
			skipOnce = false;
			play();
			
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_START, false, false, strURL, this, timeTotal));
		}
		
		/**
		 * Loads a sound from the library to be played. This cannot be used in 
		 * conjunction with TempoLite since the location is not a url.
		 * 
		 * @param	sound	The sound object from the library
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function loadAsset(sound:Sound):void {
			if (sound == null) {
				trace2("SoundPlayer - loadAsset : Must enter a sound to load");
				return;
			}
			
			unload();
			
			snd = sound;
			snd.addEventListener(Event.ID3, soundHandler, false, 0, true);
			
			setStatus(PlayProgressEvent.LOADED);
			sendOnce = false;
			skipOnce = false;
			play();
		}
		
		/**
		 * Controls the pause of the audio
		 * 
		 * @default true
		 * @param b	Whether to pause or not
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function pause(b:Boolean = true):void {
			if(b) {
				stop();
				pausePosition = sc ? sc.position : 0;
			} else {
				play(pausePosition);
			}
			
			_paused = b;
			
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Plays the audio, starting at the given position.
		 * 
		 * @default 0
		 * @param pos	Position to play from
		 */
		public function play(pos:int = 0):void {
			if (_paused) {
				if (_status != PlayProgressEvent.LOADING) {
					if (pos == 0 && pausePosition != 0) pos = pausePosition;
					if (sc) sc.removeEventListener(Event.SOUND_COMPLETE, soundHandler);
					sc = snd.play(pos, 0, getSoundTransform());
					
					if(sc) {
						sc.addEventListener(Event.SOUND_COMPLETE, soundHandler, false, 0, true);
					} else {
						trace2("SoundPlayer - play : No SoundChannel available");
						return;
					}
					
					_paused = false;
					pausePosition = 0;
					
					if (!autoStart && !skipOnce) {
						pause(true);
						skipOnce = true;
						return;
					} else if (!sendOnce) {
						dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_START, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
						sendOnce = true;
						setStatus(PlayProgressEvent.STARTED);
					}
					
					playTimer.start();
				}
			}
		}
		
		/**
		 * Seeks to time given in the audio.
		 * 
		 * @param n	Seconds into playback to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seek(time:*):void {
			var n:Number = time as Number;
			n = Math.max(0, Math.min(snd.length, n * 1000));
			if(!_paused) {
				stop();
				play(n);
			} else {
				pausePosition = n;
			}
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Seeks to the given percent in the audio
		 * 
		 * @param n	Percent to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seekPercent(n:Number):void {
			seek((n * getEstimatedLength()) / 1000);
		}
		
		/**
		 * Stops the audio at the specified position. Sets the position given 
		 * as the pause position.
		 */
		public function stop():void {
			pausePosition = 0;
			if(sc) sc.stop();
			playTimer.stop();
			_paused = true;
		}
		
		/**
		 * Stops the audio, closes the sound class, and resets the metadata.
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function unload():void {
			stop();
			try {
				snd.close();
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
				trace2("SoundPlayer - unload : " + error.message);
			}
			setStatus(PlayProgressEvent.UNLOADED);
			_metaData = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		protected function errorHandler(e:ErrorEvent):void {
			trace2("SoundPlayer - " + e.type + " : " + e.text);
			dispatchEvent(e.clone());
		}
		
		protected function getEstimatedLength():int {
			// If the metadata length is available, use that instead
			var n:int = Math.ceil(snd.length / (snd.bytesLoaded / snd.bytesTotal));
			return (_metaData) ? (_metaData.TLEN) ? _metaData.TLEN : n : n;
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
		
		protected function soundHandler(e:Event):void {
			switch (e.type) {
				case Event.COMPLETE :
					_loadCurrent = snd.bytesLoaded;
					_loadTotal = snd.bytesTotal;
					dispatchEvent(new LoadEvent(LoadEvent.LOAD_COMPLETE, false, false, strURL, this, timeTotal));
					break;
				case Event.ID3 :
					_metaData = e.target.id3;
					dispatchEvent(new MetaDataEvent(MetaDataEvent.METADATA, false, false, _metaData));
					break;
				case Event.SOUND_COMPLETE :
					if (autoRewind) {
						stop();
					}
					dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_COMPLETE, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
					break;
				case TimerEvent.TIMER :
					dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
					break;
			}
		}
		
		protected function trace2(...arguements):void {
			if (debug) trace(arguements);
		}
		
		protected function updateSoundTransform():void {
			if (sc) sc.soundTransform = getSoundTransform();
		}
		
		protected function getSoundTransform():SoundTransform {
			var transform:SoundTransform = new SoundTransform(_volume, _pan);
			transform.leftToLeft = _leftToLeft;
			transform.leftToRight = _leftToRight;
			transform.rightToLeft = _rightToLeft;
			transform.rightToRight = _rightToRight;
			return transform;
		}
	}
}