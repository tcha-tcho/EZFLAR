package com.transmote.flar {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;

	/**
	 * use the contents of a Camera feed as a source image for FLARToolkit marker detection.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARCameraSource extends Sprite implements IFLARSource {
		private var sourceWidth:Number;
		private var sourceHeight:Number;
		private var _downsampleRatio:Number;
		
		private var camera:Camera;
		private var video:Video;
		private var snapshotBitmap:Bitmap;
		private var snapshot:BitmapData;
		private var sampleContainer:Sprite;
		
		/**
		 * constructor.
		 * @param	width				camera and source image width
		 * @param	height				camera and source image height
		 * @param	fps					framerate of camera capture
		 * @param	downsampleRatio		amount to downsample camera input.
		 * 								adjust to balance between image quality and marker tracking performance.
		 * 								a value of 1.0 results in no downsampling;
		 * 								a value of 0.5 (the default) downsamples the camera input by half.
		 */
		public function FLARCameraSource (width:int=640, height:int=480, fps:Number=30, downsampleRatio:Number=0.5) {
			this.init(width, height, fps, downsampleRatio);
		}
		
		/**
		 * update the BitmapData source.
		 */
		public function update () :void {
			this.snapshot.draw(this.video);
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
		
		private function init (width:int, height:int, fps:Number, downsampleRatio:Number) :void {
			this._downsampleRatio = downsampleRatio;
			this.sourceWidth = width * this._downsampleRatio;
			this.sourceHeight = height * this._downsampleRatio;
			
			this.camera = Camera.getCamera();
			this.camera.setMode(this.sourceWidth, this.sourceHeight, fps);
			
			this.video = new Video(this.sourceWidth, this.sourceHeight);
			this.video.attachCamera(this.camera);
			
			this.snapshot = new BitmapData(this.sourceWidth, this.sourceHeight, false, 0);
			this.snapshotBitmap = new Bitmap(this.snapshot);
			this.snapshotBitmap.scaleX = this.snapshotBitmap.scaleY = 1/this._downsampleRatio;
			this.addChild(this.snapshotBitmap);
		}
	}
}