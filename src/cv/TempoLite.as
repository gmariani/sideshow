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

package cv {

	import cv.data.PlayList;
	import cv.events.LoadEvent;
	import cv.events.MetaDataEvent;
	import cv.events.PlayProgressEvent;
	import cv.interfaces.IMediaPlayer;
	import cv.interfaces.IPlaylistParser;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	
	/**
	 * Dispatched from the PlayList when a change has occured
	 *
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * Dispatched everytime a cue point is encountered
	 *
	 * @eventType cv.events.MetaDataEvent.CUE_POINT
	 */
	[Event(name = "cuePoint", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched as a media file has completed loading
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
	 * Dispatched after Tempo has begun loading the next item, also at the end of an item playing
	 *
	 * @eventType cv.TempoLite.NEXT
	 */
	[Event(name = "next", type = "flash.events.Event")]
	
	/**
	 * Dispatched as a media file finishes playing
	 *
	 * @eventType flash.events.ProgressEvent.PLAY_COMPLETE
	 */
	[Event(name = "playComplete", type = "flash.events.Event")]
	
	/**
	 * Dispatched as a media file is playing
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_PROGRESS
	 */
	[Event(name="playProgress", type="cv.events.PlayProgressEvent")]
	
	/**
	 * Dispatched once as a media file first begins to play
	 *
	 * @eventType cv.TempoLite.PLAY_START
	 */
	[Event(name = "playStart", type = "flash.events.Event")]
	
	/**
	 * Dispatched after Tempo has begun loading the previous item
	 *
	 * @eventType cv.TempoLite.PREVIOUS
	 */
	[Event(name = "previous", type = "flash.events.Event")]
	
	/**
	 * Dispatched from the PlayListManager when ever an item is removed, or updated, or the entire list is updated
	 *
	 * @eventType cv.TempoLite.REFRESH_PLAYLIST
	 */
	[Event(name = "refreshPlaylist", type = "flash.events.Event")]
	
	/**
	 * Dispatched whenever the isPlaying, isReadyToPlay or isPause properties have changed.
	 *
	 * @eventType cv.TempoLite.STATUS
	 */
	[Event(name = "status", type = "flash.events.Event")]
	
	/**
	 * Dispatched as metadata is receieved from a player
	 *
	 * @eventType cv.events.MetaDataEvent.METADATA
	 */
	[Event(name="metadata", type="cv.events.MetaDataEvent")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 3.0.5<br>
	 * <h3>Date:</h3> 5/04/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * TempoLite is based off of its sister project Tempo this is a parsed down version that 
	 * does not handle a UI. TempoLite is best compared with players like video.Maru, in 
	 * the sense that it’s just a component that is dragged on stage and handles all of 
	 * the media playback. This allows for a UI as complicated as you want to make it while 
	 * the actually playback is handled by TempoLite.
	 * <br>
	 * <br>
	 * <h3>Coded By:</h3> Gabriel Mariani, gabriel[at]coursevector.com<br>
	 * Copyright 2009, Course Vector (This work is subject to the terms in http://blog.coursevector.com/terms.)<br>
	 * <br>
	 * <h3>Notes:</h3>
	 * <ul>
	 * 		<li>This class will add about 15kb to your Flash file.</li>
	 * </ul>
	 * <hr>
	 * <ul>
	 * <li>3.0.5
	 * <ul>
	 * 		<li>Updated NetStreamPlayer to 3.0.5</li>
	 * 		<li>Updated SoundPlayer to 3.0.5</li>
	 * 		<li>Updated ImagePlayer to 1.0.4</li>
	 * </ul>
	 * </li>
	 * <li>3.0.4
	 * <ul>
	 * 		<li>Updated NetStreamPlayer to 3.0.4</li>
	 * 		<li>Updated SoundPlayer to 3.0.4</li>
	 * 		<li>Updated ImagePlayer to 1.0.3</li>
	 * 		<li>currentPercent is now a number from 0 - 1</li>
	 * 		<li>seekPercent is now accepts a number from 0 - 1</li>
	 * </ul>
	 * </li>
	 * <li>3.0.3
	 * <ul>
	 * 		<li>Updated NetStreamPlayer to 3.0.3</li>
	 * </ul>
	 * </li>
	 * <li>3.0.2
	 * <ul>
	 * 		<li>Changed loadCurrent and loadTotal to uint</li>
	 * </ul>
	 * </li>
	 * <li>3.0.1
	 * <ul>
	 * 		<li>load() and seek() are now typed to *. </li>
	 * </ul>
	 * </li>
	 * <li>3.0.0
	 * <ul>
	 * 		<li>Changed unloadMedia() to just unload()</li>
	 * 		<li>Changed bufferTime to just buffer</li>
	 * </ul>
	 * </li>
	 * </ul>
	 * 
	 * @example This is the same code as in the TempoLiteDemo.fla
	 * <br/><br/>
	 * <listing version="3.0">
	 * import cv.TempoLite;
	 * import cv.media.SoundPlayer;
	 * import cv.media.NetStreamPlayer;
	 * import cv.media.RTMPPlayer;
	 * import cv.media.ImagePlayer;
	 * import flash.events.Event;
	 * import cv.events.LoadEvent;
	 * import cv.events.PlayProgressEvent;
	 * import cv.events.MetaDataEvent;
	 * import cv.formats.*;
	 * 
	 * var tempo:TempoLite = new TempoLite(null, [ASX, ATOM, B4S, M3U, PLS, XSPF]);
	 * tempo.debug = true;
	 * 
	 * var nsP:NetStreamPlayer = new NetStreamPlayer();
	 * nsP.video = vidScreen;
	 * tempo.addPlayer(nsP);
	 * nsP.debug = true;
	 * 
	 * var sndP:SoundPlayer = new SoundPlayer();
	 * sndP.debug = true;
	 * tempo.addPlayer(sndP);
	 * 
	 * var imgP:ImagePlayer = new ImagePlayer();
	 * this.addChildAt(imgP, 0);
	 * imgP.debug = true;
	 * tempo.addPlayer(imgP);
	 * 
	 * var rtP:RTMPPlayer = new RTMPPlayer();
	 * rtP.streamHost = "rtmp://cp34534.edgefcs.net/ondemand";
	 * //rtP.video = vidScreen;
	 * //rtP.debug = true;
	 * //tempo.addPlayer(rtP);
	 * 
	 * //tempo.load("images/2_1600.jpg");
	 * //tempo.load({url:"34548/PodcastIntro", extOverride:"flv"});
	 * //tempo.load("music/01 Sunrise Projector.mp3");
	 * //tempo.loadPlayList("playlists/xspf_example.xml");
	 * //tempo.loadPlayList("playlists/pls_example.pls");
	 * //tempo.loadPlayList("playlists/m3u_example.m3u");
	 * //tempo.loadPlayList("playlists/b4s_example.b4s");
	 * //tempo.loadPlayList("playlists/asx_example.xml");
	 * tempo.loadPlayList("playlists/atom_example.xml");
	 * </listing>
     */
	
    public class TempoLite extends EventDispatcher implements IMediaPlayer {
		
		/**
         * The current version of TempoLite in use.
		 */
		public static const VERSION:String = "3.0.5";
		
		/**
		 * Enables/Disables debug traces
		 */
		public var debug:Boolean = false;
		
		// Events
		public static const NEXT:String = "next";
		public static const PREVIOUS:String = "prev";
		public static const REFRESH_PLAYLIST:String = "refreshPlaylist";
		public static const NEW_PLAYLIST:String = "newPlaylist";
		public static const REPEAT_TRACK:String = "track";
		public static const REPEAT_ALL:String = "all";
		public static const REPEAT_NONE:String = "none";
		
		// Private
		protected var _autoStart:Boolean = true;
		protected var _autoStartIndex:int = 0;
		protected var _cM:IMediaPlayer;
		protected var _ext:String; // File extension
		protected var _list:PlayList =  new PlayList();
		protected var _listShuffled:PlayList;
		protected var _players:Array = new Array();
		protected var _repeat:Boolean = false;
		protected var _repeatAll:Boolean = false;
		protected var _shuffle:Boolean = false;
		protected var strRepeat:String;
		protected var _volume:Number = 0.5;
		protected var _pause:Boolean = false;
		protected var _parsers:Array = new Array();
		
		/**
		 * Constructor. 
		 * 
		 * This creates a new TempoLite instance.
		 * 
		 * @param	players An array of players to use with TempoLite
		 */
		public function TempoLite(players:Array = null, formats:Array = null) {
			trace2("Course Vector TempoLite: v" + VERSION);
			
			strRepeat = REPEAT_NONE;
			
			var i:int = players ? players.length : 0;
			while (i--) {
				addPlayer(players[i]);
			}
			
			// Set current media manager
			if(_players[0]) _cM = _players[0];
			
			i = formats ? formats.length : 0;
			while (i--) {
				_parsers.push(new formats[i]);
			}
			
			updateList();
		}
		
		//--------------------------------------
		// IMediaPlayer Properties
		//--------------------------------------
		
		/** 
		 * Whether a video will play immediately when a playlist is loaded.
		 */
		public function get autoStart():Boolean { return _autoStart }
		/** @private **/
		public function set autoStart(v:Boolean):void {
			_autoStart = v;
			setPlayersProp("autoStart", v);
		}
		
		/**
		 * Retrieve the current play progress as a percent.
		 */
		public function get currentPercent():Number { return _cM ? _cM.currentPercent : 0 }
		
		/** 
		 * If TempoLite is currently paused.
		 */
		public function get paused():Boolean { return _cM ? _cM.paused : true }
		
		/** 
		 * Current status of media
		 */
		public function get status():String { return _cM ? _cM.status : PlayProgressEvent.UNLOADED }
		
		/**
		 * Retrieve the current bytes loaded of the current item.
		 */
		public function get loadCurrent():uint { return _cM ? _cM.loadCurrent : 0 }
		
		/**
		 * Retrieve the total bytes to load of the current item.
		 */
		public function get loadTotal():uint {	return _cM ? _cM.loadTotal : 0 }
		
		/** 
		 * A number from 0 to 1 determines volume.
		 *
		 * @default 0.5
		 */
		public function get volume():Number { return _volume }
		/** @private **/
		public function set volume(v:Number):void {
			var n:Number = Math.max(0, Math.min(1, v));
			_volume = n;
			setPlayersProp("volume", _volume);
		}
		
		/**
		 * Retrieve the metadata from the current item playing if available.
		 */
		public function get metaData():Object { return _cM ? _cM.metaData : { } }
		
		/**
		 * Retrieve the current play time of the current item playing.
		 * 
		 * @return the current play time of the item playing.
		 */
		public function get timeCurrent():Number {
			var n:Number = _cM.timeCurrent != 0 ? _cM.timeCurrent / 1000 : 0;
			return int(String(n.toFixed(3)).replace(".", ""));
		}
		
		/**
		 * Retrieve the play time remaining of the current item playing.
		 * 
		 * @return the play time remaining of the item playing.
		 */
		public function get timeLeft():Number {
			var n:Number = _cM.timeLeft != 0 ? _cM.timeLeft / 1000 : 0;
			return -1 * int(String(n.toFixed(3)).replace(".", ""));
		}
		
		/**
		 * Retrieve the total play time of the current item playing.
		 * 
		 * @return the total play time of the item playing.
		 */
		public function get timeTotal():Number {
			var n:Number = _cM.timeTotal != 0 ? _cM.timeTotal / 1000 : 0;
			return int(String(n.toFixed(3)).replace(".", ""));
		}
		
		//--------------------------------------
		// TempoLite Properties
		//--------------------------------------
		
		/** 
		 * If autoStart is true, the index of the item in the playlist to play first.
		 */
		public function get autoStartIndex():int { return _autoStartIndex }
		/** @private **/
		public function set autoStartIndex(v:int):void {
			_autoStartIndex = v;
		}
		
		/**
		 * Retrieve the current index in the playlist.
		 */
		public function get currentIndex():uint { return _list.index }
		
		/**
		 * Retrieve the current item playing.
		 */
		public function get currentItem():Object { return _list.getCurrent() }
		
		/** 
		 * Retrieves the number of items in the playlist.
		 */
		public function get length():uint { return _list.length }
		
		/**
		 * Retrieve the current playlist in <code>PlayList</code> format (enhanced array).
		 */
		public function get list():PlayList { return _list }
		
		/**
		 * Retrieve the current shuffled playlist in <code>PlayList</code> format (enhanced array).
		 */
		public function get listShuffled():PlayList { return _listShuffled }
		
		/** 
		 * Sets whether repeat is enabled, or which type of repeat is enabled.
		 * Accepted values are:
		 * <li>TempoLite.REPEAT_ALL</li>
		 * <li>TempoLite.REPEAT_TRACK</li>
		 * <li>TempoLite.REPEAT_NONE</li>
		 * 
		 * @default TempoLite.REPEAT_NONE
		 */
		public function get repeat():String { return strRepeat }
		/** @private **/
		public function set repeat(v:String):void {
			switch(v) {
				case REPEAT_ALL :
					_repeatAll = list.repeatAll = true;
					_repeat = list.repeat = false;
					strRepeat = v;
					break;
				case REPEAT_TRACK : 
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = true;
					strRepeat = v;
					break;
				case REPEAT_NONE :
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = false;
					strRepeat = v;
				default:
					return;
			}
		}
		
		/** 
		 * Whether to shuffle the playlist or not.
		 *
		 * @default false
		 */
		public function get shuffle():Boolean { return _shuffle }
		/** @private **/
		public function set shuffle(v:Boolean):void { _shuffle = v }
		
		//--------------------------------------
		//  IMediaPlayer Methods
		//--------------------------------------
		
		public function isValid(ext:String, url:String):Boolean {
			return false;
		}
		
		/**
		 * Create a playlist of a single item and load the item.
		 * 
		 * @param item The url or the item object to be played.
		 */
		public function load(item:*):void {
			if (item == null) throw Error("Must pass a valid url or item object to play");
			_list = new PlayList();
			addItem(item);
			onNewPlaylist();
		}
		
		/**
		 * Pauses the current playback.
		 * 
		 * @default true
		 * @param b Value to set pause to
		 */
		public function pause(b:Boolean = true):void {
			_pause = b;
			if(_cM) _cM.pause(_pause);
		}
		
		/**
		 * Plays starting at the given position.
		 * 
		 * @default 0
		 * @param pos	Position to play from
		 */
		public function play(pos:int = 0):void {
			if(_cM) _cM.play(pos);
		}
		
		/**
		 * Seek to a specific time (in seconds) in the current item playing.
		 * Pass a string of the time to seek relative to the current play time.
		 * 
		 * @param time Specific time to seek to, in seconds
		 */
		public function seek(time:*):void {
			var n:Number = isNaN(Number(time)) ? 0 : Number(time);
			if(_cM) {
				if (time is String) n += _cM.timeCurrent / 1000;
				if (time is String) n *= 1000;
				_cM.seek(n);
			}
		}
		
		/**
		 * Seek to a specific percent (0 - 1) in the current item playing.
		 * 
		 * @param percent Percentage to seek to
		 */
		public function seekPercent(percent:Number):void {
			if(_cM) _cM.seekPercent(percent);
		}
		
		/**
		 * Stops the audio at the specified position. Sets the position given as the pause position.
		 */
		public function stop():void {
			if(_cM) _cM.stop();
		}
		
		/**
		 * Unloads the current item playing. 
		 */
		public function unload():void {
			callPlayersMethod("unload");
		}
		
		//--------------------------------------
		// TempoLite Methods
		//--------------------------------------
		
		/**
		 * Add an item to the playlist at the end, or at index specified.
		 * 
		 * @param item	item to be added.
		 * 
		 * @default -1
		 * @param index where the item should be added in the playlist.
		 */
		public function addItem(item:*, index:int = -1):uint {
			item = getItemObject(item);
			if (index >= 0) {
				var a:Array = _list.splice(index);
				_list[index] = item;
				_list = _list.concat(a) as PlayList;
			} else {
				index = _list.push(item);
			}
			
			updateList();
			
			return index;
		}
		
		/**
		 * Adds a player for use by TempoLite. Which can enable TempoLite to
		 * handle more types of media.
		 * 
		 * @param	player	The player to add
		 */
		public function addPlayer(player:IMediaPlayer):uint {
			var f:Function = player.addEventListener;
			f(LoadEvent.LOAD_START, 			eventHandler, false, 0, true); //LoadEvent
			f(LoadEvent.LOAD_PROGRESS, 			eventHandler, false, 0, true); //ProgressEvent
			f(LoadEvent.LOAD_COMPLETE, 			eventHandler, false, 0, true);
			f(Event.CHANGE, 					eventHandler, false, 0, true);
			f(PlayProgressEvent.PLAY_START, 	eventHandler, false, 0, true);
			f(PlayProgressEvent.STATUS, 		eventHandler, false, 0, true);
			f(PlayProgressEvent.PLAY_PROGRESS, 	eventHandler, false, 0, true); // PlayProgressEvent
			f(PlayProgressEvent.PLAY_COMPLETE, 	playlistHandler, false, 0, true);
			f(MetaDataEvent.METADATA, 			metaDataHandler, false, 0, true); //MetaDataEvent
			f(MetaDataEvent.CUE_POINT, 			eventHandler, false, 0, true);
			var index:uint = _players.push(player);
			
			if (_cM == null) _cM = _players[0];
			return index;
		}
		
		/**
		 * Clears the current playlist.
		 */
		public function clearItems():void {
			_list = new PlayList();
			onNewPlaylist();
		}
		
		/**
		 * Loads a new playlist and clears any previous playlsit.
		 * 
		 * @param url The path to the playlist file.
		 */
		public function loadPlayList(url:String):void {
			if (!url) throw Error("Must pass a valid url to the playlist");
			
			_ext = url.substr(-3).toLowerCase();
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadedHandler);
			loader.load(new URLRequest(url));
		}
		
		/**
		 * Plays the next item in the playlist.
		 */
		public function next():void { 
			var o:Object;
			if (!_shuffle || _list.repeat || _list.repeatAll) {
				o = _list.getNext();
				_listShuffled.index = _list.index;
			} else {
				o = _listShuffled.getNext();
				_list.index = o.index;
				o = _list.getCurrent();
			}
			if (o) loadItem(o);
		}
		
		/**
		 * Plays the current item in the playlist, or at the 
		 * specified index in the playlist.
		 * 
		 * @default 0
		 * @param index The index of the item to be played
		 */
		public function playItem(index:uint = 0):void {
			_list.index = index;
			loadItem(_list.getCurrent());
		}
		
		/**
		 * Plays the previous item in the playlist.
		 * 
		 * @see #event:previous
		 */
		public function previous():void {
			var o:Object;
			if(!_shuffle || _list.repeat || _list.repeatAll) {
				o = _list.getPrevious();
				_listShuffled.index = _list.index;
			} else {
				o = _listShuffled.getPrevious();
				_list.index = o.index;
				o = _list.getCurrent();
			}
			if (o) loadItem(o);
			dispatchEvent(new Event(TempoLite.PREVIOUS));
		}
		
		/**
		 * Remove an item from the playlist from the end, or at index specified.
		 * 
		 * @default -1
		 * @param index The index of the item to be removed
		 * 
		 * @see #event:refreshPlaylist
		 */
		public function removeItem(index:int = -1):void {
			if (index < 0) index = _list.length - 1; // Get last item in the list
			_list.removeAt(index);
			dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
		}
		
		/**
		 * Remove a player from TempoLite.
		 * 
		 * @param	player	The player to be removed.
		 */
		public function removePlayer(player:IMediaPlayer):void {
			var i:uint = _players.length;
			while (i--) {
				if (_players[i] === player) {
					player.unload();
					var f:Function = player.removeEventListener;
					f(LoadEvent.LOAD_START, 			eventHandler);
					f(LoadEvent.LOAD_PROGRESS, 			eventHandler);
					f(LoadEvent.LOAD_COMPLETE, 			eventHandler);
					f(Event.CHANGE, 					eventHandler);
					f(PlayProgressEvent.PLAY_START, 	eventHandler);
					f(PlayProgressEvent.STATUS, 		eventHandler);
					f(PlayProgressEvent.PLAY_PROGRESS, 	eventHandler);
					f(PlayProgressEvent.PLAY_COMPLETE, 	playlistHandler);
					f(MetaDataEvent.METADATA, 			metaDataHandler);
					f(MetaDataEvent.CUE_POINT, 			eventHandler);
					_players.splice(i, 1);
					if (_cM === player) _cM = _players[0] || null;
				}
			}
		}
		
		/**
		 * Converts a time in 00:00:000 format and converts it back into a number.
		 * 
		 * @param	text The string to convert
		 * @return The converted number
		 */
		public static function stringToTime(text:String):int {
            var arr:Array = text.split(":");
            var time:Number = 0;
            if (arr.length > 1) {
				// Milliseconds
                time = Number(arr[arr.length--]);
				// Seconds
				time += Number(arr[arr.length - 2]) * 60;
                if (arr.length == 3) {
					// Minutes
                    time += Number(arr[arr.length - 3]) * 3600;
                }
            } else {
                time = Number(text);
            }
            return int(time);
		}
		
		/**
		 * Converts milliseconds to a 00:00:000 format.
		 * 
		 * @param	n Milliseconds to convert
		 * @return The converted string
		 */
		public static function timeToString(n:int):String {
			var ms:int = int(n % 1000);
			var s:int = n / 1000;
			var m:int = int(s / 60);
			s = int(s % 60);
			return zero(m) + ":" + zero(s) + ":" + zero(ms, true);
		}
		
		/**
		 * Updates a property of an Item in the playlist. This is used in 
		 * situations where the metadata has been loaded, and the correct 
		 * duration or title is updated for the playlist display. Dispatches 
		 * the TempoLite.REFRESH_PLAYLIST event.
		 * 
		 * @param	index 	The index of the item to be updated
		 * @param	key		The property name (length, title, etc)
		 * @param	value	The value to update the prop to.
		 */
		public function updateItem(index:uint, key:String, value:*):void {
			if(_list[index]) {
				if(key == "length") value /= 1000;
				if(_list[index][key] != value) {
					_list[index][key] = value;
					dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
				}
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		protected function callPlayersMethod(methodName:String, methodValue:* = null):void {
			var i:int = _players.length;
			while (i--) {
				if (methodValue != null) {
					_players[i][methodName](methodValue);
				} else {
					_players[i][methodName]();
				}
			}
		}
		
		protected function eventHandler(e:Event):void {
			dispatchEvent(e.clone());
		}
		
		protected function getItemObject(item:*):Object {
			if (item is String) {
				var url:String = item as String;
				item = new Object();
				item.url = url;
			}
			
			if (!item.hasOwnProperty("title")) item.title = "";
			if (!item.hasOwnProperty("length")) item.length = -1;
			return item;
		}
		
		// Determines what kind of playlist is loaded and returns in PlayList format
		protected function getType(data:String):PlayList {
			var i:int = _parsers.length;
			while (i--) {
				var p:IPlaylistParser = _parsers[i];
				if (p.isValid(_ext, data)) {
					return p.toPlayList(data);
					break;
				}
			}
			
			trace2("TempoLite - Warning : Unknown playlist file type; creating a new playlist.");
			return new PlayList();
		}
		
		protected function loadItem(o:Object):void {
			unload();
			
			var ext:String = o.hasOwnProperty("extOverride") ? o.extOverride : o.url.substr( -3).toLowerCase();
			var i:int = _players.length;
			while (i--) {
				if (IMediaPlayer(_players[i]).isValid(ext, o.url)) {
					_cM = _players[i];
					_cM.load(o.url);
					return;
					break;
				}
			}
			
			trace2("TempoLite - Warning : No player loaded capable of playing '" + o.url + "'");
		}
		
		protected function loadedHandler(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			_list = getType(loader.data as String);
			_list.index = 0;
			updateList();
			
			onNewPlaylist();
		}
		
		protected function metaDataHandler(e:MetaDataEvent):void {
			if (e.data.hasOwnProperty("TLEN")) {
				// MP3
				updateItem(_list.index, "length", e.data.TLEN);
			} else if (e.data.hasOwnProperty("duration")) {
				// Netstream
				updateItem(_list.index, "length", e.data.duration * 1000);
			}
			dispatchEvent(e.clone());
		}
		
		protected function onNewPlaylist():void {
			dispatchEvent(new Event(TempoLite.NEW_PLAYLIST));
			if (_autoStart) _list.index = _autoStartIndex;
			if (_list.getCurrent()) loadItem(_list.getCurrent());
		}
		
		protected function playlistHandler(e:Event):void {
			switch(e.type) {
				case PlayProgressEvent.PLAY_COMPLETE :
					next();
					dispatchEvent(e.clone());
					dispatchEvent(new Event(TempoLite.NEXT));
					break;
			}
		}
		
		protected function setPlayersProp(propName:String, propValue:*):void {
			var i:int = _players.length;
			while (i--) {
				_players[i][propName] = propValue;
			}
		}
		
		protected function shuffleList(arr:PlayList):PlayList {
			var temp:PlayList = new PlayList();
			var idx:int;
			var l:int = arr.length;
			while (l > 0) {
				idx = int(Math.random() * l);
				temp.push(arr[idx]);
				arr.splice(idx, 1);
				l = arr.length;
			}
			return temp;
		}
		
		protected function trace2(...args):void {
			if (debug) trace(args);
		}
		
		protected function updateList():void {
			_listShuffled = new PlayList();
			
			// Check for files without a title from metadata
			// Extracts the file name from the url if there is no given title
			var l:int = _list.length;
			var i:int;
			for (i = 0; i < l; i++) {
				var item:Object = _list[i];
				if (item.title == "") {
					var arrURL:Array = item.url.indexOf("\\") != -1 ? item.url.split("\\") : item.url.split("/");
					item.title = arrURL[arrURL.length - 1];
				}
				
				_listShuffled.push(item);
			}
			
			l = _listShuffled.length;
			for (i = 0; i < l; i++) {
				_listShuffled[i].index = i;
			}
			_listShuffled = shuffleList(_listShuffled);
			_listShuffled.index = _list.index;
			
			_list.repeat = _repeat;
			_list.repeatAll = _repeatAll;
			_listShuffled.repeat = _repeat;
			_listShuffled.repeatAll = _repeatAll;
			dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
		}
		
		protected static function zero(n:int, isMS:Boolean = false):String {
			if(isMS) {
				if(n < 10) return "00" + n;
				if(n < 100) return "0" + n;
			}
			if (n < 10) return "0" + n;
			return "" + n;
		}
    }
}