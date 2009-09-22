package com.tchatcho.constructors {
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class MP3Events extends EventDispatcher {
		public var _dispatchMP3:Boolean = false;
		public static const STOPSOUND:String = "stopsound";
		public function MP3Events() {
			public function set dispatchMP3(value:Boolean):void{
				dispatchEvent(new Event (STOPSOUND));
				_dispatchMP3 = value;
			}
			public function get dispatchMP3():Object{
				return _dispatchMP3;
			}
		}
	}
}