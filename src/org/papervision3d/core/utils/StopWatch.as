package org.papervision3d.core.utils
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	public class StopWatch extends EventDispatcher
	{
		private var startTime:int;
		private var stopTime:int;
		private var elapsedTime:int;
		private var isRunning:Boolean;
		
		public function StopWatch()
		{
			super();
		}
		
		public function start():void
		{
			if(!isRunning){
				startTime = getTimer();
				isRunning = true;
			}
		}
		
		public function stop():int
		{
			if(isRunning){
				stopTime = getTimer();
				elapsedTime = stopTime-startTime;
				isRunning = false;
				return elapsedTime;
			}else{
				return 0;
			}
		}
		
		public function reset():void
		{
			isRunning = false;
		}
	
	}
}