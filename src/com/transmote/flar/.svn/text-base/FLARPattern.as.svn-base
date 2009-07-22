package com.transmote.flar {
	
	/**
	 * wrapper for all information needed by FLARToolkit to track an individual marker.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARPattern {
		internal var _filename:String;
		internal var _resolution:int;
		internal var _patternToBorderRatio:Number;
		internal var _unscaledMarkerWidth:Number;
		internal var _minConfidence:Number;
		
		/**
		 * constructor.
		 * 
		 * @param	filename				location of marker pattern file.
		 * @param	resolution				resolution (width/height) of marker pattern file.
		 * @param	patternToBorderRatio	out of the entire width/height of a marker, the amount that
		 * 									the pattern occupies relative to the amount the border occupies.
		 * 									value is expressed as a percentage.
		 * 									for example, a value of 50 indicates that the width of the pattern area
		 * 									is equal to the total width (on either side of the pattern) of the border.
		 * 									defaults to 50.
		 * @param	unscaledMarkerWidth		the width of a marker (in pixels) on-screen at which
		 * 									the scale of its transformation matrix is 1.0.
		 * 									defaults to 80.
		 * @param	minConfidence			'confidence' is a value assigned by FLARToolkit to each detected marker,
		 * 									that describes the algorithm's perceived accuracy of the pattern match.
		 * 									this value sets the minimum confidence required to signal a recognized marker.
		 * 									defaults to 0.5.
		 */
		public function FLARPattern (filename:String, resolution:int, patternToBorderRatio:Number=50, unscaledMarkerWidth:Number=80, minConfidence:Number=0.5) {
			this._filename = filename;
			this._resolution = resolution;
			this._patternToBorderRatio = patternToBorderRatio;
			this._unscaledMarkerWidth = unscaledMarkerWidth;
			this._minConfidence = minConfidence;
		}
		
		/**
		 * location of marker pattern file.
		 */
		public function get filename () :String {
			return this._filename;
		}
		
		/**
		 * resolution (width/height) of marker pattern file.
		 */
		public function get resolution () :Number {
			return this._resolution;
		}
		
		/**
		 * out of the entire width/height of a marker, the amount that
		 * the pattern occupies relative to the amount the border occupies.
		 * value is expressed as a percentage.
		 * for example, a value of 50 indicates that the width of the pattern area
		 * is equal to the total width (on either side of the pattern) of the border.
		 */
		public function get patternToBorderRatio () :Number {
			return this._patternToBorderRatio;
		}
		/**
		 * the width of a marker (in pixels) on-screen at which
		 * the scale of its transformation matrix is 1.0.
		 */
		public function get unscaledMarkerWidth () :Number {
			return this._unscaledMarkerWidth;
		}
		
		/**
		 * 'confidence' is a value assigned by FLARToolkit to each detected marker,
		 * that describes the algorithm's perceived accuracy of the pattern match.
		 * this value sets the minimum confidence required to signal a recognized marker.
		 */
		public function get minConfidence () :Number {
			return this._minConfidence;
		}
		public function set minConfidence (val:Number) :void {
			this._minConfidence = val;
		}
	}
}