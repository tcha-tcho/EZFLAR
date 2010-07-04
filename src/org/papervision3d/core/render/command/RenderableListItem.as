package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 */	
	import flash.geom.Point;
	
	import org.papervision3d.core.geom.renderables.AbstractRenderable;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class RenderableListItem extends AbstractRenderListItem
	{
		public var renderable:Class;
		public var renderableInstance:AbstractRenderable;
		public var instance:DisplayObject3D;
		
		public function RenderableListItem()
		{
			super();
		}
		
		public function hitTestPoint2D(point:Point, renderHitData:RenderHitData):RenderHitData
		{
			return renderHitData;
		}
		
	}
}