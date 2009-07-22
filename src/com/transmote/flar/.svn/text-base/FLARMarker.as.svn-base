package com.transmote.flar {
	import org.libspark.flartoolkit.core.FLARSquare;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	/**
	 * container for information about a detected marker.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARMarker {
		internal var _transformMatrix:FLARTransMatResult;
		internal var _patternId:int;
		internal var _direction:int;
		internal var _confidence:Number;
		internal var _outline:FLARMarkerOutline;
		
		/**
		 * constructor.
		 */
		public function FLARMarker (patternId:int, direction:int, confidence:Number, outline:FLARMarkerOutline, transformMatrix:FLARTransMatResult) {
			this._patternId = patternId;
			this._direction = direction;
			this._confidence = confidence;
			this._outline = outline;
			this._transformMatrix = transformMatrix;
		}
		
		/**
		 * copy the properties of a FLARMarker into this FLARMarker.
		 */
		public function copy (otherMarker:FLARMarker) :void {
			this._patternId = otherMarker._patternId;
			this._direction = otherMarker._direction;
			this._confidence = otherMarker._confidence;
			this._outline = otherMarker._outline;
			this._transformMatrix = otherMarker._transformMatrix;
		}
		
		/**
		 * ID of this marker's pattern.
		 * pattern IDs are zero-indexed, and are
		 * assigned to patterns in the order they were initially loaded.
		 */
		public function get patternId () :int {
			return this._patternId;
		}
		
		/**
		 * 
		 */
		public function get direction () :int {
			return this._direction;
		}
		
		/**
		 * 'confidence' is a value assigned by FLARToolkit to each detected marker,
		 * that describes the algorithm's perceived accuracy of the pattern match.
		 */
		public function get confidence () :Number {
			return this._confidence;
		}
		
		/**
		 * FLARMarkerOutline that describes outline of pattern of detected marker.
		 */
		public function get outline () :FLARMarkerOutline {
			return this._outline;
		}
		
		/**
		 * FLARTransMatResult matrix that describes transformation of marker relative to the camera.
		 * apply to FLARBaseNodes that should appear 'tethered' to the marker.
		 */
		public function get transformMatrix () :FLARTransMatResult {
			return this._transformMatrix;
		}
	}
}