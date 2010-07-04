package org.papervision3d.core.animation
{
	public interface IAnimatable
	{
		/**
		 * Plays the animation.
		 * 
		 * @param 	clip	Optional clip name.
		 */ 
		function play(clip:String=null):void;
		
		/**
		 * Stops the animation.
		 */ 
		function stop():void;
	}
}