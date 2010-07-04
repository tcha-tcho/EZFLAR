/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
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
 * For further information please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */

package org.libspark.flartoolkit.support.away3d_lite {
	import away3dlite.arcane;
	import away3dlite.cameras.Camera3D;
	
	import flash.geom.Matrix3D;
	
	import jp.nyatla.nyartoolkit.as3.core.param.NyARPerspectiveProjectionMatrix;
	
	import org.libspark.flartoolkit.core.param.FLARParam;
	
	use namespace arcane;
	
	/**
	 * Camera3D subclass for use with FLARToolkit.
	 * many thanks to Mikael Emtinger for figuring this one out.
	 */
	public class FLARCamera3D extends Camera3D {
		private var projectionData:Vector.<Number>;
		private var flarProjectionMatrix:Matrix3D;
		
		/**
		 * @param	flarParams					camera parameters data, e.g. from FLARCameraParams.dat / camera_para.dat
		 * @param	viewportToSourceWidthRatio	ratio of Away3DLite scene to FLAR bitmap source,
		 * 										used to scale calculations between FLARToolkit and Away3DLite.
		 * 										Flash native 3D uses a horizontal FOV, so only the width ratio is needed.
		 * 										see: http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS36223081-8938-4b45-BB89-F1F8B1A52E4E.html
		 */
		public function FLARCamera3D (flarParams:FLARParam, viewportToSourceWidthRatio:Number) :void {
			super();
			this.x = 0;
			this.y = 0;
			this.z = 0;
			
			var fm:NyARPerspectiveProjectionMatrix = flarParams.getPerspectiveProjectionMatrix();
			this.flarProjectionMatrix = new Matrix3D(Vector.<Number>([
					fm.m00*viewportToSourceWidthRatio,	fm.m01,	0,	fm.m03,
					fm.m10,	fm.m11*viewportToSourceWidthRatio,	0,	fm.m13,
					fm.m20,	fm.m21,	fm.m22,	1,
					0,		0,		0,		0
				]));
			
		}
		
		/**
		 * Returns the 3d matrix representing the camera projection for the view.
		 * @see away3dlite.containers.View3D#render()
		 */
		public override function get projectionMatrix3D () :Matrix3D {
			return this.flarProjectionMatrix;
		}
	}
}