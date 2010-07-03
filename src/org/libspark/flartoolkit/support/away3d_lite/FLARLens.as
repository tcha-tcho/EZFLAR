package org.libspark.flartoolkit.support.away3d_lite {
	import away3dlite.arcane;
	import away3dlite.cameras.lenses.AbstractLens;
	
	import flash.geom.Matrix3D;
	
	use namespace arcane;
	
	public class FLARLens extends AbstractLens {
		private var flarProjectionMatrix:Matrix3D;
				
		public function FLARLens (flarProjectionMatrix:Matrix3D) {
			this.flarProjectionMatrix = flarProjectionMatrix;
			super();
		}
		
		arcane override function _update () :void {
			_projectionMatrix3D = this.flarProjectionMatrix;
		}
	}
}