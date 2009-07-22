package com.transmote.flar {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	/**
	 * use the contents of a Loader as a source image for FLARToolkit marker detection.
	 * FLARLoaderSource samples the contents of a Loader against a white background,
	 * to provide maximum contrast for marker detection.
	 * this class can be used for testing marker detection without a camera,
	 * for example with a swf or jpeg with valid patterns within.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARLoaderSource extends Sprite implements IFLARSource {
		private var sourceWidth:Number;
		private var sourceHeight:Number;
		private var _downsampleRatio:Number;
		
		private var matRect:Rectangle;
		private var loader:Loader;
		private var loaderContainer:Sprite;		// used for scaling for BitmapData sampling
		private var snapshot:BitmapData;
		private var snapshotBitmap:Bitmap;
		
		
		/**
		 * constructor.
		 * @param	contentPath		filename to load.
		 * @param	width			width of file.
		 * @param	height			height of file.
		 * @param	downsampleRatio		amount to downsample camera input.
		 * 								adjust to balance between image quality and marker tracking performance.
		 * 								a value of 1.0 results in no downsampling;
		 * 								a value of 0.5 (the default) downsamples the camera input by half.
		 */
		public function FLARLoaderSource (contentPath:String, width:Number, height:Number, downsampleRatio:Number=0.5) {
			this._downsampleRatio = downsampleRatio;
			
			this.sourceWidth = width * this._downsampleRatio;
			this.sourceHeight = height * this._downsampleRatio;
			
			this.matRect = new Rectangle(0, 0, this.sourceWidth, this.sourceHeight);
			
			this.loadContent(contentPath);
		}
		
		/**
		 * update the BitmapData source used for analysis.
		 */
		public function update () :void {
			this.snapshot.fillRect(this.matRect, 0xFFFFFFFF);
			this.snapshot.draw(this.loaderContainer);
		}
		
		/**
		 * retrieve the BitmapData source used for analysis.
		 * NOTE: returns the actual BitmapData object, not a clone.
		 */
		public function get source () :BitmapData {
			return this.snapshot;
		}
		
		/**
		 * size of BitmapData source used for analysis.
		 */
		public function get sourceSize () :Rectangle {
			return new Rectangle(0, 0, this.sourceWidth, this.sourceHeight);
		}
		
		/**
		 * amount by which the BitmapData source is downsampled.
		 */
		public function get downsampleRatio () :Number {
			return this._downsampleRatio;
		}
		
		private function loadContent (path:String) :void {
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError, false, 0, true);
			this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadError, false, 0, true);
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoaded, false, 0, true);
			this.loader.load(new URLRequest(path));
		}
		
		private function onLoadError (evt:Event) :void {
			var errorText:String = "FLARLoaderSource load error.";
			if (evt is IOErrorEvent) {
				errorText = IOErrorEvent(evt).text;
			} else if (evt is SecurityErrorEvent) {
				errorText = SecurityErrorEvent(evt).text;
			}
			
			this.onLoaded(evt, new Error(errorText));
		}
		
		private function onLoaded (evt:Event, error:Error=null) :void {
			var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
			
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
			loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadError);
			loaderInfo.removeEventListener(Event.COMPLETE, this.onLoaded);
			
			if (error) { throw error; }
			
			this.loaderContainer = new Sprite();
			this.loader.scaleX = this.loader.scaleY = this._downsampleRatio;
			this.loaderContainer.addChild(this.loader);
			
			this.snapshot = new BitmapData(this.sourceWidth, this.sourceHeight, false, 0xFFFFFFFF);
			this.snapshotBitmap = new Bitmap(this.snapshot, PixelSnapping.AUTO, true);
			this.snapshotBitmap.scaleX = this.snapshotBitmap.scaleY = 1/this._downsampleRatio;
			this.addChild(this.snapshotBitmap);
			
			
			this.dispatchEvent(new Event(Event.INIT));
		}
	}
}