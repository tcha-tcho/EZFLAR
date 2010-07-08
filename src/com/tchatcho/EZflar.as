/* 
 * EZFLAR v. 0.2 (beta)
 * http://www.ezflar.com
 * Copyright 2009, tcha-tcho
 * --------------------------------------------------------------------------------
 * EZFLAR is based in the Example developed by Eric Socolofsky in FLARManager.
 * This sofware attempt to wrap 3 great codes to provide a quick way to work:
 * FLARManager(c), developed by Eric Socolofsky
 * FLARToolkit(c), developed by Saqoosha as part of the Libspark project.
 * PaperVision3D(c), developed by PV3D team
 *
 * Bla bla bla bla this is under GPL... bla bla
 *
 *	http://www.tcha-tcho.com
 *  hey! fork this at http://github.com/tcha-tcho/EZFLAR
 * 
 */
package com.tchatcho {
	import com.transmote.flar.source.FLARCameraSource;
	import com.transmote.flar.source.FLARLoaderSource;
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.pattern.FLARPattern;
	import com.transmote.utils.time.FramerateDisplay;

	import flash.display.Sprite;
	import flash.events.Event;

	import com.tchatcho.Base_model;
	import flash.media.Camera;
	import flash.events.*;
    import com.tchatcho.NoCamera;

	//to handle objects from outside
	import com.transmote.flar.marker.FLARMarker;
	import org.papervision3d.*;
	
	//TODO: Loading all code, loading each model working

	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	public class EZflar extends Sprite {
		//defaults paths to assets inside resources folder
		private static const PATH_TO_MODELS:String = "models/";
		private static const CAMERA_PARAMS_PATH:String = "flar/FLARparams.dat";
		private static const PATTERN_PATH:String = "flar/patterns/";
		private static const PATTERN_RESOLUTION:uint = 16;

		private var patterns:Vector.<FLARPattern>;//arg! :( Arrays are quicker than vectors
		private var flarManager:FLARManager;
		private var flarLoader:FLARLoaderSource;
		private var base_model:Base_model;
		private var _camSource:FLARCameraSource;
		private var _objects:Array;
		private var _width:int;
		private var _height:int;
		private var _frameRate:Number;
		private var _downSampleRatio:Number;
		private var _isMirrored:Boolean = false;
		private var _noCamMessage:String = "Sorry ;( ... we need a cam";
		private var _noCamColorTxt:uint = 0x00FF00;
		private var _noCamColorBackground = 0xCCFFCC;
		private var _nocam:NoCamera;
		private var _pathToResources:String = new String();
		
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
			_frameRate = frameRate;
			_downSampleRatio = downSampleRatio;
			_objects = objects;
		}
		public function initializer(theStage:*, newPath:String = "./resources/"):void{
			this._pathToResources = newPath;
			this.init();
			theStage.addChild(this);
		};
		private function init () :void {
			trace("EZFLAR 0.2 (CS4 version) is running!  :)\n keep calm and look crazy!\n");
			if(Camera.names.length > 0) {
				
				//_camSource = new FLARCameraSource(_width, _height, _frameRate, _downSampleRatio)
				
				// build list of FLARPatterns for FLARToolkit to detect
				this.patterns = new Vector.<FLARPattern>();
				for (var i:int = 0; i < _objects.length; i++) {
					if(_objects[i][0][2] == undefined){_objects[i][0][2] = null}
					if(_objects[i][1] == undefined){_objects[i][1] = null}
					this.patterns.push(new FLARPattern(_pathToResources + PATTERN_PATH+ _objects[i][0][0], PATTERN_RESOLUTION));
				}

				// use Camera (default)
				this.flarManager = new FLARManager();

				//this.flarManager.initManual(_pathToResources + CAMERA_PARAMS_PATH, patterns,_camSource);
				//this.flarManager = new FLARManager(this._pathToResources+"flar/flarConfig.xml");
				this.flarManager.initManual(_pathToResources + CAMERA_PARAMS_PATH, this.patterns);

				this.addChild(FLARCameraSource(this.flarManager.flarSource));

				// begin listening for FLARMarkerEvents 
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
				this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
				this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
			} else {
				_nocam = new NoCamera(_width,_height, _noCamMessage, _noCamColorTxt, _noCamColorBackground);				
				addChild(_nocam)
				if(this._isMirrored == false){
					this.mirror();
				}
			}
		}
		public function customizeNoCam(message:String, colorTxt:uint, colorBackground:uint):void{
			_noCamMessage = message;
			_noCamColorTxt = colorTxt;
			_noCamColorBackground = colorBackground;
			if(Camera.names.length < 1){
				removeChild(_nocam)
				_nocam = new NoCamera(_width,_height, _noCamMessage, _noCamColorTxt, _noCamColorBackground);
				addChild(_nocam)
			}
			
		}
		public function mirror():void{
			if(this._isMirrored == false){
				this.scaleX = -1;
				this.x = _width;
				this._isMirrored = true;
			} else {
				this.scaleX = 1;
				this.x = 0;
				this._isMirrored = false;
			}
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
				_height,
				_pathToResources,
				PATH_TO_MODELS);
			this.addChild(this.base_model);
			if (_funcStarted != null){
				_funcStarted();
			}
		}
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("marker added");
			this.base_model.addMarker(evt.marker);
			if (_funcAdded != null){
				_funcAdded(evt);
			}
		}

		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			trace("marker updated");
			if (_funcUpdated != null){
				_funcUpdated(evt);
			}
		}

		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("marker removed");
			this.base_model.removeMarker(evt.marker);
			if (_funcRemoved != null){
				_funcRemoved(evt);
			}
		}

		public function onStarted(func:Function):void{
			_funcStarted = func;
		}

		public function onAdded(func:Function):void{
			trace("marker added");
			_funcAdded = func;
		}

		public function onUpdated(func:Function):void{
			_funcUpdated = func;
		}
		public function onRemoved(func:Function):void{
			trace("marker removed");
			_funcRemoved = func;
		}
		public function addModelTo(set1:Array, set2:Array = null):void{
			this.base_model.addModelToStage(set1, set2);
		}
		public function getObject(onMarker:int,thisName:String = "universe"):*{
			var arrToReturn:Array = new Array();
			arrToReturn = this.base_model.getObjectByName(onMarker,thisName);
			if(arrToReturn.length == 1){
				return arrToReturn[0];
			}else{
				return arrToReturn;
			};
		}
	}
}