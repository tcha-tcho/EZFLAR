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
package jp.nyatla.nyartoolkit.as3.core.analyzer.raster.threshold 
{
	import jp.nyatla.nyartoolkit.as3.core.analyzer.histogram.*;
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.threshold.*;
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;
	
	public class NyARRasterThresholdAnalyzer_SlidePTile implements INyARRasterThresholdAnalyzer
	{
		protected var _raster_analyzer:NyARRasterAnalyzer_Histogram;
		private var _sptile:NyARHistogramAnalyzer_SlidePTile;
		private var _histgram:NyARHistogram;
		public function NyARRasterThresholdAnalyzer_SlidePTile(i_persentage:int, i_raster_format:int, i_vertical_interval:int)
		{
			NyAS3Utils.assert (0 <= i_persentage && i_persentage <= 50);
			//初期化
			if(!initInstance(i_raster_format,i_vertical_interval)){
				throw new NyARException();
			}
			this._sptile=new NyARHistogramAnalyzer_SlidePTile(i_persentage);
			this._histgram=new NyARHistogram(256);
		}
		protected function initInstance(i_raster_format:int,i_vertical_interval:int):Boolean
		{
			this._raster_analyzer=new NyARRasterAnalyzer_Histogram(i_raster_format,i_vertical_interval);
			return true;
		}
		public function setVerticalInterval(i_step:int):void
		{
			this._raster_analyzer.setVerticalInterval(i_step);
			return;
		}

		
		public function analyzeRaster(i_input:INyARRaster):int
		{
			this._raster_analyzer.analyzeRaster(i_input, this._histgram);
			return this._sptile.getThreshold(this._histgram);
		}
	}
}