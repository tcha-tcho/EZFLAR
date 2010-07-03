package jp.nyatla.nyartoolkit.as3.core.raster.rgb {
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;

	/**
	 * NyARRasterインタフェイスの基本関数/メンバを実装したクラス
	 * 
	 * 
	 */
	public class NyARRgbRaster_BasicClass implements INyARRgbRaster
	{
		protected var _size:NyARIntSize;
		private var _buffer_type:int;
		public function NyARRgbRaster_BasicClass(...args:Array)
		{
			switch(args.length) {
			case 1:
				if (args[0] is NyAS3Const_Inherited) {
					//blank
				}
				break;
			case 2:
				if (args[0] is NyARIntSize && args[1] is int){
					overload_NyARRgbRaster_BasicClass(NyARIntSize(args[0]),int(args[1]));
				}
				break;
			default:
				throw new NyARException();
			}
		}
		protected function overload_NyARRgbRaster_BasicClass(i_size:NyARIntSize,i_buffer_type:int):void
		{
			this._size= i_size;
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
		public function getRgbPixelReader():INyARRgbPixelReader
		{
			throw new NyARException();
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