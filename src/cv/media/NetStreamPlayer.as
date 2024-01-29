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
	
	import cv.interfaces.IMediaPlayer;
	import cv.events.MetaDataEvent;
	import cv.events.LoadEvent;
	import cv.events.PlayProgressEvent;
	import flash.errors.IOError;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when a cue point is reached.
	 *
	 * @eventType cv.events.MetadataEvent.CUE_POINT
	 */
	[Event(name = "cuePoint", type = "cv.events.MetadataEvent")]
	
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
	 * @eventType cv.events.LoadEvent.LOAD_START
	 */
	[Event(name = "loadStart", type = "cv.events.LoadEvent")]
	
	/**
	 * Dispatched as metadata is receieved from the media playing
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
	 * Dispatched when isPause or isPlaying has updated.
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
	 * The NetStreamPlayer class is a facade for controlling loading, and playing
	 * of video, streaming video and M4A files within Flash. It intelligently handles pausing, and
	 * loading.
	 * 
	 * Note: Sometimes playhead won't move on videos, this is because there is no 
	 * metadata describing it's duration. If this occurs, there is no way to
	 * calculate how long a video is, so it stops the playhead from moving.
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
	 * 		<li>seekPercent is now accepts a number from 0 - 1</li>
	 * </ul>
	 * </li>
	 * <li>3.0.3
	 * <ul>
	 * 		<li>Fixed PLAY_START</li>
	 * 		<li>STATUS is now dispatched when stopped</li>
	 * </ul>
	 * </li>
	 * <li>3.0.2
	 * <ul>
	 * 		<li>Tweaked how load complete reports</li>
	 * 		<li>loadCurrent and loadTotal are now uints and more accurate</li>
	 * </ul>
	 * </li>
	 * <li>3.0.1
	 * <ul>
	 * 		<li>Changed how PLAY_START and autoStart is handled. autoStart is no longer overwritten and will pause before any audio is heard.</li>
	 * 		<li>Handles autostart and PLAY_START better. Also has a new status of STARTED to differentiate between when autoStart and the first play().</li>
	 * 		<li>Added autoRewind prop. If set, it will rewind after PLAY_COMPLETE so the play button can be used to resume.</li>
	 * </ul>
	 * </li>
	 * <li>3.0.0
	 * <ul>
	 * 		<li>Refactored release</li>
	 * </ul>
	 * </li>
	 * </ul>
     */
	public class NetStreamPlayer extends EventDispatcher implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "3.0.5";
		
		public var debug:Boolean = false;
		
		/** 
		 * Gets or sets whether the video object will be scaled to the metadata given
		 * for video dimensions.
		 */
		public var autoScale:Boolean = false;
		
		/**
		 * Will automatically call stop (rewind) after playing complete. If disabled, this will pause
		 * the player instead.
		 */
		public var autoRewind:Boolean = false;
		
		protected var _autoStart:Boolean = true;
		protected var _buffer:Number = 0.1;
		protected var _loadCurrent:uint;
		protected var _loadTotal:uint;
		protected var _metaData:Object;
		protected var _volume:Number = .5;
		protected var _leftToLeft:Number = 1;
		protected var _leftToRight:Number = 0;
		protected var _rightToLeft:Number = 0;
		protected var _rightToRight:Number = 1;
		protected var _pan:Number = 0;
		protected var arrFileTypes:Array = ["flv","f4v","f4p","f4b","f4a","3gp","3g2","mov","mp4","m4v","m4a","p4v"];
		protected var _status:String = PlayProgressEvent.UNLOADED;
		protected var _paused:Boolean = false;
		protected var loadTimer:Timer = new Timer(10);
		protected var ns:NetStream;
		protected var playTimer:Timer = new Timer(10);
		protected var strURL:String;
		protected var vid:Video;
		protected var sendOnce:Boolean = false;
		protected var skipOnce:Boolean = false;
		protected var _streamHost:String = null;
		protected var _encoding:uint = 0;
		protected var nc:NetConnection;
		protected var client:Object;
		
		public function NetStreamPlayer() {
			playTimer.addEventListener(TimerEvent.TIMER, playTimerHandler, false, 0, true);
			loadTimer.addEventListener(TimerEvent.TIMER, loadTimerHandler, false, 0, true);
			client = { onCuePoint:onCuePoint, onMetaData:onMetaData };
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
		 * Gets or sets how long the NetStreamPlayer should buffer the video before playing, in seconds.
		 */
		public function get buffer():int { return _buffer }
		/** @private **/
		public function set buffer(n:int):void {
			if(n <= 0) n = 0.1;
			_buffer = n;
		}
		
		/** 
		 * Gets the current play progress in terms of percent
		 */
		public function get currentPercent():Number {	return ns ? (ns.time * 1000) / getEstimatedLength() : 0 }
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the left speaker.
		 */
		public function get leftToLeft():Number { return _leftToLeft }
		/** @private **/
		public function set leftToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_leftToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the right speaker.
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
		 */
		public function get metaData():Object { return _metaData }
		
		/** 
		 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right). 
		 * A value of 0 represents no panning (balanced center between right and left). 
		 */
		public function get pan():Number { return _pan }
		/** @private **/
		public function set pan(n:Number):void {
			var v:Number = Math.max(-1, Math.min(1, n));
			_pan = v;
			if (ns) {
				var transform:SoundTransform = ns.soundTransform;
				transform.pan = _pan;
				ns.soundTransform = transform;
				
				_leftToLeft = transform.leftToLeft;
				_leftToRight = transform.leftToRight;
				_rightToLeft = transform.rightToLeft;
				_rightToRight = transform.rightToRight;
			}
		}
		
		/**
		 * Returns the pause status of the player.
		 */
		public function get paused():Boolean { return _paused }
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the left speaker.
		 */
		public function get rightToLeft():Number { return _rightToLeft }
		/** @private **/
		public function set rightToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_rightToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the right speaker.
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
		public function get timeCurrent():Number { return ns ? ns.time * 1000 : 0 }
		
		/** 
		 * Gets the remaining play time in milliseconds
		 */
		public function get timeLeft():Number {	return ns ? timeTotal - timeCurrent : 0	}
		
		/** 
		 * Gets the total play time in milliseconds
		 */
		public function get timeTotal():Number { return getEstimatedLength() }
		
		/** 
		 * Gets or sets the reference to the display video object.
		 */
		public function get video():Video {	return vid }
		/** @private **/
		public function set video(v:Video):void {
			vid = v;
			
			if(ns) vid.attachNetStream(ns);
			
			if(autoScale && _metaData) {
				vid.width = _metaData.width;
				vid.height = _metaData.height;
			}
		}
		
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
		 * Validates if the given filetype is compatible to be played with NetStreamPlayer. 
		 * The acceptable file types are :
		 * <ul>
		 * <li>flv : video/x-flv Flash Video</li>
		 * <li>f4v : video/mp4 	Flash Video</li>
		 * <li>f4p : video/mp4 	Protected Flash Video</li>
		 * <li>f4b : audio/mp4 	Flash Audio Book</li>
		 * <li>f4a : audio/mp4 	Flash Audio</li>
		 * <li>3gp : video/3gpp  audio/3gpp	3GPP for GSM-based Phones</li>
		 * <li>3g2 : video/3gpp  audio/3gpp	3GPP2 for CDMA-based Phones</li>
		 * <li>mov : video/quicktime	QuickTime Movie</li>
		 * <li>mp4 : video/mp4 	H.264 MPEG-4 Video</li>
		 * <li>m4v : video/mp4 	H.264 MPEG-4 Video</li>
		 * <li>m4a : audio/mp4 	Audio-only MPEG-4</li>
		 * <li>p4v : audio/mp4 	Protected H.264 MPEG-4 Video</li>
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
		 * @fparam s	The url of the file to be loaded
		 */
		public function load(item:*):void {
			var s:String = item as String;
			if (s == "" || s == null) {
				throw new Error("NetStreamPlayer - load : Must enter a url to load a file");
				return;
			}
			
			unload();
			
			strURL = unescape(s);
			
			createConnection(_streamHost);
		}
		
		/**
		 * Loads a netstream from the BulkLoader to be played. This cannot be used in 
		 * conjunction with TempoLite since the location is not a url. Using
		 * loadAsset will IGNORE any streamhosts set becuase you can only use this
		 * if the video is progressively downloaded.
		 * 
		 * @internal
		 * 	Not complete yet. BulkLoader seems to handle NetStreams kinda funky, staying
		 * away til this is cleaned up.
		 * 
		 * @param	netstream	The netstream object from the BulkLoader
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		/*public function loadAsset(netstream:NetStream):void {
			if (netstream == null) {
				throw new Error("NetStreamPlayer - loadAsset : Must enter a netstream to load");
				return;
			}
			
			unload();
			
			createConnection();
			
			createStream(netstream);
		}*/
		
		/**
		 * Controls the pause of the media
		 * 
		 * @default true
		 * @param b	Whether to pause or not
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function pause(b:Boolean = true):void {
			_paused = b;
			
			if (b) {
				if(ns) ns.pause();
				playTimer.stop();
			} else {
				if(ns) ns.resume();
				playTimer.start();
			}
			
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Plays the media, starting at the given position.
		 * 
		 * @default 0
		 * @param pos	Position to play from
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function play(pos:int = 0):void {
			if (_status != PlayProgressEvent.LOADING) {
				if(_paused) {
					pause(false);
					return;
				} else {
					ns.play(strURL);
					ns.seek(pos);
					updateSoundTransform();
					_paused = false;
					playTimer.start();
				}
			}
		}
		
		/**
		 * Seeks to time given in the media.
		 * 
		 * @param n	Seconds into the media to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seek(time:*):void {
			var n:Number = time as Number;
			n = Math.max(0, Math.min(getEstimatedLength(), n / 1000));
			ns.seek(n);
			if(_paused) ns.pause();
		}
		
		/**
		 * Seeks to the given percent in the media
		 * 
		 * @param n	Percent to seek to
		 * 
		 * @see cv.events.PlayProgressEvent.PLAY_PROGRESS
		 */
		public function seekPercent(n:Number):void { seek(n * getEstimatedLength()) }
		
		/**
		 * Stops the media at the specified position. Sets the position given as the pause position.
		 */
		public function stop():void {
			if (ns) {
				ns.pause();
				ns.seek(0);
			}
			playTimer.stop();
			_paused = true;
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Stops the media, closes the NetConnetion or NetStream, and resets the metadata.
		 * 
		 * @see cv.events.PlayProgressEvent.STATUS
		 */
		public function unload():void {
			stop();
			try {
				if (vid) vid.clear();
				if (_streamHost != null && _streamHost) {
					if (nc) nc.close();
				} else {
					if (ns) ns.close();
				}
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
			}
			setStatus(PlayProgressEvent.UNLOADED);
			_metaData = null;
			ns = null;
			nc = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		protected function createConnection(command:String = null):void {
			nc = new NetConnection();
			nc.client = client;
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
			nc.objectEncoding = _encoding;
			nc.connect(command);
		}
		
		protected function createStream(netstream:NetStream = null):void {
			ns = netstream || new NetStream(nc);
			ns.client = client;
			ns.bufferTime = _buffer;
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			ns.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
			if(vid) vid.attachNetStream(ns);
			
			loadTimer.start();
			
			// On Load Open
			setStatus(PlayProgressEvent.LOADED);
			sendOnce = false;
			skipOnce = false;
			_paused = false;
			play();
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_START, false, false, strURL, this, timeTotal));
		}
		
		protected function errorHandler(e:ErrorEvent):void {
			trace2("NetStreamPlayer - " + e.type + " : " + e.text);
			dispatchEvent(e.clone());
		}
		
		protected function getEstimatedLength():int {
			return (_metaData) ? _metaData.duration * 1000 : 0;
		}
		
		protected function loadTimerHandler(event:TimerEvent):void {
			try {
				_loadCurrent = ns.bytesLoaded;
				_loadTotal = ns.bytesTotal;
				if(ns.bytesLoaded == ns.bytesTotal) {
					loadTimer.stop();
					setStatus(PlayProgressEvent.LOADED);
					dispatchEvent(new LoadEvent(LoadEvent.LOAD_COMPLETE, false, false, strURL, this, timeTotal));
				} else {
					dispatchEvent(new ProgressEvent(LoadEvent.LOAD_PROGRESS, false, false, ns.bytesLoaded, ns.bytesTotal));
				}
			} catch (error:Error) {
				// Ignore this error
			}
		}
		
		protected function netStatusHandler(e:NetStatusEvent):void {
			trace2("NetStreamPlayer - netStatusHandler : " + e.info.code);
			try {
				switch (e.info.code) {
					/* Errors */
					case "NetStream.Play.Failed":
						trace2("NetStreamPlayer - netStatusHandler - Error : An error has occurred in playback. (" + e.info.code + ")");
						stop();
						break;
					case "NetStream.Play.StreamNotFound":
					case "NetConnection.Connect.Rejected":
					case "NetConnection.Connect.Failed":
						stop();
						trace2("NetStreamPlayer - netStatusHandler - Error : File/Stream not found. (" + e.info.code + ")");
						break;
					case "NetStream.Seek.InvalidTime":
						// Seek to last available time
						seek(e.info.message.details);
						break;
					case "NetStream.FileStructureInvalid":
						trace2("NetStreamPlayer - netStatusHandler - Error : The MP4's file structure is invalid. (" + e.info.code + ")");
						stop();
						break;
					case "NetStream.NoSupportedTrackFound":
						trace2("NetStreamPlayer - netStatusHandler - Error : The MP4 doesn't contain any supported tracks. (" + e.info.code + ")");
						stop();
						break;
					
					/* Status */
					/*case "NetStream.Buffer.Empty":
						//pause(true);
						break;
					case "NetStream.Buffer.Full":
						//pause(false);
						break;
					case "NetStream.Buffer.Flush":
						// Data has finished streaming, and the remaining buffer will be emptied.
						break;*/
					case "NetStream.Play.Start":
						// Video started
						if (!autoStart && !skipOnce) {
							pause(true);
							skipOnce = true;
						}
						break;
					case "NetStream.Play.Stop":
						if (autoRewind) {
							stop();
						} else {
							pause(true);
						}
						dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_COMPLETE, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
						break;
					/*case "NetStream.Play.Reset":
						//Caused by a play list reset.
						break;
					case "NetStream.Pause.Notify":
						// Paused
						break;
					case "NetStream.Unpause.Notify":
						// Resumed
						break;*/
					case "NetStream.Seek.Notify":
						// Seek was successful, delay it a bit so it's called after this event has completed becuase the actual
						// progress information hasnt updated yet.
						setTimeout(updateProgress, 50);
						break;
					/*case "NetConnection.Connect.Closed":
						//The connection was closed successfully.*/
					case "NetConnection.Connect.Success":
						//The connection attempt succeeded.
						createStream();
						break;
				}
			} catch (error:Error) {
				// Ignore this error
				trace2("NetStreamPlayer - netStatusHandler - Error : " + error.message);
			}
		}
		
		/*
		{name, parameters, time, type}
		name - The name given to the cue point when it was embedded in the video file. 
		parameters - A associative array of name/value pair strings specified for this cue point. Any valid string can be used for the parameter name or value. 
		time - The time in seconds at which the cue point occurred in the video file during playback. 
		type - The type of cue point that was reached, either navigation or event. 
		*/
		protected function onCuePoint(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.CUE_POINT, o));
		}
		
		/**
		 * Handles the metadata returned. Possible data sent:
		 * <li>canSeekToEnd</li>
		 * <li>cuePoints</li>
		 * <li>audiocodecid</li>
		 * <li>audiodelay</li>
		 * <li>audiodatarate</li>
		 * <li>videocodecid</li>
		 * <li>framerate</li>
		 * <li>videodatarate</li>
		 * <li>height - Older version of encode</li>
		 * <li>width - Older version of encode</li>
		 * <li>duration - Older version of encode</li>
		 * 
		 * @param	o
		 */
		protected function onMetaData(o:Object):void {
			_metaData = o;
			
			if(autoScale) {
				if (vid && o.hasOwnProperty("width") && o.hasOwnProperty("height")) {
					vid.width = o.width;
					vid.height = o.height;
				}
			}
			
			dispatchEvent(new MetaDataEvent(MetaDataEvent.METADATA, _metaData));
		}
		
		protected function playTimerHandler(event:TimerEvent):void {
			updateProgress();
		}
		
		protected function setStatus(str:String):void {
			_status = str;
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.STATUS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		protected function trace2(...arguements):void {
			if (debug) trace(arguements);
		}
		
		protected function updateSoundTransform():void {
			if (ns) {
				var transform:SoundTransform = ns.soundTransform;
				transform.volume = _volume;
				transform.leftToLeft = _leftToLeft;
				transform.leftToRight = _leftToRight;
				transform.rightToLeft = _rightToLeft;
				transform.rightToRight = _rightToRight;
				ns.soundTransform = transform;
				
				_pan = ns.soundTransform.pan;
			}
		}
		
		protected function updateProgress():void {
			if (!sendOnce && vid && playTimer.running) {
				if (vid.videoHeight != 0 && vid.videoWidth != 0) {
					dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_START, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
					sendOnce = true;
					setStatus(PlayProgressEvent.STARTED);
				}
			}
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
	}
}