package org.papervision3d.core.render.draw
{
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public interface ITriangleDrawer
	{
		function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void;
	}
	
	
}