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
	import jp.nyatla.nyartoolkit.as3.core.match.*;
	import jp.nyatla.nyartoolkit.as3.core.pickup.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	public class NyARCustomSingleDetectMarker
	{	
		private var _is_continue:Boolean = false;
		private var _square_detect:NyARSquareContourDetector;
		protected var _transmat:INyARTransMat;
		//画処理用
		private var _bin_raster:NyARBinRaster;
		protected var _tobin_filter:INyARRasterFilter_Rgb2Bin;
		private var _detect_cb:DetectSquareCB;
		private var _offset:NyARRectOffset; 


		public function NyARCustomSingleDetectMarker()
		{

			return;
		}
		protected function initInstance(
			i_patt_inst:INyARColorPatt,
			i_sqdetect_inst:NyARSquareContourDetector,
			i_transmat_inst:INyARTransMat,
			i_filter:INyARRasterFilter_Rgb2Bin,
			i_ref_param:NyARParam,
			i_ref_code:NyARCode,
			i_marker_width:Number):void
		{
			var scr_size:NyARIntSize=i_ref_param.getScreenSize();		
			// 解析オブジェクトを作る
			this._square_detect = i_sqdetect_inst;
			this._transmat = i_transmat_inst;
			this._tobin_filter=i_filter;
			//２値画像バッファを作る
			this._bin_raster=new NyARBinRaster(scr_size.w,scr_size.h);
			//_detect_cb
			this._detect_cb=new DetectSquareCB(i_patt_inst,i_ref_code,i_ref_param);
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
		protected function detectMarkerLiteB(i_raster:INyARRgbRaster):Boolean		{
			//サイズチェック
			if(!this._bin_raster.getSize().isEqualSize_NyARIntSize(i_raster.getSize())){
				throw new NyARException();
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
		public function getTransmationMatrix(o_result:NyARTransMatResult):void
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
		 * 現在の矩形を返します。
		 * @return
		 */
		public function refSquare():NyARSquare
		{
			return this._detect_cb.square;
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
		 * getTransmationMatrixの計算モードを設定します。 初期値はTRUEです。
		 * 
		 * @param i_is_continue
		 * TRUEなら、transMatCont互換の計算をします。 FALSEなら、transMat互換の計算をします。
		 */
		public function setContinueMode(i_is_continue:Boolean):void
		{
			this._is_continue = i_is_continue;
		}
	}
}

import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
import jp.nyatla.nyartoolkit.as3.core.match.*;
import jp.nyatla.nyartoolkit.as3.core.pickup.*;
import jp.nyatla.nyartoolkit.as3.core.param.*;
import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.*;
import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
import jp.nyatla.nyartoolkit.as3.*;
import jp.nyatla.nyartoolkit.as3.core.types.*;

/**
 * detectMarkerのコールバック関数
 */
class DetectSquareCB implements NyARSquareContourDetector_IDetectMarkerCallback
{
	//公開プロパティ
	public var confidence:Number;
	public var square:NyARSquare=new NyARSquare();
	
	//参照インスタンス
	private var _ref_raster:INyARRgbRaster;
	//所有インスタンス
	private var _inst_patt:INyARColorPatt;
	private var _deviation_data:NyARMatchPattDeviationColorData;
	private var _match_patt:NyARMatchPatt_Color_WITHOUT_PCA;
	private var __detectMarkerLite_mr:NyARMatchPattResult=new NyARMatchPattResult();
	private var _coordline:NyARCoord2Linear;
	
	public function DetectSquareCB(i_inst_patt:INyARColorPatt,i_ref_code:NyARCode,i_param:NyARParam)
	{
		this._inst_patt=i_inst_patt;
		this._deviation_data=new NyARMatchPattDeviationColorData(i_ref_code.getWidth(),i_ref_code.getHeight());
		this._coordline=new NyARCoord2Linear(i_param.getScreenSize(),i_param.getDistortionFactor());
		this._match_patt=new NyARMatchPatt_Color_WITHOUT_PCA(i_ref_code);
		return;
	}
	private var __tmp_vertex:Vector.<NyARIntPoint2d>=NyARIntPoint2d.createArray(4);
	/**
	 * 矩形が見付かるたびに呼び出されます。
	 * 発見した矩形のパターンを検査して、方位を考慮した頂点データを確保します。
	 */
	public function onSquareDetect(i_sender:NyARSquareContourDetector,i_coordx:Vector.<int>,i_coordy:Vector.<int>,i_coor_num:int,i_vertex_index:Vector.<int>):void
	{
		var i:int;
		var mr:NyARMatchPattResult=this.__detectMarkerLite_mr;
		//輪郭座標から頂点リストに変換
		var vertex:Vector.<NyARIntPoint2d>=this.__tmp_vertex;
		vertex[0].x=i_coordx[i_vertex_index[0]];
		vertex[0].y=i_coordy[i_vertex_index[0]];
		vertex[1].x=i_coordx[i_vertex_index[1]];
		vertex[1].y=i_coordy[i_vertex_index[1]];
		vertex[2].x=i_coordx[i_vertex_index[2]];
		vertex[2].y=i_coordy[i_vertex_index[2]];
		vertex[3].x=i_coordx[i_vertex_index[3]];
		vertex[3].y=i_coordy[i_vertex_index[3]];
	
		//画像を取得
		if (!this._inst_patt.pickFromRaster(this._ref_raster,vertex)){
			return;
		}
		//取得パターンをカラー差分データに変換して評価する。
		this._deviation_data.setRaster(this._inst_patt);
		if(!this._match_patt.evaluate(this._deviation_data,mr)){
			return;
		}
		//現在の一致率より低ければ終了
		if (this.confidence > mr.confidence){
			return;
		}
		//一致率の高い矩形があれば、方位を考慮して頂点情報を作成
		var sq:NyARSquare=this.square;
		this.confidence = mr.confidence;
		//directionを考慮して、squareを更新する。
		for(i=0;i<4;i++){
			var idx:int=(i+4 - mr.direction) % 4;
			this._coordline.coord2Line(i_vertex_index[idx],i_vertex_index[(idx+1)%4],i_coordx,i_coordy,i_coor_num,sq.line[i]);
		}
		for (i = 0; i < 4; i++) {
			//直線同士の交点計算
			if(!NyARLinear.crossPos(sq.line[i],sq.line[(i + 3) % 4],sq.sqvertex[i])){
				throw new NyARException();//ここのエラー復帰するならダブルバッファにすればOK
			}
		}
	}
	public function init(i_raster:INyARRgbRaster):void
	{
		this.confidence=0;
		this._ref_raster=i_raster;
		
	}
}
