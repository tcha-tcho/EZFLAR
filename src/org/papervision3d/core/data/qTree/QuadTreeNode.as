package org.papervision3d.core.data.qTree {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.math.util.FastRectangleTools;	
	
	/**
	 * @Author Ralph Hauwert
	 * 
	 */
	public class QuadTreeNode
	{
		
		public var nodeType:int = QuadTreeNodeTypes.NODE_TYPE_LEAF;
		public var boundingRectangle:Rectangle;
		public var depth:int;
		public var maxDepth:int;
		public var items:Array;
		public var children:Array;
		public var parent:QuadTreeNode;
		
		public var hasItems:Boolean;
		public var hasActiveChildren:Boolean;
		
		/**
		 * Quad Layout
		 * 
		 * 1 2
		 * 3 4
		 */
		public var child_1:QuadTreeNode;
		public var child_2:QuadTreeNode;
		public var child_3:QuadTreeNode;
		public var child_4:QuadTreeNode;
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var hWidth:Number;
		public var hHeight:Number;
		
		public function QuadTreeNode(parent:QuadTreeNode, depth:int, maxDepth:int, x:Number, y:Number, width:Number, height:Number)
		{
			boundingRectangle = new Rectangle(x, y, width, height);
			
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			hWidth = width/2;
			hHeight = height/2;
			this.depth = depth;
			this.maxDepth = maxDepth;
			init();
		}
		
		protected function init():void
		{
			items = new Array();
			children = new Array();
			partition();
		}
		
		protected function partition():void
		{
			if(depth <= maxDepth){
				var nDepth:int = depth+1;
				child_1 = new QuadTreeNode(this,nDepth, maxDepth,x,y,hWidth,hHeight);
				children.push(child_1);
				child_2 = new QuadTreeNode(this,nDepth, maxDepth,x+hWidth, y, hWidth, hHeight);
				children.push(child_2);
				child_3 = new QuadTreeNode(this,nDepth, maxDepth,x, y+hHeight, hWidth, hHeight);
				children.push(child_3);
				child_4 = new QuadTreeNode(this,nDepth, maxDepth,x+hWidth, y+hHeight, hWidth, hHeight);
				children.push(child_4);
				nodeType = QuadTreeNodeTypes.NODE_TYPE_CHILD;
			}else{
				nodeType = QuadTreeNodeTypes.NODE_TYPE_LEAF;
			}
		}
		
		public function clearItems():void
		{
			if(hasActiveChildren){
				var node:QuadTreeNode;
				for each(node in children){
					if(node.hasActiveChildren || node.hasItems){
						node.clearItems();
					}
				}
			}
			hasActiveChildren = false;
			hasItems = false;
			items.length = 0;
		}
		
		public function queryPoint(point:Point, array:Array):void
		{
			if(boundingRectangle.containsPoint(point)){
				//Check own items.
				if(hasItems){
					var i:QuadTreeItem;
					for each(i in items){
						if(i.rectangle.containsPoint(point)){
							array.push(i);
						}
					}
				}
				//Check children active
				if(hasActiveChildren){
					var c:QuadTreeNode;
					for each(c in children){
						if(c.hasItems || c.hasActiveChildren){
							if(c.boundingRectangle.containsPoint(point)){
								c.queryPoint(point,array);
							}
						}
					}
				}
			}
		}
		
		public function queryRectangle(rectangle:Rectangle, array:Array):void
		{
			if(FastRectangleTools.intersects(rectangle, boundingRectangle)){
				//Check own items
				if(hasItems){
					var i:QuadTreeItem;
					for each(i in items){
						if(FastRectangleTools.intersects(i.rectangle, rectangle)){
							array.push(i);
						}
					}
				}
				//Check children active
				if(hasActiveChildren){
					var c:QuadTreeNode;
					for each(c in children){
						if(c.hasItems || c.hasActiveChildren){
							if(FastRectangleTools.intersects(c.boundingRectangle, rectangle)){
								c.queryRectangle(rectangle,array);
							}
						}
					}
				}
			}
		}
		
		public function insertItem(item:QuadTreeItem):Boolean
		{
			//Check if we contain it, if not return false to parent.
			if(boundingRectangle.containsRect(item.rectangle)){
				if(nodeType == QuadTreeNodeTypes.NODE_TYPE_CHILD){
					//Check if children can contain this item
					if(item.rectangle.width <= hWidth && item.rectangle.height <= hHeight){
						var childContains:Boolean;
						var child:QuadTreeNode;
						for each(child in children)
						{
							//TODO : Add check for rect size..if it's bigger then the children, we don't bother.
							childContains = child.insertItem(item);
							if(childContains){
								break;
							}
						}
						if(!childContains){
							//This contains, but children don't, insert here.
							doInsertItem(item);
						}else{
							//Note that on of the children has an item now, this should be hasChildItems = true ?, to stop searching.
							hasActiveChildren = true;
						}
					}else{
						//The item is to big to fit in the children, insert it here.
						doInsertItem(item);
					}
					return true;
				}else{
					//This is a leaf node that contains, insert there.
					doInsertItem(item);
				}
			}
			return false;
		}
		
		private function doInsertItem(item:QuadTreeItem):void
		{
			items[item] = item;
			hasItems = true;
		}
		
		public function draw(graphics:Graphics):void
		{
			var child:QuadTreeNode;
			for each(child in children){
				child.draw(graphics);
			}
			if(hasItems){
				graphics.beginFill(0xFF0000,.5);
			}
			
			graphics.lineStyle(maxDepth-depth+2, 0, 1);
			graphics.drawRect(x,y,width,height);
			graphics.lineStyle();
			graphics.endFill();
		}
		
		public function drawItems(graphics:Graphics):void
		{
			var item:QuadTreeItem;
			if(hasItems){
				for each(item in items){
					item.draw(graphics);
				}
			}
			var child:QuadTreeNode;
			for each(child in children){
				child.drawItems(graphics);
			}
		}
		
		
	}
}