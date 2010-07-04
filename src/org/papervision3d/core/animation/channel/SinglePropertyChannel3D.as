package org.papervision3d.core.animation.channel
{
	import org.papervision3d.core.animation.IAnimationDataProvider;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class SinglePropertyChannel3D extends AbstractChannel3D
	{
		public var targetProperty:String;
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 * @param	targetProperty
		 * @param	name
		 */ 
		public function SinglePropertyChannel3D(target:DisplayObject3D, targetProperty:String, name:String=null)
		{
			super(target, name);
			this.targetProperty = targetProperty;
		}
		
		/**
		 * Updates this channel.
		 * 
		 * @param	keyframe
		 * @param	target
		 */ 
		override public function updateToFrame(keyframe:uint):void
		{
			super.updateToFrame(keyframe);	
			
			if(!target[this.targetProperty])
				return;
				
			target[this.targetProperty] = currentKeyFrame.output[0];
		}	
	}
}