package org.papervision3d.core.data.qTree
{
	/**
	 * @Author Ralph Hauwert
	 * 
	 */
	public class QuadTreeBaseNode extends QuadTreeNode
	{
		
		public function QuadTreeBaseNode(width:int, height:int, maxDepth:int)
		{
			super(this, 0, maxDepth, 0,0,width,height);
		}
		
		override protected function init():void
		{
			super.init();
		}
		
	}
}