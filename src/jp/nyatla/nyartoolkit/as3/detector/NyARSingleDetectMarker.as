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
	import jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.utils.*;
	import jp.nyatla.nyartoolkit.as3.core.pickup.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.*;
	
/**
 * 画像からARCodeに最も一致するマーカーを1個検出し、その変換行列を計算するクラスです。
 * 
 */
public class NyARSingleDetectMarker extends NyARCustomSingleDetectMarker
{
	public static const PF_ARTOOLKIT_COMPATIBLE:int=1;
	public static const PF_NYARTOOLKIT:int=2;
	public static const PF_NYARTOOLKIT_ARTOOLKIT_FITTING:int=100;
	public static const PF_TEST2:int=201;
	
	/**
	 * 検出するARCodeとカメラパラメータから、1個のARCodeを検出するNyARSingleDetectMarkerインスタンスを作ります。
	 * 
	 * @param i_param
	 * カメラパラメータを指定します。
	 * @param i_code
	 * 検出するARCodeを指定します。
	 * @param i_marker_width
	 * ARコードの物理サイズを、ミリメートルで指定します。
	 * @param i_input_raster_type
	 * 入力ラスタのピクセルタイプを指定します。この値は、INyARBufferReaderインタフェイスのgetBufferTypeの戻り値を指定します。
	 * @throws NyARException
	 */
	public function NyARSingleDetectMarker(i_param:NyARParam,i_code:NyARCode,i_marker_width:Number,i_input_raster_type:int,i_profile_id:int=PF_NYARTOOLKIT)
	{
		super();
		initInstance2(i_param,i_code,i_marker_width,i_input_raster_type,i_profile_id);
		return;
	}
	/**
	 * コンストラクタから呼び出す関数です。
	 * @param i_ref_param
	 * @param i_ref_code
	 * @param i_marker_width
	 * @param i_input_raster_type
	 * @param i_profile_id
	 * @throws NyARException
	 */
	protected function initInstance2(
		i_ref_param:NyARParam,
		i_ref_code:NyARCode,
		i_marker_width:Number,
		i_input_raster_type:int,
		i_profile_id:int):void
	{
		var th:NyARRasterFilter_ARToolkitThreshold=new NyARRasterFilter_ARToolkitThreshold(100,i_input_raster_type);
		var patt_inst:INyARColorPatt;
		var sqdetect_inst:NyARSquareContourDetector;
		var transmat_inst:INyARTransMat;

		switch(i_profile_id){
		case PF_NYARTOOLKIT://default
			patt_inst=new NyARColorPatt_Perspective_O2(i_ref_code.getWidth(), i_ref_code.getHeight(),4,25);
			sqdetect_inst=new NyARSquareContourDetector_Rle(i_ref_param.getScreenSize());
			transmat_inst=new NyARTransMat(i_ref_param);
			break;
		default:
			throw new NyARException();
		}
		super.initInstance(patt_inst,sqdetect_inst,transmat_inst,th,i_ref_param,i_ref_code,i_marker_width);
		
	}

	/**
	 * i_imageにマーカー検出処理を実行し、結果を記録します。
	 * 
	 * @param i_raster
	 * マーカーを検出するイメージを指定します。イメージサイズは、コンストラクタで指定i_paramの
	 * スクリーンサイズと一致し、かつi_input_raster_typeに指定した形式でなければいけません。
	 * @return マーカーが検出できたかを真偽値で返します。
	 * @throws NyARException
	 */
	public function detectMarkerLite(i_raster:INyARRgbRaster,i_threshold:int):Boolean
	{
		(NyARRasterFilter_ARToolkitThreshold(this._tobin_filter)).setThreshold(i_threshold);
		return super.detectMarkerLiteB(i_raster);
	}
}


}