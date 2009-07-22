package com.transmote.utils.time {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	 * call a method one time, after a specified delay.
	 * accepts optional parameters.
	 * (wraps a simple Timer implementation.)
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class Timeout {
		private var timer:Timer;
		private var func:Function;
		private var params:Array;
		
		public function Timeout (func:Function, delay:Number, ...params:Array) {
			this.func = func;
			this.params = params;
			
			this.timer = new Timer(delay, 1);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.timer.start();
		}
		
		private function onTimerComplete (evt:TimerEvent=null) :void {
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			if (this.params.length) { this.func(this.params); }
			else { this.func(); }
			this.destroy();
		}
		
		public function cancel () :void {
			if (!this.timer) { return; }
			
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onTimerComplete);
			this.destroy();
		}
		
		private function destroy () :void {
			this.timer = null;
			this.func = null;
			this.params = null;
		}
	}
}