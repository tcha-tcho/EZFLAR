package org.papervision3d.core.render.draw
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.display.Graphics;
	
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public interface ILineDrawer
	{
		function drawLine(line:Line3D, graphics:Graphics, renderSessionData:RenderSessionData):void;
	}
}