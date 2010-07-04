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
package org.libspark.flartoolkit.core.raster.rgb
{
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import org.libspark.flartoolkit.core.rasterreader.*;
	import flash.display.BitmapData;

	public class FLARRgbRaster_BitmapData extends NyARRgbRaster_BasicClass
	{
		private var _bitmapData:BitmapData;
		private var _rgb_reader:FLARRgbPixelReader_BitmapData;

		public function FLARRgbRaster_BitmapData(i_width:int,i_height:int)
		{
			super(new NyARIntSize(i_width, i_height),NyARBufferType.OBJECT_AS3_BitmapData);
			this._bitmapData = new BitmapData(i_width,i_height,false);
			this._rgb_reader = new FLARRgbPixelReader_BitmapData(this._bitmapData);
		}
		public override function getRgbPixelReader():INyARRgbPixelReader
		{
			return this._rgb_reader;
		}
		public override function getBuffer():Object
		{
			return this._bitmapData;
		}
		public override function hasBuffer():Boolean
		{
			return this._bitmapData != null;
		}
	}
}

