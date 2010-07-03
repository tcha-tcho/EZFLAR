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
package jp.nyatla.nyartoolkit.as3.utils
{
	import jp.nyatla.nyartoolkit.as3.core.pickup.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	/**
	 * マーカの周辺領域からビットマップを取得する方法を提供します。
	 * 比較的負荷が大きいので、連続してパターンを取得し続ける用途には向いていません。
	 *
	 */
	public class TransformedBitmapPickup extends NyARColorPatt_Perspective_O2
	{
		private var _work_points:Vector.<NyARIntPoint2d> = NyARIntPoint2d.createArray(4);

		private var _ref_perspective:NyARPerspectiveProjectionMatrix;

		/**
		 * 
		 * @param i_width
		 * 取得するビットマップの幅
		 * @param i_height
		 * 取得するビットマップの解像度
		 * @param i_resolution
		 * resolution of reading pixel per point. ---- 取得時の解像度。高解像度のときは1を指定してください。低解像度のときは2以上を指定します。
		 */
		public function TransformedBitmapPickup(i_ref_cparam:NyARPerspectiveProjectionMatrix,i_width:int,i_height:int,i_resolution:int)
		{
			super(i_width, i_height, i_resolution, 0);
			this._ref_perspective = i_ref_cparam;
		}

		/**
		 * This function retrieves bitmap from the area defined by RECT(i_l,i_t,i_r,i_b) above transform matrix i_base_mat. 
		 * ----
		 * この関数は、basementで示される平面のAで定義される領域から、ビットマップを読み出します。
		 * 例えば、8cmマーカでRECT(i_l,i_t,i_r,i_b)に-40,0,0,-40.0を指定すると、マーカの左下部分の画像を抽出します。
		 * 
		 * マーカから離れた場所になるほど、また、マーカの鉛直方向から外れるほど誤差が大きくなります。
		 * @param i_src_imege
		 * 詠み出し元の画像を指定します。
		 * @param i_l
		 * 基準点からの左上の相対座標（x）を指定します。
		 * @param i_t
		 * 基準点からの左上の相対座標（y）を指定します。
		 * @param i_r
		 * 基準点からの右下の相対座標（x）を指定します。
		 * @param i_b
		 * 基準点からの右下の相対座標（y）を指定します。
		 * @param i_base_mat
		 * @return 画像の取得の成否を返す。
		 */
		public function pickupImage2d(i_src_imege:INyARRgbRaster,i_l:Number,i_t:Number,i_r:Number,i_b:Number,i_base_mat:NyARTransMatResult):Boolean
		{
			var cp00:Number, cp01:Number, cp02:Number, cp11:Number, cp12:Number;
			cp00 = this._ref_perspective.m00;
			cp01 = this._ref_perspective.m01;
			cp02 = this._ref_perspective.m02;
			cp11 = this._ref_perspective.m11;
			cp12 = this._ref_perspective.m12;
			//マーカと同一平面上にある矩形の4個の頂点を座標変換して、射影変換して画面上の
			//頂点を計算する。
			//[hX,hY,h]=[P][RT][x,y,z]

			//出力先
			var poinsts:Vector.<NyARIntPoint2d> = this._work_points;		
			
			var yt0:Number,yt1:Number,yt2:Number;
			var x3:Number, y3:Number, z3:Number;
			
			var m00:Number=i_base_mat.m00;
			var m10:Number=i_base_mat.m10;
			var m20:Number=i_base_mat.m20;
			
			//yとtの要素を先に計算
			yt0=i_base_mat.m01 * i_t+i_base_mat.m03;
			yt1=i_base_mat.m11 * i_t+i_base_mat.m13;
			yt2=i_base_mat.m21 * i_t+i_base_mat.m23;
			// l,t
			x3 = m00 * i_l + yt0;
			y3 = m10 * i_l + yt1;
			z3 = m20 * i_l + yt2;
			poinsts[0].x = (int) ((x3 * cp00 + y3 * cp01 + z3 * cp02) / z3);
			poinsts[0].y = (int) ((y3 * cp11 + z3 * cp12) / z3);
			// r,t
			x3 = m00 * i_r + yt0;
			y3 = m10 * i_r + yt1;
			z3 = m20 * i_r + yt2;
			poinsts[1].x = (int) ((x3 * cp00 + y3 * cp01 + z3 * cp02) / z3);
			poinsts[1].y = (int) ((y3 * cp11 + z3 * cp12) / z3);

			//yとtの要素を先に計算
			yt0=i_base_mat.m01 * i_b+i_base_mat.m03;
			yt1=i_base_mat.m11 * i_b+i_base_mat.m13;
			yt2=i_base_mat.m21 * i_b+i_base_mat.m23;

			// r,b
			x3 = m00 * i_r + yt0;
			y3 = m10 * i_r + yt1;
			z3 = m20 * i_r + yt2;
			poinsts[2].x = (int) ((x3 * cp00 + y3 * cp01 + z3 * cp02) / z3);
			poinsts[2].y = (int) ((y3 * cp11 + z3 * cp12) / z3);
			// l,b
			x3 = m00 * i_l + yt0;
			y3 = m10 * i_l + yt1;
			z3 = m20 * i_l + yt2;
			poinsts[3].x = (int) ((x3 * cp00 + y3 * cp01 + z3 * cp02) / z3);
			poinsts[3].y = (int) ((y3 * cp11 + z3 * cp12) / z3);
			return this.pickFromRaster(i_src_imege, poinsts);
		}
	}

}