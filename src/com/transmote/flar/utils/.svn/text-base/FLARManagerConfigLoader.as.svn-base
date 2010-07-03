package com.transmote.flar.utils {
	import __AS3__.vec.Vector;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.flarManagerInternal;
	import com.transmote.flar.pattern.FLARPattern;
	import com.transmote.flar.utils.smoother.IFLARMatrixSmoother;
	import com.transmote.flar.utils.threshold.IThresholdAdapter;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	use namespace flarManagerInternal;
	
	/**
	 * loads and parses FLARManager xml configuration file.
	 */
	public class FLARManagerConfigLoader extends EventDispatcher {
		public static const CONFIG_FILE_LOADED:String = "configFileLoaded";
		public static const CONFIG_FILE_PARSED:String = "configFileParsed";
		
		flarManagerInternal var cameraParamsPath:String;
		flarManagerInternal var patterns:Vector.<FLARPattern>;
		flarManagerInternal var sourceWidth:int = 640;
		flarManagerInternal var sourceHeight:int = 480;
		flarManagerInternal var displayWidth:int = 640;
		flarManagerInternal var displayHeight:int = 480;
		flarManagerInternal var framerate:Number = 30;
		flarManagerInternal var downsampleRatio:Number = 0.5;
		flarManagerInternal var useProxy:Boolean = false;
		flarManagerInternal var loaderPath:String = "";
		
		private var configFileLoader:URLLoader;
		
		private var thresholdAdapter:IThresholdAdapter;
		private var sampleBlurring:int;
		private var invertedStr:String;
		private var mirrorDisplayStr:String;
		private var markerUpdateThreshold:Number;
		private var markerRemovalDelay:int;
		private var markerExtrapolationStr:String;
		private var smoothing:int;
		private var smoother:IFLARMatrixSmoother;
		private var adaptiveSmoothingCenter:Number;
		private var minimumLabelSize:Number;
		private var thresholdSourceDisplayStr:String;

		
		public function FLARManagerConfigLoader () {}
		
		/**
		 * copies properties specified by config file into FLARManager,
		 * and removes all complex Objects from FLARManagerConfigLoader memory.
		 */ 
		public function harvestConfig (flarManager:FLARManager=null) :void {
			if (flarManager) {
				if (this.thresholdAdapter) {
					flarManager.thresholdAdapter = this.thresholdAdapter;
				}
				if (!isNaN(this.sampleBlurring) && this.sampleBlurring > 0) {
					flarManager.sampleBlurring = this.sampleBlurring;
				}
				if (this.invertedStr) {
					if (this.invertedStr.toLowerCase() == "true") { flarManager.inverted = true; }
					else if (this.invertedStr.toLowerCase() == "false") { flarManager.inverted = false; }
				}
				if (this.mirrorDisplayStr) {
					if (this.mirrorDisplayStr.toLowerCase() == "true") { flarManager.mirrorDisplay = true; }
					else if (this.mirrorDisplayStr.toLowerCase() == "false") { flarManager.mirrorDisplay = false; }
				}
				if (!isNaN(this.markerUpdateThreshold) && this.markerUpdateThreshold > 0) {
					flarManager.markerUpdateThreshold = this.markerUpdateThreshold;
				}
				if (!isNaN(this.markerRemovalDelay) && this.markerRemovalDelay > 0) {
					flarManager.markerRemovalDelay = this.markerRemovalDelay;
				}
				if (this.markerExtrapolationStr) {
					if (this.markerExtrapolationStr.toLowerCase() == "true") { flarManager.markerExtrapolation = true; }
					else if (this.markerExtrapolationStr.toLowerCase() == "false") { flarManager.markerExtrapolation = false; }
				}
				if (!isNaN(this.smoothing) && this.smoothing > 0) {
					flarManager.smoothing = this.smoothing;
				}
				if (this.smoother) {
					flarManager.smoother = this.smoother;
				}
				if (!isNaN(this.adaptiveSmoothingCenter)) {
					flarManager.adaptiveSmoothingCenter = this.adaptiveSmoothingCenter;
				}
				if (!isNaN(this.minimumLabelSize)) {
					flarManager.minimumLabelSize = this.minimumLabelSize;
				}
				if (this.thresholdSourceDisplayStr) {
					if (this.thresholdSourceDisplayStr.toLowerCase() == "true") { flarManager.thresholdSourceDisplay = true; }
					else if (this.thresholdSourceDisplayStr.toLowerCase() == "false") { flarManager.thresholdSourceDisplay = false; }
				}
			}
			
			this.smoother = null;
			this.thresholdAdapter = null;
		}
		
		/**
		 * halts all processes and frees this instance for garbage collection.
		 */
		public function dispose () :void {
			this.harvestConfig();
			this.patterns = null;
			if (this.configFileLoader) {
				this.configFileLoader.close();
				this.configFileLoader = null;
			}
		}
		
		flarManagerInternal function loadConfigFile (configFilePath:String) :void {
			this.configFileLoader = new URLLoader();
			this.configFileLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onConfigLoaded);
			this.configFileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onConfigLoaded);
			this.configFileLoader.addEventListener(Event.COMPLETE, this.onConfigLoaded);
			this.configFileLoader.load(new URLRequest(configFilePath));
		}
		
		flarManagerInternal function parseConfigFile (configFileXML:XML) :void {
			this.parseSourceSettings(configFileXML.flarSourceSettings);
			this.parseFLARManagerSettings(configFileXML.flarManagerSettings);
			this.parsePatterns(configFileXML.patterns);
			
			// camera parameters file
			this.cameraParamsPath = configFileXML.cameraParamsFile.@path;
			
			this.dispatchEvent(new Event(CONFIG_FILE_PARSED));
		}
		
		private function parseSourceSettings (sourceSettingsXML:XMLList) :void {
			var sourceWidth:int = parseInt(sourceSettingsXML.@sourceWidth);
			if (!isNaN(sourceWidth) && sourceWidth > 0) {
				this.sourceWidth = sourceWidth;
			}
			var sourceHeight:int = parseInt(sourceSettingsXML.@sourceHeight);
			if (!isNaN(sourceHeight) && sourceHeight > 0) {
				this.sourceHeight = sourceHeight;
			}
			var displayWidth:int = parseInt(sourceSettingsXML.@displayWidth);
			if (!isNaN(displayWidth) && displayWidth > 0) {
				this.displayWidth = displayWidth;
			}
			var displayHeight:int = parseInt(sourceSettingsXML.@displayHeight);
			if (!isNaN(displayHeight) && displayHeight > 0) {
				this.displayHeight = displayHeight;
			}
			var framerate:Number = parseFloat(sourceSettingsXML.@framerate);
			if (!isNaN(framerate) && framerate > 0) {
				this.framerate = framerate;
			}
			var downsampleRatio:Number = parseFloat(sourceSettingsXML.@downsampleRatio);
			if (!isNaN(downsampleRatio) && downsampleRatio > 0) {
				this.downsampleRatio = downsampleRatio;
			}
			this.loaderPath = sourceSettingsXML.@loaderPath;
			this.useProxy = sourceSettingsXML.@useProxy == "true";
		}
		
		private function parseFLARManagerSettings (flarManagerSettingsXML:XMLList) :void {
			var thresholdAdapterName:String = flarManagerSettingsXML.thresholdAdapter.@className;
			if (thresholdAdapterName != "") {
				if (thresholdAdapterName.indexOf(".") == -1) {
					thresholdAdapterName = "com.transmote.flar.utils.threshold." + thresholdAdapterName;
				}
				
				try {
					var ThresholdAdapterClass:Class = flash.utils.getDefinitionByName(thresholdAdapterName) as Class;
					this.thresholdAdapter = new ThresholdAdapterClass();
				} catch (e:Error) {
					trace("error creating threshold adapter with className:"+ thresholdAdapterName +".  ensure the config file specifies a fully-qualified class name, or that the class is in the com.transmote.flar.utils.threshold package.  also, be sure to create a reference to the class anywhere in the project, to ensure it is compiled into the SWF.");
				}
				if (this.thresholdAdapter) {
					var thresholdAdapterParamsList:XMLList = flarManagerSettingsXML.thresholdAdapter[0].@*;
					if (thresholdAdapterParamsList.length() > 1) {
						try {
							var thresholdAdapterParamsObj:Object = new Object();
							for (i=0; i<thresholdAdapterParamsList.length(); i++) {
								paramName = thresholdAdapterParamsList[i].name();
								if (paramName == "className") { continue; }
								thresholdAdapterParamsObj[paramName] = thresholdAdapterParamsList[i].toString();
							}
							this.thresholdAdapter.initFromXML(thresholdAdapterParamsObj);
						} catch (e:Error) {
							trace("error applying threshold adapter params:"+ thresholdAdapterParamsList);
						}
					}
				}
			}
			
			var sampleBlurringVal:int = parseInt(flarManagerSettingsXML.@sampleBlurring);
			this.sampleBlurring = sampleBlurringVal;
			
			this.invertedStr = flarManagerSettingsXML.@inverted.toString();
			this.mirrorDisplayStr = flarManagerSettingsXML.@mirrorDisplay.toString();
			
			var markerUpdateThresholdVal:Number = parseFloat(flarManagerSettingsXML.@markerUpdateThreshold);
			this.markerUpdateThreshold = markerUpdateThresholdVal;
			
			var markerRemovalDelayVal:int = parseInt(flarManagerSettingsXML.@markerRemovalDelay);
			this.markerRemovalDelay = markerRemovalDelayVal;
			
			this.markerExtrapolationStr = flarManagerSettingsXML.@markerExtrapolation.toString();
			
			var smoothingVal:int = parseInt(flarManagerSettingsXML.@smoothing);
			this.smoothing = smoothingVal;
			
			var smootherName:String = flarManagerSettingsXML.smoother.@className;
			if (smootherName != "") {
				if (smootherName.indexOf(".") == -1) {
					smootherName = "com.transmote.flar.utils.smoother." + smootherName;
				}
				
				try {
					var SmootherClass:Class = flash.utils.getDefinitionByName(smootherName) as Class;
					this.smoother = new SmootherClass();
				} catch (e:Error) {
					trace("error creating smoother with className:"+ smootherName +".  ensure the config file specifies a fully-qualified class name, or that the class is in the com.transmote.flar.utils.smoother package.  also, be sure to create a reference to the class anywhere in the project, to ensure it is compiled into the SWF.");
				}
				if (this.smoother) {
					var smootherParamsList:XMLList = flarManagerSettingsXML.smoother[0].@*;
					if (smootherParamsList.length() > 1) {
						try {
							var smootherParamsObj:Object = new Object();
							var paramName:String;
							for (var i:int=0; i<smootherParamsList.length(); i++) {
								paramName = smootherParamsList[i].name();
								if (paramName == "className") { continue; }
								smootherParamsObj[paramName] = smootherParamsList[i].toString();
							}
							this.smoother.initFromXML(smootherParamsObj);
						} catch (e:Error) {
							trace("error applying smoother params:"+ smootherParamsList);
						}
					}
				}
			}
			
			var adaptiveSmoothingCenterVal:Number = parseFloat(flarManagerSettingsXML.@adaptiveSmoothingCenter);
			this.adaptiveSmoothingCenter = adaptiveSmoothingCenterVal;
			
			var minimumLabelSize:Number = parseFloat(flarManagerSettingsXML.@minimumLabelSize);
			this.minimumLabelSize = minimumLabelSize;
			
			this.thresholdSourceDisplayStr = flarManagerSettingsXML.@thresholdSourceDisplay.toString();
		}
			
		private function parsePatterns (patternsXML:XMLList) :void {
			// pattern list
			var resolutionStr:String = patternsXML.@resolution;
			var resolution:Number = NaN;
			if (resolutionStr != "") { resolution = parseFloat(resolutionStr); }
			
			var patternToBorderRatioStr:String = patternsXML.@patternToBorderRatio;
			var patternToBorderRatio:Number = NaN;
			if (patternToBorderRatioStr != "") { patternToBorderRatio = parseFloat(patternToBorderRatioStr); }
			
			var minConfidenceStr:String = patternsXML.@minConfidence;
			var minConfidence:Number = NaN;
			if (minConfidenceStr != "") { minConfidence = parseFloat(minConfidenceStr); }
			
			this.patterns = new Vector.<FLARPattern>();
			var patternPath:String;
			var patternSize:Number;
			for each (var pattern:XML in patternsXML.pattern) {
				patternSize = NaN;
				if (pattern.@size != "") { patternSize = parseFloat(pattern.@size); }
				
				this.patterns.push(new FLARPattern(pattern.@path, resolution, patternToBorderRatio, patternSize, minConfidence));
			}
		}
		
		private function onConfigLoaded (evt:Event) :void {
			this.configFileLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onConfigLoaded);
			this.configFileLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onConfigLoaded);
			this.configFileLoader.removeEventListener(Event.COMPLETE, this.onConfigLoaded);
			
			if (evt is ErrorEvent) {
				var errorEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
				errorEvent.text = ErrorEvent(evt).text;
				this.dispatchEvent(errorEvent);
				return;
			}
			
			this.dispatchEvent(new Event(CONFIG_FILE_LOADED));
			
			use namespace flarManagerInternal;
			this.parseConfigFile(new XML(this.configFileLoader.data as String));
			this.configFileLoader.close();
			this.configFileLoader = null;
		}
	}
}