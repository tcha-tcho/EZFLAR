package com.transmote.flar {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.FLARException;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetectorResult;
	
	/**
	 * manager for computer vision applications using FLARToolkit
	 * (http://www.libspark.org/wiki/saqoosha/FLARToolKit/en).
	 * 
	 * basic usage is as follows:
	 * pass a path to a camera parameters file and a list of FLARPatterns to the constructor.
	 * optionally pass an IFLARSource to use as the source image for marker detection;
	 * FLARManager will by default create a FLARCameraSource that uses the first available camera.
	 * 
	 * assign event listeners to FLARManager for MARKER_ADDED,
	 * MARKER_UPDATED, and MARKER_REMOVED FLARMarkerEvents.
	 * these FLARMarkerEvents encapsulate the FLARMarker instances that they refer to.
	 * alternatively, it is possible to retrieve all active markers
	 * directly from FLARManager, via FLARManager.activeMarkers.
	 * 
	 * FLARMarkers are simple objects that contain information about detected markers
	 * provided by FLARToolkit.  FLARManager maintains a list of active markers,
	 * and updates the list and the markers within every frame.
	 * 
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARManager extends EventDispatcher {
		// if a detected marker is within this distance from an active marker,
		// FLARManager considers the detected marker to be an update of the active marker.
		// else, the detected marker is a new marker.
		private static const MARKER_UPDATE_THRESHOLD:Number = 20;
		
		private var _cameraParams:FLARParam;
		private var _flarSource:IFLARSource;
		private var _threshold:Number = 80;
		
		private var patternLoader:FLARPatternLoader;
		private var allPatterns:Array;//:Vector.<FLARPattern>;
		private var markerDetector:FLARMultiMarkerDetector;
		private var flarRaster:FLARRgbRaster_BitmapData;
		
		private var enterframer:Sprite;
		private var _activeMarkers:Array;//:Vector.<FLARMarker>;
		
		private var bInited:Boolean;
		private var bCameraParamsLoaded:Boolean;
		private var bPatternsLoaded:Boolean;
		
		
		/**
		 * Constructor.
		 * 
		 * @param	cameraParamsPath	camera parameters filename.
		 * @param	patterns			list of FLARPatterns to detect.
		 * @param	source				IFLARSource instance to use as source image for marker detection.
		 * 									if null, FLARManager will create a camera capture source.
		 */
		public function FLARManager (cameraParamsPath:String, patterns:Array/*:Vector.<FLARPattern>*/, source:IFLARSource=null) {
			this._flarSource = source ? source : this.createDefaultSource();
			this.init(cameraParamsPath, patterns);
		}
		
		
		//-----<ACCESSORS>---------------------------------//
		/**
		 * list of all currently-active markers.
		 */
		public function get activeMarkers () :Array {//:Vector.<FLARMarker> {
			return this._activeMarkers;
		}
		
		/**
		 * FLARParam used by this FLARManager.
		 * can be used to instantiate a FLARCamera3D for use with Papervision.
		 */
		public function get cameraParams () :FLARParam {
			return this._cameraParams;
		}
				
		/**
		 * IFLARSource instance this FLARManager is using as the source image for marker detection.
		 */
		public function get flarSource () :IFLARSource {
			return this._flarSource;
		}
		
		/**
		 * pixels in source image with a brightness <= to this.threshold are candidates for marker detection.
		 * increase to increase likelihood of marker detection;
		 * increasing too high will cause engine to incorrectly detect non-existent markers.
		 * defaults to 80 (values can range from 0 to 255).
		 */
		public function get threshold () :uint {
			return this._threshold;
		}
		public function set threshold (val:uint) :void {
			this._threshold = val;
		}
		//-----</ACCESSORS>--------------------------------//
		
		
		
		//-----<PUBLIC METHODS>----------------------------//
		/**
		 * begin detecting markers once per frame.
		 * this method is called automatically on initialization.
		 * @return		false if FLARManager is not yet initialized; else true.
		 */
		public function activate () :Boolean {
			if (!this.bInited) {
				return false;
			}
			
			if (!this.enterframer) {
				this.enterframer = new Sprite();
			}
			this.enterframer.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
			
			this._activeMarkers = new Array();//Vector.<FLARMarker>();
			
			return true;
		}
		
		/**
		 * stop detecting markers.
		 */
		public function deactivate () :void {
			if (this.enterframer) {
				this.enterframer.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			}
			
			this._activeMarkers = null;
		}
		//-----</PUBLIC METHODS>---------------------------//
		
		
		
		//-----<MARKER DETECTION>----------------------------//
		private function onEnterFrame (evt:Event) :void {
			if (!this.updateSource()) { return; }
			this.detectMarkers();
		}
		
		private function updateSource () :Boolean {
			try {
				// ensure this.flarRaster has been initialized
				if (this.flarRaster == null) {
					this.flarRaster = new FLARRgbRaster_BitmapData(this.flarSource.source);
				}
			} catch (e:Error) {
				// this.flarSource not yet fully initialized
				return false;
			}
			
			// update source image
			this.flarSource.update();
			return true;
		}
		
		private function detectMarkers () :void {
			var numFoundMarkers:int = 0;
				
			try {
				// detect marker(s)
				numFoundMarkers = this.markerDetector.detectMarkerLite(this.flarRaster, this.threshold);
			} catch (e:FLARException) {
				// error in FLARToolkit processing; send to console
				trace(e);
				return;
			}
			
			//trace("numFoundMarkers:"+numFoundMarkers);
			if (numFoundMarkers == 0) { return; }
			
			// build list of detected markers
//			var detectedMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var detectedMarkers:Array = new Array();
			var detectedMarkerResult:FLARMultiMarkerDetectorResult;
			var patternIndex:int;
			var detectedPattern:FLARPattern;
			var confidence:Number;
			var outline:FLARMarkerOutline;
			var transmat:FLARTransMatResult;
			var i:uint = numFoundMarkers;
			while (i--) {
				detectedMarkerResult = this.markerDetector.getResult(i);
				patternIndex = this.markerDetector.getARCodeIndex(i);
				detectedPattern = this.allPatterns[patternIndex];
				confidence = this.markerDetector.getConfidence(i);
				if (confidence < detectedPattern._minConfidence) {
					// detected marker's confidence is below the minimum required confidence for its pattern.
					continue;
				}
				
				transmat = new FLARTransMatResult();
				this.markerDetector.getTransmationMatrix(i, transmat);
				
				outline = new FLARMarkerOutline(detectedMarkerResult.square.line,
					detectedMarkerResult.square.sqvertex,
					detectedMarkerResult.square.imvertex,
					detectedMarkerResult.square.label);
				
				detectedMarkers.push(new FLARMarker(patternIndex, detectedMarkerResult.direction, confidence, outline, transmat));
			}
			
			// compare detected markers against active markers
			i = detectedMarkers.length;
			var j:uint;
			var detectedMarker:FLARMarker;
			var activeMarker:FLARMarker;
			var closestMarker:FLARMarker;
			var closestDist:Number = Number.POSITIVE_INFINITY;
			var dist:Number;
//			var updatedMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
//			var newMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var updatedMarkers:Array = new Array();
			var newMarkers:Array = new Array();
			while (i--) {
				j = this._activeMarkers.length;
				detectedMarker = detectedMarkers[i];
				closestMarker = null;
				closestDist = Number.POSITIVE_INFINITY;
				while (j--) {
					activeMarker = this._activeMarkers[j];
					if (detectedMarker._patternId == activeMarker._patternId) {
						dist = Point.distance(detectedMarker.outline._centerpoint, activeMarker.outline._centerpoint);
						if (dist < closestDist && dist < MARKER_UPDATE_THRESHOLD) {
							closestMarker = activeMarker;
							closestDist = dist;
						}
					}
				}
				
				if (closestMarker) {
					// updated marker
					closestMarker.copy(detectedMarker);
					updatedMarkers.push(closestMarker);
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_UPDATED, closestMarker));
				} else {
					// new marker
					newMarkers.push(detectedMarker);
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_ADDED, detectedMarker));
				}
			}
			
			i = this._activeMarkers.length;
			var removedMarker:FLARMarker;
			while (i--) {
				activeMarker = this._activeMarkers[i];
				if (updatedMarkers.indexOf(activeMarker) == -1) {
					// removed marker
					removedMarker = this._activeMarkers.splice(i, 1)[0];
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_REMOVED, removedMarker));
				}
			}
			
			this._activeMarkers = this._activeMarkers.concat(newMarkers);
		}
		//-----</MARKER DETECTION>---------------------------//
		
		
		
		//-----<INITIALIZATION>----------------------------//
		private function init (cameraParamsPath:String, patterns:Array/*:Vector.<FLARPattern>*/) :void {
			this.loadCameraParams(cameraParamsPath);
			this.allPatterns = patterns;
			this.loadPatterns(this.allPatterns);
		}
		
		private function loadCameraParams (cameraParamsPath:String) :void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onCameraParamsLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onCameraParamsLoadError);
			loader.addEventListener(Event.COMPLETE, this.onCameraParamsLoaded);
			loader.load(new URLRequest(cameraParamsPath));
		}
		
		private function onCameraParamsLoadError (evt:Event) :void {
			var errorText:String = "Camera params load error.";
			if (evt is IOErrorEvent) {
				errorText = IOErrorEvent(evt).text;
			} else if (evt is SecurityErrorEvent) {
				errorText = SecurityErrorEvent(evt).text;
			}
			
			this.onCameraParamsLoaded(evt, new Error(errorText));
		}
		
		private function onCameraParamsLoaded (evt:Event, error:Error=null) :void {
			var loader:URLLoader = evt.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onCameraParamsLoadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onCameraParamsLoadError);
			loader.removeEventListener(Event.COMPLETE, this.onCameraParamsLoaded);
			
			if (error) { throw error; }
			
			this._cameraParams = new FLARParam();
			this._cameraParams.loadARParam(ByteArray(loader.data));
			var sourceSize:Rectangle = this.flarSource.sourceSize;
			this._cameraParams.changeScreenSize(sourceSize.width, sourceSize.height);
			
			this.bCameraParamsLoaded = true;
			this.checkForInitComplete();
		}
		
		private function loadPatterns (patterns:Array/*:Vector.<FLARPattern>*/) :void {
			this.patternLoader = new FLARPatternLoader();
			this.patternLoader.addEventListener(Event.INIT, this.onPatternsLoaded);
			this.patternLoader.loadPatterns(patterns);
		}
		
		private function onPatternsLoaded (evt:Event) :void {
			this.patternLoader.removeEventListener(Event.INIT, this.onPatternsLoaded);
			this.bPatternsLoaded = true;
			this.checkForInitComplete();
		}
		
		private function createDefaultSource () :IFLARSource {
			var source:IFLARSource = new FLARCameraSource();
			return source;
		}
		
		private function checkForInitComplete () :void {
			if (!this.bCameraParamsLoaded || !this.bPatternsLoaded || !this._flarSource) { return; }
			
			if (this.patternLoader.loadedPatterns.length == 0) {
				throw new Error("no markers successfully loaded.");
			}
			
			try {
				this.flarRaster = new FLARRgbRaster_BitmapData(this.flarSource.source);
			} catch (e:Error) {
				// this.flarSource not yet fully initialized
				this.flarRaster = null;
			}
			
			this.markerDetector = new FLARMultiMarkerDetector(this._cameraParams, this.patternLoader.loadedPatterns, this.patternLoader.unscaledMarkerWidths, this.patternLoader.loadedPatterns.length);
			this.bInited = true;
			this.activate();
			
			this.dispatchEvent(new Event(Event.INIT));
		}
		//-----</INITIALIZATION>---------------------------//
	}
}