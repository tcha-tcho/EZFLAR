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
	* The WireframeMaterial class creates a wireframe material, where only the outlines of the faces are drawn.
	* <p/>
	* Materials collects data about how objects appear when rendered.
	*/
	public class WireframeMaterial extends TriangleMaterial implements ITriangleDrawer
	{
		
		/**
		* The WireframeMaterial class creates a wireframe material, where only the outlines of the faces are drawn.
		*
		* @param	asset				A BitmapData object.
		* @param	initObject			[optional] - An object that contains additional properties with which to populate the newly created material.
		*/
		public function WireframeMaterial( color:Number=0xFF00FF, alpha:Number=100, thickness:Number = 0 )
		{
			this.lineColor     = color;
			this.lineAlpha     = alpha;
			this.lineThickness = thickness;

			this.doubleSided = false;
		}
		
		/**
		 *  drawTriangle
		 */
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData = null, altUV:Matrix = null):void
		{
			var x0:Number = face3D.v0.vertex3DInstance.x;
			var y0:Number = face3D.v0.vertex3DInstance.y;
			
			if( lineAlpha )
			{
				graphics.lineStyle( lineThickness, lineColor, lineAlpha );
				graphics.moveTo( x0, y0 );
				graphics.lineTo( face3D.v1.vertex3DInstance.x, face3D.v1.vertex3DInstance.y );
				graphics.lineTo( face3D.v2.vertex3DInstance.x, face3D.v2.vertex3DInstance.y );
				graphics.lineTo( x0, y0 );
				graphics.lineStyle();

				renderSessionData.renderStatistics.triangles++;
			}

		}

		// ______________________________________________________________________ TO STRING

		/**
		* Returns a string value representing the material properties in the specified WireframeMaterial object.
		*
		* @return	A string.
		*/
		public override function toString(): String
		{
			return 'WireframeMaterial - color:' + this.lineColor + ' alpha:' + this.lineAlpha;
		}
	}
}