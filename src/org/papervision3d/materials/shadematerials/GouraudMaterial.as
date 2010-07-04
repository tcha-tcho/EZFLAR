package org.papervision3d.materials.shadematerials
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.material.AbstractSmoothShadeMaterial;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	import org.papervision3d.core.render.material.IUpdateBeforeMaterial;
	import org.papervision3d.materials.utils.LightMaps;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class GouraudMaterial extends AbstractSmoothShadeMaterial implements ITriangleDrawer, IUpdateBeforeMaterial
	{
		
		private var gouraudMap:BitmapData;
		
		public function GouraudMaterial(light3D:LightObject3D, lightColor:int = 0xFFFFFF, ambientColor:int=0x000000)
		{
			super();
			this.light = light3D;
			gouraudMap = LightMaps.getGouraudMap(lightColor,ambientColor);
		}
		
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
		{
			lightMatrix = Matrix3D(lightMatrices[face3D.instance]);
			var p0:Number = (face3D.v0.normal.x * lightMatrix.n31 + face3D.v0.normal.y * lightMatrix.n32 + face3D.v0.normal.z * lightMatrix.n33)*255;
			
			transformMatrix.tx = p0;
			transformMatrix.ty = 1;
		    transformMatrix.a = ((face3D.v1.normal.x * lightMatrix.n31 + face3D.v1.normal.y * lightMatrix.n32 + face3D.v1.normal.z * lightMatrix.n33)*255) - p0;
		    transformMatrix.c = ((face3D.v2.normal.x * lightMatrix.n31 + face3D.v2.normal.y * lightMatrix.n32 + face3D.v2.normal.z * lightMatrix.n33)*255) - p0;
			transformMatrix.b = 2;
			transformMatrix.d = 3;
		    transformMatrix.invert();
		    
		    var x0:Number = face3D.v0.vertex3DInstance.x;
		    var y0:Number = face3D.v0.vertex3DInstance.y;
			var x1:Number = face3D.v1.vertex3DInstance.x;
			var y1:Number = face3D.v1.vertex3DInstance.y;
			var x2:Number = face3D.v2.vertex3DInstance.x;
			var y2:Number = face3D.v2.vertex3DInstance.y;
	
			triMatrix.a = x1 - x0;
			triMatrix.b = y1 - y0;
			triMatrix.c = x2 - x0;
			triMatrix.d = y2 - y0;
			triMatrix.tx = x0;
			triMatrix.ty = y0;
			transformMatrix.concat(triMatrix);
					
		    graphics.beginBitmapFill( gouraudMap, transformMatrix, false, false);
		    graphics.moveTo( x0, y0 );
			graphics.lineTo( x1, y1 );
			graphics.lineTo( x2, y2 );
			graphics.lineTo( x0, y0 );
			graphics.endFill();
			
			renderSessionData.renderStatistics.shadedTriangles++;
		}
		
	}
}