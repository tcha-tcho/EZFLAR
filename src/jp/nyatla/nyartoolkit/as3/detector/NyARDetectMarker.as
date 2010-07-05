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
package jp.nyatla.nyartoolkit.as3.detector 
{
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.pickup.*;


	/**
	 * 複数のマーカーを検出し、それぞれに最も一致するARコードを、コンストラクタで登録したARコードから 探すクラスです。最大300個を認識しますが、ゴミラベルを認識したりするので100個程度が限界です。
	 * 
	 */
	public class NyARDetectMarker
	{

		private var _detect_cb:NyARDetectSquareCB;
		public static const AR_SQUARE_MAX:int = 300;
		private var _is_continue:Boolean = false;
		private var _square_detect:NyARSquareContourDetector;
		protected var _transmat:INyARTransMat;
		private var _offset:Vector.<NyARRectOffset>;


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
		 * @param i_input_raster_type
		 * 入力ラスタのピクセルタイプを指定します。この値は、INyARBufferReaderインタフェイスのgetBufferTypeの戻り値を指定します。
		 * @throws NyARException
		 */
		public function NyARDetectMarker(i_param:NyARParam, i_code:Vector.<NyARCode>, i_marker_width:Vector.<Number>, i_number_of_code:int, i_input_raster_type:int)
		{
			initInstance(i_param,i_code,i_marker_width,i_number_of_code,i_input_raster_type);
			return;
		}
		protected function initInstance(
			i_ref_param:NyARParam,
			i_ref_code:Vector.<NyARCode>,
			i_marker_width:Vector.<Number>,
			i_number_of_code:int,
			i_input_raster_type:int):void
		{

			var scr_size:NyARIntSize=i_ref_param.getScreenSize();
			// 解析オブジェクトを作る
			var cw:int = i_ref_code[0].getWidth();
			var ch:int = i_ref_code[0].getHeight();

			//detectMarkerのコールバック関数
			this._detect_cb=new NyARDetectSquareCB(
				new NyARColorPatt_Perspective_O2(cw, ch,4,25),
				i_ref_code,i_number_of_code,i_ref_param);
			this._transmat = new NyARTransMat(i_ref_param);
			//NyARToolkitプロファイル
			this._square_detect =new NyARSquareContourDetector_Rle(i_ref_param.getScreenSize());
			this._tobin_filter=new NyARRasterFilter_ARToolkitThreshold(100,i_input_raster_type);

			//実サイズ保存
			this._offset = NyARRectOffset.createArray(i_number_of_code);
			for(var i:int=0;i<i_number_of_code;i++){
				this._offset[i].setSquare(i_marker_width[i]);
			}
			//２値画像バッファを作る
			this._bin_raster=new NyARBinRaster(scr_size.w,scr_size.h);
			return;		
		}
		
		private var _bin_raster:NyARBinRaster;

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
		public function detectMarkerLite(i_raster:INyARRgbRaster,i_threshold:int):int
		{
			// サイズチェック
			if (!this._bin_raster.getSize().isEqualSize_NyARIntSize(i_raster.getSize())) {
				throw new NyARException();
			}

			// ラスタを２値イメージに変換する.
			(NyARRasterFilter_ARToolkitThreshold(this._tobin_filter)).setThreshold(i_threshold);
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
		public function getTransmationMatrix(i_index:int, o_result:NyARTransMatResult):void
		{
			var result:NyARDetectMarkerResult = this._detect_cb.result_stack.getItem(i_index);
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
		 * getTransmationMatrixの計算モードを設定します。
		 * 
		 * @param i_is_continue
		 * TRUEなら、transMatContinueを使用します。 FALSEなら、transMatを使用します。
		 */
		public function setContinueMode(i_is_continue:Boolean):void
		{
			this._is_continue = i_is_continue;
		}

	}
}