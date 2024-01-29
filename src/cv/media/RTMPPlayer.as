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
	import cv.media.NetStreamPlayer;
	import flash.events.NetStatusEvent;
	
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	
	/**
	 * Dispatched when onBWDone is called.
	 *
	 * @eventType cv.events.MetaDataEvent.BAND_WIDTH
	 */
	[Event(name = "bandwidth", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onCaption is called.
	 *
	 * @eventType cv.events.MetaDataEvent.CAPTION
	 */
	[Event(name = "caption", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onCaptionInfo is called.
	 *
	 * @eventType cv.events.MetaDataEvent.CAPTION_INFO
	 */
	[Event(name = "captionInfo", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onFCSubscribe is called.
	 *
	 * @eventType cv.events.MetaDataEvent.FC_SUBSCRIBE
	 */
	[Event(name = "fcSubscribe", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onImageData is called.
	 *
	 * @eventType cv.events.MetaDataEvent.IMAGE_DATA
	 */
	[Event(name = "imageData", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onLastSecond is called.
	 *
	 * @eventType cv.events.MetaDataEvent.LAST_SECOND
	 */
	[Event(name = "lastSecond", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onPlayStatus is called.
	 *
	 * @eventType cv.events.MetaDataEvent.PLAY_STATUS
	 */
	[Event(name = "playStatus", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when onTextData is called.
	 *
	 * @eventType cv.events.MetaDataEvent.TEXT_DATA
	 */
	[Event(name = "textData", type = "cv.events.MetaDataEvent")]
	
	/**
	 * Dispatched when RTMPSampleAccess is called.
	 *
	 * @eventType cv.events.MetaDataEvent.RTMP_SAMPLE_ACCESS
	 */
	[Event(name = "RTMPSampleAccess", type = "cv.events.MetaDataEvent")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 1.0.0<br>
	 * <h3>Date:</h3> 3/10/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * The RTMPPlayer class extends the capabilities of the NetStreamPlayer.
	 * Allowing it to stream media from a server.
     */
	public class RTMPPlayer extends NetStreamPlayer implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "1.0.0";
		
		public function RTMPPlayer() {
			super();
			
			client = {
				onBWCheck:onBWCheck,
				onBWDone:onBWDone,
				onCaption:onCaption,
				onCaptionInfo:onCaptionInfo,
				onCuePoint:onCuePoint,
				onFCSubscribe:onFCSubscribe,
				onImageData:onImageData,
				onLastSecond:onLastSecond,
				onMetaData:onMetaData,
				onPlayStatus:onPlayStatus,
				onTextData:onTextData,
				RtmpSampleAccess:RtmpSampleAccess
			};
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/**
		 * Returns a reference to the NetConnection if it exists. This is used
		 * instead of having all the same properties in NetStreamPlayer.
		 * 
		 * Note: addHeader() and call() are added to NetStreamPlayer for your
		 * convenience.
		 * 
		 * @see RTMPPlayer#addHeader()
		 * @see RTMPPlayer#call()
		 */
		public function get netConnection():NetConnection { return nc }
		
		/** 
		 * Gets or sets the object encodeing for use with streaming servers.
		 */
		public function get objectEncoding():uint { return _encoding }
		/** @private **/
		public function set objectEncoding(value:uint):void { if(value == 0 || value == 3) _encoding = value }
		
		/** 
		 * Gets or sets the stream host url for use with streaming media.
		 */
		public function get streamHost():String { return _streamHost }
		/** @private **/
		public function set streamHost(value:String):void {	_streamHost = value }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Adds a context header to the Action Message Format (AMF) packet structure. 
		 * This header is sent with every future AMF packet. If you call 
		 * NetConnection.addHeader() using the same name, the new header replaces the 
		 * existing header, and the new header persists for the duration of the 
		 * NetConnection object. You can remove a header by calling 
		 * NetConnection.addHeader() with the name of the header to remove an 
		 * undefined object.
		 * 
		 * @param	operation Identifies the header and the ActionScript object 
		 * data associated with it.
		 * @param	mustUnderstand A value of true indicates that the server must 
		 * understand and process this header before it handles any of the 
		 * following headers or messages. 
		 * @param	param Any ActionScript object. 
		 */
		public function addHeader(operation:String, mustUnderstand:Boolean = false, param:Object = null):void {
			if(nc) nc.addHeader(operation, mustUnderstand, param);
		}
		
		/**
		 * Invokes a command or method on Flash Media Server or on an 
		 * application server running Flash Remoting.
		 * 
		 * @param	command A method specified in the form [objectPath/]method. 
		 * For example, the someObject/doSomething command tells the remote 
		 * server to invoke the clientObject.someObject.doSomething() method, 
		 * with all the optional ... arguments parameters. If the object path 
		 * is missing, clientObject.doSomething() is invoked on the remote server.
		 * @param	responder	An optional object that is used to handle return 
		 * values from the server. The Responder object can have two defined 
		 * methods to handle the returned result: result and status. If an error 
		 * is returned as the result, status is invoked; otherwise, result is 
		 * invoked. The Responder object can process errors related to specific 
		 * operations, while the NetConnection object responds to errors related 
		 * to the connection status.
		 * @param	... rest Optional arguments that can be of any ActionScript 
		 * type, including a reference to another ActionScript object. These 
		 * arguments are passed to the method specified in the command parameter 
		 * when the method is executed on the remote application server. 
		 */
		public function call(command:String, responder:Responder, ... rest):void {
			if(nc) nc.call(command, responder, rest);
		}
		
		override public function isValid(ext:String, url:String):Boolean {
			if (streamHost != null) {
				if (streamHost.toLowerCase().indexOf("rtmp://") == -1) return false;
			}
			
			return super.isValid(ext, url);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		/**
		 * This is required by native bandwidth detection. It takes an argument,
		 * ...rest. The function must return a value, even if the value is 0, to 
		 * indicate to the server that the client has received the data.
		 * 
		 * @param	... rest
		 * @return
		 */
		protected function onBWCheck(... rest):Number {
			return 0;
		}
		
		/**
		 * The server calls the onBWDone() function when it finishes measuring 
		 * the bandwidth. It takes four arguments. The first argument it returns 
		 * is the bandwidth measured in Kbps. The second and third arguments are 
		 * not used. The fourth argument is the latency in milliseconds.
		 * 
		 * @param	... rest
		 */
		protected function onBWDone(... rest):void {
			trace2("RTMPPlayer - onBWDone : " + rest[0] + "Kbps / " + rest[3] + "ms");
			if (rest.length > 0) {
				dispatchEvent(new MetaDataEvent(MetaDataEvent.BAND_WIDTH, {bandwidth:rest[0], latency:rest[3]}));
			}
		}
		
		protected function onCaption(cps:String, spk:Number):void {
			trace2("RTMPPlayer - onCaption", cps, spk);
			dispatchEvent(new MetaDataEvent(MetaDataEvent.CAPTION, {captions:cps, speaker:spk}));
		}
		
		protected function onCaptionInfo(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.CAPTION_INFO, o));
		}
		
		// onCuePoint handled by NetStreamPlayer
		
		protected function onFCSubscribe(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.FC_SUBSCRIBE, o));
		}
		
		protected function onImageData(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.IMAGE_DATA, o));
		}
		
		protected function onLastSecond(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.LAST_SECOND, o));
		}
		
		// onMetaData handled by NetStreamPlayer
		
		protected function onPlayStatus(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.PLAY_STATUS, o));
		}
		
		protected function onTextData(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.TEXT_DATA, o));
		}
		
		override protected function netStatusHandler(e:NetStatusEvent):void {
			super.netStatusHandler(e);
			
			try {
				switch (e.info.code) {
					/* Errors */
					case "NetStream.Failed":
						//Flash Media Server only. An error has occurred for a reason other than those listed in other event codes. 
						trace2("RTMPPlayer - netStatusHandler : An unknown error has occurred. (" + e.info.code + ")");
						break;
					case "NetStream.Publish.BadName":
						trace2("RTMPPlayer - netStatusHandler : Attempt to publish a stream which is already being published by someone else.");
						break;
					case "NetStream.Record.NoAccess":
						trace2("RTMPPlayer - netStatusHandler : Attempt to record a stream that is still playing or the client has no access right.");
						break;
					case "NetStream.Record.Failed":
						trace2("RTMPPlayer - netStatusHandler : An attempt to record a stream failed.");
						break;
					case "NetStream.Seek.Failed":
						// Seek failed
						break;
					case "NetConnection.Call.BadVersion":
						trace2("RTMPPlayer - netStatusHandler : Packet encoded in an unidentified format.");
						break;
					case "NetConnection.Call.Prohibited":
						trace2("RTMPPlayer - netStatusHandler : An Action Message Format (AMF) operation is prevented for security reasons. Either the AMF URL is not in the same domain as the SWF file, or the AMF server does not have a policy file that trusts the domain of the SWF file.");
						break;
					case "NetConnection.Call.Failed":
						trace2("RTMPPlayer - netStatusHandler : The connection attempt failed.");
						break;
					case "NetConnection.Connect.AppShutdown":
						trace2("RTMPPlayer - netStatusHandler : The specified application is shutting down.");
						break;
					case "NetConnection.Connect.InvalidApp":
						trace2("RTMPPlayer - netStatusHandler : The application name specified during connect is invalid.");
						break;
					case "SharedObject.Flush.Failed":
						trace2("RTMPPlayer - netStatusHandler : The \"pending\" status is resolved, but the SharedObject.flush() failed.");
						break;
					case "SharedObject.BadPersistence":
						trace2("RTMPPlayer - netStatusHandler : A request was made for a shared object with persistence flags, but the request cannot be granted because the object has already been created with different flags.");
						break;
					case "SharedObject.UriMismatch":
						trace2("RTMPPlayer - netStatusHandler : An attempt was made to connect to a NetConnection object that has a different URI (URL) than the shared object.");
						break;
						
					/* Warnings */
					case "NetStream.Play.InsufficientBW":
						trace2("RTMPPlayer - netStatusHandler : The client does not have sufficient bandwidth to play the data at normal speed.");
						break;
					
					/* Status */
					case "NetStream.Publish.Start":
						trace2("RTMPPlayer - netStatusHandler : Publish was successful.");
						break;
					case "NetStream.Publish.Idle":
						trace2("RTMPPlayer - netStatusHandler : The publisher of the stream is idle and not transmitting data.");
						break;
					case "NetStream.Unpublish.Success":
						trace2("RTMPPlayer - netStatusHandler : The unpublish operation was successful.");
						break;
					case "NetStream.Play.PublishNotify":
						trace2("RTMPPlayer - netStatusHandler : The initial publish to a stream is sent to all subscribers.");
						break;
					case "NetStream.Play.UnpublishNotify":
						trace2("RTMPPlayer - netStatusHandler : An unpublish from a stream is sent to all subscribers.");
						break;
					case "NetStream.Record.Start":
						trace2("RTMPPlayer - netStatusHandler : Recording has started.");
						break;
					case "NetStream.Record.Stop":
						trace2("RTMPPlayer - netStatusHandler : Recording stopped.");
						break;
					case "SharedObject.Flush.Success":
						trace2("RTMPPlayer - netStatusHandler : The \"pending\" status is resolved and the SharedObject.flush() call succeeded.");
						break;
				}
			} catch (error:Error) {
				// Ignore this error
				trace2("NetStreamPlayer - netStatusHandler - Error : " + error.message);
			}
		}
		
		protected function RtmpSampleAccess(o:Object):void {
			dispatchEvent(new MetaDataEvent(MetaDataEvent.RTMP_SAMPLE_ACCESS, o));
		}
	}
}