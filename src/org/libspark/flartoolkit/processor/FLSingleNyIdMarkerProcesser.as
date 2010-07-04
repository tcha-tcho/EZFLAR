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
package org.libspark.flartoolkit.processor 
{
	import flash.display.*;
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
	import jp.nyatla.nyartoolkit.as3.nyidmarker.data.*;
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.threshold.*;
	import jp.nyatla.as3utils.*;
	
	import org.libspark.flartoolkit.core.raster.*;
	import org.libspark.flartoolkit.core.rasterfilter.rgb2bin.*;
	import org.libspark.flartoolkit.core.squaredetect.*;
	import org.libspark.flartoolkit.core.*;
	import org.libspark.flartoolkit.*;
	import org.libspark.flartoolkit.core.param.*;
	import org.libspark.flartoolkit.core.raster.rgb.*;
	import org.libspark.flartoolkit.core.transmat.*;	
	import org.libspark.flartoolkit.core.analyzer.raster.threshold.*;
	
	
	public class FLSingleNyIdMarkerProcesser
	{
		/**
		 * オーナーが自由に使えるタグ変数です。
		 */
		public var tag:Object;

		/**
		 * ロスト遅延の管理
		 */
		private var _lost_delay_count:int = 0;
		private var _lost_delay:int = 5;

		private var _square_detect:FLARSquareContourDetector;
		protected var _transmat:INyARTransMat;
		private var _offset:NyARRectOffset; 
		private var _is_active:Boolean;
		private var _current_threshold:int=110;
		// [AR]検出結果の保存用
		private var _bin_raster:FLARBinRaster;
		private var _tobin_filter:FLARRasterFilter_Threshold;
		private var _callback:DetectSquareCB;
		private var _data_current:INyIdMarkerData;


		public function FLSingleNyIdMarkerProcesser()
		{
			return;
		}
		private var _initialized:Boolean=false;
		protected function initInstance(i_param:FLARParam, i_encoder:INyIdMarkerDataEncoder ,i_marker_width:int):void
		{
			//初期化済？
			NyAS3Utils.assert(this._initialized==false);
			
			var scr_size:NyARIntSize = i_param.getScreenSize();
			// 解析オブジェクトを作る
			this._square_detect = new FLARSquareContourDetector(scr_size);
			this._transmat = new NyARTransMat(i_param);
			this._callback=new DetectSquareCB(i_param,i_encoder);

			// ２値画像バッファを作る
			this._bin_raster = new FLARBinRaster(scr_size.w, scr_size.h);
			//ワーク用のデータオブジェクトを２個作る
			this._data_current=i_encoder.createDataInstance();
			this._tobin_filter =new FLARRasterFilter_Threshold(110);
			this._threshold_detect=new FLARRasterThresholdAnalyzer_SlidePTile(15,4);
			this._initialized=true;
			this._is_active=false;
			this._offset = new NyARRectOffset();
			this._offset.setSquare(i_marker_width);
			return;
			
		}

		public function setMarkerWidth(i_width:int):void
		{
			this._offset.setSquare(i_width);
			return;
		}

		public function reset(i_is_force:Boolean):void
		{
			if (i_is_force == false && this._is_active){
				// 強制書き換えでなければイベントコール
				this.onLeaveHandler();
			}
			//マーカ無効
			this._is_active=false;
			return;
		}

		public function detectMarker(i_raster:INyARRgbRaster):void
		{
			// サイズチェック
			if (!this._bin_raster.getSize().isEqualSize_int(i_raster.getSize().w, i_raster.getSize().h)) {
				throw new NyARException();
			}
			// ラスタを２値イメージに変換する.
			this._tobin_filter.setThreshold(this._current_threshold);
			this._tobin_filter.doFilter(i_raster, this._bin_raster);

			// スクエアコードを探す(第二引数に指定したマーカ、もしくは新しいマーカを探す。)
			this._callback.init(i_raster,this._is_active?this._data_current:null);
			this._square_detect.detectMarkerCB(this._bin_raster, this._callback);

			// 認識状態を更新(マーカを発見したなら、current_dataを渡すかんじ)
			var is_id_found:Boolean=updateStatus(this._callback.square,this._callback.marker_data);

			//閾値フィードバック(detectExistMarkerにもあるよ)
			if(is_id_found){
				//マーカがあれば、マーカの周辺閾値を反映
				this._current_threshold=(this._current_threshold+this._callback.threshold)/2;
			}else{
				//マーカがなければ、探索+DualPTailで基準輝度検索
				var th:int=this._threshold_detect.analyzeRaster(i_raster);
				this._current_threshold=(this._current_threshold+th)/2;
			}		
			return;
		}

		
		private var _threshold_detect:NyARRasterThresholdAnalyzer_SlidePTile;
		private var __NyARSquare_result:FLARTransMatResult = new FLARTransMatResult();

		/**オブジェクトのステータスを更新し、必要に応じてハンドル関数を駆動します。
		 */
		private function updateStatus(i_square:FLARSquare,i_marker_data:INyIdMarkerData):Boolean
		{
			var is_id_found:Boolean=false;
			var result:FLARTransMatResult = this.__NyARSquare_result;
			if (!this._is_active) {// 未認識中
				if (i_marker_data==null) {// 未認識から未認識の遷移
					// なにもしないよーん。
					this._is_active=false;
				} else {// 未認識から認識の遷移
					this._data_current.copyFrom(i_marker_data);
					// イベント生成
					// OnEnter
					this.onEnterHandler(this._data_current);
					// 変換行列を作成
					this._transmat.transMat(i_square, this._offset, result);
					// OnUpdate
					this.onUpdateHandler(i_square, result);
					this._lost_delay_count = 0;
					this._is_active=true;
					is_id_found=true;
				}
			} else {// 認識中
				if (i_marker_data==null) {
					// 認識から未認識の遷移
					this._lost_delay_count++;
					if (this._lost_delay < this._lost_delay_count) {
						// OnLeave
						this.onLeaveHandler();
						this._is_active=false;
					}
				} else if(this._data_current.isEqual(i_marker_data)) {
					//同じidの再認識
					this._transmat.transMatContinue(i_square, this._offset, result);
					// OnUpdate
					this.onUpdateHandler(i_square, result);
					this._lost_delay_count = 0;
					is_id_found=true;
				} else {// 異なるコードの認識→今はサポートしない。
					throw new  NyARException();
				}
			}
			return is_id_found;
		}	
		//通知ハンドラ
		protected function onEnterHandler(i_code:INyIdMarkerData):void
		{
			throw new NyARException("onEnterHandler not implemented.");
		}
		protected function onLeaveHandler():void
		{
			throw new NyARException("onLeaveHandler not implemented.");
		}
		protected function onUpdateHandler(i_square:FLARSquare, result:FLARTransMatResult):void
		{
			throw new NyARException("onUpdateHandler not implemented.");
		}
	}
}
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
import jp.nyatla.nyartoolkit.as3.nyidmarker.data.*;
import jp.nyatla.nyartoolkit.as3.nyidmarker.*;

import org.libspark.flartoolkit.core.squaredetect.*;

/**
 * detectMarkerのコールバック関数
 */
class DetectSquareCB implements NyARSquareContourDetector_IDetectMarkerCallback
{
	//公開プロパティ
	public var square:FLARSquare=new FLARSquare();
	public var marker_data:INyIdMarkerData;
	public var threshold:int;

	
	//参照
	private var _ref_raster:INyARRgbRaster;
	//所有インスタンス
	private var _current_data:INyIdMarkerData;
	private var _id_pickup:NyIdMarkerPickup = new NyIdMarkerPickup();
	private var _coordline:NyARCoord2Linear;
	private var _encoder:INyIdMarkerDataEncoder;

	
	private var _data_temp:INyIdMarkerData;
	private var _prev_data:INyIdMarkerData;
	
	public function DetectSquareCB(i_param:NyARParam,i_encoder:INyIdMarkerDataEncoder)
	{
		this._coordline=new NyARCoord2Linear(i_param.getScreenSize(),i_param.getDistortionFactor());
		this._data_temp=i_encoder.createDataInstance();
		this._current_data=i_encoder.createDataInstance();
		this._encoder=i_encoder;
		return;
	}
	private var __tmp_vertex:Vector.<NyARIntPoint2d>=NyARIntPoint2d.createArray(4);
	/**
	 * Initialize call back handler.
	 */
	public function init(i_raster:INyARRgbRaster,i_prev_data:INyIdMarkerData):void
	{
		this.marker_data=null;
		this._prev_data=i_prev_data;
		this._ref_raster=i_raster;
	}
	private var _marker_param:NyIdMarkerParam=new NyIdMarkerParam();
	private var _marker_data:NyIdMarkerPattern =new NyIdMarkerPattern();

	/**
	 * 矩形が見付かるたびに呼び出されます。
	 * 発見した矩形のパターンを検査して、方位を考慮した頂点データを確保します。
	 */
	public function onSquareDetect(i_sender:NyARSquareContourDetector,i_coordx:Vector.<int>,i_coordy:Vector.<int>,i_coor_num:int,i_vertex_index:Vector.<int>):void
	{
		//既に発見済なら終了
		if(this.marker_data!=null){
			return;
		}
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
	
		var param:NyIdMarkerParam=this._marker_param;
		var patt_data:NyIdMarkerPattern=this._marker_data;			
		// 評価基準になるパターンをイメージから切り出す
		if (!this._id_pickup.pickFromRaster(this._ref_raster,vertex, patt_data, param)){
			return;
		}
		//エンコード
		if(!this._encoder.encode(patt_data,this._data_temp)){
			return;
		}

		//継続認識要求されている？
		if (this._prev_data==null){
			//継続認識要求なし
			this._current_data.copyFrom(this._data_temp);
		}else{
			//継続認識要求あり
			if(!this._prev_data.isEqual((this._data_temp))){
				return;//認識請求のあったIDと違う。
			}
		}
		//新しく認識、または継続認識中に更新があったときだけ、Square情報を更新する。
		//ココから先はこの条件でしか実行されない。
		var sq:NyARSquare=this.square;
		//directionを考慮して、squareを更新する。
		var i:int;
		for(i=0;i<4;i++){
			var idx:int=(i+4 - param.direction) % 4;
			this._coordline.coord2Line(i_vertex_index[idx],i_vertex_index[(idx+1)%4],i_coordx,i_coordy,i_coor_num,sq.line[i]);
		}
		for (i= 0; i < 4; i++) {
			//直線同士の交点計算
			if(!NyARLinear.crossPos(sq.line[i],sq.line[(i + 3) % 4],sq.sqvertex[i])){
				throw new NyARException();//ここのエラー復帰するならダブルバッファにすればOK
			}
		}
		this.threshold=param.threshold;
		this.marker_data=this._current_data;//みつかった。
	}
}	