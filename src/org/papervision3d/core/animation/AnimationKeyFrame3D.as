package org.papervision3d.core.animation
{
	/**
	 * @author Tim Knip
	 */ 
	public class AnimationKeyFrame3D
	{
		public static const INTERPOLATION_LINEAR:String = "LINEAR";
		public static const INTERPOLATION_BEZIER:String = "BEZIER";
		
		/** */
		public var name:String;
		
		/** */
		public var time:Number;
		
		/** */
		public var output:Array;
		
		/** */
		public var interpolation:String;
		
		/** */
		public var inTangent:Array;
		
		/** */
		public var outTangent:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param 	name
		 * @param	time
		 * @param	output
		 * @param	interpolation
		 * @param	inTangent
		 * @param	outTangent
		 */ 
		public function AnimationKeyFrame3D(name:String, time:Number, output:Array = null, interpolation:String = null, inTangent:Array = null, outTangent:Array = null)
		{
			this.name = name;
			this.time = time;
			this.output = output || new Array();
			this.interpolation = interpolation || INTERPOLATION_LINEAR;
			this.inTangent = inTangent || new Array();
			this.outTangent = outTangent || new Array();
		}
	}
}