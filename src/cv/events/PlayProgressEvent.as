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

package cv.events {
	
	import flash.events.Event;
	
	/**
	 * The PlayProgressEvent class defines events for media players. 
	 * These events include the following:
	 * <ul>
	 * <li><code>PlayProgressEvent.PLAY_START</code>: dispatched when playback has begun.</li>
	 * <li><code>PlayProgressEvent.PLAY_PROGRESS</code>: dispatched constantly during playback.</li>
	 * <li><code>PlayProgressEvent.PLAY_COMPLETE</code>: dispatched when playback is complete.</li>
	 * <li><code>PlayProgressEvent.STATUS</code>: dispatched whenever status has changed.</li>
	 * <li><code>PlayProgressEvent.LOADING</code>: constant used to verify file is loading.</li>
	 * <li><code>PlayProgressEvent.LOADED</code>: constant used to verify file is loaded but hasn't played once yet.</li>
	 * <li><code>PlayProgressEvent.STARTED</code>: constant used to verify file has started playing atleast once.</li>
	 * <li><code>PlayProgressEvent.UNLOADED</code>: constant used to verify file is unlaoded.</li>
	 * </ul>
	 */
	public class PlayProgressEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an <code>playProgress</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>percent</code></td><td>The percentage of progress for the media playing.</td></tr>
		 * 	  <tr><td><code>elapsed</code></td><td>The elapsed time of the media playing.</td></tr>
		 * 	  <tr><td><code>remain</code></td><td>The remaining time of the media playing.</td></tr>
		 * 	  <tr><td><code>total</code></td><td>The total time of the media playing.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType playProgress
		 */
		public static const PLAY_PROGRESS:String = "playProgress";
		
		public static const PLAY_START:String = "playStart";
		
		public static const PLAY_COMPLETE:String = "playComplete";
		
		public static const STATUS:String = "status";
		
		public static const LOADING:String = "loading";
		
		public static const LOADED:String = "loaded";
		
		public static const STARTED:String = "started";
		
		public static const UNLOADED:String = "unloaded";
		
		/**
         * The reference to the percentage of progress for the media playing.
		 */
		public var percent:uint;
		
		/**
         * The reference to the elapsed time of the media playing.
		 */
		public var elapsed:Number;
		
		/**
         * The reference to the remaining time of the media playing.
		 */
		public var remain:Number;
		
		/**
         * The reference to the total time of the media playing.
		 */
		public var total:Number;
		
		/**
		 * Creates a new PlayProgressEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param percent The play progress in terms of percent.
		 * 
         * @param elapsed The time elapsed in terms of milliseconds.
		 * 
         * @param remain The time remaining in terms of milliseconds.
		 * 
         * @param total The total time in terms of milliseconds.
		 */
		public function PlayProgressEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, percent:uint=0, elapsed:Number=0, remain:Number=0, total:Number=0) {
			super(type, bubbles, cancelable);
			this.percent = percent;
			this.elapsed = elapsed;
			this.remain = remain;
			this.total = total;
		}
		
		/**
		 * Creates a copy of the PlayProgressEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new PlayProgressEvent object with parameter values that match those of the original.
		 */
		override public function clone():Event {
			return new PlayProgressEvent(type, bubbles, cancelable, percent, elapsed, remain, total);
		}
		
		/**
		 * Returns a string that contains all the properties of the PlayProgressEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>PlayProgressEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> percent=<em>value</em> elapsed=<em>value</em> remain=<em>value</em> total=<em>value</em></code>]</p>
		 *
         * @return A string representation of the PlayProgressEvent object.
		 */
		override public function toString():String {
			return formatToString("LoadEvent", "type", "bubbles", "cancelable", "percent", "elapsed", "remain", "total", "eventPhase");
		}
	}
}