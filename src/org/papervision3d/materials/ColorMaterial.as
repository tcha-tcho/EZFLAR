package org.papervision3d.materials
{
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.material.TriangleMaterial;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.ITriangleDrawer;

/**
* The ColorMaterial class creates a solid color material.
*
* Materials collects data about how objects appear when rendered.
*
*/
public class ColorMaterial extends TriangleMaterial implements ITriangleDrawer
{
	
	/**
	* The ColorMaterial class creates a solid color material.
	*
	* @param	asset				A BitmapData object.
	* @param	initObject			[optional] - An object that contains additional properties with which to populate the newly created material.
	*/
	public function ColorMaterial( color:Number=0xFF00FF, alpha:Number = 1, interactive:Boolean = false )
	{
		this.fillColor = color;
		this.fillAlpha = alpha;
		this.interactive = interactive;
	}
	
	/**
	 *  drawTriangle
	 */
	override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
	{
		var x0:Number = face3D.v0.vertex3DInstance.x;
		var y0:Number = face3D.v0.vertex3DInstance.y;
		var x1:Number = face3D.v1.vertex3DInstance.x;
		var y1:Number = face3D.v1.vertex3DInstance.y;
		var x2:Number = face3D.v2.vertex3DInstance.x;
		var y2:Number = face3D.v2.vertex3DInstance.y;
		
		graphics.beginFill( fillColor, fillAlpha );
		graphics.moveTo( x0, y0 );
		graphics.lineTo( x1, y1 );
		graphics.lineTo( x2, y2 );
		graphics.lineTo( x0, y0 );
		graphics.endFill();
		
		renderSessionData.renderStatistics.triangles++;
	
	}
	
	/**
	* Returns a string value representing the material properties in the specified ColorMaterial object.
	*
	* @return	A string.
	*/
	public override function toString(): String
	{
		return 'ColorMaterial - color:' + this.fillColor + ' alpha:' + this.fillAlpha;
	}
}
}