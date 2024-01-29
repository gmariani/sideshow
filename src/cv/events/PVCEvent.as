package cv.events {
	
	import flash.events.Event;
	
	public class PVCEvent extends Event {
		
		//public static const NOTIFICATION:String = "NOTIFICATION";
		
		// the body of the notification instance
		private var body:Object;
		
		// the type of the notification instance
		private var type2:String;
		
		// the name of the notification instance
		//private var name:String;
		
		//notificationName:String, body:Object=null, type:String=null
		public function PVCEvent(name:String, body:Object=null, type:String="", bubbles:Boolean=false, cancelable:Boolean=false) { 
			//super(NOTIFICATION, bubbles, cancelable);
			super(name, bubbles, cancelable);
			//this.name = name;
			this.body = body;
			this.type2 = type;
		} 
		
		public override function clone():Event { 
			return new PVCEvent(type, body, type2, bubbles, cancelable);
		}
		
		/**
		 * Get the string representation of the <code>Notification</code> instance.
		 * 
		 * @return the string representation of the <code>Notification</code> instance.
		 */
		public override function toString():String { 
			var msg:String = "Notification Name: " + getName();
			msg += "\nBody:" + (( body == null ) ? "null" : body.toString());
			msg += "\nType:" + (( type2 == null ) ? "null" : type2);
			return msg;
		}
		
		/**
		 * Set the body of the <code>Notification</code> instance.
		 */
		public function setBody(body:Object):void { this.body = body; }
		
		/**
		 * Get the body of the <code>Notification</code> instance.
		 * 
		 * @return the body object. 
		 */
		public function getBody():Object { return body; }
		
		/**
		 * Get the type of the <code>Notification</code> instance.
		 * 
		 * @return the type  
		 */
		//public function getName():String { return name;	}
		public function getName():String { return type;	}
		
		/**
		 * Get the name of the <code>Notification</code> instance.
		 * 
		 * @return the name of the <code>Notification</code> instance.
		 */
		public function getType():String { return type2; }
		
		/**
		 * Set the type of the <code>Notification</code> instance.
		 */
		public function setType(type:String):void { this.type2 = type;	}
	}
}