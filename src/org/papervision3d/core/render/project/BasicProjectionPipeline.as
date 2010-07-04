package org.papervision3d.core.render.project
{
	import org.papervision3d.core.culling.IObjectCuller;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.Vertices3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class BasicProjectionPipeline extends ProjectionPipeline
	{
		
		public function BasicProjectionPipeline()
		{
			super();
			init();
		}
		
		protected function init():void
		{
				
		}
		
		/**
		 * project(renderSessionData:RenderSessionData);
		 * 
		 * Projects all base objects
		 * 
		 * @returns void;
		 */
		override public function project(renderSessionData:RenderSessionData):void
		{
			// Transform camera
			renderSessionData.camera.transformView();
			
			//Start looping through all objects in the scene.
			var objects:Array = renderSessionData.renderObjects;
			var p:DisplayObject3D;
			var i:Number = objects.length;
	
			//The frustum camera requires 4x4 matrices.
			if( renderSessionData.camera is IObjectCuller){
				for each(p in objects){
					//Test if the object is set to visible
					if(p.visible){
						//If we filter objects per viewport..then....
						if(renderSessionData.viewPort.viewportObjectFilter){
							//...test if the object should be rendered to this viewport.
							if(renderSessionData.viewPort.viewportObjectFilter.testObject(p)){
								//Calculate the view for this object.
								p.view.calculateMultiply4x4(renderSessionData.camera.eye, p.transform);
								//And project it.
								projectObject(p, renderSessionData);
							}else{
								//...if the object shouldn't be rendered on this viewport
								renderSessionData.renderStatistics.filteredObjects++;
							}
						}else{
							//If we don't filter objects.
							p.view.calculateMultiply4x4(renderSessionData.camera.eye, p.transform);
							projectObject(p, renderSessionData);
						}
					}
				}
			}else{
				for each(p in objects){
					//Test if the object is set to visible
					
					if( p.visible){
						//If we filter objects per viewport..then....
						if(renderSessionData.viewPort.viewportObjectFilter){
							if(renderSessionData.viewPort.viewportObjectFilter.testObject(p)){
								//Calculate the view for this object.
								p.view.calculateMultiply(renderSessionData.camera.eye, p.transform);
								//And project it.
								projectObject(p, renderSessionData);
							}else{
								//The object is filtered.
								renderSessionData.renderStatistics.filteredObjects++;
							}
						}else{
							//Calculate the view for this object
							p.view.calculateMultiply(renderSessionData.camera.eye, p.transform);
							//And project it
							projectObject(p, renderSessionData);
						}
					}
				}
			}
		}
		
		protected function projectObject(object:DisplayObject3D, renderSessionData:RenderSessionData):void
		{
			//Collect everything from the object
			object.project(renderSessionData.camera, renderSessionData);
		}
		
	}
}