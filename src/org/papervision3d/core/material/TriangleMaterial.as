package org.papervision3d.core.material
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;

	public class TriangleMaterial extends MaterialObject3D implements ITriangleDrawer
	{
		public function TriangleMaterial()
		{
			super();
		}
		
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
		{
			
		}
		
	}
}