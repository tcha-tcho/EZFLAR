package com.tchatcho {
	import com.transmote.flar.FLARCameraSource;
	import com.transmote.flar.FLARLoaderSource;
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.FLARMarkerEvent;
	import com.transmote.flar.FLARPattern;
	import com.transmote.utils.time.FramerateDisplay;

	import flash.display.Sprite;
	import flash.events.Event;

	import com.tchatcho.Base_model;
	import flash.media.Camera;
	import flash.events.*;
    
	
	//to handle objects from outside
	import com.transmote.flar.FLARMarker;
	import org.papervision3d.objects.DisplayObject3D;


	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	public class EZflar extends Sprite {
		private static const CAMERA_PARAMS_PATH:String = "../resources/flar/FLARparams.dat";
		private static const PATTERN_PATH:String = "../resources/flar/patterns/";
		private static const PATTERN_RESOLUTION:uint = 16;

		private var patterns:Array;
		private var flarManager:FLARManager;
		private var flarLoader:FLARLoaderSource;
		private var base_model:Base_model;
		private var _camSource:FLARCameraSource;
		private var _objects:Array;
		private var _width:int;
		private var _height:int;


		private var _funcStarted:Function;
		private var _funcAdded:Function;
		private var _funcUpdated:Function;
		private var _funcRemoved:Function;

		public function EZflar (objects:Array,
								 width:int = 640,
								 height:int = 480,
								 frameRate:Number = 30,
								 downSampleRatio:Number = 0.5,
								 mirror:Boolean = true){
			_width = width;
			_height = height;
			_objects = objects;
			_camSource = new FLARCameraSource(width, height, frameRate, downSampleRatio)
			this.init();
		}

		private function init () :void {
			trace("EZFLAR 0.1(beta) is running!  :)\n keep calm and look busy!\n");	
			if(Camera.names.length > 0) {
				// build list of FLARPatterns for FLARToolkit to detect
				this.patterns = new Array();
				for (var i:int = 0; i < _objects.length; i++) {
					if(_objects[i][0][2] == undefined){_objects[i][0][2] = null}
					if(_objects[i][1] == undefined){_objects[i][1] = null}
					this.patterns.push(new FLARPattern(PATTERN_PATH+ _objects[i][0][0], PATTERN_RESOLUTION));
				}

				// use Camera (default)
				this.flarManager = new FLARManager(CAMERA_PARAMS_PATH, patterns,_camSource);
				this.addChild(FLARCameraSource(this.flarManager.flarSource));

				// begin listening for FLARMarkerEvents
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
				this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
			} else {
				//TODO: render nocam.swf, and test if this initiate the cam twice
				trace("you need a cam");
			}
		}
		public function mirror():void{
			this.scaleX = -1;
			this.x = _width;				
		};
		public function moveTo(x:Number = 640, y:Number = -1):void{
			this.x = x;
			this.y = y;
		}
		
		public function viewFrameRate():void{
			//build a frame display to watch performance
			var framerateDisplay:FramerateDisplay = new FramerateDisplay();
			this.stage.addChild(framerateDisplay);
		}
		private function onFlarManagerInited (evt:Event) :void {
			this.base_model = new Base_model(_objects,
				this.patterns.length,
				this.flarManager.cameraParams,
				_width,
				_height);
			this.addChild(this.base_model);
			if (_funcStarted != null){
				_funcStarted();
			}
		}
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			this.base_model.addMarker(evt.marker);
			if (_funcAdded != null){
				_funcAdded(evt);
			}
		}

		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			if (_funcUpdated != null){
				_funcUpdated(evt);
			}
		}

		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.base_model.removeMarker(evt.marker);
			if (_funcRemoved != null){
				_funcRemoved(evt);
			}
		}

		public function onStarted(func:Function):void{
			_funcStarted = func;
		}

		public function onAdded(func:Function):void{
			_funcAdded = func;
		}

		public function onUpdated(func:Function):void{
			_funcUpdated = func;
		}
		public function onRemoved(func:Function):void{
			_funcRemoved = func;
		}
		public function object(marker:int, propertyToChange:String, newValue:Number, thisName:String = "universe"):void {
			this.base_model.changeObjectProperty(marker, propertyToChange, newValue, thisName);
		}
		public function addModelTo(set1:Array, set2:Array = null):void{
			this.base_model.addModelToStage(set1, set2);
		}
	}
}