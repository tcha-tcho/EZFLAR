/**
* @author John Grden
*/
package org.papervision3d.core.components.as3.flash9 {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.core.components.as3.core.PV3DUIComponent;
	import org.papervision3d.core.components.as3.utils.CoordinateTools;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	import com.blitzagency.xray.logger.XrayLog;	

	/**
	* Dispatched when the Scene3D has been created along with the camera.
	* 
	* @eventType org.papervision3d.components.as3.flash9.PV3DScene3D.SCENE_INIT
	*/
	[Event(name="sceneInit", type="flash.events.Event")]
	
	/**
	 * PV3DScene3D creates a MovieScene3D and FreeCamera3D for quick scene and resize management.  You can access the scene and camera for full control with code at runtime.
	 * 
	 */	

	public class PV3DScene3D extends PV3DUIComponent
	{
		/**
		* @eventType sceneInit
		*/		
		public static const SCENE_INIT:String = "sceneInit";
		
		// public vars
		// component UI handlers
		[Inspectable ( defaultValue="Free", enumeration="Free, Target", type="List", name="Camera Type" )]
		/**
		* @private
		*/		
		public var cameraType				:String = "Free";
		
		[Inspectable ( type="Number", defaultValue=-1000, name="Camera Z")]
		/**
		* @private
		*/
		public function set cameraZ(z:Number):void
		{
			_cameraZ = z;
			try
			{
				currentCamera3D.z = z;
				updateScene();
			}catch(e:Error)
			{
				
			}
		}
		/**
		* @private
		*/
		public function get cameraZ():Number
		{
			return _cameraZ;
		}
		
		[Inspectable ( type="Number", defaultValue=1, name="Camera Zoom")]
		/**
		* @private
		*/
		public function set cameraZoom(zoom:Number):void
		{
			_cameraZoom = zoom;
			try
			{
				currentCamera3D.zoom = zoom;
				updateScene();
			}catch(e:Error)
			{
				
			}
		}
		/**
		* @private
		*/
		public function get cameraZoom():Number
		{
			return _cameraZoom;
		}
		
		[Inspectable ( type="Number", defaultValue=300, name="Camera Focus")]
		/**
		* @private
		*/
		public function set cameraFocus(focus:Number):void
		{
			_cameraFocus = focus;
			try
			{
				currentCamera3D.focus = focus;
				updateScene();
			}catch(e:Error)
			{
				// camera not ready
			}
		}
		/**
		* @private
		*/
		public function get cameraFocus():Number
		{
			return _cameraFocus;
		}
		
		[Inspectable ( type="Boolean", defaultValue="true", name="Auto Render Scene")]
		/**
		* @private
		*/
		public function set autoRenderScene(value:Boolean):void
		{
			_autoRenderScene = value;
		}
		/**
		* @private
		*/
		public function get autoRenderScene():Boolean
		{
			return _autoRenderScene;
		}
		
		/**
		 * @private 
	 	*/
		public var currentCamera3D			:CameraObject3D;
		
		/**
		* @private
		*/
		public function set cameraTarget(p_target:DisplayObject3D):void
		{
			_cameraTarget = p_target;
			targetCam.target = _cameraTarget;
		}
		/**
		* @private
		*/
		public function get cameraTarget():DisplayObject3D
		{
			return _cameraTarget;
		}
		
		// scenes
	    /**
		* @private
		*/
	    protected var _scene     				:Scene3D = null;
	    /**
		* The InteractiveScene3D used by the component
		*/
	    public function set scene(scene3d:Scene3D):void
	    {
	    	_scene = scene3d;
	    }
	    public function get scene():Scene3D
	    {			
			return _scene;
	    }
	    /**
	     * The camera used by the component.  FreeCamer3D by default
	     * @return 
	     * 
	     */	    
	    public function get camera():CameraObject3D { return currentCamera3D; }
	    public function set camera(p_camera:CameraObject3D):void { currentCamera3D = p_camera; }
	    
	    /**
	    * @private
	    */	    
	    protected var timer					:Timer = new Timer(25,0);
		
		// cameras
		/**
		 * @private 
	 	*/
		protected var targetCam				:Camera3D;
		
		/**
		 * @private 
	 	*/
	 	protected var _cameraTarget			:DisplayObject3D;
		/**
		 * @private 
	 	*/
		protected var _cameraZ				:Number = -1000;
		/**
		 * @private 
	 	*/
		protected var _cameraZoom			:Number = 1;
		/**
		 * @private 
	 	*/
		protected var _cameraFocus			:Number = 300;
		/**
		 * @private 
	 	*/
		protected var _autoRenderScene		:Boolean = true;
		/**
		 * @private 
	 	*/
		protected var freeCam 				:FreeCamera3D;

		/**
		* The sprite container where the scene will be drawn
		*/		
		protected var canvas				:Sprite = null;
		/**
		 * @private 
	 	*/
		protected var mainCanvas			:Sprite = null;
		
		public var viewport					:Viewport3D;
		
		public var renderer					:BasicRenderEngine = new BasicRenderEngine();
		
		public function PV3DScene3D()
		{
			super();
			initApp();
		}
		
		/**
		 * Used to pause the rendering of the scene
		 * 
		 */		
		public function pause():void
		{
			timer.stop();
		}
		
		/**
		 * Used to resume the rendering of the scene
		 * 
		 */		
		public function resume():void
		{
			timer.start();
		}
		
		/**
		 * @private 
	 	*/
		override protected function configUI():void
		{
			log.debug("configUI");
			if(isLivePreview) 
			{
				trace("displayLogo?");
				displayLogo();
			}
			
			manageStageSize();
			
			var coordinates:Point = CoordinateTools.localToLocal(this, parent);
			screenOffsetX = coordinates.x;
			screenOffsetY = coordinates.y;
			
			canvas = new Sprite();
			canvas.name = "canvas";
			mainCanvas = new Sprite();
			mainCanvas.name = "mainCanvas";
			
			addChild(canvas);
			canvas.addChild(mainCanvas);
			
			createCamera(cameraType);
			
			// create scene object
			init3D();
			
			// updateScene
			if(!isLivePreview && autoRenderScene)
			{
				timer.addEventListener(TimerEvent.TIMER, handleTimerUpdate);
				timer.start();
			}else
			{
				// gives me 5 frame updates it seems
				stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
		}
		
		/**
		 * @private 
	 	*/
		protected function displayLogo():void
		{	
			var logo:Logo = new Logo();
			addChild(logo);
		}
		
		/**
		 * @private 
	 	*/
		protected function init3D():void
		{
			// Scene - we use InteractiveScene3D by default and we assume this for them since they're in the IDE
			createScene();
			dispatchEvent(new Event(SCENE_INIT));
		}
		
		protected function createScene():void
		{
			scene = new Scene3D();
			viewport = new Viewport3D(sceneWidth, sceneHeight, resizeWithStage, true, true, true);
			addChild(viewport);
		}
		
		/**
		 * @private 
	 	*/
		protected function createCamera(cameraChoice:String):void
		{
			switch(cameraChoice)
			{
				case "Free":
					currentCamera3D = freeCam = new FreeCamera3D();
				break;
				
				case "Target":
					currentCamera3D = targetCam = new Camera3D();
				break;
			}
			
			currentCamera3D.z = cameraZ;
			currentCamera3D.zoom = cameraZoom;
			currentCamera3D.focus = cameraFocus;
		}
		
		/**
		 * @private 
	 	*/
		override protected function alignStage():void
		{
			try
			{		
				//log.debug("alignStage width/height", (sceneWidth/2) + ", " + (sceneHeight/2));		
				mainCanvas.x = sceneWidth/2;//stage.stageWidth/2;
				mainCanvas.y = sceneHeight/2;//stage.stageHeight/2;

				updateScene();
				//scene.renderCamera( freeCam );
			}catch(e:Error)
			{
				//log.error("alignStage Error", e.message);
			}
		}
		
		/**
		 * @private 
	 	*/
		protected function handleTimerUpdate(e:TimerEvent):void
		{
			updateScene();
		}
		
		/**
		 * @private 
	 	*/
		protected function handleEnterFrame(e:Event):void
		{
			//trace("enter frame");
			updateScene();
		}
		
		/**
		 * @private 
	 	*/
		protected function updateScene():void
		{
			try
			{
				//scene.renderCamera( currentCamera3D );
				renderer.renderScene(scene, currentCamera3D, viewport);
			}catch(e:Error)
			{
				log.debug("updateScene error", e.message);
			}
		}
	}
}