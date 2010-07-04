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
package org.libspark.flartoolkit.core.analyzer.raster
{
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.as3utils.*;
	import flash.display.BitmapData;
	
	public class FLARRasterAnalyzer_Histogram extends NyARRasterAnalyzer_Histogram
	{
		public function FLARRasterAnalyzer_Histogram(i_vertical_interval:int)
		{
			super(NyARBufferType.OBJECT_AS3_BitmapData,i_vertical_interval);
		}
		protected override function initInstance(i_raster_format:int,i_vertical_interval:int):Boolean
		{
			if (i_raster_format != NyARBufferType.OBJECT_AS3_BitmapData) {
				return false;
			}else {
				this._vertical_skip = i_vertical_interval;
			}
			return true;
		}
		/**
		 * o_histgramにヒストグラムを出力します。
		 * @param i_input
		 * @param o_histgram
		 * @return
		 * @throws NyARException
		 */
		public override function analyzeRaster(i_input:INyARRaster,o_histgram:NyARHistogram):int
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
			return createHistgram_AS3_BitmapData(i_input, size,h,this._vertical_skip);		
		}
		
		private function createHistgram_AS3_BitmapData(i_reader:INyARRaster,i_size:NyARIntSize,o_histgram:Vector.<int>,i_skip:int):int
		{
			//[Todo:]この方法だとパフォーマンスでないから、Bitmapdataの
			NyAS3Utils.assert (i_reader.isEqualBufferType(NyARBufferType.OBJECT_AS3_BitmapData));
			var input:BitmapData=BitmapData(i_reader.getBuffer());
			for (var y:int = i_size.h-1; y >=0 ; y-=i_skip){
				var pt:int=y*i_size.w;
				for (var x:int = i_size.w - 1; x >= 0; x--) {
					var p:int=input.getPixel(x,y);
					o_histgram[(int)((((p>>8)&0xff)+((p>>16)&0xff)+(p&0xff))/3)]++;
					pt++;
				}
			}
			return i_size.w*i_size.h;
		}
	}
}
