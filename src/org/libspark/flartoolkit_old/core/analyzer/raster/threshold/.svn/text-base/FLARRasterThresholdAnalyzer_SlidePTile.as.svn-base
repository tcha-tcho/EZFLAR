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
package org.libspark.flartoolkit.core.analyzer.raster.threshold 
{
	import jp.nyatla.nyartoolkit.as3.core.analyzer.histogram.*;
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.threshold.*;
	import jp.nyatla.nyartoolkit.as3.core.analyzer.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.as3utils.*;
	
	import org.libspark.flartoolkit.core.analyzer.raster.threshold.*;
	import org.libspark.flartoolkit.core.analyzer.raster.*;
	
	public class FLARRasterThresholdAnalyzer_SlidePTile extends NyARRasterThresholdAnalyzer_SlidePTile
	{
		public function FLARRasterThresholdAnalyzer_SlidePTile(i_persentage:int, i_vertical_interval:int)
		{
			super(i_persentage, NyARBufferType.OBJECT_AS3_BitmapData,i_vertical_interval);
		}
		protected override function initInstance(i_raster_format:int,i_vertical_interval:int):Boolean
		{
			if (i_raster_format != NyARBufferType.OBJECT_AS3_BitmapData) {
				return false;
			}
			this._raster_analyzer=new FLARRasterAnalyzer_Histogram(i_vertical_interval);
			return true;
		}
	}
}