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
package jp.nyatla.nyartoolkit.as3.core.types.matrix
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	public class NyARDoubleMatrix33 implements INyARDoubleMatrix
	{
		public var m00:Number;
		public var m01:Number;
		public var m02:Number;
		public var m10:Number;
		public var m11:Number;
		public var m12:Number;
		public var m20:Number;
		public var m21:Number;
		public var m22:Number;
		public static function createArray(i_number:int):Vector.<NyARDoubleMatrix33>
		{
			var ret:Vector.<NyARDoubleMatrix33>=new Vector.<NyARDoubleMatrix33>(i_number);
			for(var i:int=0;i<i_number;i++)
			{
				ret[i]=new NyARDoubleMatrix33();
			}
			return ret;
		}
		/**
		 * 遅いからあんまり使わないでね。
		 */
		public function setValue(i_value:Vector.<Number>):void
		{
			this.m00=i_value[0];
			this.m01=i_value[1];
			this.m02=i_value[2];
			this.m10=i_value[3];
			this.m11=i_value[4];
			this.m12=i_value[5];
			this.m20=i_value[6];
			this.m21=i_value[7];
			this.m22=i_value[8];
			return;
		}
		public function setValue_NyARDoubleMatrix33(i_value:NyARDoubleMatrix33):void
		{
			this.m00=i_value.m00;
			this.m01=i_value.m01;
			this.m02=i_value.m02;
			this.m10=i_value.m10;
			this.m11=i_value.m11;
			this.m12=i_value.m12;
			this.m20=i_value.m20;
			this.m21=i_value.m21;
			this.m22=i_value.m22;
			return;
		}	
		/**
		 * 遅いからあんまり使わないでね。
		 */
		public function getValue(o_value:Vector.<Number>):void
		{
			o_value[0]=this.m00;
			o_value[1]=this.m01;
			o_value[2]=this.m02;
			o_value[3]=this.m10;
			o_value[4]=this.m11;
			o_value[5]=this.m12;
			o_value[6]=this.m20;
			o_value[7]=this.m21;
			o_value[8]=this.m22;
			return;
		}
		public function inverse(i_src:NyARDoubleMatrix33):Boolean
		{
			var a11:Number,a12:Number,a13:Number,a21:Number,a22:Number,a23:Number,a31:Number,a32:Number,a33:Number;
			var b11:Number,b12:Number,b13:Number,b21:Number,b22:Number,b23:Number,b31:Number,b32:Number,b33:Number;	
			a11=i_src.m00;a12=i_src.m01;a13=i_src.m02;
			a21=i_src.m10;a22=i_src.m11;a23=i_src.m12;
			a31=i_src.m20;a32=i_src.m21;a33=i_src.m22;
			
			b11=a22*a33-a23*a32;
			b12=a32*a13-a33*a12;
			b13=a12*a23-a13*a22;
			
			b21=a23*a31-a21*a33;
			b22=a33*a11-a31*a13;
			b23=a13*a21-a11*a23;
			
			b31=a21*a32-a22*a31;
			b32=a31*a12-a32*a11;
			b33=a11*a22-a12*a21;
					
			var det_1:Number=a11*b11+a21*b12+a31*b13;
			if(det_1==0){
				return false;
			}
			det_1=1/det_1;

			this.m00=b11*det_1;
			this.m01=b12*det_1;
			this.m02=b13*det_1;
			
			this.m10=b21*det_1;
			this.m11=b22*det_1;
			this.m12=b23*det_1;
			
			this.m20=b31*det_1;
			this.m21=b32*det_1;
			this.m22=b33*det_1;
			
			return true;
		}
		/**
		 * この関数は、0-PIの間で値を返します。
		 * @param o_out
		 */
		public final function getZXYAngle(o_out:NyARDoublePoint3d):void
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
		public final function setZXYAngle_NyARDoublePoint3d(i_angle:NyARDoublePoint3d):void
		{
			setZXYAngle_Number(i_angle.x,i_angle.y,i_angle.z);
			return;
		}
		public final function setZXYAngle_Number(i_x:Number,i_y:Number,i_z:Number):void
		{
			var sina:Number = Math.sin(i_x);
			var cosa:Number = Math.cos(i_x);
			var sinb:Number = Math.sin(i_y);
			var cosb:Number = Math.cos(i_y);
			var sinc:Number = Math.sin(i_z);
			var cosc:Number = Math.cos(i_z);
			this.m00 = cosc * cosb - sinc * sina * sinb;
			this.m01 = -sinc * cosa;
			this.m02 = cosc * sinb + sinc * sina * cosb;
			this.m10 = sinc * cosb + cosc * sina * sinb;
			this.m11 = cosc * cosa;
			this.m12 = sinc * sinb - cosc * sina * cosb;
			this.m20 = -cosa * sinb;
			this.m21 = sina;
			this.m22 = cosb * cosa;
			return;
		}
		/**
		 * 回転行列を適応して座標変換します。
		 * @param i_angle
		 * @param o_out
		 */
		public final function transformVertex_NyARDoublePoint3d(i_position:NyARDoublePoint3d,o_out:NyARDoublePoint3d):void
		{
			transformVertex_double(i_position.x,i_position.y,i_position.z,o_out);
			return;
		}
		
		public final function transformVertex_double(i_x:Number,i_y:Number,i_z:Number,o_out:NyARDoublePoint3d):void
		{
			o_out.x=this.m00*i_x+this.m01*i_y+this.m02*i_z;
			o_out.y=this.m10*i_x+this.m11*i_y+this.m12*i_z;
			o_out.z=this.m20*i_x+this.m21*i_y+this.m22*i_z;
			return;
		}
	}

}