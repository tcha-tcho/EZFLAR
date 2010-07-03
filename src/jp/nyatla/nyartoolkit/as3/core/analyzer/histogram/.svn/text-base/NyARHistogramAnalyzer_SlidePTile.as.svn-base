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
package jp.nyatla.nyartoolkit.as3.core.analyzer.histogram 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.as3utils.*;
	public class NyARHistogramAnalyzer_SlidePTile implements INyARHistogramAnalyzer_Threshold
	{
		private var _persentage:int;
		public function NyARHistogramAnalyzer_SlidePTile(i_persentage:int)
		{
			NyAS3Utils.assert (0 <= i_persentage && i_persentage <= 50);
			//初期化
			this._persentage=i_persentage;
		}	
		public function getThreshold(i_histgram:NyARHistogram):int
		{
			//総ピクセル数を計算
			var n:int=i_histgram.length;
			var sum_of_pixel:int=i_histgram.total_of_data;
			var hist:Vector.<int>=i_histgram.data;
			// 閾値ピクセル数確定
			var th_pixcels:int = sum_of_pixel * this._persentage / 100;
			var th_wk:int;
			var th_w:int, th_b:int;

			// 黒点基準
			th_wk = th_pixcels;
			for (th_b = 0; th_b < n-2; th_b++) {
				th_wk -= hist[th_b];
				if (th_wk <= 0) {
					break;
				}
			}
			// 白点基準
			th_wk = th_pixcels;
			for (th_w = n-1; th_w > 1; th_w--) {
				th_wk -= hist[th_w];
				if (th_wk <= 0) {
					break;
				}
			}
			// 閾値の保存
			return (th_w + th_b) / 2;
		}
	}


}