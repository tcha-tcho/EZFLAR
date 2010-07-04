/**
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
 * Contributors
 *  rokubou
 * 
 * !!ATTENTION!!
 *  This is a source code while experimenting. 
 *  I want you to teach when there is a good correction method. 
 */

package org.libspark.flartoolkit.support.away3d_lite {
	import away3dlite.containers.ObjectContainer3D;
	
	import flash.geom.Matrix3D;
	
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	
	public class FLARBaseNode extends ObjectContainer3D {
		
		public function FLARBaseNode(...initarray) {
			super();
		}
		
		public function setTransformMatrix(r:FLARTransMatResult):void {
//			var m:Matrix3D = new Matrix3D(Vector.<Number>([
//					 r.m00,	 r.m10,	 r.m20, 0,
//					-r.m01,	-r.m11,	-r.m21, 0,
//					-r.m02,	-r.m12,	-r.m22, 0,
//					 r.m03,	 r.m13,	 r.m23, 1
//					]));
			var m:Matrix3D = new Matrix3D(Vector.<Number>([
					 r.m00,	 r.m10,	 r.m20, 0,
					-r.m02,	-r.m12,	-r.m22, 0,
					 r.m01,	 r.m11,	 r.m21, 0,
					 r.m03,	 r.m13,	 r.m23, 1
					]));
			this.transform.matrix3D = m;
		}
	}
}