package com.transmote.utils.time {
	import flash.utils.Timer;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	/**
	 * PausableTimer is a Timer that can be paused
	 * and later resumed at the count at which it was paused.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class PausableTimer extends Timer {		
		private var startTime:Number;
		private var timeRemainingAtPause:Number;
		private var originalDelay:Number;
		
		public function PausableTimer (delay:Number, repeatCount:int=0) {
			super(delay, repeatCount);
			this.originalDelay = delay;
		}
		
		public override function start () :void {
			this.startTime = new Date().getTime();
			super.start();
			this.addEventListener(TimerEvent.TIMER, this.onTimer, false, 0, true);
		}
		
		public override function get delay () :Number {
			return this.originalDelay;
		}
		public override function set delay (value:Number) :void {
			this.originalDelay = value;
			super.delay = value;
		}
		
		public function pause () :void {
			if (!this.running) { return; }
			this.stop();
			var endTime:Number = new Date().getTime();
			this.timeRemainingAtPause = super.delay - (endTime - this.startTime);
		}
		
		public function resume () :void {
			if (this.timeRemainingAtPause > 0) {
				super.delay = this.timeRemainingAtPause;
				this.timeRemainingAtPause = 0;
			}
			this.startTime = new Date().getTime();
			this.start();
		}
		
		private function onTimer (evt:TimerEvent) :void {
			super.delay = this.originalDelay;
			this.startTime = new Date().getTime();
		}
	}
}