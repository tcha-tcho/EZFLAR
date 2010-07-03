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

package com.transmote.flar.marker {
	import __AS3__.vec.Vector;
	
	import com.transmote.flar.flarManagerInternal;
	import com.transmote.flar.pattern.FLARPattern;
	import com.transmote.flar.source.IFLARSource;
	import com.transmote.flar.utils.geom.FLARGeomUtils;
	import com.transmote.flar.utils.smoother.IFLARMatrixSmoother;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquare;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARDoublePoint2d;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARLinear;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.NyARDoubleMatrix34;
	
	/**
	 * <p>
	 * Container for information about a detected marker, including:<br>
	 * <ul>
	 * <li>pattern and session ids</li>
	 * <li>centerpoint of marker</li>
	 * <li>corners of marker outline</li>
	 * <li>Vector3D instance that describes x, y, and z location, and rotation (in the z-axis) of marker</li>
	 * <li>rotation of marker around x, y, and z axes</li>
	 * </ul>
	 * </p>
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 * @see		com.transmote.flar.marker.FLARMarkerEvent
	 */
	public class FLARMarker {
		private static const MAX_ADAPTIVE_SMOOTHING:Number = 15;
		private static const LOW_SPEED_EXPONENT:Number = 1.25;
		private static const HIGH_SPEED_EXPONENT:Number = 0.75;
		
		private static var sessionIdCounter:uint = 0;
		
		internal var _flarSource:IFLARSource;
		internal var _flarPattern:FLARPattern;
		
		internal var _sessionId:int = -1;
		internal var _patternId:int;
		internal var _confidence:Number;
		
		internal var _direction:int;
		internal var _flarSquare:NyARSquare;
		internal var _transformMatrix:NyARDoubleMatrix34;
		
		internal var _centerpoint2D:Point = null;
		internal var _centerpoint3D:Point = null;
		internal var _vector3D:Vector3D = null;
		internal var _rotationX:Number = NaN;
		internal var _rotationY:Number = NaN;
		internal var _rotationZ:Number = NaN;
		
		private var _corners:Vector.<Point>;
		private var _velocity:Vector3D;
		private var rotations:Vector3D;
		private var rotationSpeeds:Vector3D;
		
		private var removalAge:uint = 0;
		private var screenCenter:Point;
		private var matrixHistory:Vector.<NyARDoubleMatrix34>;
		
		/**
		 * constructor.
		 */
		public function FLARMarker (
			transformMatrix:NyARDoubleMatrix34, flarSource:IFLARSource, flarPattern:FLARPattern,
			patternId:int, direction:int, square:NyARSquare, confidence:Number) {
			this._patternId = patternId;
			this._direction = direction;
			this._flarSquare = square;
			this._confidence = confidence;
			this._transformMatrix = transformMatrix;
			this._flarSource = flarSource;
			this._flarPattern = flarPattern;
			this._velocity = new Vector3D();
			
			if (this._flarSource.mirrored) {
				this.mirror();
			}
			
			this.screenCenter = new Point(0.5*this._flarSource.sourceSize.width, 0.5*this._flarSource.sourceSize.height);
			this.calcCorners();
		}
		
		
		//-----<ACCESSORS: MARKER METADATA>--------------------------//
		/**
		 * ID unique to this marker in this session.
		 * no two markers in a session share the same sessionId.
		 */
		public function get sessionId () :uint {
			return this._sessionId;
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
		 * 'confidence' is a value assigned by FLARToolkit to each detected marker,
		 * that describes the algorithm's perceived accuracy of the pattern match.
		 */
		public function get confidence () :Number {
			return this._confidence;
		}
		//-----<END ACCESSORS: MARKER METADATA>----------------------//
		
		
		
		//-----<ACCESSORS: MARKER POSITION AND ORIENTATION>----------//
		/**
		 * closest orthographic orientation of detected marker.
		 * value between 0 and 3, inclusive:
		 * 0: up
		 * 1: left
		 * 2: down
		 * 3: right
		 */
		public function get direction () :int {
			return this._direction;
		}
		
		/**
		 * FLARSquare instance used to create this FLARMarker instance.
		 * can be accessed if direct access to FLARToolkit output is desired;
		 * no downsampling correction is applied.
		 */
		public function get flarSquare () :NyARSquare {
			return this._flarSquare;
		}
		
		/**
		 * a Vector of four Points that describe the four points of the detected marker's outline.
		 */
		public function get corners () :Vector.<Point> {
			return this._corners;
		}
		
		/**
		 * NyARDoubleMatrix34 matrix that describes transformation of marker relative to the camera.
		 * apply to FLARBaseNodes that should appear 'tethered' to the marker.
		 */
		public function get transformMatrix () :NyARDoubleMatrix34 {
			return this._transformMatrix;
		}
		
		/**
		 * return the transformation matrix of this FLARMarker
		 * as a Flash Matrix object, for applying 2D transformations to Flash DisplayObject instances.
		 * to apply to a DisplayObject, set displayObject.transform.matrix = flarMarker.matrix2D.
		 */
		public function get matrix2D () :Matrix {
			var matrix:Matrix = new Matrix();
			var rotation:Number = Math.atan2(this.transformMatrix.m01, -this.transformMatrix.m11);
			if (this._flarSource.mirrored) { rotation = 2*Math.PI - rotation; }
			
			matrix.translate(-0.5*this._flarPattern.unscaledMarkerWidth, -0.5*this._flarPattern.unscaledMarkerWidth);
			matrix.rotate(rotation);
			matrix.scale(this.scale2D, this.scale2D);
			matrix.translate(this.x, this.y);
			
			return matrix;
		}
		
		/**
		 * return the transformation matrix of this FLARMarker
		 * as a Flash Matrix3D object, for applying 3D transformations to Flash DisplayObject instances.
		 * to apply to a DisplayObject, set displayObject.transform.matrix3D = flarMarker.matrix3D.
		 */
		public function get matrix3D () :Matrix3D {
			var matrix3D:Matrix3D = FLARGeomUtils.convertFLARMatrixToFlashMatrix3D(this._transformMatrix, this._flarSource.mirrored);
			matrix3D.prependTranslation(-0.5*this._flarPattern.unscaledMarkerWidth, -0.5*this._flarPattern.unscaledMarkerWidth, 0);
			matrix3D.appendTranslation(this.x, this.y, 0);
			return matrix3D;
		}
		
		/**
		 * return x coordinate of marker.
		 */
		public function get x () :Number {
			return this.centerpoint.x;
		}
		
		/**
		 * return y coordinate of marker.
		 */
		public function get y () :Number {
			return this.centerpoint.y;
		}
		
		/**
		 * return z coordinate of marker.
		 */
		public function get z () :Number {
			return this._transformMatrix.m23;
		}
		
		/**
		 * centerpoint of marker outline in the 2D space of the screen,
		 * calculated as the average of the outline's four corner points.
		 * to access the centerpoint reported by FLARToolkit in three dimensions,
		 * use FLARMarker.centerpoint.
		 */
		public function get centerpoint () :Point {
			if (!this._centerpoint2D) {
				this._centerpoint2D = this.calcCenterpoint2D();
			}
			return this._centerpoint2D;
		}
		
		/**
		 * centerpoint of marker outline extracted from FLARToolkit transformation matrix.
		 * this centerpoint is determined based on the 3D location of the detected marker,
		 * and is used by FLARManager in 3D calculations.
		 * to avoid having to correct for Z location, use centerpoint2D.
		 */
		public function get centerpoint3D () :Point {
			if (!this._centerpoint3D) {
				this._centerpoint3D = this.calcCenterpoint3D(this._transformMatrix);
			}
			return this._centerpoint3D;
		}
		
		/**
		 * returns centerpoint at location toward which this FLARMarker is moving
		 * (target location at end of smoothing animation).
		 */
		public function get targetCenterpoint3D () :Point {
			if (!this.matrixHistory) {
				return this.centerpoint3D;
			}
			
			// find most recent stored transformation matrix
			var i:int = this.matrixHistory.length - 1;
			while (this.matrixHistory[i] == null) {
				i--;
				if (i == -1) {
					return this.centerpoint3D;
				}
			}
						
			return this.calcCenterpoint3D(this.matrixHistory[i]);
		}
		
		/**
		 * Vector3D instance that describes x, y, and z coordinates,
		 * as well as rotationZ (stored as vector3D.w).
		 */
		public function get vector3D () :Vector3D {
			if (!this._vector3D) {
				if (this._transformMatrix) {
					this._vector3D = new Vector3D(this.x, this.y, this.z, this.rotation2D);
				} else {
					// no transformMatrix when using FLARProxy
					this._vector3D = new Vector3D(this.centerpoint.x, this.centerpoint.y, 0, 0);
				}
			}
			return this._vector3D;
		}
		
		/**
		 * rotation of marker along X axis.
		 */
		public function get rotationX () :Number {
			if (!this.rotations) {
				this.calcRotations();
			}
			return this.rotations.x;
		}
		
		/**
		 * rotation of marker along Y axis.
		 */
		public function get rotationY () :Number {
			if (!this.rotations) {
				this.calcRotations();
			}
			return this.rotations.y;
		}
		
		/**
		 * rotation of marker along Z axis.
		 */
		public function get rotationZ () :Number {
			if (!this.rotations) {
				this.calcRotations();
			}
			return this.rotations.z;
		}
		
		/**
		 * returns the rotation of the marker in 2D.
		 * this method is equivalent to rotationZ.
		 */
		public function get rotation2D () :Number {
			if (!this.rotations) {
				this.calcRotations();
			}
			return this.rotations.z;
		}
		
		/**
		 * returns the scale of the marker for use in 2D applications.
		 */
		public function get scale2D () :Number {
			var diag1:Number = Point.distance(this.corners[0], this.corners[2]);
			var diag2:Number = Point.distance(this.corners[1], this.corners[3]);
			var size:Number = Math.sqrt(0.25 * (diag1*diag1 + diag2*diag2));
			return (size / this._flarPattern.unscaledMarkerWidth);
		}
		//-----<ACCESSORS: MARKER POSITION AND ORIENTATION>----------//
		
		
		
		//-----<ACCESSORS: MARKER MOTION>----------------------------//
		/**
		 * Vector3D instance that describes change between the previous and current frames
		 * in x, y, and z coordinates, as well as change in rotationZ (stored as vector3D.w).
		 */
		public function get velocity () :Vector3D {
			return this._velocity;
		}
		
		/**
		 * length of the marker's (x,y) motion vector
		 * between the previous and current frames.
		 */
		public function get motionSpeed2D () :Number {
			return Math.sqrt(this._velocity.x*this._velocity.x + this._velocity.y*this._velocity.y);
		}
		
		/**
		 * direction (in degrees) of the marker's (x,y) motion
		 * between the previous and current frames.
		 */
		public function get motionDirection2D () :Number {
			return 180 * Math.atan2(this._velocity.y, this._velocity.x) / Math.PI;
		}
		
		/**
		 * amount of change (in degrees) in the marker's rotation along the x-axis
		 * between the previous and current frames.
		 */
		public function get rotationSpeedX () :Number {
			return this.rotationSpeeds.x;
		}
		
		/**
		 * amount of change (in degrees) in the marker's rotation along the y-axis
		 * between the previous and current frames.
		 */
		public function get rotationSpeedY () :Number {
			return this.rotationSpeeds.y;
		}
		
		/**
		 * amount of change (in degrees) in the marker's rotation along the z-axis
		 * between the previous and current frames.
		 */
		public function get rotationSpeedZ () :Number {
			return this.rotationSpeeds.z;
		}
		//-----<END ACCESSORS: MARKER MOTION>------------------------//
		
		
		
		//-----<PUBLIC METHODS>--------------------------------------//
		/**
		 * copy the properties of a FLARMarker into this FLARMarker.
		 * FLARMarkers are updated across frames by
		 * copying the properties of newly-detected markers.
		 */
		public function copy (otherMarker:FLARMarker) :void {
			this.calcRotationSpeeds(otherMarker);
			this.calcVelocity(otherMarker);
			
			this._patternId = otherMarker._patternId;
			this._direction = otherMarker._direction;
			this._flarSquare = otherMarker._flarSquare;
			this._confidence = otherMarker._confidence;
			this._transformMatrix = otherMarker._transformMatrix;
			this._flarSource = otherMarker._flarSource;
			this._flarPattern = otherMarker._flarPattern;
			
			this.resetAllCalculations();
		}
		
		/**
		 * free this FLARMarker instance up for garbage collection.
		 */
		public function dispose () :void {
			this._flarSquare = null;
			this._transformMatrix = null;
			this._flarSource = null;
			this._flarPattern = null;
			this.matrixHistory = null;
			this._centerpoint2D = null;
			this._centerpoint3D = null;
			this._vector3D = null;
			this.rotations = null;
			this.rotationSpeeds = null;
			this._corners = null;
			this._velocity = null;
		}
		
		public function toString () :String {
			return ("FLARMarker [sId:"+ this.sessionId +", patternId:"+ this.patternId +"]");
		}
		//-----<END PUBLIC METHODS>----------------------------------//
		
		
		
		//-----<flarManagerInternal METHODS>-------------------------//
		/**
		 * apply smoothing algorithm over a number of frames.
		 * called by FLARManager as part of marker tracking/maintenance process.
		 */
		flarManagerInternal function applySmoothing (smoother:IFLARMatrixSmoother, numFrames:int, adaptiveSmoothingCenter:Number) :void {
			if (adaptiveSmoothingCenter > 0) {
				numFrames = this.adaptSmoothing(numFrames, adaptiveSmoothingCenter);
			}
			
			if (numFrames == 0) {
				this.matrixHistory = null;
				return;
			}
			
			if (!this.matrixHistory) {
				this.matrixHistory = new Vector.<NyARDoubleMatrix34>(numFrames, false);
			} else if (this.matrixHistory.length != numFrames) {
				// remove null values from array before changing size,
				// to insure no information is lost.
				var i:int = this.matrixHistory.length;
				var j:int;
				while (i-- > 0) {
					if (this.matrixHistory[i] != null) { continue; }
					j = i;
					while (j--) {
						if (this.matrixHistory[j] != null || j==-1) { break; }
					}
					this.matrixHistory.splice(j+1, i-j);
					i = j;
				}
				
				this.matrixHistory.length = numFrames;
			}
			
			for (i=0; i<numFrames-1; i++) {
				if (this.matrixHistory[i+1]) {
					// only copy non-null matrices, to avoid discarding matrices with data.
					this.matrixHistory[i] = this.matrixHistory[i+1];
				}
			}
			this.matrixHistory[i] = this._transformMatrix;
			
			this._transformMatrix = smoother.smoothMatrices(this.matrixHistory);
		}
		
		flarManagerInternal function setSessionId () :void {
			// called only by FLARManager, when a new FLARMarker is detected.
			if (this._sessionId == -1) {
				this._sessionId = FLARMarker.sessionIdCounter++;
			}
		}
		
		flarManagerInternal function resetRemovalAge () :void {
			// removal age is the number of frames that have elapsed
			// since this FLARMarker was last detected by FLARToolkit.
			this.removalAge = 0;
		}
		
		flarManagerInternal function ageAfterRemoval () :uint {
			// removal age is the number of frames that have elapsed
			// since this FLARMarker was last detected by FLARToolkit.
			// also extrapolates marker velocity to approximate new location.
			this.removalAge++;
			this.transformMatrix.m03 += this.velocity.x;
			this.transformMatrix.m13 += this.velocity.y;
			this.transformMatrix.m23 += this.velocity.z;
			return this.removalAge;
		}
		//-----<END flarManagerInternal METHODS>---------------------//
		
		
		
		//-----<PRIVATE METHODS>-------------------------------------//
		private function mirror () :void {
			const sourceWidth:Number = this._flarSource.sourceSize.width;
			
			// mirror FLARSquare
			var i:int = 4;
			var flarCorner:NyARDoublePoint2d;
			var flarLine:NyARLinear;
			while (i--) {
				flarCorner = NyARDoublePoint2d(this.flarSquare.sqvertex[i]);
				flarCorner.x = sourceWidth - flarCorner.x;
				
				// NOTE: flarLine mirroring is untested.
				flarLine = NyARLinear(this.flarSquare.line[i]);
				flarLine.dx *= -1;
			}
		}
		
		private function adaptSmoothing (numFrames:int, adaptiveSmoothingCenter:Number) :int {
			// evaluate marker speeds ((x,y,z) and rotationX/Y/Z) against adaptiveSmoothingCenter.
			// if speed is less, apply more smoothing; if speed is more, apply less smoothing.
			// choose lowest amount smoothing from four results, to ensure responsiveness during motion.
			var speeds:Vector.<Number> = Vector.<Number>([this.motionSpeed2D, this.velocity.z, this.rotationSpeeds.x, this.rotationSpeeds.y, this.rotationSpeeds.z]);
			speeds.fixed = true;
			var speed:Number;
			var smoothing:Number;
			var leastSmoothing:Number = MAX_ADAPTIVE_SMOOTHING;
			for (var i:int=0; i<speeds.length; i++) {
				speed = Math.abs(speeds[i]);
				if (speed < adaptiveSmoothingCenter) {
					smoothing = numFrames + Math.pow((adaptiveSmoothingCenter-speed), LOW_SPEED_EXPONENT);
					smoothing = Math.min(MAX_ADAPTIVE_SMOOTHING, smoothing);
				} else {
					smoothing = numFrames - Math.pow((speed-adaptiveSmoothingCenter), HIGH_SPEED_EXPONENT);
					smoothing = Math.max(0, smoothing);
				}
				
				leastSmoothing = Math.min(smoothing, leastSmoothing);
			}
			
			var speedsStr:String = "";
			for (i=0; i<speeds.length; i++) { 
				speedsStr += Math.floor(Math.abs(speeds[i])) +" ";
			}
			//trace("speeds:"+speedsStr+"| smoothing:"+Math.floor(leastSmoothing));
			
			return Math.floor(leastSmoothing);
		}
		
		private function calcCenterpoint2D () :Point {
			var x:Number = 0;
			var y:Number = 0;
			var i:int = 4;
			while (i--) {
				x += this.corners[i].x;
				y += this.corners[i].y;
			}
			return new Point(0.25*x, 0.25*y);
		}
		
		private function calcCenterpoint3D (matrix:NyARDoubleMatrix34) :Point {
			var centerPt:Point = new Point(this.screenCenter.x + matrix.m03, this.screenCenter.y + matrix.m13);
			centerPt.x /= this._flarSource.resultsToDisplayRatio;
			centerPt.y /= this._flarSource.resultsToDisplayRatio;
			return centerPt;
		}
		
		private function calcCorners () :void {
			this._corners = new Vector.<Point>(4);
			var i:int = 4;
			var flarCorner:NyARDoublePoint2d;
			while (i--) {
				flarCorner = NyARDoublePoint2d(this.flarSquare.sqvertex[i]);
				this._corners[i] = new Point(flarCorner.x / this._flarSource.resultsToDisplayRatio, flarCorner.y / this._flarSource.resultsToDisplayRatio);
			}
		}
		
		private function calcRotations () :void {
			this.rotations = FLARGeomUtils.calcFLARMatrixRotations(this._transformMatrix);
			
			if (this._flarSource.mirrored) {
				this.rotations.z = 180 - this.rotations.z; 
			}
		}
		
		private function calcRotationSpeeds (newMarker:FLARMarker) :void {
			var dRotX:Number = newMarker.rotationX - this.rotationX;
			if (dRotX > 180) { dRotX -= 360; }
			else if (dRotX < -180) { dRotX += 360; }
			var dRotY:Number = newMarker.rotationY - this.rotationY;
			if (dRotY > 180) { dRotY -= 360; }
			else if (dRotY < -180) { dRotY += 360; }
			var dRotZ:Number = newMarker.rotationZ - this.rotationZ;
			if (dRotZ > 180) { dRotZ -= 360; }
			else if (dRotZ < -180) { dRotZ += 360; }
			
			this.rotationSpeeds = new Vector3D(
				dRotX,
				dRotY,
				dRotZ,
				0
			);
		}
		
		private function calcVelocity (newMarker:FLARMarker) :void {
			this._velocity = new Vector3D(newMarker.x-this.x, newMarker.y-this.y, newMarker.z-this.z, this.rotationSpeeds.z);
		}
		
		private function resetAllCalculations () :void {
			this._centerpoint2D = null;
			this._centerpoint3D = null;
			this._vector3D = null;
			this.rotations = null;
			this.calcCorners();
		}
		//-----<END PRIVATE METHODS>---------------------------------//
	}
}