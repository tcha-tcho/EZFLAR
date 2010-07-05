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
package jp.nyatla.nyartoolkit.as3.core.raster
{
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;

	public class NyARRaster_BasicClass implements INyARRaster
	{
		protected var _size:NyARIntSize;
		private var _buffer_type:int;
		/*
		 * public function NyARRaster_BasicClass(int i_width,int i_height,int i_buffer_type)
		 */
		public function NyARRaster_BasicClass(...args:Array)
		{
			switch(args.length) {
			case 1:
				if (args[0] is NyAS3Const_Inherited) {
					//blank
				}
				break;
			case 3:
				if (args[0] is int && args[1] is int && args[2] is int){
					overload_NyARRaster_BasicClass(int(args[0]),int(args[1]),int(args[2]));
				}
				break;
			default:
				throw new NyARException();
			}
		}
		protected function overload_NyARRaster_BasicClass(i_width:int ,i_height:int,i_buffer_type:int):void
		{
			this._size = new NyARIntSize(i_width, i_height);
			this._buffer_type=i_buffer_type;
		}

		final public function getWidth():int
		{
			return this._size.w;
		}

		final public function getHeight():int
		{
			return this._size.h;
		}

		final public function getSize():NyARIntSize
		{
			return this._size;
		}
		final public function getBufferType():int
		{
			return _buffer_type;
		}
		final public function isEqualBufferType(i_type_value:int):Boolean
		{
			return this._buffer_type==i_type_value;
		}

		public function getBuffer():Object
		{
			throw new NyARException();
		}
		public function hasBuffer():Boolean
		{
			throw new NyARException();
		}		
		public function wrapBuffer(i_ref_buf:Object):void
		{
			throw new NyARException();
		}
		

		
	}
}