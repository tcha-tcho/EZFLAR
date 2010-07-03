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
package jp.nyatla.nyartoolkit.as3.core.param
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	/**
	 * カメラの歪み成分を格納するクラスと、補正関数群
	 * http://www.hitl.washington.edu/artoolkit/Papers/ART02-Tutorial.pdf
	 * 11ページを読むといいよ。
	 * 
	 * x=x(xi-x0),y=s(yi-y0)
	 * d^2=x^2+y^2
	 * p=(1-fd^2)
	 * xd=px+x0,yd=py+y0
	 */
	public class NyARCameraDistortionFactor implements INyARCameraDistortionFactor
	{
		private static const PD_LOOP:int = 3;
		private var _f0:Number;//x0
		private var _f1:Number;//y0
		private var _f2:Number;//100000000.0*ｆ
		private var _f3:Number;//s
		public function copyFrom(i_ref:NyARCameraDistortionFactor):void
		{
			this._f0=i_ref._f0;
			this._f1=i_ref._f1;
			this._f2=i_ref._f2;
			this._f3=i_ref._f3;
			return;
		}
		/**
		 * 配列の値をファクタ値としてセットする。
		 * @param i_factor
		 * 4要素以上の配列
		 */
		public function setValue(i_factor:Vector.<Number>):void
		{
			this._f0=i_factor[0];
			this._f1=i_factor[1];
			this._f2=i_factor[2];
			this._f3=i_factor[3];
			return;
		}
		public function getValue(o_factor:Vector.<Number>):void
		{
			o_factor[0]=this._f0;
			o_factor[1]=this._f1;
			o_factor[2]=this._f2;
			o_factor[3]=this._f3;
			return;
		}	
		public function changeScale(i_scale:Number):void
		{
			this._f0=this._f0*i_scale;// newparam->dist_factor[0] =source->dist_factor[0] *scale;
			this._f1=this._f1*i_scale;// newparam->dist_factor[1] =source->dist_factor[1] *scale;
			this._f2=this._f2/ (i_scale * i_scale);// newparam->dist_factor[2]=source->dist_factor[2]/ (scale*scale);
			//this.f3=this.f3;// newparam->dist_factor[3] =source->dist_factor[3];
			return;
		}
		/**
		 * int arParamIdeal2Observ( const double dist_factor[4], const double ix,const double iy,double *ox, double *oy ) 関数の代替関数
		 * 
		 * @param i_in
		 * @param o_out
		 */
		public function ideal2Observ(i_in:NyARDoublePoint2d,o_out:NyARDoublePoint2d):void
		{
			var x:Number = (i_in.x - this._f0) * this._f3;
			var y:Number = (i_in.y - this._f1) * this._f3;
			if (x == 0.0 && y == 0.0) {
				o_out.x = this._f0;
				o_out.y = this._f1;
			} else {
				var d:Number = 1.0 - this._f2 / 100000000.0 * (x * x + y * y);
				o_out.x = x * d + this._f0;
				o_out.y = y * d + this._f1;
			}
			return;
		}

		/**
		 * ideal2Observをまとめて実行します。
		 * @param i_in
		 * @param o_out
		 */
		public function ideal2ObservBatch(i_in:Vector.<NyARDoublePoint2d>, o_out:Vector.<NyARDoublePoint2d> ,i_size:int):void
		{
			var x:Number, y:Number;
			var d0:Number = this._f0;
			var d1:Number = this._f1;
			var d3:Number = this._f3;
			var d2_w:Number = this._f2 / 100000000.0;
			for (var i:int = 0; i < i_size; i++) {
				x = (i_in[i].x - d0) * d3;
				y = (i_in[i].y - d1) * d3;
				if (x == 0.0 && y == 0.0) {
					o_out[i].x = d0;
					o_out[i].y = d1;
				} else {
					var d:Number = 1.0 - d2_w * (x * x + y * y);
					o_out[i].x = x * d + d0;
					o_out[i].y = y * d + d1;
				}
			}
			return;
		}

		/**
		 * int arParamObserv2Ideal( const double dist_factor[4], const double ox,const double oy,double *ix, double *iy );
		 * 
		 * @param ix
		 * @param iy
		 * @param ix
		 * @param iy
		 * @return
		 */
		public function observ2Ideal(ix:Number, iy:Number, o_point:NyARDoublePoint2d):void
		{
			var z02:Number, z0:Number, p:Number, q:Number, z:Number, px:Number, py:Number, opttmp_1:Number;
			var d0:Number = this._f0;
			var d1:Number = this._f1;

			px = ix - d0;
			py = iy - d1;
			p = this._f2 / 100000000.0;
			z02 = px * px + py * py;
			q = z0 = Math.sqrt(z02);// Optimize//q = z0 = Math.sqrt(px*px+ py*py);

			for (var i:int = 1;; i++) {
				if (z0 != 0.0) {
					// Optimize opttmp_1
					opttmp_1 = p * z02;
					z = z0 - ((1.0 - opttmp_1) * z0 - q) / (1.0 - 3.0 * opttmp_1);
					px = px * z / z0;
					py = py * z / z0;
				} else {
					px = 0.0;
					py = 0.0;
					break;
				}
				if (i == PD_LOOP) {
					break;
				}
				z02 = px * px + py * py;
				z0 = Math.sqrt(z02);// Optimize//z0 = Math.sqrt(px*px+ py*py);
			}
			o_point.x = px / this._f3 + d0;
			o_point.y = py / this._f3 + d1;
			return;
		}

		/**
		 * 指定範囲のobserv2Idealをまとめて実行して、結果をo_idealに格納します。
		 * @param i_x_coord
		 * @param i_y_coord
		 * @param i_start
		 *            coord開始点
		 * @param i_num
		 *            計算数
		 * @param o_ideal
		 *            出力バッファ[i_num][2]であること。
		 */
		public function observ2IdealBatch(i_x_coord:Vector.<int>,i_y_coord:Vector.<int>,i_start:int,i_num:int,o_x_coord:Vector.<Number>,o_y_coord:Vector.<Number>):void
		{
			var z02:Number, z0:Number, q:Number, z:Number, px:Number, py:Number, opttmp_1:Number;
			var d0:Number = this._f0;
			var d1:Number = this._f1;
			var d3:Number = this._f3;
			var p:Number = this._f2 / 100000000.0;
			for (var j:int = 0; j < i_num; j++) {

				px = i_x_coord[i_start + j] - d0;
				py = i_y_coord[i_start + j] - d1;

				z02 = px * px + py * py;
				q = z0 = Math.sqrt(z02);// Optimize//q = z0 = Math.sqrt(px*px+py*py);

				for (var i:int = 1;; i++) {
					if (z0 != 0.0) {
						// Optimize opttmp_1
						opttmp_1 = p * z02;
						z = z0 - ((1.0 - opttmp_1) * z0 - q)/ (1.0 - 3.0 * opttmp_1);
						px = px * z / z0;
						py = py * z / z0;
					} else {
						px = 0.0;
						py = 0.0;
						break;
					}
					if (i == PD_LOOP) {
						break;
					}
					z02 = px * px + py * py;
					z0 = Math.sqrt(z02);// Optimize//z0 = Math.sqrt(px*px+ py*py);
				}
				o_x_coord[j] = px / d3 + d0;
				o_y_coord[j] = py / d3 + d1;
			}
			return;
		}	
	}
}