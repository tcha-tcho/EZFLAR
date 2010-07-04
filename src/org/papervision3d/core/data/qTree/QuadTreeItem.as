package org.papervision3d.core.data.qTree {
		import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.math.util.FastRectangleTools;	
		
	
	/**
	 * @Author Ralph Hauwert
	 * 
	 */
	public class QuadTreeItem
	{
		public var data:Object;
		public var rectangle:Rectangle;
		
		public function QuadTreeItem(data:Object, rectangle:Rectangle):void
		{
			this.data = data;
			this.rectangle = rectangle;
		}
		
		public function draw(graphics:Graphics):void
		{
			graphics.beginFill(0x00FF00, .3);
			graphics.drawRect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
			graphics.endFill();
		}
		
		public function clipRectangleWith(brectangle:Rectangle):void 
		{
			FastRectangleTools.intersection(this.rectangle, brectangle, this.rectangle);
		}
	}
}