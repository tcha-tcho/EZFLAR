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
package jp.nyatla.nyartoolkit.as3.core.analyzer.raster 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.as3utils.*;
	
	public class NyARRasterAnalyzer_Histogram
	{
		protected var _histImpl:ICreateHistogramImpl;
		/**
		 * ヒストグラム解析の縦方向スキップ数。継承クラスはこのライン数づつ
		 * スキップしながらヒストグラム計算を行うこと。
		 */
		protected var _vertical_skip:int;
		
		
		public function NyARRasterAnalyzer_Histogram(i_raster_format:int, i_vertical_interval:int)
		{
			if(!initInstance(i_raster_format,i_vertical_interval)){
				throw new NyARException();
			}
		}
		protected function initInstance(i_raster_format:int,i_vertical_interval:int):Boolean
		{
			switch (i_raster_format) {
			case NyARBufferType.INT1D_GRAY_8:
				this._histImpl = new NyARRasterThresholdAnalyzer_Histogram_INT1D_GRAY_8();
				break;
			case NyARBufferType.INT1D_X8R8G8B8_32:
				this._histImpl = new NyARRasterThresholdAnalyzer_Histogram_INT1D_X8R8G8B8_32();
				break;
			default:
				return false;
			}
			//初期化
			this._vertical_skip=i_vertical_interval;
			return true;
		}
		public function setVerticalInterval(i_step:int):void
		{
			this._vertical_skip=i_step;
			return;
		}

		/**
		 * o_histgramにヒストグラムを出力します。
		 * @param i_input
		 * @param o_histgram
		 * @return
		 * @throws NyARException
		 */
		public function analyzeRaster(i_input:INyARRaster,o_histgram:NyARHistogram):int
		{
			var size:NyARIntSize=i_input.getSize();
			//最大画像サイズの制限
			NyAS3Utils.assert(size.w*size.h<0x40000000);
			NyAS3Utils.assert(o_histgram.length == 256);//現在は固定

			var  h:Vector.<int>=o_histgram.data;
			//ヒストグラム初期化
			for (var i:int = o_histgram.length-1; i >=0; i--){
				h[i] = 0;
			}
			o_histgram.total_of_data=size.w*size.h/this._vertical_skip;
			return this._histImpl.createHistogram(i_input, size,h,this._vertical_skip);		
		}		
	}
}
import jp.nyatla.nyartoolkit.as3.core.rasterfilter.*;
import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.*;	
import jp.nyatla.as3utils.*;
import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
import jp.nyatla.nyartoolkit.as3.core.types.*;

interface ICreateHistogramImpl
{
	function createHistogram(i_reader:INyARRaster,i_size:NyARIntSize,o_histgram:Vector.<int>,i_skip:int):int;
}

class NyARRasterThresholdAnalyzer_Histogram_INT1D_GRAY_8 implements ICreateHistogramImpl
{
	public function createHistogram(i_reader:INyARRaster,i_size:NyARIntSize,o_histgram:Vector.<int>,i_skip:int):int
	{
		NyAS3Utils.assert (i_reader.isEqualBufferType(NyARBufferType.INT1D_GRAY_8));
		var input:Vector.<int>=(Vector.<int>)(i_reader.getBuffer());
		for (var y:int = i_size.h-1; y >=0 ; y-=i_skip){
			var pt:int=y*i_size.w;
			for (var x:int = i_size.w-1; x >=0; x--) {
				o_histgram[input[pt]]++;
				pt++;
			}
		}
		return i_size.w*i_size.h;
	}	
}

class NyARRasterThresholdAnalyzer_Histogram_INT1D_X8R8G8B8_32 implements ICreateHistogramImpl
{
	public function createHistogram(i_reader:INyARRaster,i_size:NyARIntSize,o_histgram:Vector.<int>,i_skip:int):int
	{
		NyAS3Utils.assert (i_reader.isEqualBufferType(NyARBufferType.INT1D_X8R8G8B8_32));
		var input:Vector.<int> =Vector.<int>(i_reader.getBuffer());
		for (var y:int = i_size.h-1; y >=0 ; y-=i_skip){
			var pt:int=y*i_size.w;
			for (var x:int = i_size.w-1; x >=0; x--) {
				var p:int=input[pt];
				o_histgram[((p& 0xff)+(p& 0xff)+(p& 0xff))/3]++;
				pt++;
			}
		}
		return i_size.w*i_size.h;
	}	
}

