package org.papervision3d.view
{
	import org.papervision3d.cameras.*;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.core.view.IView;
	import org.papervision3d.render.BasicRenderEngine;
	
	/**
	 * Author Ralph Hauwert
	 */
	 
	public class BasicView extends AbstractView implements IView
	{
			
		public function BasicView(viewportWidth:Number=640, viewportHeight:Number = 320, scaleToStage:Boolean=true, interactive:Boolean = false, cameraType:String = "CAMERA3D")
		{
			super();
			
			scene = new Scene3D();
			viewport = new Viewport3D(viewportWidth, viewportHeight, scaleToStage, interactive);
			addChild(viewport);
			renderer = new BasicRenderEngine();
			
			switch(cameraType){
				case Camera3D.TYPE:
					_camera = new Camera3D();
				break;
				case FreeCamera3D.TYPE:
					_camera = new FreeCamera3D();
				break;
				case FrustumCamera3D.TYPE:
					_camera = new FrustumCamera3D(viewport);
				break;
				default:
					_camera = new Camera3D();
				break;
			}
		}
		
		public function get cameraAsCamera3D():Camera3D
		{
			return _camera as Camera3D;
		}
		
		public function get cameraAsFreeCamera3D():FreeCamera3D
		{
			return _camera as FreeCamera3D;
		}
		
		public function get cameraAsFrustumCamera3D():FrustumCamera3D
		{
			return _camera as FrustumCamera3D;
		}
	}
}