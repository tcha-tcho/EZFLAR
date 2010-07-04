package org.papervision3d.materials.special
{
	import flash.display.Graphics;
	
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ILineDrawer;

	public class LineMaterial extends MaterialObject3D implements ILineDrawer
	{
		
		public function LineMaterial(color:Number = 0xFF0000, alpha:Number = 1)
		{
			super();
			this.lineColor = color;
			this.lineAlpha = alpha;
		}
		
		public function drawLine(line:Line3D, graphics:Graphics, renderSessionData:RenderSessionData):void
		{	
			graphics.lineStyle( line.size, lineColor, lineAlpha );
			graphics.moveTo( line.v0.vertex3DInstance.x, line.v0.vertex3DInstance.y );
			
			if(line.cV){
				graphics.curveTo(line.cV.vertex3DInstance.x, line.cV.vertex3DInstance.y, line.v1.vertex3DInstance.x, line.v1.vertex3DInstance.y);
			}else{
				graphics.lineTo( line.v1.vertex3DInstance.x, line.v1.vertex3DInstance.y );
			}
			
			graphics.moveTo(0,0);
			graphics.lineStyle();
		}
		
	}
}