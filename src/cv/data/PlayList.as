/**
* Generic PlayList class with some extra functionality
* 
* Since DataProvider is only used for the UI Components, you must add this to the compiler paths:
* C:\Program Files\Adobe\Adobe Flash CS3\en\Configuration\Component Source\ActionScript 3.0\User Interface
* 
* @author Gabriel Mariani
* @version 0.1
*/

package cv.data {
	
	import fl.data.DataProvider;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	//--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the index has changed or <code>getNext()</code> and <code>getPrevious()</code> were called.
	 *
	 * @eventType cv.data.PlayList.CHANGE
	 * 
	 * @see #getPrevious()
	 * @see #getNext()
	 * @see #index
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * Dispatched when the playlist has reached the end of the playlist.
	 *
	 * @eventType cv.data.PlayList.END_OF_LIST
	 *
	 * @see #nextIndex
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "endoflist", type = "flash.events.Event")]
	
	/**
	 * Dispatched when the playlist has started playing the first item.
	 *
	 * @eventType cv.data.PlayList.START_OF_LIST
	 * 
	 * @see #previousIndex
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "startoflist", type = "flash.events.Event")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The PlayList class extends the Array class and enables the management
	 * of a list of items. This includes selecting next, previous, repeat, 
	 * repeat all, and shuffling. Also allows for a current index, so the
	 * selected item can be tracked.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	public dynamic class PlayList extends Array implements IEventDispatcher {
		
		/**
         * The <code>PlayList.CHANGE</code> constant defines the value of
		 * the <code>type</code> property of the event object that is dispatched to indicate that
		 * the playlist has changed in some way.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
		 */
		public static const CHANGE:String = "change";
		
		/**
         * The <code>PlayList.END_OF_LIST</code> constant defines the value of
		 * the <code>type</code> property of the event object that is dispatched to indicate that
		 * the playlist has reached the end of the list.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
		 */
		public static const END_OF_LIST:String = "endoflist";
		
		/**
         * The <code>PlayList.START_OF_LIST</code> constant defines the value of
		 * the <code>type</code> property of the event object that is dispatched to indicate that
		 * the playlist has reached the beginning of the list.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
		 */
		public static const START_OF_LIST:String = "startoflist";
		
		private var _isShuffle:Boolean = false;
		private var _isRepeat:Boolean = false;
		private var _isRepeatAll:Boolean = false;
		private var _currentIndex:int = 0;
		private var dispatcher:EventDispatcher;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var mimetypes:Object = new Object();
		
		public function PlayList(dp:DataProvider = null):void {
			dispatcher = new EventDispatcher(this);
			
			if(dp != null) {
				var arr:Array = dp.toArray();
				var l:uint = arr.length;
				for (var i:int = 0; i < l; i++) {
					var strTitle:String = arr[i].label;
					var objData:Object = arr[i].data;
					var strURL:String = objData.url;
					var nLength:int = objData.length;
					push({ title:strTitle, url:strURL, length:nLength });
				}
			}
			
			setMimes();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/** 
		 * Gets or sets whether shuffle is enabled or not.
		 *
		 * @default false
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get shuffle():Boolean {	return _isShuffle }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set shuffle(b:Boolean):void { _isShuffle = b }
		
		/** 
		 * Gets or sets whether an item is repeated after it's finished.
		 *
		 * @default false
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get repeat():Boolean { return _isRepeat	}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set repeat(b:Boolean):void { _isRepeat = b }
		
		/** 
		 * Gets or sets whether the playlist repeats when it's finished.
		 *
		 * @default false
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get repeatAll():Boolean { return _isRepeatAll	}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set repeatAll(b:Boolean):void { _isRepeatAll = b }
		
		/** 
		 * Gets or sets the current selected item in the playlist.
		 *
		 * @default 0
		 * 
		 * @see #event:change
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get index():uint { return _currentIndex }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set index(idx:uint):void {
			if(idx >= 0 && idx < length) {
				_currentIndex = idx;
				this.dispatchEvent(new Event(PlayList.CHANGE, false));
			}
		}
		
		/** 
		 * Gets the index of the next item in the playlist.
		 *
		 * @see #event:endoflist
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get nextIndex():int {
			var idx:int = _currentIndex + 1;
			if(_isShuffle) {
				idx = getRandomIndex();
			} else if(_isRepeat) {
				idx = _currentIndex;
			} else if(idx > length - 1) {
				if(_isRepeatAll) {
					idx = 0;
				} else {
					idx = -1;
					this.dispatchEvent(new Event(PlayList.END_OF_LIST, false));
				}
			}
			return idx;
		}
		
		/** 
		 * Gets the index of the previous item in the playlist.
		 * 
		 * @see #event:startoflist
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get previousIndex():int {
			var idx:int = _currentIndex - 1;
			if(_isShuffle) {
				idx = getRandomIndex();
			} else if(_isRepeat) {
				idx = _currentIndex;
			} else if(idx < 0) {
				if(_isRepeatAll) {
					idx = length - 1;
				} else {
					idx = -1;
					this.dispatchEvent(new Event(PlayList.START_OF_LIST, false));
				}
			}
			
			return idx;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Returns a random item from the playlist.
		 * 
		 * @return <Object> The item selected at random
		 * 
		 * @see #getRandomIndex()
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getRandom():Object {
			_currentIndex = getRandomIndex();
			return this[_currentIndex];
		}
		
		/**
		 * Returns the current item from the playlist
		 * 
		 * @return <Object> The current item
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrent():Object {
			return this[_currentIndex];
		}
		
		/**
		 * Returns the next item from the playlist.
		 * 
		 * @return <Object> The next item
		 * 
		 * @see #event:change
		 * @see #nextIndex
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getNext():Object {
			var nIdx:int = nextIndex;
			var o:Object;
			
			if(nIdx != -1)	{
				_currentIndex = nIdx;
				o = this[nIdx];
			} else {
				o = null;
			}
			
			this.dispatchEvent(new Event(PlayList.CHANGE, false));
			return o;
		}
		
		/**
		 * Returns the previous item from the playlist.
		 * 
		 * @return <Object> The previous item
		 * 
		 * @see #event:change
		 * @see #previousIndex
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getPrevious():Object {
			var nIdx:int = previousIndex;
			var o:Object;
			
			if(nIdx != -1)	{
				_currentIndex = nIdx;
				o = this[nIdx];
			} else {
				o = null;
			}
			this.dispatchEvent(new Event(PlayList.CHANGE, false));
			return o;
		}
		
		/**
		 * Returns a random index from the playlist.
		 * 
		 * @return <uint> The index randomly selected
		 * 
		 * @see #getRandom()
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getRandomIndex():uint {
			return uint(Math.random() * length);
		}
		
		/**
		 * Removes the given item from the playlist.
		 * 
		 * @param item 	<Object> The item object to be removed
		 * 
		 * @return <Boolean> Whether the removal was successful or not.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function remove(item:Object):Boolean {
			for (var i:uint = 0; i < length; i++) {
				var isSame:Boolean = true;
				for (var k:String in this[i]) {
					if (item[k] != this[i][k]) {
						isSame = false;
						break;
					}
				}
				
				if(isSame) {
					splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Removes an item at a given index.
		 * 
		 * @param idx <uint> The index of the item to be removed.
		 * 
		 * @return <Boolean> Whether the removal was successful or not.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function removeAt(idx:uint):Boolean {
			if(idx >= 0 && idx < length) {
				splice(idx, 1);
				return true;
			}
			return false;
		}
		
		/**
		 * Searchs the playlist to determin if an item is listed.
		 * 
		 * @param item 	<Object> The item to be checked for.
		 * 
		 * @return <Boolean> Whether the item is in the playlist or not.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function inPlayList(item:Object):Boolean {
			for(var i:uint = 0; i < length; i++) {
				if(this[i] == item) return true;
			}
			return false;
		}
		
		/**
		 * Converts the PlayList to a DataProvider for use
		 * with components.
		 * 
		 * @return The DataProvider equivalent of the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function toDataProvider():DataProvider {
			var dp:Array = new Array();
			for (var i:int = 0; i < length; i++) {
				var objData:Object = new Object();
				for (var k:String in this[i]) {
					objData[k] = this[i][k];
				}
				dp.push({ label:this[i].title, data:objData });
			}
			
			return new DataProvider(dp);
		}
		
		/**
		 * Registers an event listener object with an EventDispatcher object so that the listener
		 *  receives notification of an event. You can register event listeners on all nodes in the
		 *  display list for a specific type of event, phase, and priority.
		 *
		 * @param type              <String> The type of event.
		 * @param listener          <Function> The listener function that processes the event. This function must accept
		 *                            an Event object as its only parameter and must return nothing, as this example shows:
		 *                            function(evt:Event):void
		 *                            The function can have any name.
		 * @param useCapture        <Boolean (default = false)> Determines whether the listener works in the capture phase or the
		 *                            target and bubbling phases. If useCapture is set to true,
		 *                            the listener processes the event only during the capture phase and not in the
		 *                            target or bubbling phase. If useCapture is false, the
		 *                            listener processes the event only during the target or bubbling phase. To listen for
		 *                            the event in all three phases, call addEventListener twice, once with
		 *                            useCapture set to true, then again with
		 *                            useCapture set to false.
		 * @param priority          <int (default = 0)> The priority level of the event listener. The priority is designated by
		 *                            a signed 32-bit integer. The higher the number, the higher the priority. All listeners
		 *                            with priority n are processed before listeners of priority n-1. If two
		 *                            or more listeners share the same priority, they are processed in the order in which they
		 *                            were added. The default priority is 0.
		 * @param useWeakReference  <Boolean (default = false)> Determines whether the reference to the listener is strong or
		 *                            weak. A strong reference (the default) prevents your listener from being garbage-collected.
		 *                            A weak reference does not. Class-level member functions are not subject to garbage
		 *                            collection, so you can set useWeakReference to true for
		 *                            class-level member functions without subjecting them to garbage collection. If you set
		 *                            useWeakReference to true for a listener that is a nested inner
		 *                            function, the function will be garbage-collected and no longer persistent. If you create
		 *                            references to the inner function (save it in another variable) then it is not
		 *                            garbage-collected and stays persistent.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		/**
		 * Dispatches an event into the event flow. The event target is the EventDispatcher
		 *  object upon which the dispatchEvent() method is called.
		 *
		 * @param event             <Event> The Event object that is dispatched into the event flow.
		 *                            If the event is being redispatched, a clone of the event is created automatically.
		 *                            After an event is dispatched, its target property cannot be changed, so you
		 *                            must create a new copy of the event for redispatching to work.
		 * @return                  <Boolean> A value of true if the event was successfully dispatched. A value of false indicates failure or that preventDefault() was called
		 *                            on the event.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		/**
		 * Checks whether the EventDispatcher object has any listeners registered for a specific type
		 *  of event. This allows you to determine where an EventDispatcher object has altered
		 *  handling of an event type in the event flow hierarchy. To determine whether a specific
		 *  event type actually triggers an event listener, use willTrigger().
		 *
		 * @param type              <String> The type of event.
		 * @return                  <Boolean> A value of true if a listener of the specified type is registered;
		 *                            false otherwise.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		/**
		 * Removes a listener from the EventDispatcher object. If there is no matching listener registered with the EventDispatcher object, a call to this method has no effect.
		 *
		 * @param type              <String> The type of event.
		 * @param listener          <Function> The listener object to remove.
		 * @param useCapture        <Boolean (default = false)> Specifies whether the listener was registered for the capture phase or the
		 *                            target and bubbling phases. If the listener was registered for both the capture phase and the
		 *                            target and bubbling phases, two calls to removeEventListener() are required
		 *                            to remove both, one call with useCapture() set to true, and another
		 *                            call with useCapture() set to false.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Checks whether an event listener is registered with this EventDispatcher object or any of
		 *  its ancestors for the specified event type. This method returns true if an
		 *  event listener is triggered during any phase of the event flow when an event of the
		 *  specified type is dispatched to this EventDispatcher object or any of its descendants.
		 *
		 * @param type              <String> The type of event.
		 * @return                  <Boolean> A value of true if a listener of the specified type will be triggered; false otherwise.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		/**
		 * Sets the mimetypes allowed by PlayList.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Protected
		 */
		protected function setMimes():void {
			mimetypes["mp3"] = "mp3";
			mimetypes["audio/mpeg"] = "mp3";
			mimetypes["flv"] = "flv";
			mimetypes["video/x-flv"] = "flv";
			mimetypes["jpeg"] = "jpg";
			mimetypes["jpg"] = "jpg";
			mimetypes["image/jpeg"] = "jpg";
			mimetypes["png"] = "png";
			mimetypes["image/png"] = "png";
			mimetypes["gif"] = "gif";
			mimetypes["image/gif"] = "gif";
			mimetypes["rtmp"] = "rtmp";
			mimetypes["swf"] = "swf";
			mimetypes["application/x-shockwave-flash"] = "swf";
			mimetypes["rtmp"] = "rtmp";
			mimetypes["application/x-fcs"] = "rtmp";
			mimetypes["audio/x-m4a"] = "m4a";
			mimetypes["video/x-m4v"] = "m4v";
			mimetypes["video/H264"] = "mp4";
			mimetypes["video/3gpp"] = "3gp";
			mimetypes["video/x-3gpp2"] = "3g2";
			mimetypes["audio/x-3gpp2"] = "3g2";
		}
		
		/**
		 * Converts a string version of a time format into the seconds equivalent.
		 *
		 * @param str              <String> The string to convert.
		 * @return                  <Int> The number of seconds for the given time.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Protected
		 */
		protected function toSeconds(str:String):int {
			var arr:Array = str.split(":");
			var l:uint = arr.length;
			var sl:uint = str.length;
			var n:uint = 0;
			var ll:String = str.substr( -1); // Last letter
			var sec:uint = uint(str.substr(0, sl - 2)); // Seconds
			if (ll == "s") {
				n = sec;
			} else if (ll == "m") {
				n = sec * 60;
			} else if (ll == "h") {
				n = sec * 3600;
			} else if (l > 1) {
				n = uint(arr[l - 1]);
				n += uint(arr[l - 2]) * 60;
				n += uint(arr[l - 3]) * 3600;
			} else {
				n = uint(str);
			}
			
			return isNaN(n) ? -1 : n;
		}
	}
}