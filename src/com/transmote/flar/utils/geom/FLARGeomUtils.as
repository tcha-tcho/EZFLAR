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

package com.transmote.flar.utils.geom {
	import __AS3__.vec.Vector;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jp.nyatla.nyartoolkit.as3.core.transmat.NyARTransMatResult;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.NyARDoubleMatrix34;
	
	import org.libspark.flartoolkit.core.FLARMat;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.utils.ArrayUtil;
	
	/**
	 * collection of utils used for FLAR matrix transformation / conversion.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARGeomUtils {
		private static const RADIANS_TO_DEGREES:Number = 180 / Math.PI;
		private static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
		
		
		/**
		 * calculate a field-of-view to apply to a DisplayObject's perspectiveProjection
		 * that matches the FOV specified by the FLARToolkit camera parameters (FLARCameraParams.dat).
		 * 
		 * NOTE: this is not yet working correctly.
		 */
		public static function calcFOVFromCameraParams (flarCameraParams:FLARParam) :Number {
			var trans_mat:FLARMat = new FLARMat(3,4);
			var icpara_mat:FLARMat = new FLARMat(3,4);
			var p:Array = ArrayUtil.createJaggedArray(3, 3);
			var q:Array = ArrayUtil.createJaggedArray(4, 4);
			var i:int;
			var j:int;
			const size:NyARIntSize = flarCameraParams.getScreenSize();
			const width:int  = size.w;
			const height:int = size.h;
			
			flarCameraParams.getPerspectiveProjectionMatrix().decompMat(icpara_mat, trans_mat);
			
			var icpara:Vector.<Vector.<Number>> = icpara_mat.getArray();
			var trans:Vector.<Vector.<Number>> = trans_mat.getArray();
			for (i = 0; i < 4; i++) {
				icpara[1][i] = (height - 1) * (icpara[2][i]) - icpara[1][i];
			}
			
			for(i = 0; i < 3; i++) {
				for(j = 0; j < 3; j++) {
					p[i][j] = icpara[i][j] / icpara[2][2];
				}
			}
			
			// from sandy FLARCamera3D
			q[0][0] = (2.0 * p[0][0] / (width - 1));
			q[0][1] = (2.0 * p[0][1] / (width - 1));
			q[0][2] = -((2.0 * p[0][2] / (width - 1))  - 1.0);
			q[0][3] = 0.0;

			q[1][0] = 0.0;
			q[1][1] = -(2.0 * p[1][1] / (height - 1));
			q[1][2] = -((2.0 * p[1][2] / (height - 1)) - 1.0);
			q[1][3] = 0.0;

			q[2][0] = 0.0;
			q[2][1] = 0.0;
			q[2][2] = 1.0;
			q[2][3] = 0.0;
			//var NEAR_CLIP:Number = 50, FAR_CLIP:Number = 10000;
			//q[2][2] = -(FAR_CLIP + NEAR_CLIP) / (NEAR_CLIP - FAR_CLIP);
			//q[2][3] = 2.0 * FAR_CLIP * NEAR_CLIP / (NEAR_CLIP - FAR_CLIP);

			q[3][0] = 0.0;
			q[3][1] = 0.0;
			q[3][2] = 1.0;
			q[3][3] = 0.0;

			// more from sandy FLARCamera3D
			var m_projection:Array = new Array(16);
			for (i = 0; i < 4; i++) { // Row.
				// First 3 columns of the current row.
				for (j = 0; j < 3; j++) { // Column.
					m_projection[i*4 + j] =
						q[i][0] * trans[0][j] +
						q[i][1] * trans[1][j] +
						q[i][2] * trans[2][j];
				}
				// Fourth column of the current row.
				m_projection[i*4 + 3]=
					q[i][0] * trans[0][3] +
					q[i][1] * trans[1][3] +
					q[i][2] * trans[2][3] +
					q[i][3];
			}

			// technically q = m_projection at this point, but
			// what if trans would be different?
			trace ("q", q);
			trace ("m", m_projection);
			
			//return 2 * Math.atan(1 / q[1][1]);
			//return 2 * Math.atan(1 / m_projection[5]) * 180 / Math.PI; // <-- in degrees :)

			// http://blog.jactionscripters.com/2009/09/06/calculation-of-focallength/ is the key
			// flash uses horizontal NOT vertical fov
			//return 2 * Math.atan(width / (height * q[1][1])) * 180 / Math.PI;
			return 2 * Math.atan(width / (height * m_projection[5])) * 180 / Math.PI;
		}
		
		/**
		 * convert a FLAR matrix to a Flash Matrix3D.
		 */
		public static function convertFLARMatrixToFlashMatrix3D (fm:NyARDoubleMatrix34, bMirror:Boolean=true) :Matrix3D {
			if (bMirror) {
				return new Matrix3D (Vector.<Number>([
					-fm.m00,	fm.m10,		fm.m20,		0,
					-fm.m01,	fm.m11,		fm.m21,		0,
					fm.m02,		-fm.m12,	-fm.m22,	0,
					-fm.m03,	fm.m13,		fm.m23,		1
					]));
			} else {
				return new Matrix3D (Vector.<Number>([
					fm.m00,		fm.m10,		fm.m20,		0,
					-fm.m01,	-fm.m11,	-fm.m21,	0,
					-fm.m02,	-fm.m12,	-fm.m22,	0,
					fm.m03,		fm.m13,		fm.m23,		1
					]));
			}
		}
		
		/**
		 * convert a FLAR matrix to a Flash Matrix3D.
		 * deprecated: this method is equivalent to convertFLARMatrixToFlashMatrix3D,
		 * and is present only for legacy support.
		 */
		public static function convertFLARMatrixToFlashMatrix (fm:NyARDoubleMatrix34, bMirror:Boolean=true) :Matrix3D {
			return convertFLARMatrixToFlashMatrix3D(fm, bMirror);
		}
		
		/**
		 * calculate rotation around X, Y, and Z axes,
		 * and return stored in a Vector3D instance.
		 * NOTE: does not account for scale, as FLARToolkit matrices always scale equally in all three dimensons.
		 */
		public static function calcFLARMatrixRotations (fm:NyARDoubleMatrix34, bInDegrees:Boolean=true) :Vector3D {
			var rotations:Vector3D = new Vector3D();
			
			rotations.x = Math.atan2(fm.m20, fm.m22);
			rotations.y = Math.asin(-fm.m21);
			rotations.z = Math.atan2(fm.m01, -fm.m11);
			
			if (bInDegrees) {
				rotations.x *= RADIANS_TO_DEGREES;
				rotations.y *= RADIANS_TO_DEGREES;
				rotations.z *= RADIANS_TO_DEGREES;
			}
			
			return rotations;
		}
		
		/**
		 * calculate scale in X, Y, and Z dimensions,
		 * and return stored in a Vector3D instance.
		 * NOTE: FLARToolkit matrices should always scale equally in all three dimensions,
		 * 		 so this method is not likely to be useful.  but, it's here now, so here it stays.
		 */
		public static function calcFLARMatrixScales (fm:NyARDoubleMatrix34) :Vector3D {
			var scales:Vector3D = new Vector3D();
			
			scales.x = Math.sqrt(fm.m01*fm.m01 + fm.m11*fm.m11 + fm.m21*fm.m21);
			scales.y = Math.sqrt(fm.m00*fm.m00 + fm.m10*fm.m10 + fm.m20*fm.m20);
			scales.z = Math.sqrt(fm.m02*fm.m02 + fm.m12*fm.m12 + fm.m22*fm.m22);
			
			return scales;
		}
		
		/**
		 * create an identity matrix as a NyARDoubleMatrix34.
		 */
		public static function createFLARIdentityMatrix () :NyARDoubleMatrix34 {
			var matrix:NyARDoubleMatrix34 = new NyARDoubleMatrix34();
			matrix.m00 = 1;		matrix.m01 = 0;		matrix.m02 = 0;		matrix.m03 = 0;
			matrix.m10 = 0;		matrix.m11 = -1;	matrix.m12 = 0;		matrix.m13 = 0;
			matrix.m20 = 0;		matrix.m21 = 0;		matrix.m22 = -1;	matrix.m23 = 0;
			return matrix;
		}
		
		/**
		 * create an identity matrix as a FLARTransMatResult.
		 */
		public static function createFLARIdentityTransMat () :NyARTransMatResult {
			var matrix:NyARTransMatResult = new NyARTransMatResult();
			matrix.m00 = 1;		matrix.m01 = 0;		matrix.m02 = 0;		matrix.m03 = 0;
			matrix.m10 = 0;		matrix.m11 = -1;	matrix.m12 = 0;		matrix.m13 = 0;
			matrix.m20 = 0;		matrix.m21 = 0;		matrix.m22 = -1;	matrix.m23 = 0;
			return matrix;
		}
		
		/**
		 * format a FLAR matrix as a String.
		 * @param	fm		FLAR matrix to return as a String.
		 * @param	sd		number of significant digits to display.
		 */
		public static function dumpFLARMatrix (fm:NyARDoubleMatrix34, sd:int=4) :String {
			return (fm.m00.toFixed(sd) +"\u0009"+ fm.m01.toFixed(sd) +"\u0009"+ fm.m02.toFixed(sd) +"\u0009"+ fm.m03.toFixed(sd) +"\n"+
					fm.m10.toFixed(sd) +"\u0009"+ fm.m11.toFixed(sd) +"\u0009"+ fm.m12.toFixed(sd) +"\u0009"+ fm.m13.toFixed(sd) +"\n"+
					fm.m20.toFixed(sd) +"\u0009"+ fm.m21.toFixed(sd) +"\u0009"+ fm.m22.toFixed(sd) +"\u0009"+ fm.m23.toFixed(sd));
		}
		
		/**
		 * Format Flash matrix as a String.
		 * @param	matrix	matrix to return as a String.
		 * @param	sd		number of significant digits to display.
		 */
		public static function dumpMatrix3D (matrix:Matrix3D, sd:int=4) :String {
			var m:Vector.<Number> = matrix.rawData;
			return (m[0].toFixed(sd) +"\u0009"+"\u0009"+ m[1].toFixed(sd) +"\u0009"+"\u0009"+ m[2].toFixed(sd) +"\u0009"+"\u0009"+ m[3].toFixed(sd) +"\n"+
					m[4].toFixed(sd) +"\u0009"+"\u0009"+ m[5].toFixed(sd) +"\u0009"+"\u0009"+ m[6].toFixed(sd) +"\u0009"+"\u0009"+ m[7].toFixed(sd) +"\n"+
					m[8].toFixed(sd) +"\u0009"+"\u0009"+ m[9].toFixed(sd) +"\u0009"+"\u0009"+ m[10].toFixed(sd) +"\u0009"+"\u0009"+ m[11].toFixed(sd) +"\n"+
					m[12].toFixed(sd) +"\u0009"+"\u0009"+ m[13].toFixed(sd) +"\u0009"+"\u0009"+ m[14].toFixed(sd) +"\u0009"+"\u0009"+ m[15].toFixed(sd));
		}
		
		public function FLARGeomUtils () {}
	}
}