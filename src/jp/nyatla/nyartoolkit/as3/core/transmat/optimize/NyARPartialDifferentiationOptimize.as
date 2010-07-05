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
package jp.nyatla.nyartoolkit.as3.core.transmat.optimize 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.solver.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	import jp.nyatla.nyartoolkit.as3.core.utils.*;
	/**
	 * 基本姿勢と実画像を一致するように、角度を微調整→平行移動量を再計算 を繰り返して、変換行列を最適化する。
	 * 
	 */
	public class NyARPartialDifferentiationOptimize
	{
		private var _projection_mat_ref:NyARPerspectiveProjectionMatrix;

		public function NyARPartialDifferentiationOptimize(i_projection_mat_ref:NyARPerspectiveProjectionMatrix)
		{
			this._projection_mat_ref = i_projection_mat_ref;
			return;
		}

		public function sincos2Rotation_ZXY(i_sincos:Vector.<TSinCosValue>,i_rot_matrix:NyARDoubleMatrix33):void
		{
			var sina:Number = i_sincos[0].sin_val;
			var cosa:Number = i_sincos[0].cos_val;
			var sinb:Number = i_sincos[1].sin_val;
			var cosb:Number = i_sincos[1].cos_val;
			var sinc:Number = i_sincos[2].sin_val;
			var cosc:Number = i_sincos[2].cos_val;
			i_rot_matrix.m00 = cosc * cosb - sinc * sina * sinb;
			i_rot_matrix.m01 = -sinc * cosa;
			i_rot_matrix.m02 = cosc * sinb + sinc * sina * cosb;
			i_rot_matrix.m10 = sinc * cosb + cosc * sina * sinb;
			i_rot_matrix.m11 = cosc * cosa;
			i_rot_matrix.m12 = sinc * sinb - cosc * sina * cosb;
			i_rot_matrix.m20 = -cosa * sinb;
			i_rot_matrix.m21 = sina;
			i_rot_matrix.m22 = cosb * cosa;
		}

		private function rotation2Sincos_ZXY(i_rot_matrix:NyARDoubleMatrix33,o_out:Vector.<TSinCosValue>,o_ang:NyARDoublePoint3d):void
		{
			var x:Number, y:Number, z:Number;
			var sina:Number = i_rot_matrix.m21;
			if (sina >= 1.0) {
				x = Math.PI / 2;
				y = 0;
				z = Math.atan2(-i_rot_matrix.m10, i_rot_matrix.m00);
			} else if (sina <= -1.0) {
				x = -Math.PI / 2;
				y = 0;
				z = Math.atan2(-i_rot_matrix.m10, i_rot_matrix.m00);
			} else {
				x = Math.asin(sina);
				y = Math.atan2(-i_rot_matrix.m20, i_rot_matrix.m22);
				z = Math.atan2(-i_rot_matrix.m01, i_rot_matrix.m11);
			}
			o_ang.x=x;
			o_ang.y=y;
			o_ang.z=z;
			o_out[0].sin_val = Math.sin(x);
			o_out[0].cos_val = Math.cos(x);
			o_out[1].sin_val = Math.sin(y);
			o_out[1].cos_val = Math.cos(y);
			o_out[2].sin_val = Math.sin(z);
			o_out[2].cos_val = Math.cos(z);
			return;
		}

		/*
		 * 射影変換式 基本式 ox=(cosc * cosb - sinc * sina * sinb)*ix+(-sinc * cosa)*iy+(cosc * sinb + sinc * sina * cosb)*iz+i_trans.x; oy=(sinc * cosb + cosc * sina *
		 * sinb)*ix+(cosc * cosa)*iy+(sinc * sinb - cosc * sina * cosb)*iz+i_trans.y; oz=(-cosa * sinb)*ix+(sina)*iy+(cosb * cosa)*iz+i_trans.z;
		 * 
		 * double ox=(cosc * cosb)*ix+(-sinc * sina * sinb)*ix+(-sinc * cosa)*iy+(cosc * sinb)*iz + (sinc * sina * cosb)*iz+i_trans.x; double oy=(sinc * cosb)*ix
		 * +(cosc * sina * sinb)*ix+(cosc * cosa)*iy+(sinc * sinb)*iz+(- cosc * sina * cosb)*iz+i_trans.y; double oz=(-cosa * sinb)*ix+(sina)*iy+(cosb *
		 * cosa)*iz+i_trans.z;
		 * 
		 * sina,cosaについて解く cx=(cp00*(-sinc*sinb*ix+sinc*cosb*iz)+cp01*(cosc*sinb*ix-cosc*cosb*iz)+cp02*(iy))*sina
		 * +(cp00*(-sinc*iy)+cp01*((cosc*iy))+cp02*(-sinb*ix+cosb*iz))*cosa
		 * +(cp00*(i_trans.x+cosc*cosb*ix+cosc*sinb*iz)+cp01*((i_trans.y+sinc*cosb*ix+sinc*sinb*iz))+cp02*(i_trans.z));
		 * cy=(cp11*(cosc*sinb*ix-cosc*cosb*iz)+cp12*(iy))*sina +(cp11*((cosc*iy))+cp12*(-sinb*ix+cosb*iz))*cosa
		 * +(cp11*((i_trans.y+sinc*cosb*ix+sinc*sinb*iz))+cp12*(i_trans.z)); ch=(iy)*sina +(-sinb*ix+cosb*iz)*cosa +i_trans.z; sinb,cosb hx=(cp00*(-sinc *
		 * sina*ix+cosc*iz)+cp01*(cosc * sina*ix+sinc*iz)+cp02*(-cosa*ix))*sinb +(cp01*(sinc*ix-cosc * sina*iz)+cp00*(cosc*ix+sinc * sina*iz)+cp02*(cosa*iz))*cosb
		 * +(cp00*(i_trans.x+(-sinc*cosa)*iy)+cp01*(i_trans.y+(cosc * cosa)*iy)+cp02*(i_trans.z+(sina)*iy)); double hy=(cp11*(cosc *
		 * sina*ix+sinc*iz)+cp12*(-cosa*ix))*sinb +(cp11*(sinc*ix-cosc * sina*iz)+cp12*(cosa*iz))*cosb +(cp11*(i_trans.y+(cosc *
		 * cosa)*iy)+cp12*(i_trans.z+(sina)*iy)); double h =((-cosa*ix)*sinb +(cosa*iz)*cosb +i_trans.z+(sina)*iy); パラメータ返還式 L=2*Σ(d[n]*e[n]+a[n]*b[n])
		 * J=2*Σ(d[n]*f[n]+a[n]*c[n])/L K=2*Σ(-e[n]*f[n]+b[n]*c[n])/L M=Σ(-e[n]^2+d[n]^2-b[n]^2+a[n]^2)/L 偏微分式 +J*cos(x) +K*sin(x) -sin(x)^2 +cos(x)^2
		 * +2*M*cos(x)*sin(x)
		 */
		private function optimizeParamX(i_angle_y:TSinCosValue,i_angle_z:TSinCosValue,i_trans:NyARDoublePoint3d,i_vertex3d:Vector.<NyARDoublePoint3d>, i_vertex2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int,i_hint_angle:Number):Number
		{
			var cp:NyARPerspectiveProjectionMatrix = this._projection_mat_ref;
			var sinb:Number = i_angle_y.sin_val;
			var cosb:Number = i_angle_y.cos_val;
			var sinc:Number = i_angle_z.sin_val;
			var cosc:Number = i_angle_z.cos_val;
			var L:Number, J:Number, K:Number, M:Number, N:Number, O:Number;
			L = J = K = M = N = O = 0;
			for (var i:int = 0; i < i_number_of_vertex; i++) {
				var ix:Number, iy:Number, iz:Number;
				ix = i_vertex3d[i].x;
				iy = i_vertex3d[i].y;
				iz = i_vertex3d[i].z;

				var cp00:Number = cp.m00;
				var cp01:Number = cp.m01;
				var cp02:Number = cp.m02;
				var cp11:Number = cp.m11;
				var cp12:Number = cp.m12;

				var X0:Number = (cp00 * (-sinc * sinb * ix + sinc * cosb * iz) + cp01 * (cosc * sinb * ix - cosc * cosb * iz) + cp02 * (iy));
				var X1:Number = (cp00 * (-sinc * iy) + cp01 * ((cosc * iy)) + cp02 * (-sinb * ix + cosb * iz));
				var X2:Number = (cp00 * (i_trans.x + cosc * cosb * ix + cosc * sinb * iz) + cp01 * ((i_trans.y + sinc * cosb * ix + sinc * sinb * iz)) + cp02 * (i_trans.z));
				var Y0:Number = (cp11 * (cosc * sinb * ix - cosc * cosb * iz) + cp12 * (iy));
				var Y1:Number = (cp11 * ((cosc * iy)) + cp12 * (-sinb * ix + cosb * iz));
				var Y2:Number = (cp11 * ((i_trans.y + sinc * cosb * ix + sinc * sinb * iz)) + cp12 * (i_trans.z));
				var H0:Number = (iy);
				var H1:Number = (-sinb * ix + cosb * iz);
				var H2:Number = i_trans.z;

				var VX:Number = i_vertex2d[i].x;
				var VY:Number = i_vertex2d[i].y;

				var a:Number, b:Number, c:Number, d:Number, e:Number, f:Number;
				a = (VX * H0 - X0);
				b = (VX * H1 - X1);
				c = (VX * H2 - X2);
				d = (VY * H0 - Y0);
				e = (VY * H1 - Y1);
				f = (VY * H2 - Y2);

				L += d * e + a * b;
				N += d * d + a * a;
				J += d * f + a * c;
				M += e * e + b * b;
				K += e * f + b * c;
				O += f * f + c * c;

			}
			L *=2;
			J *=2;
			K *=2;

			return getMinimumErrorAngleFromParam(L,J, K, M, N, O, i_hint_angle);


		}

		private function optimizeParamY(i_angle_x:TSinCosValue,i_angle_z:TSinCosValue,i_trans:NyARDoublePoint3d,i_vertex3d:Vector.<NyARDoublePoint3d>,i_vertex2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int,i_hint_angle:Number):Number
		{
			var cp:NyARPerspectiveProjectionMatrix = this._projection_mat_ref;
			var sina:Number = i_angle_x.sin_val;
			var cosa:Number = i_angle_x.cos_val;
			var sinc:Number = i_angle_z.sin_val;
			var cosc:Number = i_angle_z.cos_val;
			var L:Number, J:Number, K:Number, M:Number, N:Number, O:Number;
			L = J = K = M = N = O = 0;
			for (var i:int = 0; i < i_number_of_vertex; i++) {
				var ix:Number, iy:Number, iz:Number;
				ix = i_vertex3d[i].x;
				iy = i_vertex3d[i].y;
				iz = i_vertex3d[i].z;

				var cp00:Number = cp.m00;
				var cp01:Number = cp.m01;
				var cp02:Number = cp.m02;
				var cp11:Number = cp.m11;
				var cp12:Number = cp.m12;

				var X0:Number = (cp00 * (-sinc * sina * ix + cosc * iz) + cp01 * (cosc * sina * ix + sinc * iz) + cp02 * (-cosa * ix));
				var X1:Number = (cp01 * (sinc * ix - cosc * sina * iz) + cp00 * (cosc * ix + sinc * sina * iz) + cp02 * (cosa * iz));
				var X2:Number = (cp00 * (i_trans.x + (-sinc * cosa) * iy) + cp01 * (i_trans.y + (cosc * cosa) * iy) + cp02 * (i_trans.z + (sina) * iy));
				var Y0:Number = (cp11 * (cosc * sina * ix + sinc * iz) + cp12 * (-cosa * ix));
				var Y1:Number = (cp11 * (sinc * ix - cosc * sina * iz) + cp12 * (cosa * iz));
				var Y2:Number = (cp11 * (i_trans.y + (cosc * cosa) * iy) + cp12 * (i_trans.z + (sina) * iy));
				var H0:Number = (-cosa * ix);
				var H1:Number = (cosa * iz);
				var H2:Number = i_trans.z + (sina) * iy;

				var VX:Number = i_vertex2d[i].x;
				var VY:Number = i_vertex2d[i].y;

				var a:Number, b:Number, c:Number, d:Number, e:Number, f:Number;
				a = (VX * H0 - X0);
				b = (VX * H1 - X1);
				c = (VX * H2 - X2);
				d = (VY * H0 - Y0);
				e = (VY * H1 - Y1);
				f = (VY * H2 - Y2);

				L += d * e + a * b;
				N += d * d + a * a;
				J += d * f + a * c;
				M += e * e + b * b;
				K += e * f + b * c;
				O += f * f + c * c;

			}
			L *= 2;
			J *= 2;
			K *= 2;
			return getMinimumErrorAngleFromParam(L,J, K, M, N, O, i_hint_angle);

		}

		private function optimizeParamZ(i_angle_x:TSinCosValue,i_angle_y:TSinCosValue,i_trans:NyARDoublePoint3d,i_vertex3d:Vector.<NyARDoublePoint3d>,i_vertex2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int,i_hint_angle:Number):Number
		{
			var cp:NyARPerspectiveProjectionMatrix = this._projection_mat_ref;
			var sina:Number = i_angle_x.sin_val;
			var cosa:Number = i_angle_x.cos_val;
			var sinb:Number = i_angle_y.sin_val;
			var cosb:Number = i_angle_y.cos_val;
			var L:Number, J:Number, K:Number, M:Number, N:Number, O:Number;
			L = J = K = M = N = O = 0;
			for (var i:int = 0; i < i_number_of_vertex; i++) {
				var ix:Number, iy:Number, iz:Number;
				ix = i_vertex3d[i].x;
				iy = i_vertex3d[i].y;
				iz = i_vertex3d[i].z;

				var cp00:Number = cp.m00;
				var cp01:Number = cp.m01;
				var cp02:Number = cp.m02;
				var cp11:Number = cp.m11;
				var cp12:Number = cp.m12;

				var X0:Number = (cp00 * (-sina * sinb * ix - cosa * iy + sina * cosb * iz) + cp01 * (ix * cosb + sinb * iz));
				var X1:Number = (cp01 * (sina * ix * sinb + cosa * iy - sina * iz * cosb) + cp00 * (cosb * ix + sinb * iz));
				var X2:Number = cp00 * i_trans.x + cp01 * (i_trans.y) + cp02 * (-cosa * sinb) * ix + cp02 * (sina) * iy + cp02 * ((cosb * cosa) * iz + i_trans.z);
				var Y0:Number = cp11 * (ix * cosb + sinb * iz);
				var Y1:Number = cp11 * (sina * ix * sinb + cosa * iy - sina * iz * cosb);
				var Y2:Number = (cp11 * i_trans.y + cp12 * (-cosa * sinb) * ix + cp12 * ((sina) * iy + (cosb * cosa) * iz + i_trans.z));
				var H0:Number = 0;
				var H1:Number = 0;
				var H2:Number = ((-cosa * sinb) * ix + (sina) * iy + (cosb * cosa) * iz + i_trans.z);

				var VX:Number = i_vertex2d[i].x;
				var VY:Number = i_vertex2d[i].y;

				var a:Number, b:Number, c:Number, d:Number, e:Number, f:Number;
				a = (VX * H0 - X0);
				b = (VX * H1 - X1);
				c = (VX * H2 - X2);
				d = (VY * H0 - Y0);
				e = (VY * H1 - Y1);
				f = (VY * H2 - Y2);

				L += d * e + a * b;
				N += d * d + a * a;
				J += d * f + a * c;
				M += e * e + b * b;
				K += e * f + b * c;
				O += f * f + c * c;

			}
			L *=2;
			J *=2;
			K *=2;
			
			return getMinimumErrorAngleFromParam(L,J, K, M, N, O, i_hint_angle);
		}
		private var __angles_in:Vector.<TSinCosValue>=TSinCosValue.createArray(3);
		private var __ang:NyARDoublePoint3d=new NyARDoublePoint3d();
		public function modifyMatrix(io_rot:NyARDoubleMatrix33,i_trans:NyARDoublePoint3d,i_vertex3d:Vector.<NyARDoublePoint3d>,i_vertex2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int):void
		{
			var angles_in:Vector.<TSinCosValue> = this.__angles_in;// x,y,z
			var ang:NyARDoublePoint3d = this.__ang;

			// ZXY系のsin/cos値を抽出
			rotation2Sincos_ZXY(io_rot, angles_in,ang);
			ang.x += optimizeParamX(angles_in[1], angles_in[2], i_trans, i_vertex3d, i_vertex2d, i_number_of_vertex, ang.x);
			ang.y += optimizeParamY(angles_in[0], angles_in[2], i_trans, i_vertex3d, i_vertex2d, i_number_of_vertex, ang.y);
			ang.z += optimizeParamZ(angles_in[0], angles_in[1], i_trans, i_vertex3d, i_vertex2d, i_number_of_vertex, ang.z);
			io_rot.setZXYAngle_Number(ang.x, ang.y, ang.z);
			return;
		}
		private var __sin_table:Vector.<Number> = new Vector.<Number>(4);
		/**
		 * エラーレートが最小になる点を得る。
		 */
		private function getMinimumErrorAngleFromParam(iL:Number,iJ:Number,iK:Number,iM:Number,iN:Number,iO:Number,i_hint_angle:Number):Number
		{
			var sin_table:Vector.<Number> = this.__sin_table;

			var M:Number = (iN - iM)/iL;
			var J:Number = iJ/iL;
			var K:Number = -iK/iL;

			// パラメータからsinテーブルを作成
			// (- 4*M^2-4)*x^4 + (4*K- 4*J*M)*x^3 + (4*M^2 -(K^2- 4)- J^2)*x^2 +(4*J*M- 2*K)*x + J^2-1 = 0
			var number_of_sin:int = NyAREquationSolver.solve4Equation(-4 * M * M - 4, 4 * K - 4 * J * M, 4 * M * M - (K * K - 4) - J * J, 4 * J * M - 2 * K, J * J - 1, sin_table);


			// 最小値２個を得ておく。
			var min_ang_0:Number = Number.MAX_VALUE;
			var min_ang_1:Number = Number.MAX_VALUE;
			var min_err_0:Number = Number.MAX_VALUE;
			var min_err_1:Number = Number.MAX_VALUE;
			for (var i:int = 0; i < number_of_sin; i++) {
				// +-cos_v[i]が頂点候補
				var sin_rt:Number = sin_table[i];
				var cos_rt:Number = Math.sqrt(1 - (sin_rt * sin_rt));
				// cosを修復。微分式で0に近い方が正解
				// 0 = 2*cos(x)*sin(x)*M - sin(x)^2 + cos(x)^2 + sin(x)*K + cos(x)*J
				var a1:Number = 2 * cos_rt * sin_rt * M + sin_rt * (K - sin_rt) + cos_rt * (cos_rt + J);
				var a2:Number = 2 * (-cos_rt) * sin_rt * M + sin_rt * (K - sin_rt) + (-cos_rt) * ((-cos_rt) + J);
				// 絶対値になおして、真のcos値を得ておく。
				a1 = a1 < 0 ? -a1 : a1;
				a2 = a2 < 0 ? -a2 : a2;
				cos_rt = (a1 < a2) ? cos_rt : -cos_rt;
				var ang:Number = Math.atan2(sin_rt, cos_rt);
				// エラー値を計算
				var err:Number = iN * sin_rt * sin_rt + (iL*cos_rt + iJ) * sin_rt + iM * cos_rt * cos_rt + iK * cos_rt + iO;
				// 最小の２個を獲得する。
				if (min_err_0 > err) {
					min_err_1 = min_err_0;
					min_ang_1 = min_ang_0;
					min_err_0 = err;
					min_ang_0 = ang;
				} else if (min_err_1 > err) {
					min_err_1 = err;
					min_ang_1 = ang;
				}
			}
			// [0]をテスト
			var gap_0:Number;
			gap_0 = min_ang_0 - i_hint_angle;
			if (gap_0 > Math.PI) {
				gap_0 = (min_ang_0 - Math.PI * 2) - i_hint_angle;
			} else if (gap_0 < -Math.PI) {
				gap_0 = (min_ang_0 + Math.PI * 2) - i_hint_angle;
			}
			// [1]をテスト
			var gap_1:Number;
			gap_1 = min_ang_1 - i_hint_angle;
			if (gap_1 > Math.PI) {
				gap_1 = (min_ang_1 - Math.PI * 2) - i_hint_angle;
			} else if (gap_1 < -Math.PI) {
				gap_1 = (min_ang_1 + Math.PI * 2) - i_hint_angle;
			}
			return Math.abs(gap_1) < Math.abs(gap_0) ? gap_1 : gap_0;
		}
	}


}

class TSinCosValue{
	public var cos_val:Number;
	public var sin_val:Number;
	public static function createArray(i_size:int):Vector.<TSinCosValue>
	{
		var result:Vector.<TSinCosValue>=new Vector.<TSinCosValue>(i_size);
		for(var i:int=0;i<i_size;i++){
			result[i]=new TSinCosValue();
		}
		return result;
	}
}
