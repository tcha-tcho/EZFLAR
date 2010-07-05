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
package jp.nyatla.nyartoolkit.as3.nyidmarker 
{
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;

	/**
	 * ラスタ画像の任意矩形から、NyARIdMarkerDataを抽出します。
	 *
	 */
	public class NyIdMarkerPickup
	{
		private var _perspective_reader:PerspectivePixelReader;
		private var __pickFromRaster_th:TThreshold=new TThreshold();
		private var __pickFromRaster_encoder:MarkerPattEncoder=new MarkerPattEncoder();


		public function NyIdMarkerPickup()
		{
			this._perspective_reader=new PerspectivePixelReader();
			return;
		}
		/**
		 * i_imageから、idマーカを読みだします。
		 * o_dataにはマーカデータ、o_paramにはまーかのパラメータを返却します。
		 * @param image
		 * @param i_square
		 * @param o_data
		 * @param o_param
		 * @return
		 * @throws NyARException
		 */
		public function pickFromRaster(image:INyARRgbRaster,i_vertex:Vector.<NyARIntPoint2d>,o_data:NyIdMarkerPattern,o_param:NyIdMarkerParam):Boolean
		{
			
			//遠近法のパラメータを計算
			if(!this._perspective_reader.setSourceSquare(i_vertex)){
				return false;
			};
			
			var reader:INyARRgbPixelReader=image.getRgbPixelReader();
			var raster_size:NyARIntSize=image.getSize();
			


			var th:TThreshold=this.__pickFromRaster_th;
			var encoder:MarkerPattEncoder=this.__pickFromRaster_encoder;
			//マーカパラメータを取得
			this._perspective_reader.detectThresholdValue(reader,raster_size,th);

			if(!this._perspective_reader.readDataBits(reader,raster_size,th, encoder)){
				return false;
			}
			var d:int=encoder.encode(o_data);
			if(d<0){
				return false;
			}
			o_param.direction=d;
			o_param.threshold=th.th;
			
			return true;
		}
	}
}

import jp.nyatla.as3utils.*;
import jp.nyatla.nyartoolkit.as3.core.utils.*;
import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
import jp.nyatla.nyartoolkit.as3.core.types.*;
import jp.nyatla.nyartoolkit.as3.nyidmarker.*;
import jp.nyatla.nyartoolkit.as3.nyidmarker.data.*;

/**
 * NyARColorPatt_NyIdMarkerがラスタからPerspective変換して読みだすためのクラス
 *
 */
class PerspectivePixelReader
{
	private var _param_gen:NyARPerspectiveParamGenerator_O1=new NyARPerspectiveParamGenerator_O1(1,1,100,100);
	private var _cparam:Vector.<Number>=new Vector.<Number>(8);


	public function PerspectivePixelReader()
	{
		return;
	}

	public function setSourceSquare(i_vertex:Vector.<NyARIntPoint2d>):Boolean
	{
		return this._param_gen.getParam(i_vertex, this._cparam);
	}

	/**
	 * 矩形からピクセルを切り出します
	 * @param i_lt_x
	 * @param i_lt_y
	 * @param i_step_x
	 * @param i_step_y
	 * @param i_width
	 * @param i_height
	 * @param i_out_st
	 * o_pixelへの格納場所の先頭インデクス
	 * @param o_pixel
	 * @throws NyARException
	 */
	private function rectPixels(i_reader:INyARRgbPixelReader,i_raster_size:NyARIntSize,i_lt_x:int,i_lt_y:int,i_step_x:int,i_step_y:int,i_width:int,i_height:int,i_out_st:int,o_pixel:Vector.<int>):Boolean
	{
		var cpara:Vector.<Number>=this._cparam;
		var ref_x:Vector.<int>=this._ref_x;
		var ref_y:Vector.<int>=this._ref_y;
		var pixcel_temp:Vector.<int>=this._pixcel_temp;
		var raster_width:int=i_raster_size.w;
		var raster_height:int=i_raster_size.h;

		var out_index:int=i_out_st;
		var cpara_6:Number=cpara[6];
		var cpara_0:Number=cpara[0];
		var cpara_3:Number=cpara[3];

		for(var i:int=0;i<i_height;i++){
			//1列分のピクセルのインデックス値を計算する。
			var cy0:int=1+i*i_step_y+i_lt_y;
			var cpy0_12:Number=cpara[1]*cy0+cpara[2];
			var cpy0_45:Number=cpara[4]*cy0+cpara[5];
			var cpy0_7:Number=cpara[7]*cy0+1.0;			
			var pt:int = 0;
			var i2:int;
			for(i2=0;i2<i_width;i2++)
			{
				var cx0:int=1+i2*i_step_x+i_lt_x;				
				var d:Number=cpara_6*cx0+cpy0_7;
				var x:int=(int)((cpara_0*cx0+cpy0_12)/d);
				var y:int=(int)((cpara_3*cx0+cpy0_45)/d);
				if(x<0||y<0||x>=raster_width||y>=raster_height)
				{
					return false;
				}
				ref_x[pt]=x;
				ref_y[pt]=y;
				pt++;
			}
			//1行分のピクセルを取得(場合によっては専用アクセサを書いた方がいい)
			i_reader.getPixelSet(ref_x,ref_y,i_width,pixcel_temp);
			//グレースケールにしながら、line→mapへの転写
			for(i2=0;i2<i_width;i2++){
				var index:int=i2*3;
				o_pixel[out_index]=(pixcel_temp[index+0]+pixcel_temp[index+1]+pixcel_temp[index+2])/3;
				out_index++;
			}			
		}
		return true;
	}
	/**
	 * i_freqにあるゼロクロス点の周期が、等間隔か調べます。
	 * 次段半周期が、前段の80%より大きく、120%未満であるものを、等間隔周期であるとみなします。
	 * @param i_freq
	 * @param i_width
	 */
	private static function checkFreqWidth(i_freq:Vector.<int>,i_width:int):Boolean
	{
		var c:int=i_freq[1]-i_freq[0];
		var count:int=i_width*2-1;
		for (var i:int= 1; i < count; i++) {
			var n:int=i_freq[i+1]-i_freq[i];
			var v:int=n*100/c;
			if(v>150 || v<50){
				return false;
			}
			c=n;
		}
		return true;
	}
	/**
	 * i_freq_count_tableとi_freq_tableの内容を調査し、最も大きな周波数成分を返します。
	 * @param i_freq_count_table
	 * @param i_freq_table
	 * @param o_freq_table
	 * @return
	 * 見つかれば0以上、密辛ければ0未満
	 */
	private static function getMaxFreq(i_freq_count_table:Vector.<int>,i_freq_table:Vector.<int>,o_freq_table:Vector.<int>):int
	{
		//一番成分の大きいものを得る
		var index:int=-1;
		var max:int = 0;
		var i:int;
		for(i=0;i<MAX_FREQ;i++){
			if(max<i_freq_count_table[i]){
				index=i;
				max=i_freq_count_table[i];
			}
		}		
		if(index==-1){
			return -1;
		}
		/*周波数インデクスを計算*/
		var st:int=(index-1)*index;
		for(i=0;i<index*2;i++)
		{
			o_freq_table[i]=i_freq_table[st+i]*FRQ_STEP/max;
		}
		return index;
	}
		
	
	//タイミングパターン用のパラメタ(FRQ_POINTS*FRQ_STEPが100を超えないようにすること)
	private static const FRQ_EDGE:int=5;
	private static const FRQ_STEP:int=2;
	private static const FRQ_POINTS:int=(100-(FRQ_EDGE*2))/FRQ_STEP;
	

	private static const MIN_FREQ:int=3;
	private static const MAX_FREQ:int=10;
	private static const FREQ_SAMPLE_NUM:int=4;
	private static const MAX_DATA_BITS:int=MAX_FREQ+MAX_FREQ-1;

	private var _ref_x:Vector.<int>=new Vector.<int>(108);
	private var _ref_y:Vector.<int>=new Vector.<int>(108);
	//(model+1)*4*3とTHRESHOLD_PIXEL*3のどちらか大きい方
	private var _pixcel_temp:Vector.<int>=new Vector.<int>(108*3);
	
	private var _freq_count_table:Vector.<int>=new Vector.<int>(MAX_FREQ);
	private var _freq_table:Vector.<int>=new Vector.<int>((MAX_FREQ*2-1)*MAX_FREQ*2/2);

	/**
	 * i_y1行目とi_y2行目を平均して、タイミングパターンの周波数を得ます。
	 * LHLを1周期として、たとえばLHLHLの場合は2を返します。LHLHやHLHL等の始端と終端のレベルが異なるパターンを
	 * 検出した場合、関数は失敗します。
	 * 
	 * @param i_y1
	 * @param i_y2
	 * @param i_th_h
	 * @param i_th_l
	 * @param o_edge_index
	 * 検出したエッジ位置(H->L,L->H)のインデクスを受け取る配列です。
	 * [FRQ_POINTS]以上の配列を指定してください。
	 * @return
	 * @throws NyARException
	 */
	public function getRowFrequency(i_reader:INyARRgbPixelReader,i_raster_size:NyARIntSize,i_y1:int,i_th_h:int,i_th_l:int,o_edge_index:Vector.<int>):int
	{
		var i:int;
		//3,4,5,6,7,8,9,10
		var freq_count_table:Vector.<int>=this._freq_count_table;
		//0,2,4,6,8,10,12,14,16,18,20の要素を持つ配列
		var freq_table:Vector.<int>=this._freq_table;
		//初期化
		var cpara:Vector.<Number>=this._cparam;
//		final INyARRgbPixelReader reader=this._raster.getRgbPixelReader();
		var ref_x:Vector.<int>=this._ref_x;
		var ref_y:Vector.<int>=this._ref_y;
		var pixcel_temp:Vector.<int>=this._pixcel_temp;
		for(i=0;i<10;i++){
			freq_count_table[i]=0;
		}
		for(i=0;i<110;i++){
			freq_table[i]=0;
		}
		var raster_width:int=i_raster_size.w;
		var raster_height:int=i_raster_size.h;

		var cpara_0:Number=cpara[0];
		var cpara_3:Number=cpara[3];
		var cpara_6:Number=cpara[6];		
		
		//10-20ピクセル目からタイミングパターンを検出
		for (i = 0; i < FREQ_SAMPLE_NUM; i++) {
			var i2:int;
			//2行分のピクセルインデックスを計算
			var cy0:Number=1+i_y1+i;
			var cpy0_12:Number=cpara[1]*cy0+cpara[2];
			var cpy0_45:Number=cpara[4]*cy0+cpara[5];
			var cpy0_7:Number=cpara[7]*cy0+1.0;

			var pt:int=0;
			for(i2=0;i2<FRQ_POINTS;i2++)
			{
				var cx0:Number=1+i2*FRQ_STEP+FRQ_EDGE;			
				var d:Number=(cpara_6*cx0)+cpy0_7;
				var x:int=(int)((cpara_0*cx0+cpy0_12)/d);
				var y:int=(int)((cpara_3*cx0+cpy0_45)/d);
				if(x<0||y<0||x>=raster_width||y>=raster_height)
				{
					return -1;
				}
				ref_x[pt]=x;
				ref_y[pt]=y;
				pt++;
			}
			
			//ピクセルを取得(入力画像を多様化するならここから先を調整すること)
			i_reader.getPixelSet(ref_x,ref_y,FRQ_POINTS,pixcel_temp);

			//o_edge_indexを一時的に破壊して調査する
			var freq_t:int=getFreqInfo(pixcel_temp,i_th_h,i_th_l,o_edge_index);			
			
			//周期は3-10であること
			if(freq_t<MIN_FREQ || freq_t>MAX_FREQ){
				continue;
			}
			//周期は等間隔であること
			if(!checkFreqWidth(o_edge_index,freq_t)){
				continue;
			}
			//検出カウンタを追加
			freq_count_table[freq_t]++;
			var table_st:int=(freq_t-1)*freq_t;
			for(i2=0;i2<freq_t*2;i2++){
				freq_table[table_st+i2]+=o_edge_index[i2];
			}
		}
		return getMaxFreq(freq_count_table,freq_table,o_edge_index);
	}
	
	public function getColFrequency(i_reader:INyARRgbPixelReader,i_raster_size:NyARIntSize,i_x1:int,i_th_h:int,i_th_l:int,o_edge_index:Vector.<int>):int
	{
		var i:int;
		var cpara:Vector.<Number>=this._cparam;
//		final INyARRgbPixelReader reader=this._raster.getRgbPixelReader();
		var ref_x:Vector.<int>=this._ref_x;
		var ref_y:Vector.<int>=this._ref_y;
		var pixcel_temp:Vector.<int>=this._pixcel_temp;
		//0,2,4,6,8,10,12,14,16,18,20=(11*20)/2=110
		//初期化
		var freq_count_table:Vector.<int>=this._freq_count_table;
		for(i=0;i<10;i++){
			freq_count_table[i]=0;
		}
		var freq_table:Vector.<int> = this._freq_table;
		for(i=0;i<110;i++){
			freq_table[i]=0;
		}
		var raster_width:int=i_raster_size.w;
		var raster_height:int=i_raster_size.h;
		
		
		var cpara7:Number=cpara[7];
		var cpara4:Number=cpara[4];
		var cpara1:Number=cpara[1];
		//基準点から4ピクセルを参照パターンとして抽出
		for (i = 0; i < FREQ_SAMPLE_NUM; i++) {
			var i2:int;

			var cx0:int=1+i+i_x1;
			var cp6_0:Number=cpara[6]*cx0;
			var cpx0_0:Number=cpara[0]*cx0+cpara[2];
			var cpx3_0:Number=cpara[3]*cx0+cpara[5];
			
			var pt:int=0;
			for(i2=0;i2<FRQ_POINTS;i2++)
			{
				var cy:int=1+i2*FRQ_STEP+FRQ_EDGE;
				
				var d:Number=cp6_0+cpara7*cy+1.0;
				var x:int=(int)((cpx0_0+cpara1*cy)/d);
				var y:int=(int)((cpx3_0+cpara4*cy)/d);
				if(x<0||y<0||x>=raster_width||y>=raster_height)
				{
					return -1;
				}
				ref_x[pt]=x;
				ref_y[pt]=y;				
				pt++;
			}		
		
			//ピクセルを取得(入力画像を多様化するならここを調整すること)
			i_reader.getPixelSet(ref_x,ref_y,FRQ_POINTS,pixcel_temp);
			
			var freq_t:int=getFreqInfo(pixcel_temp,i_th_h,i_th_l,o_edge_index);
			//周期は3-10であること
			if(freq_t<MIN_FREQ || freq_t>MAX_FREQ){
				continue;
			}
			//周期は等間隔であること
			if(!checkFreqWidth(o_edge_index,freq_t)){
				continue;
			}
			//検出カウンタを追加
			freq_count_table[freq_t]++;
			var table_st:int=(freq_t-1)*freq_t;
			for(i2=0;i2<freq_t*2;i2++){
				freq_table[table_st+i2]+=o_edge_index[i2];
			}
		}
		return getMaxFreq(freq_count_table,freq_table,o_edge_index);		
	}

	/**
	 * デバックすんだらstaticにしておｋ
	 * @param i_pixcels
	 * @param i_th_h
	 * @param i_th_l
	 * @param o_edge_index
	 * @return
	 */
	private static function getFreqInfo(i_pixcels:Vector.<int>,i_th_h:int,i_th_l:int,o_edge_index:Vector.<int>):int
	{
		//トークンを解析して、周波数を計算
		var i:int=0;
		var frq_l2h:int=0;
		var frq_h2l:int = 0;
		var index:int,pix:int;
		while(i<FRQ_POINTS){
			//L->Hトークンを検出する
			while(i<FRQ_POINTS){
				index=i*3;
				pix=(i_pixcels[index+0]+i_pixcels[index+1]+i_pixcels[index+2])/3;
				if(pix>i_th_h){
					//トークン発見
					o_edge_index[frq_l2h+frq_h2l]=i;
					frq_l2h++;
					break;
				}
				i++;
			}
			i++;
			//L->Hトークンを検出する
			while(i<FRQ_POINTS){
				index=i*3;
				pix=(i_pixcels[index+0]+i_pixcels[index+1]+i_pixcels[index+2])/3;
				if(pix<=i_th_l){
					//トークン発見
					o_edge_index[frq_l2h+frq_h2l]=i;
					frq_h2l++;
					break;
				}
				i++;
			}
			i++;
		}
		return frq_l2h==frq_h2l?frq_l2h:-1;			
	}

	private static const THRESHOLD_EDGE:int=10;
	private static const THRESHOLD_STEP:int=2;
	private static const THRESHOLD_WIDTH:int=10;
	private static const THRESHOLD_PIXEL:int=THRESHOLD_WIDTH/THRESHOLD_STEP;
	private static const THRESHOLD_SAMPLE:int=THRESHOLD_PIXEL*THRESHOLD_PIXEL;
	private static const THRESHOLD_SAMPLE_LT:int=THRESHOLD_EDGE;
	private static const THRESHOLD_SAMPLE_RB:int=100-THRESHOLD_WIDTH-THRESHOLD_EDGE;
	

	/**
	 * ピクセル配列の上位、下位の4ピクセルのピクセル値平均を求めます。
	 * この関数は、(4/i_pixcel.length)の領域を占有するPtail法で双方向の閾値を求めることになります。
	 * @param i_pixcel
	 * @param i_initial
	 * @param i_out
	 */
	private function getPtailHighAndLow(i_pixcel:Vector.<int>,i_out:THighAndLow ):void
	{
		var h3:int,h2:int,h1:int,h0:int,l3:int,l2:int,l1:int,l0:int;
		h3=h2=h1=h0=l3=l2=l1=l0=i_pixcel[0];
		
		for(var i:int=i_pixcel.length-1;i>=1;i--){
			var pix:int=i_pixcel[i];
			if(h0<pix){
				if(h1<pix){
					if(h2<pix){
						if(h3<pix){
							h0=h1;
							h1=h2;
							h2=h3;
							h3=pix;
						}else{
							h0=h1;
							h1=h2;
							h2=pix;
						}
					}else{
						h0=h1;
						h1=pix;
					}
				}else{
					h0=pix;
				}
			}
			if(l0>pix){
				if(l1>pix){
					if(l2>pix){
						if(l3>pix){
							l0=l1;
							l1=l2;
							l2=l3;
							l3=pix;
						}else{
							l0=l1;
							l1=l2;
							l2=pix;
						}
					}else{
						l0=l1;
						l1=pix;
					}
				}else{
					l0=pix;
				}
			}
		}
		i_out.l=(l0+l1+l2+l3)/4;
		i_out.h=(h0+h1+h2+h3)/4;
		return;
	}
	private var __detectThresholdValue_hl:THighAndLow=new THighAndLow();
	private var __detectThresholdValue_tpt:NyARIntPoint2d=new NyARIntPoint2d();
	private var _th_pixels:Vector.<int>=new Vector.<int>(THRESHOLD_SAMPLE*4);
	/**
	 * 指定した場所のピクセル値を調査して、閾値を計算して返します。
	 * @param i_reader
	 * @param i_x
	 * @param i_y
	 * @return
	 * @throws NyARException
	 */
	public function detectThresholdValue(i_reader:INyARRgbPixelReader,i_raster_size:NyARIntSize,o_threshold:TThreshold):void
	{
		var th_pixels:Vector.<int>=this._th_pixels;

		//左上のピックアップ領域からピクセルを得る(00-24)
		rectPixels(i_reader,i_raster_size,THRESHOLD_SAMPLE_LT,THRESHOLD_SAMPLE_LT,THRESHOLD_STEP,THRESHOLD_STEP,THRESHOLD_PIXEL,THRESHOLD_PIXEL,0,th_pixels);
		
		//左下のピックアップ領域からピクセルを得る(25-49)
		rectPixels(i_reader,i_raster_size,THRESHOLD_SAMPLE_LT,THRESHOLD_SAMPLE_RB,THRESHOLD_STEP,THRESHOLD_STEP,THRESHOLD_PIXEL,THRESHOLD_PIXEL,THRESHOLD_SAMPLE,th_pixels);
		
		//右上のピックアップ領域からピクセルを得る(50-74)
		rectPixels(i_reader,i_raster_size,THRESHOLD_SAMPLE_RB,THRESHOLD_SAMPLE_LT,THRESHOLD_STEP,THRESHOLD_STEP,THRESHOLD_PIXEL,THRESHOLD_PIXEL,THRESHOLD_SAMPLE*2,th_pixels);

		//右下のピックアップ領域からピクセルを得る(75-99)
		rectPixels(i_reader,i_raster_size,THRESHOLD_SAMPLE_RB,THRESHOLD_SAMPLE_RB,THRESHOLD_STEP,THRESHOLD_STEP,THRESHOLD_PIXEL,THRESHOLD_PIXEL,THRESHOLD_SAMPLE*3,th_pixels);

		var hl:THighAndLow=this.__detectThresholdValue_hl;
		//Ptailで求めたピクセル平均
		getPtailHighAndLow(th_pixels,hl);


		
		//閾値中心
		var th:int=(hl.h+hl.l)/2;
		//ヒステリシス(差分の20%)
		var th_sub:int=(hl.h-hl.l)/5;
		
		o_threshold.th=th;
		o_threshold.th_h=th+th_sub;//ヒステリシス付き閾値
		o_threshold.th_l=th-th_sub;//ヒステリシス付き閾値

		//エッジを計算(明点重心)
		var lt_x:int,lt_y:int,lb_x:int,lb_y:int,rt_x:int,rt_y:int,rb_x:int,rb_y:int;
		var tpt:NyARIntPoint2d=this.__detectThresholdValue_tpt;
		//LT
		if(getHighPixelCenter(0,th_pixels,THRESHOLD_PIXEL,THRESHOLD_PIXEL,th,tpt)){
			lt_x=tpt.x*THRESHOLD_STEP;
			lt_y=tpt.y*THRESHOLD_STEP;
		}else{
			lt_x=11;
			lt_y=11;
		}
		//LB
		if(getHighPixelCenter(THRESHOLD_SAMPLE*1,th_pixels,THRESHOLD_PIXEL,THRESHOLD_PIXEL,th,tpt)){
			lb_x=tpt.x*THRESHOLD_STEP;
			lb_y=tpt.y*THRESHOLD_STEP;
		}else{
			lb_x=11;
			lb_y=-1;
		}
		//RT
		if(getHighPixelCenter(THRESHOLD_SAMPLE*2,th_pixels,THRESHOLD_PIXEL,THRESHOLD_PIXEL,th,tpt)){
			rt_x=tpt.x*THRESHOLD_STEP;
			rt_y=tpt.y*THRESHOLD_STEP;
		}else{
			rt_x=-1;
			rt_y=11;
		}
		//RB
		if(getHighPixelCenter(THRESHOLD_SAMPLE*3,th_pixels,THRESHOLD_PIXEL,THRESHOLD_PIXEL,th,tpt)){
			rb_x=tpt.x*THRESHOLD_STEP;
			rb_y=tpt.y*THRESHOLD_STEP;
		}else{
			rb_x=-1;
			rb_y=-1;
		}
		//トラッキング開始位置の決定
		o_threshold.lt_x=(lt_x+lb_x)/2+THRESHOLD_SAMPLE_LT-1;
		o_threshold.rb_x=(rt_x+rb_x)/2+THRESHOLD_SAMPLE_RB+1;
		o_threshold.lt_y=(lt_y+rt_y)/2+THRESHOLD_SAMPLE_LT-1;
		o_threshold.rb_y=(lb_y+rb_y)/2+THRESHOLD_SAMPLE_RB+1;
		return;
	}

	private function getHighPixelCenter(i_st:int,i_pixels:Vector.<int>,i_width:int,i_height:int,i_th:int,o_point:NyARIntPoint2d):Boolean
	{
		var rp:int=i_st;
		var pos_x:int=0;
		var pos_y:int=0;
		var number_of_pos:int=0;
		for(var i:int=0;i<i_height;i++){
			for(var i2:int=0;i2<i_width;i2++){
				if(i_pixels[rp++]>i_th){
					pos_x+=i2;
					pos_y+=i;
					number_of_pos++;
				}
			}
		}
		if(number_of_pos>0){
			pos_x/=number_of_pos;
			pos_y/=number_of_pos;
		}else{
			return false;
		}
		o_point.x=pos_x;
		o_point.y=pos_y;
		return true;
	}
	private var __detectDataBitsIndex_freq_index1:Vector.<int>=new Vector.<int>(FRQ_POINTS);
	private var __detectDataBitsIndex_freq_index2:Vector.<int>=new Vector.<int>(FRQ_POINTS);
	private function detectDataBitsIndex(i_reader:INyARRgbPixelReader,i_raster_size:NyARIntSize,i_th:TThreshold,o_index_row:Vector.<Number>,o_index_col:Vector.<Number>):int
	{
		var i:int;
		//周波数を測定
		var freq_index1:Vector.<int>=this.__detectDataBitsIndex_freq_index1;
		var freq_index2:Vector.<int>=this.__detectDataBitsIndex_freq_index2;
		
		var frq_t:int=getRowFrequency(i_reader,i_raster_size,i_th.lt_y,i_th.th_h,i_th.th_l,freq_index1);
		var frq_b:int=getRowFrequency(i_reader,i_raster_size,i_th.rb_y,i_th.th_h,i_th.th_l,freq_index2);
		//周波数はまとも？
		if((frq_t<0 && frq_b<0) || frq_t==frq_b){
			return -1;
		}
		//タイミングパターンからインデクスを作成
		var freq_h:int,freq_v:int;
		var index:Vector.<int>;
		if(frq_t>frq_b){
			freq_h=frq_t;
			index=freq_index1;
		}else{
			freq_h=frq_b;
			index=freq_index2;
		}
		for(i=0;i<freq_h+freq_h-1;i++){
			o_index_row[i*2]=((index[i+1]-index[i])*2/5+index[i])+FRQ_EDGE;
			o_index_row[i*2+1]=((index[i+1]-index[i])*3/5+index[i])+FRQ_EDGE;
		}		
		
		
		var frq_l:int=getColFrequency(i_reader,i_raster_size,i_th.lt_x,i_th.th_h,i_th.th_l,freq_index1);
		var frq_r:int=getColFrequency(i_reader,i_raster_size,i_th.rb_x,i_th.th_h,i_th.th_l,freq_index2);
		//周波数はまとも？
		if((frq_l<0 && frq_r<0) || frq_l==frq_r){
			return -1;
		}
		//タイミングパターンからインデクスを作成
		if(frq_l>frq_r){
			freq_v=frq_l;
			index=freq_index1;
		}else{
			freq_v=frq_r;
			index=freq_index2;
		}
		//同じ周期？
		if(freq_v!=freq_h){
			return -1;
		}
		
		for(i=0;i<freq_v+freq_v-1;i++){
			var w:int=index[i];
			var w2:int= index[i + 1] - w;
			o_index_col[i*2]=((w2)*2/5+w)+FRQ_EDGE;
			o_index_col[i*2+1]=((w2)*3/5+w)+FRQ_EDGE;
		}		
		//Lv4以上は無理
		if(freq_v>MAX_FREQ){
			return -1;
		}
		return freq_v;
		
	}
	private var __readDataBits_index_bit_x:Vector.<Number>=new Vector.<Number>(MAX_DATA_BITS*2);
	private var __readDataBits_index_bit_y:Vector.<Number>=new Vector.<Number>(MAX_DATA_BITS*2);
	
	public function readDataBits(i_reader:INyARRgbPixelReader, i_raster_size:NyARIntSize, i_th:TThreshold, o_bitbuffer:MarkerPattEncoder):Boolean
	{
		var index_x:Vector.<Number>=this.__readDataBits_index_bit_x;
		var index_y:Vector.<Number>=this.__readDataBits_index_bit_y;
		

		//読み出し位置を取得
		var size:int=detectDataBitsIndex(i_reader,i_raster_size,i_th,index_x,index_y);
		var resolution:int=size+size-1;
		if(size<0){
			return false;
		}
		if(!o_bitbuffer.initEncoder(size-1)){
			return false;
		}		
		
		var cpara:Vector.<Number>=this._cparam;
		var ref_x:Vector.<int>=this._ref_x;
		var ref_y:Vector.<int>=this._ref_y;
		var pixcel_temp:Vector.<int>=this._pixcel_temp;
		
		var cpara_0:Number=cpara[0];
		var cpara_1:Number=cpara[1];
		var cpara_3:Number=cpara[3];
		var cpara_6:Number=cpara[6];
		
		
		var th:int=i_th.th;
		var p:int=0;
		for (var i:int = 0; i < resolution; i++) {
			var i2:int;
			//1列分のピクセルのインデックス値を計算する。
			var cy0:Number=1+index_y[i*2+0];
			var cy1:Number=1+index_y[i*2+1];			
			var cpy0_12:Number=cpara_1*cy0+cpara[2];
			var cpy0_45:Number=cpara[4]*cy0+cpara[5];
			var cpy0_7:Number=cpara[7]*cy0+1.0;
			var cpy1_12:Number=cpara_1*cy1+cpara[2];
			var cpy1_45:Number=cpara[4]*cy1+cpara[5];
			var cpy1_7:Number=cpara[7]*cy1+1.0;
			
			var pt:int=0;
			for(i2=0;i2<resolution;i2++)
			{			

				var d:Number;
				var cx0:Number=1+index_x[i2*2+0];
				var cx1:Number=1+index_x[i2*2+1];

				var cp6_0:Number=cpara_6*cx0;
				var cpx0_0:Number=cpara_0*cx0;
				var cpx3_0:Number=cpara_3*cx0;

				var cp6_1:Number=cpara_6*cx1;
				var cpx0_1:Number=cpara_0*cx1;
				var cpx3_1:Number=cpara_3*cx1;
				
				d=cp6_0+cpy0_7;
				ref_x[pt]=(int)((cpx0_0+cpy0_12)/d);
				ref_y[pt]=(int)((cpx3_0+cpy0_45)/d);
				pt++;

				d=cp6_0+cpy1_7;
				ref_x[pt]=(int)((cpx0_0+cpy1_12)/d);
				ref_y[pt]=(int)((cpx3_0+cpy1_45)/d);
				pt++;

				d=cp6_1+cpy0_7;
				ref_x[pt]=(int)((cpx0_1+cpy0_12)/d);
				ref_y[pt]=(int)((cpx3_1+cpy0_45)/d);
				pt++;

				d=cp6_1+cpy1_7;
				ref_x[pt]=(int)((cpx0_1+cpy1_12)/d);
				ref_y[pt]=(int)((cpx3_1+cpy1_45)/d);
				pt++;
			}
			//1行分のピクセルを取得(場合によっては専用アクセサを書いた方がいい)
			i_reader.getPixelSet(ref_x,ref_y,resolution*4,pixcel_temp);
			//グレースケールにしながら、line→mapへの転写
			for(i2=0;i2<resolution;i2++){
				var index:int=i2*3*4;
				var pixel:int=(	pixcel_temp[index+0]+pixcel_temp[index+1]+pixcel_temp[index+2]+
							pixcel_temp[index+3]+pixcel_temp[index+4]+pixcel_temp[index+5]+
							pixcel_temp[index+6]+pixcel_temp[index+7]+pixcel_temp[index+8]+
							pixcel_temp[index+9]+pixcel_temp[index+10]+pixcel_temp[index+11])/(4*3);
				//暗点を1、明点を0で表現します。
				o_bitbuffer.setBitByBitIndex(p,pixel>th?0:1);
				p++;
			}
		}
/*		
		for(int i=0;i<225*4;i++){
			this.vertex_x[i]=0;
			this.vertex_y[i]=0;
		}
		for(int i=0;i<(resolution)*2;i++){
			for(int i2=0;i2<(resolution)*2;i2++){
				this.vertex_x[i*(resolution)*2+i2]=(int)index_x[i2];
				this.vertex_y[i*(resolution)*2+i2]=(int)index_y[i];
				
			}
		}
*/		return true;
	}
	public function setSquare(i_vertex:Vector.<NyARIntPoint2d>):Boolean
	{
		if (!this._param_gen.getParam(i_vertex,this._cparam)) {
			return false;
		}
		return true;
	}

}
class MarkerPattDecoder
{
	public function decode(model:int,domain:int,mask:int):void
	{
	}
}
/**
 * マーカパターンのエンコーダです。
 *
 */
class MarkerPattEncoder
{
	private static const _bit_table_3:Vector.<int>=Vector.<int>([
		25,	26,	27,	28,	29,	30,	31,
		48,	9,	10,	11,	12,	13,	32,
		47,	24,	1,	2,	3,	14,	33,
		46,	23,	8,	0,	4,	15,	34,
		45,	22,	7,	6,	5,	16,	35,
		44,	21,	20,	19,	18,	17,	36,
		43,	42,	41,	40,	39,	38,	37
		]);
	private static const _bit_table_2:Vector.<int>=Vector.<int>([
		9,	10,	11,	12,	13,
		24,	1,	2,	3,	14,
		23,	8,	0,	4,	15,
		22,	7,	6,	5,	16,
		21,	20,	19,	18,	17]);
	private static const _bit_tables:Vector.<Vector.<int>>=Vector.<Vector.<int>>([
		_bit_table_2,_bit_table_3,null,null,null,null,null]);
	/**
	 * RECT(0):[0]=(0)
	 * RECT(1):[1]=(1-8)
	 * RECT(2):[2]=(9-16),[3]=(17-24)
	 * RECT(3):[4]=(25-32),[5]=(33-40),[6]=(41-48)
	 */
	private var _bit_table:Vector.<int>;
	private var _bits:Vector.<int>=new Vector.<int>(16);
	private var _work:Vector.<int>=new Vector.<int>(16);
	private var _model:int;
	public function setBitByBitIndex(i_index_no:int,i_value:int):void
	{
		NyAS3Utils.assert(i_value==0 || i_value==1);
		var bit_no:int=this._bit_table[i_index_no];
		if(bit_no==0){
			this._bits[0]=i_value;
		}else{
			var bidx:int=(bit_no-1)/8+1;
			var sidx:int=(bit_no-1)%8;
			this._bits[bidx]=(this._bits[bidx]&(~(0x01<<sidx)))|(i_value<<sidx);
		}
		return;
	}
	
	public function setBit(i_bit_no:int,i_value:int):void
	{
		NyAS3Utils.assert(i_value==0 || i_value==1);
		if(i_bit_no==0){
			this._bits[0]=i_value;
		}else{
			var bidx:int=(i_bit_no-1)/8+1;
			var sidx:int=(i_bit_no-1)%8;
			this._bits[bidx]=(this._bits[bidx]&(~(0x01<<sidx)))|(i_value<<sidx);
		}
		return;
	}
	public function getBit(i_bit_no:int):int
	{
		if(i_bit_no==0){
			return this._bits[0];
		}else{
			var bidx:int=(i_bit_no-1)/8+1;
			var sidx:int=(i_bit_no-1)%8;
			return (this._bits[bidx]>>(sidx))&(0x01);
		}
	}
	public function getModel():int
	{
		return this._model;
	}
	private static function getControlValue(i_model:int,i_data:Vector.<int>):int
	{
		var v:int;
		switch(i_model){
		case 2:
			v=(i_data[2] & 0x0e)>>1;
			return v>=5?v-1:v;
		case 3:
			v=(i_data[4] & 0x3e)>>1;
			return v>=21?v-1:v;
		case 4:
		case 5:
		case 6:
        case 7:
        default:
            break;
		}
		return -1;
	}
	public static function getCheckValue(i_model:int,i_data:Vector.<int>):int
	{
		var v:int;
		switch(i_model){
		case 2:
			v=(i_data[2] & 0xe0)>>5;
			return v>5?v-1:v;
		case 3:
			v=((i_data[4] & 0x80)>>7) |((i_data[5] & 0x0f)<<1);
			return v>21?v-1:v;
		case 4:
		case 5:
		case 6:
        case 7:
        default:
            break;
		}
		return -1;
	}
	public function initEncoder(i_model:int):Boolean
	{
		if(i_model>3 || i_model<2){
			//Lv4以降に対応する時は、この制限を変える。
			return false;
		}
		this._bit_table=_bit_tables[i_model-2];
		this._model=i_model;
		return true;
	}
	private function getDirection():int
	{
		var l:int,t:int,r:int,b:int;
		var timing_pat:int;
		switch(this._model){
		case 2:
			//トラッキングセルを得る
			t=this._bits[2] & 0x1f;
			r=((this._bits[2] & 0xf0)>>4)|((this._bits[3]&0x01)<<4);
			b=this._bits[3] & 0x1f;
			l=((this._bits[3] & 0xf0)>>4)|((this._bits[2]&0x01)<<4);
			timing_pat=0x0a;
			break;
		case 3:
			t=this._bits[4] & 0x7f;
			r=((this._bits[4] & 0xc0)>>6)|((this._bits[5] & 0x1f)<<2);
			b=((this._bits[5] & 0xf0)>>4)|((this._bits[6] & 0x07)<<4);
			l=((this._bits[6] & 0xfc)>>2)|((this._bits[4] & 0x01)<<6);
			timing_pat=0x2a;
			break;
		default:
			return -3;
		}
		//タイミングパターンの比較
		if(t==timing_pat){
			if(r==timing_pat){
				return (b!=timing_pat && l!=timing_pat)?2:-2;
			}else if(l==timing_pat){
				return (b!=timing_pat && r!=timing_pat)?3:-2;
			}
		}else if(b==timing_pat){
			if(r==timing_pat){
				return (t!=timing_pat && l!=timing_pat)?1:-2;
			}else if(l==timing_pat){
				return (t!=timing_pat && r!=timing_pat)?0:-2;
			}
		}
		return -1;
	}
	/**
	 * 格納しているマーカパターンをエンコードして、マーカデータを返します。
	 * @param o_out
	 * @return
	 * 成功すればマーカの方位を返却します。失敗すると-1を返します。
	 */

	public function encode(o_out:NyIdMarkerPattern):int
	{
		var d:int=getDirection();
		if(d<0){
			return -1;
		}
		//回転ビットの取得
		getRotatedBits(d,o_out.data);
		var model:int=this._model;
		//周辺ビットの取得
		o_out.model=model;
		var control_bits:int=getControlValue(model,o_out.data);
		o_out.check=getCheckValue(model,o_out.data);
		o_out.ctrl_mask=control_bits%5;
		o_out.ctrl_domain=control_bits/5;
		if(o_out.ctrl_domain!=0 || o_out.ctrl_mask!=0){
			return -1;
		}
		//マスク解除処理を実装すること
		return d;
	}
	private function getRotatedBits(i_direction:int,o_out:Vector.<int>):void
	{
		var sl:int=i_direction*2;
		var sr:int=8-sl;

		var w1:int;
		o_out[0]=this._bits[0];
		//RECT1
		w1=this._bits[1];
		o_out[1]=((w1<<sl)|(w1>>sr))& 0xff;
		
		//RECT2
		sl=i_direction*4;
		sr=16-sl;
		w1=this._bits[2]|(this._bits[3]<<8);
		w1=(w1<<sl)|(w1>>sr);
		o_out[2]=w1 & 0xff;
		o_out[3]=(w1>>8) & 0xff;

		if(this._model<2){
			return;
		}

		//RECT3
		sl=i_direction*6;
		sr=24-sl;			
		w1=this._bits[4]|(this._bits[5]<<8)|(this._bits[6]<<16);
		w1=(w1<<sl)|(w1>>sr);
		o_out[4]=w1 & 0xff;
		o_out[5]=(w1>>8) & 0xff;
		o_out[6]=(w1>>16) & 0xff;
		
		if(this._model<3){
			return;
		}
		//RECT4(Lv4以降はここの制限を変える)
//		shiftLeft(this._bits,7,3,i_direction*8);
//		if(this._model<4){
//			return;
//		}
		return;
	}
	public function shiftLeft(i_pack:Vector.<int>,i_start:int,i_length:int,i_ls:int):void
	{
		var i:int;
		var work:Vector.<int>=this._work;
		//端数シフト
		var mod_shift:int=i_ls%8;
		for(i=i_length-1;i>=1;i--){
			work[i]=(i_pack[i+i_start]<<mod_shift)|(0xff&(i_pack[i+i_start-1]>>(8-mod_shift)));
		}
		work[0]=(i_pack[i_start]<<mod_shift)|(0xff&(i_pack[i_start+i_length-1]>>(8-mod_shift)));
		//バイトシフト
		var byte_shift:int=(i_ls/8)%i_length;
		for(i=i_length-1;i>=0;i--){
			i_pack[(byte_shift+i)%i_length+i_start]=0xff & work[i];
		}
		return;
	}	
}
class TThreshold
{
	public var th_h:int;
	public var th_l:int;
	public var th:int;
	public var lt_x:int;
	public var lt_y:int;
	public var rb_x:int;
	public var rb_y:int;
}



class THighAndLow{
	public var h:int;
	public var l:int;
}
