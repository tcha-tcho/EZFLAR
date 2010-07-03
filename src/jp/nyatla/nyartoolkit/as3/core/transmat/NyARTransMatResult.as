/* 
 * PROJECT: NyARToolkitAS3
 * --------------------------------------------------------------------------------
 * This work is based on the original ARToolKit developed by
 *   Hirokazu Kato
 *   Mark Billinghurst
 *   HITLab, University of Washington, Seattle
 * http://www.hitl.washington.edu/artoolkit/
 *
 * The NyARToolkitAS3 is AS3 edition ARToolKit class library.
 * Copyright (C)2010 Ryo Iizuka
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * For further information please contact.
 *	http://nyatla.jp/nyatoolkit/
 *	<airmail(at)ebony.plala.or.jp> or <nyatla(at)nyatla.jp>
 * 
 */
package jp.nyatla.nyartoolkit.as3.core.transmat
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	public class NyARTransMatResult extends NyARDoubleMatrix34
	{
		/**
		 * エラーレート。この値はINyARTransMatの派生クラスが使います。
		 */
		public var error:Number;	
		public var has_value:Boolean = false;
		/**
		 * この関数は、0-PIの間で値を返します。
		 * @param o_out
		 */
		public function getZXYAngle(o_out:NyARDoublePoint3d):void
		{
			var sina:Number = this.m21;
			if (sina >= 1.0) {
				o_out.x = Math.PI / 2;
				o_out.y = 0;
				o_out.z = Math.atan2(-this.m10, this.m00);
			} else if (sina <= -1.0) {
				o_out.x = -Math.PI / 2;
				o_out.y = 0;
				o_out.z = Math.atan2(-this.m10, this.m00);
			} else {
				o_out.x = Math.asin(sina);
				o_out.z = Math.atan2(-this.m01, this.m11);
				o_out.y = Math.atan2(-this.m20, this.m22);
			}
		}
		public function transformVertex_Number(i_x:Number,i_y:Number,i_z:Number,o_out:NyARDoublePoint3d):void
		{
			o_out.x=this.m00*i_x+this.m01*i_y+this.m02*i_z+this.m03;
			o_out.y=this.m10*i_x+this.m11*i_y+this.m12*i_z+this.m13;
			o_out.z=this.m20*i_x+this.m21*i_y+this.m22*i_z+this.m23;
			return;
		}
		public function transformVertex_NyARDoublePoint3d(i_in:NyARDoublePoint3d,o_out:NyARDoublePoint3d):void
		{
			transformVertex_Number(i_in.x,i_in.y,i_in.z,o_out);
		}
	}

}