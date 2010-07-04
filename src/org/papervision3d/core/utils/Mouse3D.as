/**
* @author De'Angelo Richardson 
*/
package org.papervision3d.core.utils
{
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.objects.DisplayObject3D;


	public class Mouse3D extends DisplayObject3D
	{
		static private var UP 								:Number3D = new Number3D(0, 1, 0);
		
		static public var enabled							:Boolean = false;
		
		private var position:Number3D = new Number3D(0, 0, 0);
		private var target:Number3D = new Number3D();
		
		public function Mouse3D(initObject:Object=null):void
		{
			
		}
		
		public function updatePosition( rhd:RenderHitData ):void
		{			
			var face3d:Triangle3D = rhd.renderable as Triangle3D;
			
			target.x = face3d.faceNormal.x; 
			target.y = face3d.faceNormal.y; 
			target.z = face3d.faceNormal.z;
				
			var zAxis:Number3D = Number3D.sub(target, position);
			zAxis.normalize();
				
			if (zAxis.modulo > 0.1)
			{
				var xAxis:Number3D = Number3D.cross(zAxis, UP);
				xAxis.normalize();
				
				var yAxis:Number3D = Number3D.cross(zAxis, xAxis);
				yAxis.normalize();
				
				var look:Matrix3D = this.transform;
					
				look.n11 = xAxis.x;
				look.n21 = xAxis.y;
				look.n31 = xAxis.z;
				
				look.n12 = -yAxis.x;
				look.n22 = -yAxis.y;
				look.n32 = -yAxis.z;
				
				look.n13 = zAxis.x;
				look.n23 = zAxis.y;
				look.n33 = zAxis.z;
			}
			
			var m:Matrix3D = Matrix3D.IDENTITY;
			this.transform = Matrix3D.multiply(face3d.instance.world, look);
			
			x = rhd.x;
			y = rhd.y;
			z = rhd.z;
		}
	}
}