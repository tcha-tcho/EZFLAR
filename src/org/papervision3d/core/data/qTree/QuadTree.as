package org.papervision3d.core.data.qTree {
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.util.FastRectangleTools;	
	
	/**
	 * @Author Ralph Hauwert
	 * 
	 */
	public class QuadTree
	{
		public var baseNode:QuadTreeBaseNode;
		
		public function QuadTree(width:Number, height:Number, maxDepth:int = 6)
		{
			baseNode = new QuadTreeBaseNode(width,height,maxDepth);
		}
		
		public function insertItem(item:QuadTreeItem):Boolean
		{
			if(FastRectangleTools.intersects(item.rectangle, baseNode.boundingRectangle)){
				if(baseNode.boundingRectangle.containsRect(item.rectangle)){
					//It falls within the quadtree, cool..back to normal..
					baseNode.insertItem(item);
				}else{
					//It doesn't fall within the tree, but it does intersect, let's clip the items rectangle.
					item.clipRectangleWith(baseNode.boundingRectangle);
					//And insert
					baseNode.insertItem(item);
				}
			}
			//It doesn't even intersect...exit...
			return false;
		}
		
		public function queryRectangle(rectangle:Rectangle):Array
		{
			var array:Array = new Array();
			baseNode.queryRectangle(rectangle, array);
			return array;
		}
		
		public function queryPoint(point:Point):Array
		{
			var array:Array = new Array();
			baseNode.queryPoint(point, array);
			return array;
		}
		
		public function clearItems():void
		{
			baseNode.clearItems();
		}
		
	}
}