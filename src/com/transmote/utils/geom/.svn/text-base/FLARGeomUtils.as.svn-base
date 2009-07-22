package com.transmote.utils.geom {
	import flash.geom.Matrix3D;
	
	import org.libspark.flartoolkit.core.types.matrix.FLARDoubleMatrix34;
	
	/**
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARGeomUtils {
		
		public static function translateFLARMatrixToFlashMatrix (fm:FLARDoubleMatrix34) :Matrix3D {
			return new Matrix3D (Vector.<Number>([
				fm.m01,		fm.m00,		fm.m02,		fm.m03,
				-fm.m11,	-fm.m10,	-fm.m12,	-fm.m13,
				fm.m21,		fm.m20,		fm.m22,		fm.m23,
				0,			0,			0,			0
				]));
		}
		
		public function FLARGeomUtils () {}
	}
}