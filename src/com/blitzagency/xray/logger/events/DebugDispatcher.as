package com.blitzagency.xray.logger.events {
	import flash.events.EventDispatcher;
	
	import com.blitzagency.xray.logger.events.DebugEvent;	

	public class DebugDispatcher extends EventDispatcher
	{
		public static var TRACE:String = "trace";

		public function sendEvent(eventName:String, obj:Object):void 
		{
			trace(obj.message);
	        dispatchEvent(new DebugEvent(DebugDispatcher.TRACE, false, false, obj));
	    }
	}
}