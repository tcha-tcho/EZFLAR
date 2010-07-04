package org.papervision3d.core.culling
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.objects.DisplayObject3D;


	/**
	 * @Author Ralph Hauwert
	 */
	public class ViewportObjectFilter implements IObjectCuller
	{
		
		protected var _mode:int;
		protected var objects:Dictionary;
		
		public function ViewportObjectFilter(mode:int):void
		{
			this.mode = mode;
			init();
		}
		
		private function init():void
		{
			objects = new Dictionary(true);
		}
		
		public function testObject(object:DisplayObject3D):int
		{
			if(objects[object]){
				if(_mode == ViewportObjectFilterMode.INCLUSIVE){
					return 1;
				}else if(_mode == ViewportObjectFilterMode.EXCLUSIVE){
					return 0;
				}
			}else{
				if(_mode == ViewportObjectFilterMode.INCLUSIVE){
					return 0;
				}else if(_mode == ViewportObjectFilterMode.EXCLUSIVE){
					return 1;
				}
			}
			return 0;
		}
		
		public function addObject(do3d:DisplayObject3D):void
		{
			objects[do3d] = do3d;
		}
		
		public function removeObject(do3d:DisplayObject3D):void
		{
			delete objects[do3d];
		}
		
		public function set mode(mode:int):void
		{
			_mode = mode;	
		}
		
		public function get mode():int
		{
			return _mode;
		}
		
		public function destroy():void
		{
			objects = null;
		}
		
	}
}