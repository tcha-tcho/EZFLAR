package org.papervision3d.objects.special {
	import org.papervision3d.cameras.FrustumCamera3D;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.materials.special.LineMaterial;	

	/**
	 * @author Tim Knip 
	 */
	public class Frustum3D extends Lines3D
	{
		/** */
		public var camera:FrustumCamera3D;
		
		/**
		 * 
		 * @param	camera
		 * @return
		 */
		public function Frustum3D( camera:FrustumCamera3D ):void
		{
			super(new LineMaterial(0x0000ff));
			
			this.camera = camera;
			
			buildFrustum();
		}
		
		/**
		 * 
		 * @return
		 */
		public function buildFrustum( scale:Number = 0.1 ):void
		{
			var i:int;
			var near:Number = camera.near * scale;
			var far:Number = camera.far * scale;
			var v:Array = new Array();
			
			this.lines = new Array();
			
			for( i = 0; i < 10; i++ )
				v.push(new Vertex3D());
				
			// compute width and height of the near and far plane sections
			var tang:Number = Math.tan((Math.PI/180.0) * camera.fov * 0.5);
			var aspect:Number = camera.viewport.width / camera.viewport.height;
			
			var nh:Number = near * tang;
			var nw:Number = nh * aspect; 
			var fh:Number = far  * tang;
			var fw:Number = fh * aspect;
			
			var vx:Number3D = new Number3D(1,0,0);
			var vy:Number3D = new Number3D(0,1,0);
			var vz:Number3D = new Number3D(0,0,1);
			
			var nc:Number3D = new Number3D();
			var fc:Number3D = new Number3D();
						
			nc.x = vz.x * near;
			nc.y = vz.y * near;
			nc.z = vz.z * near;
		
			fc.x = vz.x * far;
			fc.y = vz.y * far;
			fc.z = vz.z * far;
			
			var Xnw:Number3D = scaledNumber3D(vx, nw);
			var Ynh:Number3D = scaledNumber3D(vy, nh);
			var Xfw:Number3D = scaledNumber3D(vx, fw);
			var Yfh:Number3D = scaledNumber3D(vy, fh);
			
			// compute the 4 corners of the frustum on the near plane
			v[NTL].x = nc.x + Ynh.x - Xnw.x;
			v[NTL].y = nc.y + Ynh.y - Xnw.y;
			v[NTL].z = nc.z + Ynh.z - Xnw.z;
			
			v[NTR].x = nc.x + Ynh.x + Xnw.x;
			v[NTR].y = nc.y + Ynh.y + Xnw.y;
			v[NTR].z = nc.z + Ynh.z + Xnw.z;
			
			v[NBL].x = nc.x - Ynh.x - Xnw.x;
			v[NBL].y = nc.y - Ynh.y - Xnw.y;
			v[NBL].z = nc.z - Ynh.z - Xnw.z;
			
			v[NBR].x = nc.x - Ynh.x + Xnw.x;
			v[NBR].y = nc.y - Ynh.y + Xnw.y;
			v[NBR].z = nc.z - Ynh.z + Xnw.z;
			
			// compute the 4 corners of the frustum on the far plane
			v[FTL].x = fc.x + Yfh.x - Xfw.x;
			v[FTL].y = fc.y + Yfh.y - Xfw.y;
			v[FTL].z = fc.z + Yfh.z - Xfw.z;
			
			v[FTR].x = fc.x + Yfh.x + Xfw.x;
			v[FTR].y = fc.y + Yfh.y + Xfw.y;
			v[FTR].z = fc.z + Yfh.z + Xfw.z;
			
			v[FBL].x = fc.x - Yfh.x - Xfw.x;
			v[FBL].y = fc.y - Yfh.y - Xfw.y;
			v[FBL].z = fc.z - Yfh.z - Xfw.z;
			
			v[FBR].x = fc.x - Yfh.x + Xfw.x;
			v[FBR].y = fc.y - Yfh.y + Xfw.y;
			v[FBR].z = fc.z - Yfh.z + Xfw.z;
			
			addNewLine(0, v[NTL].x, v[NTL].y, v[NTL].z, v[NTR].x, v[NTR].y, v[NTR].z);
			addNewLine(0, v[NTR].x, v[NTR].y, v[NTR].z, v[NBR].x, v[NBR].y, v[NBR].z);
			addNewLine(0, v[NBR].x, v[NBR].y, v[NBR].z, v[NBL].x, v[NBL].y, v[NBL].z);
			addNewLine(0, v[NBL].x, v[NBL].y, v[NBL].z, v[NTL].x, v[NTL].y, v[NTL].z);
			
			addNewLine(0, v[FTL].x, v[FTL].y, v[FTL].z, v[FTR].x, v[FTR].y, v[FTR].z);
			addNewLine(0, v[FTR].x, v[FTR].y, v[FTR].z, v[FBR].x, v[FBR].y, v[FBR].z);
			addNewLine(0, v[FBR].x, v[FBR].y, v[FBR].z, v[FBL].x, v[FBL].y, v[FBL].z);
			addNewLine(0, v[FBL].x, v[FBL].y, v[FBL].z, v[FTL].x, v[FTL].y, v[FTL].z);
			
			addNewLine(0, v[NTL].x, v[NTL].y, v[NTL].z, v[FTL].x, v[FTL].y, v[FTL].z);
			addNewLine(0, v[NTR].x, v[NTR].y, v[NTR].z, v[FTR].x, v[FTR].y, v[FTR].z);
			addNewLine(0, v[NBR].x, v[NBR].y, v[NBR].z, v[FBR].x, v[FBR].y, v[FBR].z);
			addNewLine(0, v[NBL].x, v[NBL].y, v[NBL].z, v[FBL].x, v[FBL].y, v[FBL].z);
			
			//addLine(new Line3D(this, this.material, 0, v[NTL], v[NTR]));
		
		}
		
		/**
		 * 
		 * @param	num
		 * @param	scale
		 * @return
		 */
		private function scaledNumber3D( num:Number3D, scale:Number ):Number3D
		{
			var n:Number3D = num.clone();
			n.x *= scale;
			n.y *= scale;
			n.z *= scale;
			return n;
		}
		
		private static const NTL:uint = 0;
		private static const NTR:uint = 1;
		private static const NBL:uint = 2;
		private static const NBR:uint = 3;
		private static const FTL:uint = 4;
		private static const FTR:uint = 5;
		private static const FBL:uint = 6;
		private static const FBR:uint = 7;
	}	
}
