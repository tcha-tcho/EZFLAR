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
package jp.nyatla.nyartoolkit.as3.core.labeling.rlelabeling
{
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.as3utils.*;


	// RleImageをラベリングする。
	public class NyARLabeling_Rle
	{
		private static const AR_AREA_MAX:int = 100000;// #define AR_AREA_MAX 100000
		private static const AR_AREA_MIN:int = 70;// #define AR_AREA_MIN 70
		
		private var _rlestack:RleInfoStack;
		private var _rle1:Vector.<RleElement>;
		private var _rle2:Vector.<RleElement>;
		private var _max_area:int;
		private var _min_area:int;

		public function NyARLabeling_Rle(i_width:int,i_height:int)
		{
			this._rlestack=new RleInfoStack(i_width*i_height*2048/(320*240)+32);
			this._rle1 = RleElement.createArray(i_width/2+1);
			this._rle2 = RleElement.createArray(i_width/2+1);
			setAreaRange(AR_AREA_MAX,AR_AREA_MIN);
			return;
		}
		/**
		 * 対象サイズ
		 * @param i_max
		 * @param i_min
		 */
		public function setAreaRange(i_max:int,i_min:int):void
		{
			this._max_area=i_max;
			this._min_area=i_min;
			return;
		}

		/**
		 * i_bin_bufのgsイメージをREL圧縮する。
		 * @param i_bin_buf
		 * @param i_st
		 * @param i_len
		 * @param i_out
		 * @param i_th
		 * BINラスタのときは0,GSラスタの時は閾値を指定する。
		 * この関数は、閾値を暗点と認識します。
		 * 暗点<=th<明点
		 * @return
		 */
		private function toRel(i_bin_buf:Vector.<int>,i_st:int,i_len:int,i_out:Vector.<RleElement>,i_th:int):int
		{
			var current:int = 0;
			var r:int = -1;
			// 行確定開始
			var x:int = i_st;
			var right_edge:int = i_st + i_len - 1;
			while (x < right_edge) {
				// 暗点(0)スキャン
				if (i_bin_buf[x] > i_th) {
					x++;//明点
					continue;
				}
				// 暗点発見→暗点長を調べる
				r = (x - i_st);
				i_out[current].l = r;
				r++;// 暗点+1
				x++;
				while (x < right_edge) {
					if (i_bin_buf[x] > i_th) {
						// 明点(1)→暗点(0)配列終了>登録
						i_out[current].r = r;
						current++;
						x++;// 次点の確認。
						r = -1;// 右端の位置を0に。
						break;
					} else {
						// 暗点(0)長追加
						r++;
						x++;
					}
				}
			}
			// 最後の1点だけ判定方法が少し違うの。
			if (i_bin_buf[x] > i_th) {
				// 明点→rカウント中なら暗点配列終了>登録
				if (r >= 0) {
					i_out[current].r = r;
					current++;
				}
			} else {
				// 暗点→カウント中でなければl1で追加
				if (r >= 0) {
					i_out[current].r = (r + 1);
				} else {
					// 最後の1点の場合
					i_out[current].l = (i_len - 1);
					i_out[current].r = (i_len);
				}
				current++;
			}
			// 行確定
			return current;
		}

		private function addFragment(i_rel_img:RleElement,i_nof:int,i_row_index:int,o_stack:RleInfoStack):void
		{
			var l:int =i_rel_img.l;
			var len:int=i_rel_img.r - l;
			i_rel_img.fid = i_nof;// REL毎の固有ID
			var v:RleInfo = o_stack.prePush();
			v.entry_x = l;
			v.area =len;
			v.clip_l=l;
			v.clip_r=i_rel_img.r-1;
			v.clip_t=i_row_index;
			v.clip_b=i_row_index;
			v.pos_x=(len*(2*l+(len-1)))/2;
			v.pos_y=i_row_index*len;

			return;
		}
		//所望のラスタからBIN-RLEに変換しながらの低速系も準備しようかな
		
		/**
		 * 単一閾値を使ってGSラスタをBINラスタに変換しながらラベリングします。
		 * @param i_gs_raster
		 * @param i_top
		 * @param i_bottom
		 * @param o_stack
		 * @return
		 * @throws NyARException
		 */
		public function labeling_NyARBinRaster(i_bin_raster:NyARBinRaster,i_top:int,i_bottom:int,o_stack:NyARRleLabelFragmentInfoStack):int
		{
			NyAS3Utils.assert(i_bin_raster.isEqualBufferType(NyARBufferType.INT1D_BIN_8));
			return this.imple_labeling(i_bin_raster,0,i_top,i_bottom,o_stack);
		}
		/**
		 * BINラスタをラベリングします。
		 * @param i_gs_raster
		 * @param i_th
		 * 画像を２値化するための閾値。暗点<=th<明点となります。
		 * @param i_top
		 * @param i_bottom
		 * @param o_stack
		 * @return
		 * @throws NyARException
		 */
		public function labeling_NyARGrayscaleRaster(i_gs_raster:NyARGrayscaleRaster,i_th:int,i_top:int,i_bottom:int,o_stack:NyARRleLabelFragmentInfoStack):int
		{
			NyAS3Utils.assert(i_gs_raster.isEqualBufferType(NyARBufferType.INT1D_GRAY_8));
			return this.imple_labeling(i_gs_raster,i_th,i_top,i_bottom,o_stack);
		}
		private function imple_labeling(i_raster:INyARRaster,i_th:int,i_top:int,i_bottom:int,o_stack:NyARRleLabelFragmentInfoStack):int
		{
			// リセット処理
			var rlestack:RleInfoStack=this._rlestack;
			rlestack.clear();

			//
			var rle_prev:Vector.<RleElement> = this._rle1;
			var rle_current:Vector.<RleElement> = this._rle2;
			var len_prev:int = 0;
			var len_current:int = 0;
			var width:int = i_raster.getWidth();
			var in_buf:Vector.<int> = (Vector.<int>)(i_raster.getBuffer());

			var id_max:int = 0;
			var label_count:int=0;
			// 初段登録

			len_prev = toRel(in_buf, i_top, width, rle_prev, i_th);
			var i:int;
			for (i = 0; i < len_prev; i++) {
				// フラグメントID=フラグメント初期値、POS=Y値、RELインデクス=行
				addFragment(rle_prev[i], id_max, i_top,rlestack);
				id_max++;
				// nofの最大値チェック
				label_count++;
			}
			var f_array:Vector.<RleInfo> = Vector.<RleInfo>(rlestack.getArray());
			// 次段結合
			for (var y:int = i_top + 1; y < i_bottom; y++) {
				// カレント行の読込
				len_current = toRel(in_buf, y * width, width, rle_current,i_th);
				var index_prev:int = 0;

				SCAN_CUR: for (i = 0; i < len_current; i++) {
					// index_prev,len_prevの位置を調整する
					var id:int = -1;
					// チェックすべきprevがあれば確認
					SCAN_PREV: while (index_prev < len_prev) {
						if (rle_current[i].l - rle_prev[index_prev].r > 0) {// 0なら8方位ラベリング
							// prevがcurの左方にある→次のフラグメントを探索
							index_prev++;
							continue;
						} else if (rle_prev[index_prev].l - rle_current[i].r > 0) {// 0なら8方位ラベリングになる
							// prevがcur右方にある→独立フラグメント
							addFragment(rle_current[i], id_max, y,rlestack);
							id_max++;
							label_count++;
							// 次のindexをしらべる
							continue SCAN_CUR;
						}
						id=rle_prev[index_prev].fid;//ルートフラグメントid
						var id_ptr:RleInfo = f_array[id];
						//結合対象(初回)->prevのIDをコピーして、ルートフラグメントの情報を更新
						rle_current[i].fid = id;//フラグメントIDを保存
						//
						var l:int= rle_current[i].l;
						var r:int= rle_current[i].r;
						var len:int=r-l;
						//結合先フラグメントの情報を更新する。
						id_ptr.area += len;
						//tとentry_xは、結合先のを使うので更新しない。
						id_ptr.clip_l=l<id_ptr.clip_l?l:id_ptr.clip_l;
						id_ptr.clip_r=r>id_ptr.clip_r?r-1:id_ptr.clip_r;
						id_ptr.clip_b=y;
						id_ptr.pos_x+=(len*(2*l+(len-1)))/2;
						id_ptr.pos_y+=y*len;
						//多重結合の確認（２個目以降）
						index_prev++;
						while (index_prev < len_prev) {
							if (rle_current[i].l - rle_prev[index_prev].r > 0) {// 0なら8方位ラベリング
								// prevがcurの左方にある→prevはcurに連結していない。
								break SCAN_PREV;
							} else if (rle_prev[index_prev].l - rle_current[i].r > 0) {// 0なら8方位ラベリングになる
								// prevがcurの右方にある→prevはcurに連結していない。
								index_prev--;
								continue SCAN_CUR;
							}
							// prevとcurは連結している→ルートフラグメントの統合
							
							//結合するルートフラグメントを取得
							var prev_id:int =rle_prev[index_prev].fid;
							var prev_ptr:RleInfo = f_array[prev_id];
							if (id != prev_id){
								label_count--;
								//prevとcurrentのフラグメントidを書き換える。
								var i2:int;
								for(i2=index_prev;i2<len_prev;i2++){
									//prevは現在のidから最後まで
									if(rle_prev[i2].fid==prev_id){
										rle_prev[i2].fid=id;
									}
								}
								for(i2=0;i2<i;i2++){
									//currentは0から現在-1まで
									if(rle_current[i2].fid==prev_id){
										rle_current[i2].fid=id;
									}
								}
								
								//現在のルートフラグメントに情報を集約
								id_ptr.area +=prev_ptr.area;
								id_ptr.pos_x+=prev_ptr.pos_x;
								id_ptr.pos_y+=prev_ptr.pos_y;
								//tとentry_xの決定
								if (id_ptr.clip_t > prev_ptr.clip_t) {
									// 現在の方が下にある。
									id_ptr.clip_t = prev_ptr.clip_t;
									id_ptr.entry_x = prev_ptr.entry_x;
								}else if (id_ptr.clip_t < prev_ptr.clip_t) {
									// 現在の方が上にある。prevにフィードバック
								} else {
									// 水平方向で小さい方がエントリポイント。
									if (id_ptr.entry_x > prev_ptr.entry_x) {
										id_ptr.entry_x = prev_ptr.entry_x;
									}else{
									}
								}
								//lの決定
								if (id_ptr.clip_l > prev_ptr.clip_l) {
									id_ptr.clip_l=prev_ptr.clip_l;
								}else{
								}
								//rの決定
								if (id_ptr.clip_r < prev_ptr.clip_r) {
									id_ptr.clip_r=prev_ptr.clip_r;
								}else{
								}
								//bの決定

								//結合済のルートフラグメントを無効化する。
								prev_ptr.area=0;
							}


							index_prev++;
						}
						index_prev--;
						break;
					}
					// curにidが割り当てられたかを確認
					// 右端独立フラグメントを追加
					if (id < 0){
						addFragment(rle_current[i], id_max, y,rlestack);
						id_max++;
						label_count++;
					}
				}
				// prevとrelの交換
				var tmp:Vector.<RleElement> = rle_prev;
				rle_prev = rle_current;
				len_prev = len_current;
				rle_current = tmp;
			}
			//対象のラベルだけ転写
			o_stack.init(label_count);
			var o_dest_array:Vector.<NyARRleLabelFragmentInfo>=Vector.<NyARRleLabelFragmentInfo>(o_stack.getArray());
			var max:int=this._max_area;
			var min:int=this._min_area;
			var active_labels:int=0;
			for(i=id_max-1;i>=0;i--){
				var area:int=f_array[i].area;
				if(area<min || area>max){//対象外のエリア0のもminではじく
					continue;
				}
				//
				var src_info:RleInfo=f_array[i];
				var dest_info:NyARRleLabelFragmentInfo=o_dest_array[active_labels];
				dest_info.area=area;
				dest_info.clip_b=src_info.clip_b;
				dest_info.clip_r=src_info.clip_r;
				dest_info.clip_t=src_info.clip_t;
				dest_info.clip_l=src_info.clip_l;
				dest_info.entry_x=src_info.entry_x;
				dest_info.pos_x=src_info.pos_x/src_info.area;
				dest_info.pos_y=src_info.pos_y/src_info.area;
				active_labels++;
			}
			//ラベル数を再設定
			o_stack.pops(label_count-active_labels);
			//ラベル数を返却
			return active_labels;
		}	
	}
}

import jp.nyatla.nyartoolkit.as3.core.types.stack.*;
final class RleInfo
{
	//継承メンバ
	public var entry_x:int; // フラグメントラベルの位置
	public var area:int;
	public var clip_r:int;
	public var clip_l:int;
	public var clip_b:int;
	public var clip_t:int;
	public var pos_x:Number;
	public var pos_y:Number;		
}

final class RleInfoStack extends NyARObjectStack
{
	public function RleInfoStack(i_length:int)
	{
		super(i_length);
		return;
	}
	protected override function createArray(i_length:int):Vector.<Object>
	{
		var ret:Vector.<RleInfo>= new Vector.<RleInfo>(i_length);
		for (var i:int =0; i < i_length; i++){
			ret[i] = new RleInfo();
		}
		return Vector.<Object>(ret);
	}
}

class RleElement
{
	public var l:int;
	public var r:int;
	public var fid:int;
	public static function createArray(i_length:int):Vector.<RleElement>
	{
		var ret:Vector.<RleElement> = new Vector.<RleElement>(i_length);
		for (var i:int = 0; i < i_length; i++) {
			ret[i] = new RleElement();
		}
		return ret;
	}
}



