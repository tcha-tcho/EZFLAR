package org.papervision3d.materials.shadematerials
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.material.AbstractLightShadeMaterial;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	import org.papervision3d.materials.utils.LightMaps;
	
	/**
	 *	@Author Ralph Hauwert
	 */
	public class FlatShadeMaterial extends AbstractLightShadeMaterial implements ITriangleDrawer
	{
		private static var currentColor:int;
		private static var zAngle:int;
		
		private var _colors:Array;
		
		public function FlatShadeMaterial(light:LightObject3D, diffuse:uint=0xffffff, ambient:uint=0x000000)
		{
			super();
			this.fillAlpha = 1;
			this.light = light;
			_colors = LightMaps.getFlatMapArray(diffuse,ambient,1);
		}
		
		/**
		 * Localized stuff.
		 */
		private static var zd:Number;
		private static var x0:Number;
		private static var y0:Number;
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
		{
			lightMatrix = Matrix3D(lightMatrices[face3D.instance]);
			zd = face3D.faceNormal.x * lightMatrix.n31 + face3D.faceNormal.y * lightMatrix.n32 + face3D.faceNormal.z * lightMatrix.n33;
			if(zd < 0){zd = 0;};
			x0 = face3D.v0.vertex3DInstance.x;
		    y0 = face3D.v0.vertex3DInstance.y;
			zAngle = zd*0xff;
			currentColor = _colors[zAngle];
			
			graphics.beginFill(currentColor,fillAlpha);
			graphics.moveTo(x0, y0);
			graphics.lineTo(face3D.v1.vertex3DInstance.x, face3D.v1.vertex3DInstance.y);
			graphics.lineTo(face3D.v2.vertex3DInstance.x, face3D.v2.vertex3DInstance.y);
			graphics.lineTo(x0, y0);
			graphics.endFill();
			renderSessionData.renderStatistics.shadedTriangles++;
		}
		
	}
}