package com.transmote.flar {
	import flash.geom.Point;
	
	import org.libspark.flartoolkit.core.FLARSquare;
	import org.libspark.flartoolkit.core.labeling.FLARLabelingLabel;
	
	/**
	 * wrapper for FLARSquare that provides:
	 * - centerpoint of outline;
	 * - a more accurately descriptive name.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARMarkerOutline extends FLARSquare {
		internal var _centerpoint:Point;
		
		/**
		 * constructor.
		 */
		public function FLARMarkerOutline (line:Array, sqvertex:Array, imvertex:Array, label:FLARLabelingLabel) {
			super();
			this.line = line;
			this.sqvertex = sqvertex;
			this.imvertex = imvertex;
			this.label = label;
			
			this._centerpoint = new Point(
					0.25 * (this.sqvertex[0].x + this.sqvertex[1].x + this.sqvertex[2].x + this.sqvertex[3].x),
					0.25 * (this.sqvertex[0].y + this.sqvertex[1].y + this.sqvertex[2].y + this.sqvertex[3].y));
		}
		
		/**
		 * centerpoint of marker outline;
		 * calculated as average of four corner points.
		 */
		public function get centerpoint () :Point {
			return this._centerpoint;
		}
	}
}