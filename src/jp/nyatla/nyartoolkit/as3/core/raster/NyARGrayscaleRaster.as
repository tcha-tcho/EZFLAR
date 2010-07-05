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
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.utils.as3.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;
	
	public final class NyARGrayscaleRaster extends NyARRaster_BasicClass
	{

		protected var _buf:Object;
		/**
		 * バッファオブジェクトがアタッチされていればtrue
		 */
		protected var _is_attached_buffer: Boolean;
		public function NyARGrayscaleRaster(...args:Array)
		{
			super(NyAS3Const_Inherited);
			switch(args.length) {
			case 1:
				if (args[0] is NyAS3Const_Inherited) {
					//blank
				}
				break;
			case 2:
				//(int,int)
				overload_NyARGrayscaleRaster2(int(args[0]), int(args[1]));
				break;
			case 3:
				//(int,int,boolean)
				overload_NyARGrayscaleRaster3(int(args[0]), int(args[1]),Boolean(args[2]));
				break;
			case 4:
				//(int,int,int,boolean)
				overload_NyARGrayscaleRaster4(int(args[0]), int(args[1]),int(args[2]),Boolean(args[3]));
				break;
			default:
				throw new NyARException();
			}			
		}

		protected function overload_NyARGrayscaleRaster2(i_width:int,i_height:int):void
		{
			super.overload_NyARRaster_BasicClass(i_width,i_height,NyARBufferType.INT1D_GRAY_8);
			if(!initInstance(this._size,NyARBufferType.INT1D_GRAY_8,true)){
				throw new NyARException();
			}
		}	
		protected function overload_NyARGrayscaleRaster3(i_width:int,i_height:int,i_is_alloc:Boolean):void
		{
			super.overload_NyARRaster_BasicClass(i_width,i_height,NyARBufferType.INT1D_GRAY_8);
			if(!initInstance(this._size,NyARBufferType.INT1D_GRAY_8,i_is_alloc)){
				throw new NyARException();
			}
		}
		/**
		 * @param i_width
		 * @param i_height
		 * @param i_raster_type
		 * NyARBufferTypeに定義された定数値を指定してください。
		 * @param i_is_alloc
		 * @throws NyARException
		 */
		protected function overload_NyARGrayscaleRaster4(i_width:int, i_height:int, i_raster_type:int, i_is_alloc:Boolean):void
		{
			super.overload_NyARRaster_BasicClass(i_width,i_height,i_raster_type);
			if(!initInstance(this._size,i_raster_type,i_is_alloc)){
				throw new NyARException();
			}
		}
		protected function initInstance(i_size:NyARIntSize,i_buf_type:int,i_is_alloc:Boolean):Boolean
		{
			switch(i_buf_type)
			{
				case NyARBufferType.INT1D_GRAY_8:
					this._buf =i_is_alloc?new Vector.<int>(i_size.w*i_size.h):null;
					break;
				default:
					return false;
			}
			this._is_attached_buffer=i_is_alloc;
			return true;
		}
		public override function getBuffer():Object
		{
			return this._buf;
		}
		/**
		 * インスタンスがバッファを所有するかを返します。
		 * コンストラクタでi_is_allocをfalseにしてラスタを作成した場合、
		 * バッファにアクセスするまえに、バッファの有無をこの関数でチェックしてください。
		 * @return
		 */
		public override function hasBuffer():Boolean
		{
			return this._buf!=null;
		}
		public override function wrapBuffer(i_ref_buf:Object):void
		{
			NyAS3Utils.assert(!this._is_attached_buffer);//バッファがアタッチされていたら機能しない。
			this._buf=i_ref_buf;
		}	
	}

}