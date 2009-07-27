package {
	import com.transmote.flar.FLARCameraSource;
	import com.transmote.flar.FLARLoaderSource;
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.FLARMarkerEvent;
	import com.transmote.flar.FLARPattern;
	import com.transmote.utils.time.FramerateDisplay;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import Base_model;

	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	public class Base extends Sprite {
		private static const CAMERA_PARAMS_PATH:String = "../resources/flar/FLARparams.dat";
		private static const PATTERN_PATH:String = "../resources/flar/patterns/";
		private static const PATTERN_RESOLUTION:uint = 16;
		
		private var patterns:Array;
		private var flarManager:FLARManager;
		private var flarLoader:FLARLoaderSource;
		private var base_model:Base_model;
		
		public function Base () {
			this.init();
		}
		
		private function init () :void {
			// build list of FLARPatterns for FLARToolkit to detect
			this.patterns = new Array();
			this.patterns.push(new FLARPattern(PATTERN_PATH+"patt.hiro", PATTERN_RESOLUTION));
			this.patterns.push(new FLARPattern(PATTERN_PATH+"patt2.hiro", PATTERN_RESOLUTION));
			
			// use Camera (default)
			this.flarManager = new FLARManager(CAMERA_PARAMS_PATH, patterns);
			this.addChild(FLARCameraSource(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			//build a frame display to watch performance
			var framerateDisplay:FramerateDisplay = new FramerateDisplay();
			this.addChild(framerateDisplay);
			
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			this.base_model = new Base_model(this.patterns.length,
											 this.flarManager.cameraParams,
											 this.stage.stageWidth,
											 this.stage.stageHeight);
			this.addChild(this.base_model);
			
		}

		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] added");
			this.base_model.addMarker(evt.marker);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			trace("["+evt.marker.patternId+"]>>" +
				  "X:" + evt.position_x() + " || " +
				  "Y:" + evt.position_y() + " || " +
				  "Z:" + evt.position_z() + " || " +
				  "RX:" + evt.position_rotation_x() + " || " +
				  "RY:" + evt.position_rotation_y() + " || " +
				  "RZ:" + evt.position_rotation_z() + " || "
			);
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] removed");
			this.base_model.removeMarker(evt.marker);
		}
	}
}