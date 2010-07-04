package org.papervision3d.core.animation.channel
{
	import org.papervision3d.core.animation.AnimationKeyFrame3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip
	 */ 
	public class AbstractChannel3D
	{	
		/** The target for this animation channel. */
		public var target:DisplayObject3D;
		
		/** Name of the channel. */
		public var name:String;
		
		/** Array of keyframes. */	
		public var keyFrames:Array;
		
		/** Start time in seconds. */
		public var startTime:Number;
		
		/** End time in seconds. */
		public var endTime:Number;
		
		/** Current time in seconds. */
		public var currentTime:Number;
		
		/** Current keyframe as index into keyFrames array. */
		public var currentIndex:int;
		
		/** Next keyframe as index into keyFrames array. */
		public var nextIndex:int;
		
		/** Current keyframe. */
		public var currentKeyFrame:AnimationKeyFrame3D;
		
		/** Next keyframe. */
		public var nextKeyFrame:AnimationKeyFrame3D;
		
		/** Total duration in seconds. */
		public var duration:Number;
		
		/** Value between 0 and 1 indicating current position inbetween current and next keyframe. */
		public var frameAlpha:Number;
		
		/** Duration of the interval between current and next frame in seconds. */
		public var frameDuration:Number;
		
		/**
		 * Constructor.
		 * 
		 * @param	parent
		 * @param	target
		 * @param	name
		 */ 
		public function AbstractChannel3D(target:DisplayObject3D, name:String = null)
		{
			this.target = target;
			this.name = name;
			this.startTime = this.endTime = 0;
			this.keyFrames = new Array();
			this.currentKeyFrame =this.nextKeyFrame = null;
			this.currentIndex = this.nextIndex = -1;
			this.frameAlpha = 0;
		}
		
		/**
		 * Adds a new keyframe.
		 * 
		 * @param	keyframe
		 * 
		 * @return	The added keyframe.
		 */ 
		public function addKeyFrame(keyframe:AnimationKeyFrame3D):AnimationKeyFrame3D
		{
			if(this.keyFrames.length)
			{
				this.startTime = Math.min(this.startTime, keyframe.time);
				this.endTime = Math.max(this.endTime, keyframe.time);
			}
			else
			{
				this.startTime = this.endTime = keyframe.time;
			}
			
			this.duration = this.endTime - this.startTime;
			
			this.keyFrames.push(keyframe);
			this.keyFrames.sortOn("time", Array.NUMERIC);
				
			return keyframe;
		}
		
		/**
		 * Updates this channel.
		 * 
		 * @param	keyframe
		 */ 
		public function updateToFrame(keyframe:uint):void
		{	
			if(!this.keyFrames.length)
			{
				return;
			}
			
			currentIndex = keyframe;
			currentIndex = currentIndex < this.keyFrames.length - 1 ? currentIndex : 0;
			nextIndex = currentIndex + 1;
			
			currentKeyFrame = this.keyFrames[currentIndex];
			nextKeyFrame = this.keyFrames[nextIndex];
			
			frameDuration = nextKeyFrame.time - currentKeyFrame.time;
			frameAlpha = 0;
			currentTime = currentKeyFrame.time;
		}
		
		/**
		 * Updates this channel by time.
		 * 
		 */ 
		public function updateToTime(time:Number):void
		{	
			currentIndex = Math.floor((this.keyFrames.length-1) * time);
			currentIndex = currentIndex < this.keyFrames.length - 1 ? currentIndex : 0;
			nextIndex = currentIndex + 1;
			
			currentKeyFrame = this.keyFrames[currentIndex];
			nextKeyFrame = this.keyFrames[nextIndex];
			
			frameDuration = nextKeyFrame ? nextKeyFrame.time - currentKeyFrame.time : currentKeyFrame.time;
			
			currentTime = time * this.duration;
			
			frameAlpha = (currentTime - currentKeyFrame.time) / frameDuration;
			
			// clamp between 0 and 1
			frameAlpha = frameAlpha < 0 ? 0 : frameAlpha;
			frameAlpha = frameAlpha > 1 ? 1 : frameAlpha;
		}
	}
}