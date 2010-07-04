/**
 * 
 * @author John Grden
 * 
 */	
package org.papervision3d.core.components.as3.core
{
	import com.blitzagency.xray.logger.XrayLog;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	//import org.papervision3d.objects.particles.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.primitives.Cube;
	
	/**
	* Dispatched when the component has been initialized.  This does not include when the scene3d is created or a subsequent collada file is completed
	* 
	* @eventType org.papervision3d.components.as3.flash9.PV3DUIComponent.INIT_COMPLETE
	*/
	[Event(name="initComplete", type="flash.events.Event")]
	
	/**
	 * PV3DUIComponent is the core class from which the other PV3D Design-time components are built.  It takes care of stage resize events and positioning of the component
	 * 
	 */	
	
	public class PV3DUIComponent extends MovieClip
	{
		/**
		* @eventType initComplete
		*/
		public static const INIT_COMPLETE		:String = "initComplete";
		
		[Inspectable ( type="Boolean", defaultValue=false, name="Clip content")]
		/**
		* Whether or not you want the scene to have a mask applied to the area of the component.  If false, you will see the 3D scene extend beyond the bounding area of the component
		*/		
		public var clipContent				:Boolean = false;
		
		[Inspectable ( name="Resize with Stage?", defaultValue=false, type="Boolean" )]
		/**
		 * A Boolean flag that allows the component to resize to bottom/right of the stage if set to true.  Remember to set your x/y coordinates as the component will only resize from where you've positioned it on stage.
		 * @param p_resize
		 * 
		 */		
		public function set resizeWithStage(p_resize:Boolean):void
		{
			_resizeWithStage = p_resize;
			resizeStage();
		}
		
		public function get resizeWithStage():Boolean
		{
			return _resizeWithStage;
		}
		
		// coordinates
		/**
		 * @private 
	 	*/
		protected var screenOffsetX					:Number = 0;
		/**
		 * @private 
	 	*/
		protected var screenOffsetY					:Number = 0;
		
		// sizing
		/**
		* Width of your component on stage
		*/		
		public var sceneWidth						:Number = 320;
		/**
		* Height of your component on stage
		*/
		public var sceneHeight						:Number = 240;
		
		private var _resizeWithStage				:Boolean = false;
		/**
		 * @private 
	 	*/
		protected var _componentInspectorSetting	:Boolean = false;
		
		/**
		 * @private 
	 	*/
		protected var _propertyInspectorSetting		:Boolean = false;
		
		/**
		 * @private 
	 	*/
		protected var isAppInitialized				:Boolean = false;
		
		// live preview
		/**
		 * @private 
	 	*/
		protected var isLivePreview					:Boolean = false;
		
		// logging
		/**
		 * @private 
	 	*/
		protected var log							:XrayLog = new XrayLog();
		
		public function PV3DUIComponent()
		{
			super();
			includePackages();
			init();
		}
		
		private function includePackages():void
		{
			// materials;
			BitmapAssetMaterial;
			BitmapColorMaterial;
			BitmapFileMaterial;
			BitmapMaterial;
			//BitmapWireframeMaterial;
			ColorMaterial;
			//CompositeMaterial;
			//IPreciseMaterial;
			//MaterialsList;
			MovieAssetMaterial;
			MovieMaterial;
			/* PreciseBitmapAssetMaterial;
			PreciseBitmapFileMaterial;
			PreciseBitmapMaterial;
			PreciseMovieAssetMaterial;
			PreciseMovieMaterial; */
			VideoStreamMaterial;
			WireframeMaterial;
			
			// objects
			//AbstractParticle;
			//IParticle;
			//StarParticle;
			//Ase;
			Collada;
			//Cone;
			Cube;
			//Cylinder;
			DisplayObject3D;
			//OldCube;
			//PaperPlane;
			//ParticleField;
			//Plane;
			//Sphere;
			//VertexParticles;
			
			// cameras
			Camera3D;
			FreeCamera3D;
			FrustumCamera3D;
			
			// scenes
			Scene3D;		
		}
		
		/**
		 * @private
		 * @note Called when the component is actually running in a compiled SWF at runtime, rather than LivePreview
		 * @param p_piSetting
		 * 
		 */		
		public function set componentInspectorSetting(p_piSetting:Boolean):void
		{
			_componentInspectorSetting = p_piSetting;
			log.debug("componentInspectorSetting", p_piSetting);
			if(!_componentInspectorSetting) 
			{
				// properties are set, we're ready to init the app
				initApp();
			}
		}
		
		/**
		 * @private 
	 	*/
		public function get componentInspectorSetting():Boolean
		{
			return _componentInspectorSetting;
		}
		
		/**
		 * @private 
	 	*/
		public function set propertyInspectorSetting(p_piSetting:Boolean):void
		{
			_propertyInspectorSetting = p_piSetting;
		}
		
		/**
		 * @private 
	 	*/
		public function get propertyInspectorSetting():Boolean
		{
			return _propertyInspectorSetting;
		}
		
		/**
		 * @private 
	 	*/
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
		}
		
		/**
		 * @private 
	 	*/
		protected function initApp():void
		{
			isLivePreview = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
			
			configUI();
			
			drawStage();
			alignStage();
			initListeners();
			
			dispatchEvent(new Event(INIT_COMPLETE));	
			isAppInitialized = true;	
		}
		
		/**
		 * @private 
	 	*/
		protected function configUI():void
		{
			
		}
		
		// called by LivePreveiwParent class
		/**
		 * Pass in width and height to change the size of the component on stage.  This will not scale your 3D scene, only the component itself
		 * @param w
		 * @param h
		 * 
		 */		
		public function setSize(w:Number, h:Number):void
		{
			//log.debug("setSize called", w + ", " + h);
			width = w;
			height = h;
			resizeStage();
		}
		
		/**
		 * @private 
	 	*/
		protected function manageStageSize():void
		{
			sceneWidth = resizeWithStage ? stage.stageWidth : width; //super.width;
			sceneHeight = resizeWithStage ? stage.stageHeight : height; //super.height;
			super.scaleX = 1;
			super.scaleY = 1;
			scaleX = 1;
			scaleY = 1;
			width=sceneWidth;
			height=sceneHeight;
		}
		/**
		 * @private 
		 * I tried to get the designtime size of the stage, but unfortunately, JSFL isn't usable from a component ;(
	 	*/
		protected function getStageSize():void
		{
			//var values:String = MMExecute("fl.runScript(fl.configURI + \"Commands/papervision3d/setValues.jsfl\", \"getStageSize\");");
			//trace("stageSize", values);
		}
		
		/**
		 * @private 
	 	*/
		protected function drawStage():void
		{
			//return;
			scaleX = 1;
			scaleY = 1;
			graphics.clear();
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0,0,sceneWidth,sceneHeight);
			graphics.endFill();
			scrollRect = null;
			if(clipContent) scrollRect = new Rectangle(0,0,sceneWidth, sceneHeight);
		}
		
		/**
		 * @private 
	 	*/
		protected function initListeners():void
		{
			stage.addEventListener("resize", stageResizeHandler);
			stage.addEventListener("fullScreen", stageResizeHandler);
		}
		
		/**
		 * @private 
	 	*/
		protected function resizeStage():void
		{
			manageStageSize();
			drawStage();
			alignStage();
		}
		
		/**
		 * @private 
	 	*/
		protected function stageResizeHandler(e:Event):void
		{			
			if(!resizeWithStage) return;
			resizeStage();
		}
		
		/**
		 * @private 
	 	*/
		protected function alignStage():void
		{
			
		}
		
	}
}