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
	import flash.display.BitmapData;
	
	import jp.nyatla.nyartoolkit.as3.NyARException;
	import jp.nyatla.nyartoolkit.as3.core.pickup.NyARColorPatt_Perspective_O2;
	import jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin.INyARRasterFilter_Rgb2Bin;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquare;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.NyARSquareContourDetector;
	import jp.nyatla.nyartoolkit.as3.core.transmat.INyARTransMat;
	import jp.nyatla.nyartoolkit.as3.core.transmat.NyARRectOffset;
	import jp.nyatla.nyartoolkit.as3.core.transmat.NyARTransMat;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.FLARBinRaster;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.rasterfilter.rgb2bin.FLARRasterFilter_Threshold;
	import org.libspark.flartoolkit.core.squaredetect.FLARSquareContourDetector;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	/**
	 * 複数のマーカーを検出し、それぞれに最も一致するARコードを、コンストラクタで登録したARコードから 探すクラスです。最大300個を認識しますが、ゴミラベルを認識したりするので100個程度が限界です。
	 * 
	 */
	public class FLARMultiMarkerDetector
	{

		private var _detect_cb:MultiDetectSquareCB;
		public static const AR_SQUARE_MAX:int = 300;
		private var _is_continue:Boolean = false;
		private var _square_detect:NyARSquareContourDetector;
		protected var _transmat:INyARTransMat;
		private var _offset:Vector.<NyARRectOffset>;

		// import が消える現象回避用
		private var _flarcode:FLARCode;

		/**
		 * 複数のマーカーを検出し、最も一致するARCodeをi_codeから検索するオブジェクトを作ります。
		 * 
		 * @param i_param
		 * カメラパラメータを指定します。
		 * @param i_code
		 * 検出するマーカーのARCode配列を指定します。
		 * 配列要素のインデックス番号が、そのままgetARCodeIndex関数で得られるARCodeインデックスになります。 
		 * 例えば、要素[1]のARCodeに一致したマーカーである場合は、getARCodeIndexは1を返します。
		 * @param i_marker_width
		 * i_codeのマーカーサイズをミリメートルで指定した配列を指定します。 先頭からi_number_of_code個の要素には、有効な値を指定する必要があります。
		 * @param i_number_of_code
		 * i_codeに含まれる、ARCodeの数を指定します。
		 * @throws NyARException
		 */
		public function FLARMultiMarkerDetector(i_param:FLARParam, i_code:Vector.<FLARCode>, i_marker_width:Vector.<Number>, i_number_of_code:int)
		{
			initInstance(i_param,i_code,i_marker_width,i_number_of_code);
			return;
		}
		protected function initInstance(
			i_ref_param:FLARParam,
			i_ref_code:Vector.<FLARCode>,
			i_marker_width:Vector.<Number>,
			i_number_of_code:int):void
		{
			var scr_size:NyARIntSize=i_ref_param.getScreenSize();
			// @todo この部分にマーカーの幅や高さ、枠線の割合がすべて一致するかのチェックを入れる
			// もしくは、FLARCodeの生成時に強制的に同一の数値を入力する事
			
			// 解析オブジェクトを作る
			var cw:int = i_ref_code[0].getWidth();
			var ch:int = i_ref_code[0].getHeight();
			
			// 枠線の割合(ARToolKit標準と同じなら、25 -> 1.0系と数値の扱いが異なるので注意！)
			var markerWidthByDec:Number = (100 - i_ref_code[0].markerPercentWidth) / 2;
			var markerHeightByDec:Number = (100 - i_ref_code[0].markerPercentHeight) / 2;
			
			//評価パターンのホルダを作成
			// NyARColorPatt_Perspective_O2のパラメータ
			// 第1,2パラ…縦横の解像度(patデータ作ったときの分割数)
			// 第3パラ…1ピクセルあたりの縦横サンプリング数。2なら2x2=4ポイントをサンプリングする。 
			//       1,2,4,任意の数値のいずれか。値が大きいほど一致率ＵＰ、フレームレート低下。
			//       解像度16、サンプリング数4がデフォルト。解像度が大きい場合は、サンプリング数を下げることでフレームレートの低下を回避できる。
			// 第4パラ…エッジ幅の割合(ARToolKit標準と同じなら、25)->1.0系と数値の扱いが異なるので注意！
			var patt:NyARColorPatt_Perspective_O2 = new NyARColorPatt_Perspective_O2(cw, ch, 4, markerWidthByDec);
			// 縦横のエッジの割合が異なる場合にも対応できます。
			patt.setEdgeSizeByPercent(markerWidthByDec, markerHeightByDec, 4);
//			trace('w:'+markerWidthByDec+'/h:'+markerHeightByDec);
			//detectMarkerのコールバック関数
			this._detect_cb=new MultiDetectSquareCB(patt,i_ref_code,i_number_of_code,i_ref_param);
			
			this._transmat = new NyARTransMat(i_ref_param);
			//NyARToolkitプロファイル
			this._square_detect =new FLARSquareContourDetector(i_ref_param.getScreenSize());
			this._tobin_filter=new FLARRasterFilter_Threshold(100);

			//実サイズ保存
			this._offset = NyARRectOffset.createArray(i_number_of_code);
			for(var i:int=0;i<i_number_of_code;i++){
				this._offset[i].setSquare(i_marker_width[i]);
			}
			//２値画像バッファを作る
			this._bin_raster=new FLARBinRaster(scr_size.w,scr_size.h);
			return;		
		}
		
		private var _bin_raster:FLARBinRaster;

		private var _tobin_filter:INyARRasterFilter_Rgb2Bin;

		/**
		 * i_imageにマーカー検出処理を実行し、結果を記録します。
		 * 
		 * @param i_raster
		 * マーカーを検出するイメージを指定します。
		 * @param i_thresh
		 * 検出閾値を指定します。0～255の範囲で指定してください。 通常は100～130くらいを指定します。
		 * @return 見つかったマーカーの数を返します。 マーカーが見つからない場合は0を返します。
		 * @throws NyARException
		 */
		public function detectMarkerLite(i_raster:FLARRgbRaster_BitmapData,i_threshold:int):int
		{
			// サイズチェック
			if (!this._bin_raster.getSize().isEqualSize_NyARIntSize(i_raster.getSize())) {
				throw new NyARException();
			}

			// ラスタを２値イメージに変換する.
			(FLARRasterFilter_Threshold(this._tobin_filter)).setThreshold(i_threshold);
			this._tobin_filter.doFilter(i_raster, this._bin_raster);

			//detect
			this._detect_cb.init(i_raster);
			this._square_detect.detectMarkerCB(this._bin_raster,this._detect_cb);

			//見付かった数を返す。
			return this._detect_cb.result_stack.getLength();
		}

		/**
		 * i_indexのマーカーに対する変換行列を計算し、結果値をo_resultへ格納します。 直前に実行したdetectMarkerLiteが成功していないと使えません。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @param o_result
		 * 結果値を受け取るオブジェクトを指定してください。
		 * @throws NyARException
		 */
		public function getTransformMatrix(i_index:int, o_result:FLARTransMatResult):void
		{
			var result:FLARDetectMarkerResult = this._detect_cb.result_stack.getItem(i_index);
			// 一番一致したマーカーの位置とかその辺を計算
			if (_is_continue) {
				_transmat.transMatContinue(result.square, this._offset[result.arcode_id], o_result);
			} else {
				_transmat.transMat(result.square, this._offset[result.arcode_id], o_result);
			}
			return;
		}

		/**
		 * i_indexのマーカーの一致度を返します。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @return マーカーの一致度を返します。0～1までの値をとります。 一致度が低い場合には、誤認識の可能性が高くなります。
		 * @throws NyARException
		 */
		public function getConfidence(i_index:int):Number
		{
			return this._detect_cb.result_stack.getItem(i_index).confidence;
		}
		/**
		 * i_indexのマーカーのARCodeインデックスを返します。
		 * 
		 * @param i_index
		 * マーカーのインデックス番号を指定します。 直前に実行したdetectMarkerLiteの戻り値未満かつ0以上である必要があります。
		 * @return
		 */
		public function getARCodeIndex(i_index:int):int
		{
			return this._detect_cb.result_stack.getItem(i_index).arcode_id;
		}

		/**
		 * 検出したマーカーの方位を返します。
		 * 0,1,2,3の何れかを返します。
		 * 
		 * @return Returns whether any of 0,1,2,3.
		 */
		public function getDirection(i_index:int):int
		{
			return this._detect_cb.result_stack.getItem(i_index).direction;
		}
		
		/**
		 * 検出した FLARSquare 1 個返す。検出できなかったら null。
		 * @return Total return detected FLARSquare 1. Detection Dekinakattara null.
		 */
		public function getSquare(i_index:int):NyARSquare
		{
			return this._detect_cb.result_stack.getItem(i_index).square;
		}

		/**
		 * getTransmationMatrixの計算モードを設定します。
		 * 
		 * @param i_is_continue
		 * TRUEなら、transMatContinueを使用します。 FALSEなら、transMatを使用します。
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
