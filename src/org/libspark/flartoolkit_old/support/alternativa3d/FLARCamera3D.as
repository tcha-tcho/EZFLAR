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

package org.libspark.flartoolkit.support.alternativa3d {
	
	import alternativa.engine3d.core.Camera3D;
	import alternativa.types.Matrix3D;
	
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;
	
	import org.libspark.flartoolkit.core.FLARMat;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.utils.ArrayUtil;

	public class FLARCamera3D extends Camera3D {
		
		private var _projectionMatrix:Matrix3D;
		
		public function FLARCamera3D(name:String=null)
		{
			super(name);
		}

		public function setParam(param:FLARParam):void
		{
			
			const size:NyARIntSize = param.getScreenSize ();
			const tMat:FLARMat = new FLARMat (3, 4);
			const iMat:FLARMat = new FLARMat (3, 4);
			param.getPerspectiveProjectionMatrix ().decompMat (iMat, tMat);
			const i:Vector.<Vector.<Number>> = iMat.getArray ();
			const t:Vector.<Vector.<Number>> = tMat.getArray ();
			const h1:Number = size.h - 1;
			const p11:Number = (h1 * i[2][1] - i[1][1]) / i[2][2];
			const p12:Number = (h1 * i[2][2] - i[1][2]) / i[2][2];
			const q11:Number = -(2 * p11 / h1);
			const q12:Number = -(2 * p12 / h1) + 1.0;
			const mp5:Number = q11 * t[1][1] + q12 * t[2][1];
			const tan:Number = 1 / mp5 * Math.sqrt (size.w * size.w + size.h * size.h) / size.h;

			this.fov = 2 * Math.atan (tan);
		}
	}
}