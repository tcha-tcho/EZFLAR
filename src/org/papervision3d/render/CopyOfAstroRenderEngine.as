package org.papervision3d.render
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	import flash.geom.Point;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.AbstractRenderEngine;
	import org.papervision3d.core.render.IRenderEngine;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.data.RenderStatistics;
	import org.papervision3d.core.render.filter.BasicRenderFilter;
	import org.papervision3d.core.render.filter.IRenderFilter;
	import org.papervision3d.core.render.material.MaterialManager;
	import org.papervision3d.core.render.project.BasicProjectionPipeline;
	import org.papervision3d.core.render.project.ProjectionPipeline;
	import org.papervision3d.core.render.sort.BasicRenderSorter;
	import org.papervision3d.core.render.sort.IRenderSorter;
	import org.papervision3d.core.utils.StopWatch;
	import org.papervision3d.events.RendererEvent;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.core.render.command.RenderFog;
	import org.papervision3d.core.render.command.RenderTriangle;
	import org.papervision3d.core.geom.renderables.Triangle3D;

	import flash.display.Graphics;
	import __AS3__.vec.Vector;

	public class AstroRenderEngine extends AbstractRenderEngine implements IRenderEngine
	{
		
		public var projectionPipeline:ProjectionPipeline;
		
		public var sorter:IRenderSorter;
		public var filter:IRenderFilter;
		
		protected var renderDoneEvent:RendererEvent;
		protected var projectionDoneEvent:RendererEvent;
		
		protected var renderStatistics:RenderStatistics;
		protected var renderList:Array;
		protected var renderSessionData:RenderSessionData;
		protected var cleanRHD:RenderHitData = new RenderHitData();
		protected var stopWatch:StopWatch;
		
		public function BasicRenderEngine():void
		{
			init();			 
		}
		
		public function destroy():void
		{
			renderDoneEvent = null;
			projectionDoneEvent = null;
			projectionPipeline = null;
			sorter = null;
			filter = null;
			renderStatistics = null;
			renderList = null;
			renderSessionData.destroy();
			renderSessionData = null;
			cleanRHD = null;
			stopWatch = null;
		}
		
		protected function init():void
		{
			renderStatistics = new RenderStatistics();
			
			projectionPipeline = new BasicProjectionPipeline();
			
			stopWatch = new StopWatch();
				
			sorter = new BasicRenderSorter();
			filter = new BasicRenderFilter();
			
			renderList = new Array();
			
			renderSessionData = new RenderSessionData();
			renderSessionData.renderer = this;
			
			projectionDoneEvent = new RendererEvent(RendererEvent.PROJECTION_DONE, renderSessionData);
			renderDoneEvent = new RendererEvent(RendererEvent.RENDER_DONE, renderSessionData);
		}
		
		override public function renderScene(scene:SceneObject3D, camera:CameraObject3D, viewPort:Viewport3D, updateAnimation:Boolean = true):RenderStatistics
		{
			//Update the renderSessionData object.
			renderSessionData.scene = scene;
			renderSessionData.camera = camera;
			renderSessionData.viewPort = viewPort;
			renderSessionData.container = viewPort.containerSprite;
			renderSessionData.triangleCuller = viewPort.triangleCuller;
			renderSessionData.particleCuller = viewPort.particleCuller;
			renderSessionData.renderObjects = scene.objects;
			renderSessionData.renderLayers = null;
			renderSessionData.renderStatistics.clear();
			
			//Clear the viewport.
			viewPort.updateBeforeRender(renderSessionData);
			
			//Project the Scene (this will fill up the renderlist).
			projectionPipeline.project(renderSessionData);
			if(hasEventListener(RendererEvent.PROJECTION_DONE)){
				dispatchEvent(projectionDoneEvent);
			}
			
			//Render the Scene.
			doRender(renderSessionData, null);
			if(hasEventListener(RendererEvent.RENDER_DONE)){
				dispatchEvent(renderDoneEvent);
			}
			
			return renderSessionData.renderStatistics;
		}
		
		public function renderLayers(scene:SceneObject3D, camera:CameraObject3D, viewPort:Viewport3D, layers:Array = null, updateAnimation:Boolean = true):RenderStatistics
		{
			//Update the renderSessionData object.
			renderSessionData.scene = scene;
			renderSessionData.camera = camera;
			renderSessionData.viewPort = viewPort;
			renderSessionData.container = viewPort.containerSprite;
			renderSessionData.triangleCuller = viewPort.triangleCuller;
			renderSessionData.particleCuller = viewPort.particleCuller;
			renderSessionData.renderObjects = getLayerObjects(layers);
			renderSessionData.renderLayers = layers;
			renderSessionData.renderStatistics.clear();
					
			//Clear the viewport.
		
			viewPort.updateBeforeRender(renderSessionData);
			
			//Project the Scene (this will fill up the renderlist).
			projectionPipeline.project(renderSessionData);
			if(hasEventListener(RendererEvent.PROJECTION_DONE)){
				dispatchEvent(projectionDoneEvent);
			}
			
			//Render the Scene.
			doRender(renderSessionData);
			if(hasEventListener(RendererEvent.RENDER_DONE)){
				dispatchEvent(renderDoneEvent);
			}
			
			return renderSessionData.renderStatistics;
		}
		
		private function getLayerObjects(layers:Array):Array{
			var array:Array = new Array();
			
			for each (var vpl:ViewportLayer in layers){
				array = array.concat(vpl.getLayerObjects());
			}
			return array;
		}
		
		
	
		protected function doRender2(renderSessionData:RenderSessionData, layers:Array = null):RenderStatistics
		{

//			stopWatch.reset();
//			stopWatch.start();

	
			//Update Materials.
			MaterialManager.getInstance().updateMaterialsBeforeRender(renderSessionData);

			//Filter the list
			filter.filter(renderList);
			
			//Sort entire list.
			sorter.sort(renderList);
			
			var rc:RenderableListItem;
			var viewport:Viewport3D = renderSessionData.viewPort;
			var vpl:ViewportLayer;
			
//			vertices = new Vector.<Number>();
//			uvData = new Vector.<Number>();

			while(rc = renderList.pop())
			{
				
				vpl = viewport.accessLayerFor(rc, true);
				rc.render(renderSessionData, vpl.graphicsChannel);

//				if( rc is RenderTriangle )
//					processTriangle( rc as RenderTriangle );

				viewport.lastRenderList.push(rc);
				vpl.processRenderItem(rc);
			}


//			var g:Graphics = vpl.graphicsChannel;
//			g.clear();
//			g.beginFill( 0x00FF00, 0.5 );
////			g.beginBitmapFill( loader.getBitmapData('mini_texture') );
//			g.drawTriangles( vertices, null, uvData );		


			//Update Materials
			MaterialManager.getInstance().updateMaterialsAfterRender(renderSessionData);
			
//			renderSessionData.renderStatistics.renderTime = stopWatch.stop();
			renderSessionData.viewPort.updateAfterRender(renderSessionData);

			return renderStatistics;
		}






		protected function doRender(renderSessionData:RenderSessionData, layers:Array = null):RenderStatistics
		{
			stopWatch.reset();
			stopWatch.start();
			
			//Update Materials.
			MaterialManager.getInstance().updateMaterialsBeforeRender(renderSessionData);

			//Filter the list
			filter.filter(renderList);
			
			//Sort entire list.
			sorter.sort(renderList);
			
			var rc:RenderableListItem;
			var viewport:Viewport3D = renderSessionData.viewPort;
			var vpl:ViewportLayer;
			
			while(rc = renderList.pop())
			{
				
				vpl = viewport.accessLayerFor(rc, true);
				rc.render(renderSessionData, vpl.graphicsChannel);
				viewport.lastRenderList.push(rc);
				vpl.processRenderItem(rc);
			}
			
			//Update Materials
			MaterialManager.getInstance().updateMaterialsAfterRender(renderSessionData);
			
			renderSessionData.renderStatistics.renderTime = stopWatch.stop();
			renderSessionData.viewPort.updateAfterRender(renderSessionData);
			return renderStatistics;
		}
		
		
		
		
		
		
		
		
		
		public function hitTestPoint2D(point:Point, viewPort3D:Viewport3D):RenderHitData
		{
			return viewPort3D.hitTestPoint2D(point);
		}
		
		override public function addToRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.push(renderCommand);
		}
		
		override public function removeFromRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.splice(renderList.indexOf(renderCommand),1);
		}

		// _______________________________________________________________________________________ Astro

		private function processTriangle( rc:RenderTriangle ):void
		{
			var face3d:Triangle3D = rc.triangle;

			vertices.push( face3d.v0.vertex3DInstance.x );
			vertices.push( face3d.v0.vertex3DInstance.y );
			vertices.push( face3d.v1.vertex3DInstance.x );
			vertices.push( face3d.v1.vertex3DInstance.y );
			vertices.push( face3d.v2.vertex3DInstance.x );
			vertices.push( face3d.v2.vertex3DInstance.y );

			uvData.push( face3d.uv0.u );
			uvData.push( face3d.uv0.v );
			uvData.push( face3d.uv1.u );
			uvData.push( face3d.uv1.v );
			uvData.push( face3d.uv2.u );
			uvData.push( face3d.uv2.v );
		}

		private var vertices:Vector.<Number>;
		private var uvData:Vector.<Number>;
	}
}