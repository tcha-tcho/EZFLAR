package org.papervision3d.core.animation.channel
{
	import org.papervision3d.core.animation.IAnimationDataProvider;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class MorphChannel3D extends AbstractChannel3D
	{
		/**
		 * Constructor.
		 * 
		 * @param	target
		 * @param	name
		 */ 
		public function MorphChannel3D(target:DisplayObject3D, name:String=null)
		{
			super(target, name);
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

			if(!target.geometry || !target.geometry.vertices)
				return;
			
			var curOutput:Array = currentKeyFrame.output;
				
			if(curOutput.length != target.geometry.vertices.length)
				return;
				
			for(var i:int = 0; i < target.geometry.vertices.length; i++)
			{
				var v:Vertex3D = target.geometry.vertices[i];
				var w:Vertex3D = curOutput[i];
				
				v.x = w.x;
				v.y = w.y;
				v.z = w.z;
			}
		}
		
		/**
		 * Updates this channel by time.
		 * 
		 * @param	time	Value between 0 and 1 indicating position between #startTime and #endTime.
		 */ 
		public override function updateToTime(time:Number):void
		{
			super.updateToTime(time);
			
			var curOutput:Array = currentKeyFrame.output;
			var nxtOutput:Array = nextKeyFrame.output;
			
			if(!target.geometry || !target.geometry.vertices)
				return;
				
			if(curOutput.length != target.geometry.vertices.length)
				return;
				
			for(var i:int = 0; i < target.geometry.vertices.length; i++)
			{
				var u:Vertex3D = target.geometry.vertices[i];
				var v:Vertex3D = curOutput[i];
				var w:Vertex3D = nxtOutput[i];
				
				u.x = v.x + frameAlpha * (w.x - v.x);
				u.y = v.y + frameAlpha * (w.y - v.y);
				u.z = v.z + frameAlpha * (w.z - v.z);
			}
		}
	}
}