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
package jp.nyatla.nyartoolkit.as3.core.rasterreader 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.utils.NyAREquationSolver;
	import jp.nyatla.as3utils.*;
	public class NyARRgbPixelReader_INT1D_X8R8G8B8_32 implements INyARRgbPixelReader
	{
		protected var _ref_buf:Vector.<int>;

		private var _size:NyARIntSize;

		public function NyARRgbPixelReader_INT1D_X8R8G8B8_32(i_buf:Vector.<int>, i_size:NyARIntSize)
		{
			this._ref_buf = i_buf;
			this._size = i_size;
		}

		public function getPixel(i_x:int,i_y:int,o_rgb:Vector.<int>):void
		{
			var rgb:int= this._ref_buf[i_x + i_y * this._size.w];
			o_rgb[0] = (rgb>>16)&0xff;// R
			o_rgb[1] = (rgb>>8)&0xff;// G
			o_rgb[2] = rgb&0xff;// B
			return;
		}

		public function getPixelSet(i_x:Vector.<int>,i_y:Vector.<int>,i_num:int, o_rgb:Vector.<int>):void
		{
			var width:int = this._size.w;
			var ref_buf:Vector.<int> = this._ref_buf;
			for (var i:int = i_num - 1; i >= 0; i--) {
				var rgb:int=ref_buf[i_x[i] + i_y[i] * width];
				o_rgb[i * 3 + 0] = (rgb>>16)&0xff;// R
				o_rgb[i * 3 + 1] = (rgb>>8)&0xff;// G
				o_rgb[i * 3 + 2] = rgb&0xff;// B
			}
			return;
		}
		public function setPixel(i_x:int,i_y:int,i_rgb:Vector.<int>):void
		{
			this._ref_buf[i_x + i_y * this._size.w]=((i_rgb[0]<<16)&0xff)|((i_rgb[1]<<8)&0xff)|((i_rgb[2])&0xff);
		}
		public function setPixels(i_x:Vector.<int>,i_y:Vector.<int>, i_num:int,i_intrgb:Vector.<int>):void
		{
			throw new NyARException();		
		}
		/**
		 * 参照しているバッファをi_ref_bufferへ切り替えます。
		 * 内部パラメータのチェックは、実装依存です。
		 * @param i_ref_buffer
		 * @throws NyARException
		 */
		public function switchBuffer(i_ref_buffer:Object):void
		{
			NyAS3Utils.assert((Vector.<int>(i_ref_buffer)).length>=this._size.w*this._size.h);
			this._ref_buf = Vector.<int>(i_ref_buffer);
		}
		
	}


}