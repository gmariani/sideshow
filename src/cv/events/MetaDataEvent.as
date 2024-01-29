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
	 * The MetaDataEvent class defines events for media players. 
	 * These events include the following:
	 * <ul>
	 * <li><code>MetaDataEvent.METADATA</code>: dispatched when the player has recieved metadata.</li>
	 * <li><code>MetaDataEvent.BAND_WIDTH</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.CAPTION</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.CAPTION_INFO</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.CUE_POINT</code>: dispatched when the player has reached a cuepoint.</li>
	 * <li><code>MetaDataEvent.FC_SUBSCRIBE</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.IMAGE_DATA</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.LAST_SECOND</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.PLAY_STATUS</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.TEXT_DATA</code>: dispatched when using FMS.</li>
	 * <li><code>MetaDataEvent.RTMP_SAMPLE_ACCESS</code>: dispatched when using FMS.</li>
	 * </ul>
	 */
	public class MetaDataEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an <code>audioMetadata</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>data</code></td><td>The metadata object.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType metadata
		 */
		public static const METADATA:String = "metadata";
		
		public static const BAND_WIDTH:String = "bandwidth";
		
		public static const CAPTION:String = "caption";
		
		public static const CAPTION_INFO:String = "captionInfo";
		
		public static const CUE_POINT:String = "cuePoint";
		
		public static const FC_SUBSCRIBE:String = "fcSubscribe";
		
		public static const IMAGE_DATA:String = "imageData";
		
		public static const LAST_SECOND:String = "lastSecond";
		
		public static const PLAY_STATUS:String = "playStatus";
		
		public static const TEXT_DATA:String = "textData";
		
		public static const RTMP_SAMPLE_ACCESS:String = "RTMPSampleAccess";
		
		/**
         * The reference to the data object.
		 */
		public var data:Object;
		
		/**
		 * Creates a new MetaDataEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param data The metadata object.
		 */
		public function MetaDataEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		/**
		 * Creates a copy of the MetaDataEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new MetaDataEvent object with parameter values that match those of the original.
		 */
		override public function clone():Event {
			return new MetaDataEvent(type, data, bubbles, cancelable);
		}
		
		/**
		 * Returns a string that contains all the properties of the MetaDataEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>MetaDataEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> data=<em>value</em></code>]</p>
		 *
         * @return A string representation of the MetaDataEvent object.
		 */
		override public function toString():String {
			return formatToString("MenuEvent", "type", "data", "bubbles", "cancelable", "eventPhase");
		}
	}
}