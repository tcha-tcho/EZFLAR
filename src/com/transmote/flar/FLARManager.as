/* 
 * PROJECT: FLARManager
 * http://transmote.com/flar
 * Copyright 2009, Eric Socolofsky
 * --------------------------------------------------------------------------------
 * This work complements FLARToolkit, developed by Saqoosha as part of the Libspark project.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 * FLARToolkit is Copyright (C)2008 Saqoosha,
 * and is ported from NYARToolkit, which is ported from ARToolkit.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact:
 *	<eric(at)transmote.com>
 *	http://transmote.com/flar
 * 
 */

package com.transmote.flar {
	import __AS3__.vec.Vector;
	
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.pattern.FLARPattern;
	import com.transmote.flar.pattern.FLARPatternLoader;
	import com.transmote.flar.source.FLARCameraSource;
	import com.transmote.flar.source.FLARLoaderSource;
	import com.transmote.flar.source.IFLARSource;
	import com.transmote.flar.utils.FLARManagerConfigLoader;
	import com.transmote.flar.utils.FLARProxy;
	import com.transmote.flar.utils.smoother.FLARMatrixSmoother_Average;
	import com.transmote.flar.utils.smoother.IFLARMatrixSmoother;
	import com.transmote.flar.utils.threshold.DrunkHistogramThresholdAdapter;
	import com.transmote.flar.utils.threshold.IThresholdAdapter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquare;
	
	import org.libspark.flartoolkit.FLARException;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	
	use namespace flarManagerInternal;
	
	/**
	 * <p>
	 * Manager for computer vision applications using FLARToolkit
	 * (<a href="http://www.libspark.org/wiki/saqoosha/FLARToolKit/en" target="_blank">
	 * http://www.libspark.org/wiki/saqoosha/FLARToolKit/en</a>).
	 * </p>
	 * <p>
	 * Basic usage is as follows:
	 * Pass a path to a camera parameters file and a list of FLARPatterns to the constructor.
	 * Optionally pass an IFLARSource to use as the source image for marker detection;
	 * FLARManager will by default create a FLARCameraSource that uses the first available camera.
	 * Alternatively, FLARManager can be initialized using an xml file that specifies the above and other settings.
	 * </p>
	 * <p>
	 * Assign event listeners to FLARManager for MARKER_ADDED,
	 * MARKER_UPDATED, and MARKER_REMOVED FLARMarkerEvents.
	 * These FLARMarkerEvents encapsulate the FLARMarker instances that they refer to.
	 * Alternatively, it is possible to retrieve all active markers
	 * directly from FLARManager, via FLARManager.activeMarkers.
	 * </p>
	 * <p>
	 * FLARMarkers are simple objects that contain information about detected markers
	 * provided by FLARToolkit.  FLARManager maintains a list of active markers,
	 * and updates the list and the markers within every frame.
	 * </p>
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 * @see		com.transmote.flar.marker.FLARMarkerEvent
	 * @see		com.transmote.flar.source.FLARCameraSource
	 * @see		com.transmote.flar.utils.FLARProxy
	 */
	public class FLARManager extends EventDispatcher {
		private static const ZERO_POINT:Point = new Point();
		
		// general management
		private var configLoader:FLARManagerConfigLoader;
		private var _activeMarkers:Vector.<FLARMarker>;
		private var _cameraParams:FLARParam;
		private var _flarSource:IFLARSource;
		
		// source and detection adjustment
		private var _threshold:Number = 80;
		private var _sampleBlurring:int = 1;
		private var _thresholdAdapter:IThresholdAdapter;
		private var _inverted:Boolean;
		private var _mirrorDisplay:Boolean = true;
		
		// marker adjustment
		private var _markerUpdateThreshold:Number = 80;
		private var _markerRemovalDelay:int = 1;
		private var _markerExtrapolation:Boolean = true;
		private var _smoothing:int = 3;
		private var _smoother:IFLARMatrixSmoother;
		private var _adaptiveSmoothingCenter:Number = 10;
		
		// debugging
		private var _thresholdSourceDisplay:Boolean;
		
		// pattern and marker management
		private var patternLoader:FLARPatternLoader;
		private var allPatterns:Vector.<FLARPattern>;
		private var markerDetector:FLARMultiMarkerDetector;
		private var flarRaster:FLARRgbRaster_BitmapData;
		private var thresholdSourceBitmap:Bitmap;
		private var markersPendingRemoval:Vector.<FLARMarker>;
		
		// marker adjustment (private)
		private var enterframer:Sprite;
		private var averageConfidence:Number = FLARPattern.DEFAULT_MIN_CONFIDENCE;
		private var averageMinConfidence:Number = FLARPattern.DEFAULT_MIN_CONFIDENCE;
		private var sampleBlurFilter:BlurFilter;
		private var inversionShaderFilter:ShaderFilter;
		
		// application state
		private var bInited:Boolean;
		private var bCameraParamsLoaded:Boolean;
		private var bPatternsLoaded:Boolean;
		private var bActive:Boolean;
		private var bVerbose:Boolean;
		
		
		/**
		 * Constructor.
		 * Initialize FLARManager by passing in a configuration file path.
		 * 
		 * @param	flarConfigPath	path to the FLARManager configuration xml file.
		 */
		public function FLARManager (flarConfigPath:String="") {
			this._flarSource = new FLARCameraSource();
			if (flarConfigPath != "") {
				this.initFromFile(flarConfigPath);
			}
		}
		
		/**
		 * the old-fashioned way to initialize FLARManager.
		 * the preferred method is to use an external xml configuration file,
		 * and to pass its path into the FLARManager constructor.
		 * 
		 * @param	cameraParamsPath	camera parameters filename.
		 * @param	patterns			list of FLARPatterns to detect.
		 * @param	source				IFLARSource instance to use as source image for marker detection.
		 * 									if null, FLARManager will create a camera capture source.
		 */
		public function initManual (cameraParamsPath:String, patterns:Vector.<FLARPattern>, source:IFLARSource=null) :void {
			use namespace flarManagerInternal;
			
			if (source) {
				this._flarSource = source;
				this._mirrorDisplay = source.mirrored;
			} else {
				this._flarSource = new FLARCameraSource();
			}
			
			this.initConfigLoader();
			this.configLoader.cameraParamsPath = cameraParamsPath;
			this.configLoader.patterns = patterns;
			this.init();
		}
		
		/**
		 * load FLARManager configuration from an xml file.
		 * note, this method no longer needs to be called manually;
		 * simply passing the configuration file path into the constructor
		 * will also initialize correctly.  this method is here for legacy support only.
		 * 
		 * @param	flarConfigPath	path to the FLARManager configuration xml file.
		 */
		public function initFromFile (flarConfigPath:String) :void {
			use namespace flarManagerInternal;
			if (!this.configLoader) { this.initConfigLoader(); }
			this.configLoader.loadConfigFile(flarConfigPath);
		}
		
		/**
		 * init from an XML object in Flash.
		 * this can be useful when dynamically generating an XML file at runtime,
		 * such as via a middleware request.
		 */ 
		public function initFromXML (flarConfigXML:XML) :void {
			if (!this.configLoader) { this.initConfigLoader(); }
			this.configLoader.parseConfigFile(flarConfigXML);
		}
		
		
		
		//-----<CONFIG ACCESSORS>------------------------------------//
		/**
		 * pixels in source image with a brightness <= to this.threshold are candidates for marker outline detection.
		 * increase to increase likelihood of marker detection;
		 * increasing too high will cause engine to incorrectly detect non-existent markers.
		 * defaults to 80 (values can range from 0 to 255).
		 */
		public function get threshold () :int {
			return this._threshold;
		}
		public function set threshold (val:int) :void {
			if (this.bVerbose && !this.thresholdAdapter) {
				trace("[FLARManager] threshold: "+ val);
			}
			this._threshold = val;
		}
		
		/**
		 * IFLARThresholdAdapter used to automate threshold changes.
		 * 
		 * adaptive thresholding can result in better marker detection across a range of illumination.
		 * this is desirable for applications with low lighting, or in which the developer has little control
		 * over lighting conditions, such as with web applications.
		 * 
		 * note that adaptive thresholding may cause slower performance in very dark environments.
		 * this happens because a low threshold creates an image with large black areas,
		 * and images with a lot of black can cause slowdown in FLARToolkit's labeling process
		 * (FLARLabeling_BitmapData.labeling()).  in this case, thresholdAdapter should be set to null.
		 * 
		 * the default threshold adapter is DrunkHistogramThresholdAdapter, but developers can implement their own
		 * algorithms for adaptive thresholding.  to do so, implement the IThresholdAdapter interface.
		 */
		public function get thresholdAdapter () :IThresholdAdapter {
			return this._thresholdAdapter;
		}
		public function set thresholdAdapter (val:IThresholdAdapter) :void {
			if (this.bVerbose) {
				trace("[FLARManager] threshold adapter: "+ flash.utils.getQualifiedClassName(val));
			}
			this._thresholdAdapter = val;
		}
		
		/**
		 * the amount of blur applied to the source image
		 * before sending to FLARToolkit for marker detection.
		 * higher values increase framerate, but reduce detection accuracy.
		 * value must be zero or greater.  the default value is 2.
		 */
		public function get sampleBlurring () :int {
			return this._sampleBlurring;
		}
		public function set sampleBlurring (val:int) :void {
			if (!this.sampleBlurFilter) {
				this.sampleBlurFilter = new BlurFilter();
			}
			
			if (val <= 0) {
				val = 0;
				this.sampleBlurFilter.blurX = this.sampleBlurFilter.blurY = 0;
			} else {
				this.sampleBlurFilter.blurX = this.sampleBlurFilter.blurY = Math.pow(2, val-1);
			}
			
			this._sampleBlurring = val;
			
			if (this.bVerbose) {
				trace("[FLARManager] sample blurring: "+ val);
			}
		}
		
		/**
		 * set to true to detect inverted (white border) markers.
		 * if inverted has not yet been set to true in this session,
		 * there will be a slight delay before inverted becomes true,
		 * while the inversion shader is loaded.
		 * 
		 * thanks to jim alliban (http://jamesalliban.wordpress.com/)
		 * and lee brimelow (http://theflashblog.com/) for the inversion algorithm.
		 */
		public function get inverted () :Boolean {
			return this._inverted;
		}
		public function set inverted (val:Boolean) :void {
			if (val && !this._inverted && !this.inversionShaderFilter) {
				this.initInversionShader();
				return;
			}
			
			if (this.bVerbose) {
				trace("[FLARManager] inverted: "+ val);
			}
			this._inverted = val;
		}
		
		/**
		 * set to true to flip the camera image horizontally;
		 * this value is passed on to this.flarSource;
		 * note that if an IFLARSource is specified after mirrorDisplay is set,
		 * the 'mirrored' property of the new IFLARSource will overwrite this value. 
		 */
		public function get mirrorDisplay () :Boolean {
			return this._mirrorDisplay;
		}
		public function set mirrorDisplay (val:Boolean) :void {
			if (this.bVerbose) {
				trace("[FLARManager] mirror display: "+ val);
			}
			
			this._mirrorDisplay = val;
			if (this.flarSource) {
				this.flarSource.mirrored = this._mirrorDisplay;
			}
		}
		
		/**
		 * provides direct access to FLARLabeling_BitmapData.minimumLabelSize,
		 * which is the minimum size (width*height) a dark area of the source image must be
		 * in order to become a candidate for marker outline detection.
		 * higher values result in faster performance,
		 * but poorer marker detection at smaller sizes (as they appear on-screen).
		 * defaults to 100.
		 */
		public function get minimumLabelSize () :Number {
			/*
			return FLARLabeling_BitmapData.minimumLabelSize;
			*/
			return -1;
		}
		public function set minimumLabelSize (val:Number) :void {
			/*
			if (this.bVerbose) {
				trace("[FLARManager] minimum label size: "+ val);
			}
			FLARLabeling_BitmapData.minimumLabelSize = val;
			*/
		}
		
		/**
		 * if a detected marker is within this distance (pixels) from an active marker,
		 * FLARManager considers the detected marker to be an update of the active marker.
		 * else, the detected marker is a new marker.
		 * increase this value to accommodate faster-moving markers;
		 * decrease it to accommodate more markers on-screen at once.
		 */
		public function get markerUpdateThreshold () :Number {
			return this._markerUpdateThreshold;
		}
		public function set markerUpdateThreshold (val:Number) :void {
			if (this.bVerbose) {
				trace("[FLARManager] marker update threshold: "+ val);
			}
			this._markerUpdateThreshold = val;
		}
		
		/**
		 * number of frames after removal that a marker will persist before dispatching a MARKER_REMOVED event.
		 * if a marker of the same pattern appears within <tt>markerUpdateThreshold</tt> pixels
		 * of the point of removal, before <tt>markerRemovalDelay</tt> frames have elapsed,
		 * the marker will be reinstated as if it was never removed.
		 * 
		 * the default value is 1.
		 */
		public function get markerRemovalDelay () :int {
			return this._markerRemovalDelay;
		}
		public function set markerRemovalDelay (val:int) :void {
			if (this.bVerbose) {
				trace("[FLARManager] marker removal delay: "+ val);
			}
			this._markerRemovalDelay = val;
		}
		
		/**
		 * if true, FLARManager will extrapolate the position of a FLARMarker from its velocity when last detected.
		 * extrapolation continues until markerRemovalDelay frames after FLARToolkit reports a marker removed.
		 * enabling markerExtrapolation can sometimes improve tracking during fast marker motion.
		 */
		public function get markerExtrapolation () :Boolean {
			return this._markerExtrapolation;
		}
		public function set markerExtrapolation (val:Boolean) :void {
			if (this.bVerbose) {
				trace("[FLARManager] marker extrapolation: "+ (val ? "ON" : "OFF"));
			}
			this._markerExtrapolation = val;
		}
		
		/**
		 * apply a smoothing algorithm to transformation matrices generated by FLARToolkit.
		 * smoothing is equal to the number of frames over which FLARManager
		 * will average transformation matrices; the larger the number, the smoother the animation,
		 * and the slower the response time between marker position/orientation changes.
		 * a value of 0 turns smoothing off.
		 */ 
		public function get smoothing () :int {
			return this._smoothing;
		}
		public function set smoothing (val:int) :void {
			if (this.bVerbose) {
				trace("[FLARManager] smoothing: "+ val);
			}
			this._smoothing = val;
		}
		
		/**
		 * IFLARMatrixSmoother to use to apply smoothing to transformation matrices generated by FLARToolkit.
		 */
		public function get smoother () :IFLARMatrixSmoother {
			return this._smoother;
		}
		public function set smoother (val:IFLARMatrixSmoother) :void {
			if (this.bVerbose) {
				trace("[FLARManager] smoother "+ flash.utils.getQualifiedClassName(val));
			}
			this._smoother = val;
		}
		
		/**
		 * adaptive smoothing reduces jitter in marker transformation matrices for markers with
		 * little motion, while maintaining responsiveness for markers with fast motion.
		 * adaptiveSmoothingCenter is the marker motion distance (between current and last frame)
		 * at which the actual applied smoothing is equal to FLARManager.smoothing.
		 * when a marker has moved less than adaptiveSmoothingCenter, smoothing increases;
		 * when a marker has moved more than adaptiveSmoothingCenter, smoothing decreases. 
		 */
		public function get adaptiveSmoothingCenter () :Number {
			return this._adaptiveSmoothingCenter;
		}
		public function set adaptiveSmoothingCenter (val:Number) :void {
			if (this.bVerbose) {
				trace("[FLARManager] adaptive smoothing center: "+ val);
			}
			this._adaptiveSmoothingCenter = val;
		}
		
		/**
		 * display the source BitmapData used by FLARToolkit post-thresholding.
		 * useful for debugging.
		 */
		public function get thresholdSourceDisplay () :Boolean {
			return this._thresholdSourceDisplay;
		}
		public function set thresholdSourceDisplay (val:Boolean) :void {
			if (this.bVerbose) {
				trace("[FLARManager] threshold source display: "+ val);
			}
			
			this._thresholdSourceDisplay = val;
			if (this._thresholdSourceDisplay) {
				try {
					if (!this.thresholdSourceBitmap) {
						if (!this.markerDetector.thresholdedBitmapData) {
							throw new Error("Error initializing FLARMultiMarkerDetector; thresholdedBitmapData not inited.");
						}
						this.thresholdSourceBitmap = new Bitmap(this.markerDetector.thresholdedBitmapData);
						Sprite(this._flarSource).addChild(this.thresholdSourceBitmap);
					}
				} catch (e:Error) {
					this.thresholdSourceBitmap = null;
					return;
				}
			}
		}
		//-----<END CONFIG ACCESSORS>--------------------------------//
		
		
		
		//-----<OTHER ACCESSORS>-------------------------------------//
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
		 * reference to FLARCameraSource used in this application.
		 * if this application does not use a camera, returns null.
		 */
		public function get flarCameraSource () :FLARCameraSource {
			return this._flarSource as FLARCameraSource;
		}
		
		/**
		 * the number of patterns loaded for detection.
		 */
		public function get numLoadedPatterns () :int {
			return this.patternLoader.loadedPatterns.length;
		}
		
		/**
		 * Vector of all currently-active markers.
		 */
		public function get activeMarkers () :Vector.<FLARMarker> {
			return this._activeMarkers;
		}
		
		/**
		 * true if this FLARManager instance is active and currently processing marker detection.
		 */
		public function get isActive () :Boolean {
			return this.bActive;
		}
		public function set isActive (val:Boolean) :void {
			trace("[FLARManager] "+ (val ? "activated" : "deactivated"));
			
			if (val) {
				this.activate();
			} else {
				this.deactivate();
			}
		}
		
		/**
		 * if true, FLARManager will output configuration changes to the console.
		 */
		public function get verbose () :Boolean {
			return this.bVerbose;
		}
		public function set verbose (val:Boolean) :void {
			this.bVerbose = val;
			trace("[FLARManager] verbosity "+ (val ? "ON" : "OFF"));
		}
		//-----<END OTHER ACCESSORS>---------------------------------//
		
		
		
		//-----<PUBLIC METHODS>----------------------------//
		/**
		 * begin detecting markers once per frame.
		 * this method is called automatically on initialization.
		 * @return		false if FLARManager is not yet initialized; else true.
		 */
		public function activate () :Boolean {
			if (!this.bInited) { return false; }
			if (this.bActive) { return true; }
			this.bActive = true;
			
			if (this._flarSource is FLARProxy) {
				// activate FLARProxy
				var flarProxy:FLARProxy = this._flarSource as FLARProxy;
				flarProxy.activate();
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onProxyMarkerAdded);
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onProxyMarkerUpdated);
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onProxyMarkerRemoved);
			} else {
				// activate normally
				if (!this.enterframer) {
					this.enterframer = new Sprite();
				}
				this.enterframer.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
				this.enterframer.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
			}
			
			this._activeMarkers = new Vector.<FLARMarker>();
			this.markersPendingRemoval = new Vector.<FLARMarker>();
			
			return true;
		}
		
		/**
		 * stop detecting markers.
		 * removes all currently-active markers.
		 * enterframe loop continues, to update video.
		 */
		public function deactivate () :void {
			if (!this.bActive) {
				return;
			}
			this.bActive = false;
			
			if (this._flarSource is FLARProxy) {
				// deactivate FLARProxy
				var flarProxy:FLARProxy = this._flarSource as FLARProxy;
				flarProxy.deactivate();
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onProxyMarkerAdded);
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onProxyMarkerUpdated);
				flarProxy.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onProxyMarkerRemoved);
			}
			
			if (this._activeMarkers) {
				var i:int = this._activeMarkers.length;
				while (i--) {
					// remove all active markers
					this.removeMarker(this._activeMarkers[i]);
				}
				this._activeMarkers = null;
			}
			
			if (this.markersPendingRemoval) {
				i = this.markersPendingRemoval.length;
				while (i--) {
					this.markersPendingRemoval[i].dispose();
				}
				this.markersPendingRemoval = null;
			}
		}
		
		/**
		 * halts all processes and frees this instance for garbage collection.
		 */
		public function dispose () :void {
			this.deactivate();
			
			this.disposeConfigLoader();
			
			this.enterframer.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
			this.enterframer = null;
			
			this._cameraParams = null;
			
			this._flarSource.dispose();
			var flarSourceDO:DisplayObject = this._flarSource as DisplayObject;
			if (flarSourceDO && flarSourceDO.parent) {
				flarSourceDO.parent.removeChild(flarSourceDO);
			}
			this._flarSource = null;
			
			this._thresholdAdapter.dispose();
			this._thresholdAdapter = null;
			this._smoother = null;
			
			this.patternLoader.dispose();
			this.patternLoader = null;
			
			this.allPatterns = null;
			
			// NOTE: FLARToolkit classes do not implement any disposal functionality,
			//		 and will likely not be removed from memory on FLARManager disposal.
			//this.markerDetector.dispose();
			this.markerDetector = null;
			BitmapData(this.flarRaster.getBuffer()).dispose();
			this.flarRaster = null;
			
			if (this.thresholdSourceBitmap) {
				this.thresholdSourceBitmap.bitmapData.dispose();
			}
			this.thresholdSourceBitmap = null;
			
			this.sampleBlurFilter = null;
		}
		//-----<END PUBLIC METHODS>---------------------------//
		
		
		
		//-----<MARKER DETECTION>----------------------------//
		private function onEnterFrame (evt:Event) :void {
			if (!this.updateSource()) { return; }
			
			if (!this.bActive) { return; }
			
			this.ageRemovedMarkers();
			this.performSourceAdjustments();
			this.detectMarkers();
		}
		
		private function updateSource () :Boolean {
			try {
				// ensure this.flarRaster has been initialized
				if (this.flarRaster == null) {
					this.flarRaster = new FLARRgbRaster_BitmapData(this.flarSource.sourceSize.width, this.flarSource.sourceSize.height);
					this.flarSource.source = BitmapData(this.flarRaster.getBuffer());
				}
			} catch (e:Error) {
				// this.flarSource not yet fully initialized
				return false;
			}
			
			// update source image
			this.flarSource.update();
			return true;
		}
		
		private function ageRemovedMarkers () :void {
			// remove all markers older than this.markerRemovalDelay.
			var i:uint = this.markersPendingRemoval.length;
			var removedMarker:FLARMarker;
			while (i--) {
				removedMarker = this.markersPendingRemoval[i];
				if (removedMarker.ageAfterRemoval() > this.markerRemovalDelay) {
					this.removeMarker(removedMarker);
				}
			}
		}
		
		private function performSourceAdjustments () :void {
			if (this.thresholdAdapter) {
				if (this.thresholdAdapter.runsEveryFrame) {
					// adjust threshold every frame.
					this.threshold = this.thresholdAdapter.calculateThreshold(this.flarSource.source, this.threshold);
				} else {
					// adjust threshold only when confidence is low (poor marker detection).
					if (this.averageConfidence <= this.averageMinConfidence) {
						this.threshold = this.thresholdAdapter.calculateThreshold(this.flarSource.source, this.threshold);
					} else {
						this.thresholdAdapter.resetCalculations(this.threshold);
					}					
				}
				this.averageConfidence = this.averageMinConfidence = 0;
			}
			
			if (this.sampleBlurring > 0) {
				// apply blur filter to combine and reduce number of black areas in image to be labeled.
				this.flarSource.source.applyFilter(this.flarSource.source, this.flarSource.sourceSize, ZERO_POINT, this.sampleBlurFilter);
			}
			
			if (this._inverted) {
				this.flarSource.source.applyFilter(this.flarSource.source, this.flarSource.sourceSize, ZERO_POINT, this.inversionShaderFilter);
			}
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
			
			var activeMarker:FLARMarker;
			var i:uint;
			if (numFoundMarkers == 0) {
				// if no markers found, remove any existing markers and exit
				i = this._activeMarkers.length;
				while (i--) {
					this.queueMarkerForRemoval(this._activeMarkers[i]);
				}
				return;
			}
			
			// build list of detected markers
			var detectedMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			
//			var detectedMarkerResult:FLARMultiMarkerDetectorResult;
			var patternId:int;
			var direction:int;
			var square:NyARSquare;
			
			var patternIndex:int;
			var detectedPattern:FLARPattern;
			var confidence:Number;
			var confidenceSum:Number = 0;
			var minConfidenceSum:Number = 0;
			var transmat:FLARTransMatResult;
			i = numFoundMarkers;
			while (i--) {
				
//				detectedMarkerResult = this.markerDetector.getResult(i);
				patternId = this.markerDetector.getARCodeIndex(i);
				direction = this.markerDetector.getDirection(i);
				square = this.markerDetector.getSquare(i);
				
				patternIndex = this.markerDetector.getARCodeIndex(i);
				detectedPattern = this.allPatterns[patternIndex];
				confidence = this.markerDetector.getConfidence(i);
				confidenceSum += confidence;
				minConfidenceSum += detectedPattern.minConfidence;
				if (confidence < detectedPattern.minConfidence) {
					// detected marker's confidence is below the minimum required confidence for its pattern.
					continue;
				}
				
				transmat = new FLARTransMatResult();
				try {
					this.markerDetector.getTransformMatrix(i, transmat);
				} catch (e:Error) {
					// FLARException happens with rotationX of approx -60 and +60, and rotY&Z of 0.
					// not sure why...
					continue;
				}
				
//				detectedMarkers.push(new FLARMarker(detectedMarkerResult, transmat, this.flarSource, detectedPattern));
				detectedMarkers.push(new FLARMarker(transmat, this.flarSource, detectedPattern, patternId, direction, square, confidence));
			}
			this.averageConfidence = confidenceSum / numFoundMarkers;
			this.averageMinConfidence = minConfidenceSum / numFoundMarkers;
			
			// compare detected markers against active markers
			i = detectedMarkers.length;
			var j:uint, k:uint;
			var detectedMarker:FLARMarker;
			var closestMarker:FLARMarker;
			var closestDist:Number = Number.POSITIVE_INFINITY;
			var dist:Number;
			var updatedMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var newMarkers:Vector.<FLARMarker> = new Vector.<FLARMarker>();
			var removedMarker:FLARMarker;
			var bRemovedMarkerMatched:Boolean = false;
			while (i--) {
				j = this._activeMarkers.length;
				detectedMarker = detectedMarkers[i];
				closestMarker = null;
				closestDist = Number.POSITIVE_INFINITY;
				while (j--) {
					activeMarker = this._activeMarkers[j];
					if (detectedMarker.patternId == activeMarker.patternId) {
						dist = Point.distance(detectedMarker.centerpoint3D, activeMarker.targetCenterpoint3D);
						if (dist < closestDist && dist < this._markerUpdateThreshold) {
							closestMarker = activeMarker;
							closestDist = dist;
						}
					}
				}
				
				if (closestMarker) {
					// updated marker
					closestMarker.copy(detectedMarker);
					detectedMarker.dispose();
					if (this._smoothing) {
						if (!this._smoother) {
							// TODO: log as a WARN-level error
							trace("no smoother set; specify FLARManager.smoother to enable smoothing."); 
						} else {
							closestMarker.applySmoothing(this._smoother, this._smoothing, this._adaptiveSmoothingCenter);
						}
					}
					updatedMarkers.push(closestMarker);
					
					// if closestMarker is pending removal, restore it.
					k = this.markersPendingRemoval.length;
					while (k--) {
						if (this.markersPendingRemoval[k] == closestMarker) {
							closestMarker.resetRemovalAge();
							this.markersPendingRemoval.splice(k, 1);
						}
					}
					
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_UPDATED, closestMarker));
				} else {
					// new marker
					newMarkers.push(detectedMarker);
					detectedMarker.setSessionId();
					this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_ADDED, detectedMarker));
				}
			}
			
			i = this._activeMarkers.length;
			while (i--) {
				activeMarker = this._activeMarkers[i];
				if (updatedMarkers.indexOf(activeMarker) == -1) {
					// if activeMarker was not updated, queue it for removal.
					this.queueMarkerForRemoval(activeMarker);
				}
			}
			
			this._activeMarkers = this._activeMarkers.concat(newMarkers);
		}
		
		private function queueMarkerForRemoval (marker:FLARMarker) :void {
			if (this.markersPendingRemoval.indexOf(marker) == -1) {
				this.markersPendingRemoval.push(marker);
			}
		}
		
		private function removeMarker (marker:FLARMarker) :void {
			var i:uint = this._activeMarkers.indexOf(marker);
			if (i >= 0) {
				this._activeMarkers.splice(i, 1);
			}
			
			i = this.markersPendingRemoval.indexOf(marker);
			if (i >= 0) {
				this.markersPendingRemoval.splice(i, 1);
			}
			
			this.dispatchEvent(new FLARMarkerEvent(FLARMarkerEvent.MARKER_REMOVED, marker));
			marker.dispose();
		}
		
		private function onProxyMarkerAdded (evt:FLARMarkerEvent) :void {
			this.dispatchEvent(evt);
		}
		
		private function onProxyMarkerUpdated (evt:FLARMarkerEvent) :void {
			this.dispatchEvent(evt);
		}
		
		private function onProxyMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.dispatchEvent(evt);
		}
		//-----<END MARKER DETECTION>---------------------------//
		
		
		
		//-----<INITIALIZATION>----------------------------//
		private function initConfigLoader () :void {
			this.configLoader = new FLARManagerConfigLoader();
			this.configLoader.addEventListener(ErrorEvent.ERROR, this.onConfigLoadError);
			this.configLoader.addEventListener(FLARManagerConfigLoader.CONFIG_FILE_LOADED, this.onConfigLoaded);
			this.configLoader.addEventListener(FLARManagerConfigLoader.CONFIG_FILE_PARSED, this.onConfigParsed);
		}
		
		private function disposeConfigLoader () :void {
			if (!this.configLoader) { return; }
			
			this.configLoader.removeEventListener(ErrorEvent.ERROR, this.onConfigLoadError);
			this.configLoader.removeEventListener(FLARManagerConfigLoader.CONFIG_FILE_LOADED, this.onConfigLoaded);
			this.configLoader.removeEventListener(FLARManagerConfigLoader.CONFIG_FILE_PARSED, this.onConfigParsed);
			
			this.configLoader.dispose();
			this.configLoader = null;
		}
		
		private function onConfigLoaded (evt:Event) :void {
			if (this.bVerbose) {
				trace("[FLARManager] config file loaded.");
			}
		}
		
		private function onConfigLoadError (evt:ErrorEvent) :void {
			this.dispatchEvent(evt);
		}
		
		private function onConfigParsed (evt:Event) :void {
			if (this.bVerbose) {
				trace("[FLARManager] config file parsed.");
			}
			
			this.configLoader.harvestConfig(this);
			this.init();
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function init () :void {
			this.initFlarSource();
			this.loadCameraParams(this.configLoader.cameraParamsPath);
			this.allPatterns = this.configLoader.patterns;
			this.loadPatterns(this.allPatterns);
			
			// initialize sampleBlurFilter
			this.sampleBlurring = this.sampleBlurring;
		}
		
		private function initFlarSource () :void {
			var sourceParent:DisplayObjectContainer;
			var sourceAsSprite:Sprite;
			var sourceIndex:int;
			if (this._flarSource) {
				if (this._flarSource.inited) {
					// do not attempt to init if source was inited before passing into FLARManager ctor.
					return;
				}
				
				sourceAsSprite = this._flarSource as Sprite;
				sourceParent = sourceAsSprite.parent;
			}
			
			if (this.configLoader.useProxy) {
				if (sourceParent) {
					// if placeholder IFLARSource was already added to the display list, remove it...
					sourceIndex = sourceParent.getChildIndex(sourceAsSprite);
					sourceParent.removeChild(sourceAsSprite);
				}
				
				this._flarSource = new FLARProxy(this.configLoader.displayWidth, this.configLoader.displayHeight);
				
				if (sourceParent) {
					// ...and replace it with the new FLARLoaderSource.
					sourceParent.addChildAt(Sprite(this._flarSource), sourceIndex);
				}
			} else if (this.configLoader.loaderPath) {
				if (sourceParent) {
					// if placeholder IFLARSource was already added to the display list, remove it...
					sourceIndex = sourceParent.getChildIndex(sourceAsSprite);
					sourceParent.removeChild(sourceAsSprite);
				}
				
				this._flarSource = new FLARLoaderSource(
					this.configLoader.loaderPath, this.configLoader.sourceWidth,
					this.configLoader.sourceHeight, this.configLoader.downsampleRatio);
				
				if (sourceParent) {
					// ...and replace it with the new FLARLoaderSource.
					sourceParent.addChildAt(Sprite(this._flarSource), sourceIndex);
				}
			} else {
				FLARCameraSource(this._flarSource).addEventListener(ErrorEvent.ERROR, this.onCameraSourceError);
				FLARCameraSource(this._flarSource).init(
					this.configLoader.sourceWidth, this.configLoader.sourceHeight,
					this.configLoader.framerate, this._mirrorDisplay,
					this.configLoader.displayWidth, this.configLoader.displayHeight,
					this.configLoader.downsampleRatio);
			}
		}
		
		private function onCameraSourceError (evt:ErrorEvent) :void {
			this.deactivate();
			this.dispatchEvent(evt);
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
		
		private function loadPatterns (patterns:Vector.<FLARPattern>) :void {
			this.patternLoader = new FLARPatternLoader();
			this.patternLoader.addEventListener(Event.INIT, this.onPatternsLoaded);
			this.patternLoader.loadPatterns(patterns);
		}
		
		private function onPatternsLoaded (evt:Event) :void {
			this.patternLoader.removeEventListener(Event.INIT, this.onPatternsLoaded);
			this.bPatternsLoaded = true;
			this.checkForInitComplete();
		}
		
		private function checkForInitComplete () :void {
			if (!this.bCameraParamsLoaded || !this.bPatternsLoaded || !this._flarSource) { return; }
			
			if (this.patternLoader.loadedPatterns.length == 0) {
				throw new Error("no markers successfully loaded.");
			}
			
			try {
				this.flarRaster = new FLARRgbRaster_BitmapData(this.flarSource.sourceSize.width, this.flarSource.sourceSize.height);
				this.flarSource.source = BitmapData(this.flarRaster.getBuffer());
			} catch (e:Error) {
				// this.flarSource not yet fully initialized
				this.flarRaster = null;
			}
			
			this.markerDetector = new FLARMultiMarkerDetector(this._cameraParams, this.patternLoader.loadedPatterns, this.patternLoader.unscaledMarkerWidths, this.patternLoader.loadedPatterns.length);
			//this.markerDetector.setContinueMode(true);
			
			if (this.thresholdSourceDisplay) {
				// if this.thresholdSourceDisplay was set to true before initialization of
				// this.flarSource and this.markerDetector, reset it.
				this.thresholdSourceDisplay = true;
			}
			
			if (!this.smoother) {
				this.smoother = new FLARMatrixSmoother_Average();
			}
			if (!this.thresholdAdapter) {
				this.thresholdAdapter = new DrunkHistogramThresholdAdapter();
			}
			
			this.bInited = true;
			this.activate();
			
			this.dispatchEvent(new Event(Event.INIT));
		}
		
		private function initInversionShader () :void {
			var inversionShaderLoader:URLLoader = new URLLoader();
			inversionShaderLoader.dataFormat = URLLoaderDataFormat.BINARY;
			inversionShaderLoader.addEventListener(Event.COMPLETE, this.onInversionShaderLoaded);
			inversionShaderLoader.addEventListener(ErrorEvent.ERROR, this.onInversionShaderLoadError);
			inversionShaderLoader.load(new URLRequest("../resources/flar/invert.pbj"));
		}
		
		private function onInversionShaderLoadError (evt:ErrorEvent) :void {
			this.onInversionShaderLoaded(evt);
		}
		
		private function onInversionShaderLoaded (evt:Event, errorEvent:ErrorEvent=null) :void {
			var inversionShaderLoader:URLLoader = URLLoader(evt.target);
			if (!inversionShaderLoader) { return; }
			inversionShaderLoader.removeEventListener(Event.COMPLETE, this.onInversionShaderLoaded);
			inversionShaderLoader.removeEventListener(ErrorEvent.ERROR, this.onInversionShaderLoadError);
			
			if (errorEvent) {
				throw new Error("invert.pbj not found in ../resources/flar/.");
			}
			
			var inversionShader:Shader = new Shader(inversionShaderLoader.data);
			this.inversionShaderFilter = new ShaderFilter(inversionShader);
			
			this.inverted = true;
		}
		//-----<END INITIALIZATION>---------------------------//
	}
}