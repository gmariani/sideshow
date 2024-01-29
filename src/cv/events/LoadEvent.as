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
	
	import cv.interfaces.IMediaPlayer;
	import flash.events.Event;
	
	/**
	 * The LoadEvent class defines events for TempoLite and media players. 
	 * These events include the following:
	 * <ul>
	 * <li><code>LoadEvent.LOAD_START</code>: dispatched after a file has begun loading.</li>
	 * <li><code>LoadEvent.LOAD_PROGRESS</code>: dispatched while a file is loading.</li>
	 * <li><code>LoadEvent.LOAD_COMPLETE</code>: dispatched after a file has finished loading.</li>
	 * </ul>
	 */
	public class LoadEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadStart</code> event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *    <tr>
         *      <th>Property</th>
         *      <th>Value</th>
         *    </tr>
		 *    <tr>
         *      <td><code>bubbles</code></td>
         *      <td><code>false</code></td></tr>
		 *    <tr><td><code>cancelable</code></td><td><code>false</code>; there is
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>time</code></td><td>The estimated duration of the media file.</td></tr>
		 * 	  <tr><td><code>url</code></td><td>TThe url of the item being loaded.</td></tr>
		 *    <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>index</code></td><td>The zero-based index in the DataProvider
		 * 			that contains the renderer.</td></tr>
		 * 	  <tr><td><code>item</code></td><td>A reference to the data that belongs to the renderer.</td></tr>
		 * 	  <tr><td><code>mediaType</code></td><td>The type of media being loaded, either "audio" or "video".</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
         *  </table>
         *
         * @eventType loadStart
		 */
		public static const LOAD_START:String = "loadStart";
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadProgress</code> event object. 
         *
         * @eventType loadProgress
		 */
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadComplete</code> event object. 
         *
         * @eventType loadComplete
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/**
		 * Gets the url of the item that is associated with this event.
		 */
		public var url:String;
		
		/**
		 * Gets the media type of the item that is associated with this event.
		 */
		public var mediaType:IMediaPlayer;
		
		/**
		 * Gets the duration of the item that is associated with this event.
		 */
		public var time:Number;
		
		/**
		 * Creates a new LoadEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param url The url of the item being loaded.
         *
         * @param mediaType The type of media being loaded, either "audio" or "video".
         *
         * @param time The estimated duration of the media file.
		 */
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, url:String = "", mediaType:IMediaPlayer = null, time:Number= 0) {
			super(type, bubbles, cancelable);
			this.url = url;
			this.mediaType = mediaType;
			this.time = time;
		}
		
		/**
		 * Creates a copy of the LoadEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new LoadEvent object with parameter values that match those of the original.
		 */
		override public function clone():Event {
			return new LoadEvent(type, bubbles, cancelable, url, mediaType, time);
		}
		
		/**
		 * Returns a string that contains all the properties of the LoadEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>LoadEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> url=<em>value</em>
		 * 	mediaType=<em>value</em> time=<em>value</em></code>]</p>
		 *
         * @return A string representation of the LoadEvent object.
		 */
		override public function toString():String {
			return formatToString("LoadEvent", "type", "bubbles", "cancelable", "url", "mediaType", "time", "eventPhase");
		}
	}
}