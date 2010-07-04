package org.papervision3d.core.animation.channel
{
	import org.papervision3d.core.animation.IAnimationDataProvider;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class MatrixChannel3D extends AbstractChannel3D
	{
		public var member:String;
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 * @param	name
		 */ 
		public function MatrixChannel3D(target:DisplayObject3D, name:String=null)
		{
			super(target, name);
			this.member = null;
		}
		
		/**
		 * Updates this channel.
		 * 
		 * @param	keyframe
		 * @param	target
		 */ 
		public override function updateToFrame(keyframe:uint):void
		{
			super.updateToFrame(keyframe);	
			
			target.copyTransform(currentKeyFrame.output[0]);
		}
		
		public override function updateToTime(time:Number):void
		{
			super.updateToTime(time);
			
			target.copyTransform(currentKeyFrame.output[0]);
		}
	}
}