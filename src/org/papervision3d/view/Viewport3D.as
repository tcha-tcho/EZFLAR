package org.papervision3d.view {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.culling.DefaultLineCuller;
	import org.papervision3d.core.culling.DefaultParticleCuller;
	import org.papervision3d.core.culling.DefaultTriangleCuller;
	import org.papervision3d.core.culling.ILineCuller;
	import org.papervision3d.core.culling.IParticleCuller;
	import org.papervision3d.core.culling.ITriangleCuller;
	import org.papervision3d.core.culling.RectangleLineCuller;
	import org.papervision3d.core.culling.RectangleParticleCuller;
	import org.papervision3d.core.culling.RectangleTriangleCuller;
	import org.papervision3d.core.culling.ViewportObjectFilter;
	import org.papervision3d.core.render.IRenderEngine;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.utils.InteractiveSceneManager;
	import org.papervision3d.core.view.IViewport3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.layer.ViewportBaseLayer;
	import org.papervision3d.view.layer.ViewportLayer;
	

	/**
	 * @Author Ralph Hauwert
	 */
	 
	/* Changed to protected methods on 11/27/2007 by John */
	/* Added LineCulling on 22 May 08 by Seb Lee-Delisle */
	
	public class Viewport3D extends Sprite implements IViewport3D
	{
		
		//use namespace org.papervision3d.core.ns.pv3dview;
		protected var _width:Number;
		protected var _hWidth:Number;
		protected var _height:Number;
		protected var _hHeight:Number;
		
		protected var _autoClipping:Boolean;
		protected var _autoCulling:Boolean;
		protected var _autoScaleToStage:Boolean;
		protected var _interactive:Boolean;
		protected var _lastRenderer:IRenderEngine;
		protected var _viewportObjectFilter:ViewportObjectFilter;
		protected var _containerSprite:ViewportBaseLayer;
		protected var _layerInstances:Dictionary;
		
		public var sizeRectangle:Rectangle;
		public var cullingRectangle:Rectangle;
		
		public var triangleCuller:ITriangleCuller;
		public var particleCuller:IParticleCuller;
		public var lineCuller : ILineCuller;
				public var lastRenderList:Array;
		public var interactiveSceneManager:InteractiveSceneManager;
		
		protected var renderHitData:RenderHitData;
		
		public function Viewport3D(viewportWidth:Number = 640, viewportHeight:Number = 480, autoScaleToStage:Boolean = false, interactive:Boolean = false, autoClipping:Boolean = true, autoCulling:Boolean = true)
		{
			super();
			init();
			
			this.interactive = interactive;
			
			this.viewportWidth = viewportWidth;
			this.viewportHeight = viewportHeight;
			
			this.autoClipping = autoClipping;
			this.autoCulling = autoCulling;
			
			this.autoScaleToStage = autoScaleToStage;
			
			this._layerInstances = new Dictionary(true);
		}
		
		public function destroy():void
		{
			if(interactiveSceneManager){
				interactiveSceneManager.destroy();
				interactiveSceneManager = null;
			}
			lastRenderList = null;
		}
		
		protected function init():void
		{
			this.renderHitData = new RenderHitData();
			
			lastRenderList = new Array();
			sizeRectangle = new Rectangle();
			cullingRectangle = new Rectangle();
			
			_containerSprite = new ViewportBaseLayer(this);
			addChild(_containerSprite);
		
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
				
		public function hitTestMouse():RenderHitData
		{
			var p:Point = new Point(containerSprite.mouseX, containerSprite.mouseY);
			return hitTestPoint2D(p);
		}
		
		public function hitTestPoint2D(point:Point):RenderHitData
		{
			renderHitData.clear();
			if(interactive){
				var rli:RenderableListItem;
				var rhd:RenderHitData = renderHitData;
				var rc:IRenderListItem;
				for(var i:uint = lastRenderList.length; rc = lastRenderList[--i]; )
				{
					if(rc is RenderableListItem)
					{
						rli = rc as RenderableListItem;
						rhd = rli.hitTestPoint2D(point, rhd);
						if(rhd.hasHit)
						{				
							return rhd;
						}
					}
				}
			}
			return renderHitData;
		}
		
		public function getChildLayer(do3d:DisplayObject3D, createNew:Boolean=true, recurse:Boolean = true):ViewportLayer{
			return containerSprite.getChildLayer(do3d, createNew, recurse);
		}
		
		public function accessLayerFor(rc:RenderableListItem, setInstance:Boolean = false):ViewportLayer{
			
			
			var do3d:DisplayObject3D;
			
			if(rc.renderableInstance){
				do3d = rc.renderableInstance.instance;

				do3d = do3d.parentContainer?do3d.parentContainer:do3d;
				
				if(containerSprite.layers[do3d]){
					 if(setInstance){
				 		do3d.container = containerSprite.layers[do3d];
				 	}
					return containerSprite.layers[do3d];
				}else if(do3d.useOwnContainer){
					return containerSprite.getChildLayer(do3d, true, true);	
				}
			 
			 }
			
			return containerSprite;
			
		
		}
		
		protected function onAddedToStage(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize();
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE, onStageResize);
		}
		
		protected function onStageResize(event:Event = null):void
		{
			if(_autoScaleToStage)
			{
				viewportWidth = stage.stageWidth;
				viewportHeight = stage.stageHeight;
			}
		}
		
		public function set viewportWidth(width:Number):void
		{
			_width = width;
			_hWidth = width/2;
			containerSprite.x = _hWidth;
			
			cullingRectangle.x = -_hWidth;
			cullingRectangle.width = width;
			
			sizeRectangle.width = width;
			if(_autoClipping){
				scrollRect = sizeRectangle;
			}
		}
		
		public function get viewportWidth():Number
		{
			return _width;
		}
		
		public function set viewportHeight(height:Number):void
		{
			_height = height;
			_hHeight = height/2;
			containerSprite.y = _hHeight;
			
			cullingRectangle.y = -_hHeight;
			cullingRectangle.height = height;
			
			sizeRectangle.height = height;
			if(_autoClipping){
				scrollRect = sizeRectangle;
			}
		}
		
		public function get viewportHeight():Number
		{
			return _height;
		}
		
		public function get containerSprite():ViewportLayer
		{
			return _containerSprite;	
		}
		
		public function set autoClipping(clip:Boolean):void
		{
			if(clip){
				scrollRect = sizeRectangle;
			}else{
				scrollRect = null;
			}
			_autoClipping = clip;
		}
		
		public function get autoClipping():Boolean
		{
			return _autoClipping;	
		}
		
		public function set autoCulling(culling:Boolean):void
		{
			if(culling){
				triangleCuller = new RectangleTriangleCuller(cullingRectangle);
				particleCuller = new RectangleParticleCuller(cullingRectangle);
				lineCuller     = new RectangleLineCuller(cullingRectangle);
			}else if(!culling){
				triangleCuller = new DefaultTriangleCuller();
				particleCuller = new DefaultParticleCuller();
				lineCuller 	   = new DefaultLineCuller();
			}
			_autoCulling = culling;	
		}
		
		public function get autoCulling():Boolean
		{
			return _autoCulling;
		}
		
		public function set autoScaleToStage(scale:Boolean):void
		{
			_autoScaleToStage = scale;
			if(scale && stage != null){
				onStageResize();
			}
		}
		
		public function get autoScaleToStage():Boolean
		{
			return _autoScaleToStage;
		}
		
		public function set interactive(b:Boolean):void
		{
			if(b != _interactive){
				if(_interactive && interactiveSceneManager){
					interactiveSceneManager.destroy();
					interactiveSceneManager = null;
				}
				_interactive = b;
				if(b){
					interactiveSceneManager = new InteractiveSceneManager(this);
				}
			}
		}
		
		public function get interactive():Boolean
		{
			return _interactive;
		}
		
		public function updateBeforeRender(renderSessionData:RenderSessionData):void
		{
			lastRenderList.length = 0;
			
			if(renderSessionData.renderLayers){
				for each(var vpl:ViewportLayer in renderSessionData.renderLayers){ 
					vpl.updateBeforeRender();
				}
			}else{
				_containerSprite.updateBeforeRender();
			}
			
			_layerInstances = new Dictionary(true);
		}
		
		public function updateAfterRender(renderSessionData:RenderSessionData):void
		{
			if(interactive){
				interactiveSceneManager.updateRenderHitData();
			}
			
			if(renderSessionData.renderLayers){
				for each(var vpl:ViewportLayer in renderSessionData.renderLayers) {
					vpl.updateInfo();
					vpl.sortChildLayers();
					vpl.updateAfterRender();
				}
			}else{
				containerSprite.updateInfo();
				containerSprite.updateAfterRender();
			}
			
			containerSprite.sortChildLayers();
		}
		
		public function set viewportObjectFilter(vof:ViewportObjectFilter):void
		{
			_viewportObjectFilter = vof;
		}
		
		public function get viewportObjectFilter():ViewportObjectFilter
		{
			return _viewportObjectFilter;
		}
		
		
	
	}
}