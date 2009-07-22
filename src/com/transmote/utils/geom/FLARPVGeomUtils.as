package com.transmote.utils.geom {
	import org.libspark.flartoolkit.core.types.matrix.FLARDoubleMatrix34;
	import org.papervision3d.core.math.Matrix3D;
	
	/**
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARPVGeomUtils {
		
		public static function translateFLARMatrixToPVMatrix (fm:FLARDoubleMatrix34) :Matrix3D {
			return new org.papervision3d.core.math.Matrix3D ([
				fm.m01,		fm.m00,		fm.m02,		fm.m03,
				-fm.m11,	-fm.m10,	-fm.m12,	-fm.m13,
				fm.m21,		fm.m20,		fm.m22,		fm.m23,
				0,			0,			0,			0
				]);
		}
		
		public function FLARPVGeomUtils () {}
	}
}