package com.transmote.flar {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.FLARException;
	import org.libspark.flartoolkit.core.FLARCode;
	
	/**
	 * manages loading FLARPatterns and instantiating corresponding FLARCodes.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARPatternLoader extends EventDispatcher {
		private var loadingPatterns:Array;//:Vector.<FLARPattern>;
		private var _loadedPatterns:Array;	// :FLARCode
		private var _unscaledMarkerWidths:Array;
		
		private var patternsByLoader:Dictionary;
		private var flarPatternsByFlarCodes:Dictionary;
		
		private var numPatternsLoaded:uint = 0;
		private var bLoading:Boolean;
		
		
		/**
		 * constructor.
		 */
		public function FLARPatternLoader () {}
		
		/**
		 * get loaded patterns, as FLARCode instances.
		 * @throws	Error	if still loading.
		 */
		public function get loadedPatterns () :Array {
			if (this.bLoading) {
				throw new Error("currently loading patterns.  listen for Event.INIT to signal load completion.");
			}
			
			return this._loadedPatterns;
		}
		
		/**
		 * return unscaled marker widths, for use by FLARMultiMarkerDetector.
		 * this array is synchronized with this.loadedPatterns --
		 * the unscaledMarkerWidth at each index corresponds to the loaded pattern at each index.
		 */
		public function get unscaledMarkerWidths () :Array {
			return this._unscaledMarkerWidths;
		}
		
		/**
		 * load a list of FLARPatterns and store as FLARCodes,
		 * accessible as this.loadedPatterns.
		 * 
		 * @param	patterns	list of FLARPatterns to load.  
		 * @throws	Error		if pattern load is currently in progress.
		 */
		public function loadPatterns (patterns:Array/*:Vector.<FLARPattern>*/) :void {
			if (this.bLoading) {
				throw new Error("currently loading patterns.");
			}
			this.bLoading = true;
			
			this.loadingPatterns = patterns;
			this.patternsByLoader = new Dictionary(true);
			this.flarPatternsByFlarCodes = new Dictionary(true);
			this._loadedPatterns = new Array(this.loadingPatterns.length);
			
			var i:uint = this.loadingPatterns.length;
			while (i--) {
				this.loadPattern(this.loadingPatterns[i]);
			}
		}
		
		private function loadPattern (pattern:FLARPattern) :void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onPatternLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onPatternLoadError);
			loader.addEventListener(Event.COMPLETE, this.onPatternLoaded);
			this.patternsByLoader[loader] = pattern;
			loader.load(new URLRequest(pattern.filename));
		}
		
		private function onPatternLoadError (evt:Event) :void {
			var errorText:String = "Pattern load error.";
			if (evt is IOErrorEvent) {
				errorText += ("\n"+ IOErrorEvent(evt).text);
			} else if (evt is SecurityErrorEvent) {
				errorText += ("\n"+ SecurityErrorEvent(evt).text);
			}
			
			this.onPatternLoaded(evt, new Error(errorText));
		}
		
		private function onPatternLoaded (evt:Event, error:Error=null) :void {
			var loader:URLLoader = evt.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onPatternLoadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onPatternLoadError);
			loader.removeEventListener(Event.COMPLETE, this.onPatternLoaded);
			
			var loadedPattern:FLARPattern = FLARPattern(this.patternsByLoader[loader]);
			delete this.patternsByLoader[loader];
			var loadedPatternIndex:int = this.loadingPatterns.indexOf(loadedPattern);
			
			if (error) {
				this.checkForLoadCompletion();
				// TODO: probably want to change this to trace(), not throw.
				trace(error);
			} else {
				// create the FLARCode from the loaded pattern data
				// TODO: is squidder using a newer version of FLARToolkit?  mine doesn't have i_markerPercentWidth/Height.
				var flarCode:FLARCode = new FLARCode(loadedPattern._resolution, loadedPattern._resolution);//, loadedPattern._patternToBorderRatio, loadedPattern._patternToBorderRatio);
				try {
					flarCode.loadARPatt(String(loader.data));
				} catch (e:FLARException) {
					throw e;
				}
				
				// store the FLARCode in this.loadedPatterns
				this.flarPatternsByFlarCodes[flarCode] = loadedPattern;
				this._loadedPatterns[loadedPatternIndex] = flarCode;
			}
			
			this.numPatternsLoaded++;
			this.checkForLoadCompletion();
		}
		
		private function checkForLoadCompletion () :void {
			if (this.numPatternsLoaded == this.loadingPatterns.length) {
				this.sortPatternsAndUnscaledMarkerWidths();
				this.loadingPatterns = null;	// release reference to FLARPatterns list
				this.bLoading = false;
				this.dispatchEvent(new Event(Event.INIT));
			}
		}
		
		private function sortPatternsAndUnscaledMarkerWidths () :void {
			var i:int = this.loadingPatterns.length;
			this._unscaledMarkerWidths = new Array(i);
			while (i--) {
				if (this._loadedPatterns[i]) {
					this._unscaledMarkerWidths[i] = this.loadingPatterns[i].unscaledMarkerWidth;
				} else {
					// cull patterns that did not load successfully
					this._loadedPatterns.splice(i, 1);
					this._unscaledMarkerWidths.splice(i, 1);
				}
			}
		}
	}
}