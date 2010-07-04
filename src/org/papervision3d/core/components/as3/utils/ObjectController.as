package org.papervision3d.core.components.as3.utils
{ 

	/**
	 * @author John Grden
	 */
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	import com.blitzagency.xray.logger.XrayLog;	

	//import com.rockonflash.papervision3d.modelviewer.events.ObjectControllerEvent;

	public class ObjectController extends EventDispatcher
	{
		private static var _instance:ObjectController = null;
		public static function getInstance():ObjectController
		{
			if(_instance == null) _instance = new ObjectController();
			return _instance;
		}
		
		public var isMouseDown			:Boolean;
		public var restrictInversion	:Boolean = false;
		
		protected var currentRotationObj:DisplayObject3D;
		
		protected var arrowLeft			:Boolean;
		protected var arrowUp			:Boolean;
		protected var arrowRight		:Boolean;
		protected var arrowDown			:Boolean;
		
		protected var lastX				:Number;
		protected var lastY				:Number;
		protected var difX				:Number;
		protected var difY				:Number;
		
		
		
		protected var si				:Number;
		//protected var timer				:Timer = new Timer(25,0);
		
		protected var movementInc		:Number = 1;
		
		private var log					:XrayLog = new XrayLog();
		private var stage				:Stage;
		
		public function ObjectController()
		{
			// constructor
			//Mouse.addListener(this);
			//Keyboard.addListener(this);
			//timer.addEventListener(TimerEvent.TIMER, handleTimerTick);
			//timer.start();
		}
		
		public function registerControlObject(obj:DisplayObject3D):void
		{
			currentRotationObj = obj;
		}
		
		public function registerStage(p_stage:Stage):void
		{
			stage = p_stage;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			updateLastRotation();
			updateDif();
		}
		
		protected function updateLastRotation():void
		{
			lastX = stage.mouseX;
			lastY = stage.mouseY;
		}
		
		protected function updateDif():void
		{
			difX = Number(stage.mouseX - lastX);
			difY = Number(stage.mouseY - lastY);
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			updateLastRotation();
			isMouseDown = true;
		}
		
		protected function onMouseMove(e:MouseEvent):void
		{
			updateMovements();
		}
		
		/*
		protected function handleTimerTick(e:TimerEvent):void
		{
			updateMovements();
		}
		*/
		
		protected function onMouseUp(e:MouseEvent):void
		{
			isMouseDown = false;
			updateLastRotation();
		}
		
		protected function onKeyDown(e:KeyboardEvent):void 
		{
			/*
			37 // left
			38 // up
			39 // right
			40 // down
			*/
			try
			{
				movementInc += movementInc*.1;
				//log.debug("keyDown", e.keyCode);
				switch(e.keyCode)
				{
					case 37:
						arrowLeft = true;
					break;
					
					case 38:
						arrowUp = true;
					break;
					
					case 39:
						arrowRight = true;
					break;
					
					case 40:
						arrowDown = true;
					break;
				}
				
			}catch(e:Error)
			{
				log.debug("keyDown error");
			}
		}
		
		protected function onKeyUp(e:KeyboardEvent):void 
		{
			movementInc = 1;
			try
			{
				switch(e.keyCode)
				{
					case 37:
						arrowLeft = false;
					break;
					
					case 38:
						arrowUp = false;
					break;
					
					case 39:
						arrowRight = false;
					break;
					
					case 40:
						arrowDown = false;
					break;
				}
			}catch(e:Error)
			{
				log.debug("keyDown error");
			}
		}
			
		protected function handleKeyStroke():void
		{
			var inc:Number = 5 + movementInc;
			
			if(arrowLeft) currentRotationObj.x -= inc;
			if(arrowUp) currentRotationObj.z += inc;
			if(arrowRight) currentRotationObj.x += inc;
			if(arrowDown) currentRotationObj.z -= inc;
		}
		
		protected function updateMovements():void
		{
			updateDif();
			handleKeyStroke();
			
			if(!isMouseDown) return;
			
			try
			{
				var posx:Number = difX/7;
				var posy:Number = difY/7;
				
				posx = posx > 360 ? posx % 360 : posx;
				posy = posy > 360 ? posy % 360 : posy;
				
				if(restrictInversion && currentRotationObj.rotationX - posy >= (-90) && currentRotationObj.rotationX - posy <= (90))
				{
					currentRotationObj.rotationX -= posy;
				}else if(!restrictInversion)
				{
					currentRotationObj.rotationX -= posy;
				}
				currentRotationObj.rotationY += posx;
				//dispatchEvent(new ObjectControllerEvent(ObjectControllerEvent.MOVEMENT, posx, posy));
				
				if(difX != 0) lastX = stage.mouseX;
				if(difY != 0) lastY = stage.mouseY;
			}catch(e:Error)
			{
				log.debug("handleMouseMove failed");
			}
		}
	}
}