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
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */
package org.libspark.flartoolkit.detector
{
	import flash.display.*;
	import jp.nyatla.nyartoolkit.as3.core.match.*;
	import jp.nyatla.nyartoolkit.as3.core.pickup.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import org.libspark.flartoolkit.core.raster.*;
	import org.libspark.flartoolkit.core.rasterfilter.rgb2bin.*;
	import org.libspark.flartoolkit.core.squaredetect.*;
	import org.libspark.flartoolkit.core.*;
	import org.libspark.flartoolkit.*;
	import org.libspark.flartoolkit.core.param.*;
	import org.libspark.flartoolkit.core.raster.rgb.*;
	import org.libspark.flartoolkit.core.transmat.*;
	public class FLARSingleMarkerDetector
	{	
		private var _is_continue:Boolean = false;
		private var _square_detect:FLARSquareContourDetector;
		protected var _transmat:INyARTransMat;
		//画処理用
		private var _bin_raster:FLARBinRaster;
		protected var _tobin_filter:INyARRasterFilter_Rgb2Bin;
		private var _detect_cb:SingleDetectSquareCB;
		private var _offset:NyARRectOffset; 


		public function FLARSingleMarkerDetector(i_ref_param:FLARParam,i_ref_code:FLARCode,i_marker_width:Number)
		{
			var th:INyARRasterFilter_Rgb2Bin=new FLARRasterFilter_Threshold(100);
			var patt_inst:NyARColorPatt_Perspective_O2;
			var sqdetect_inst:FLARSquareContourDetector;
			var transmat_inst:INyARTransMat;
			
			// 枠線の割合(ARToolKit標準と同じなら、25 -> 1.0系と数値の扱いが異なるので注意！)
			var markerWidthByDec:Number = (100 - i_ref_code.markerPercentWidth) / 2;
			var markerHeightByDec:Number = (100 - i_ref_code.markerPercentHeight) / 2;

			//評価パターンのホルダを作成
			// NyARColorPatt_Perspective_O2のパラメータ
			// 第1,2パラ…縦横の解像度(patデータ作ったときの分割数)
			// 第3パラ…1ピクセルあたりの縦横サンプリング数。2なら2x2=4ポイントをサンプリングする。 
			//       1,2,4,任意の数値のいずれか。値が大きいほど一致率ＵＰ、フレームレート低下。
			//       解像度16、サンプリング数4がデフォルト。解像度が大きい場合は、サンプリング数を下げることでフレームレートの低下を回避できる。
			// 第4パラ…エッジ幅の割合(ARToolKit標準と同じなら、25)->1.0系と数値の扱いが異なるので注意！
			patt_inst = new NyARColorPatt_Perspective_O2(i_ref_code.getWidth(), i_ref_code.getHeight(), 4, markerWidthByDec);
			// 縦横のエッジの割合が異なる場合にも対応できます。
			patt_inst.setEdgeSizeByPercent(markerWidthByDec, markerHeightByDec, 4);
//			trace('w:'+markerWidthByDec+'/h:'+markerHeightByDec);

			sqdetect_inst=new FLARSquareContourDetector(i_ref_param.getScreenSize());
			transmat_inst=new NyARTransMat(i_ref_param);
			initInstance(patt_inst,sqdetect_inst,transmat_inst,th,i_ref_param,i_ref_code,i_marker_width);
			return;
		}
		protected function initInstance(
			i_patt_inst:INyARColorPatt,
			i_sqdetect_inst:FLARSquareContourDetector,
			i_transmat_inst:INyARTransMat,
			i_filter:INyARRasterFilter_Rgb2Bin,
			i_ref_param:FLARParam,
			i_ref_code:FLARCode,
			i_marker_width:Number):void
		{
			var scr_size:NyARIntSize=i_ref_param.getScreenSize();
			// 解析オブジェクトを作る
			this._square_detect = i_sqdetect_inst;
			this._transmat = i_transmat_inst;
			this._tobin_filter=i_filter;
			//２値画像バッファを作る
			this._bin_raster=new FLARBinRaster(scr_size.w,scr_size.h);
			//_detect_cb
			this._detect_cb=new SingleDetectSquareCB(i_patt_inst,i_ref_code,i_ref_param);
			//オフセットを作成
			this._offset=new NyARRectOffset();
			this._offset.setSquare(i_marker_width);
			return;
			
		}
		
		/**
		 * i_imageにマーカー検出処理を実行し、結果を記録します。
		 * 
		 * @param i_raster
		 * マーカーを検出するイメージを指定します。イメージサイズは、カメラパラメータ
		 * と一致していなければなりません。
		 * @return マーカーが検出できたかを真偽値で返します。
		 * @throws NyARException
		 */
		public function detectMarkerLite(i_raster:FLARRgbRaster_BitmapData,i_threshold:int):Boolean
		{
			FLARRasterFilter_Threshold(this._tobin_filter).setThreshold(i_threshold);
			//サイズチェック
			if(!this._bin_raster.getSize().isEqualSize_NyARIntSize(i_raster.getSize())){
				throw new FLARException();
			}

			//ラスタを２値イメージに変換する.
			this._tobin_filter.doFilter(i_raster,this._bin_raster);

			//コールバックハンドラの準備
			this._detect_cb.init(i_raster);
			//矩形を探す(戻り値はコールバック関数で受け取る。)
			this._square_detect.detectMarkerCB(this._bin_raster,_detect_cb);
			if(this._detect_cb.confidence==0){
				return false;
			}
			return true;
		}
		/**
		 * 検出したマーカーの変換行列を計算して、o_resultへ値を返します。
		 * 直前に実行したdetectMarkerLiteが成功していないと使えません。
		 * 
		 * @param o_result
		 * 変換行列を受け取るオブジェクトを指定します。
		 * @throws NyARException
		 */
		public function getTransformMatrix(o_result:FLARTransMatResult):void
		{
			// 一番一致したマーカーの位置とかその辺を計算
			if (this._is_continue) {
				this._transmat.transMatContinue(this._detect_cb.square,this._offset, o_result);
			} else {
				this._transmat.transMat(this._detect_cb.square,this._offset, o_result);
			}
			return;
		}
		/**
		 * 検出したマーカーの一致度を返します。
		 * 
		 * @return マーカーの一致度を返します。0～1までの値をとります。 一致度が低い場合には、誤認識の可能性が高くなります。
		 * @throws NyARException
		 */
		public function getConfidence():Number
		{
			return this._detect_cb.confidence;
		}
		
		/**
		 * 検出したマーカーの方位を返します。
		 * 0,1,2,3の何れかを返します。
		 * 
		 * @return Returns whether any of 0,1,2,3.
		 */
		public function getDirection():int
		{
			return this._detect_cb.direction;
		}
		
		/**
		 * 検出した FLARSquare 1 個返す。検出できなかったら null。
		 * @return Total return detected FLARSquare 1. Detection Dekinakattara null.
		 */
		public function getSquare():NyARSquare
		{
			return this._detect_cb.square;
		}
		
		/**
		 * getTransmationMatrixの計算モードを設定します。 初期値はTRUEです。
		 * 
		 * @param i_is_continue
		 * TRUEなら、transMatCont互換の計算をします。 FALSEなら、transMat互換の計算をします。
		 */
		public function setContinueMode(i_is_continue:Boolean):void
		{
			this._is_continue = i_is_continue;
		}
		
		/**
		 * 2値化した画像を返却します。
		 * 
		 * @return 画像情報を返却します
		 */
		public function get thresholdedBitmapData() :BitmapData
		{
			try {
				return BitmapData(FLARBinRaster(this._bin_raster).getBuffer());
			} catch (e:Error) {
				return null;
			}
			return null;
		}
	}
}

