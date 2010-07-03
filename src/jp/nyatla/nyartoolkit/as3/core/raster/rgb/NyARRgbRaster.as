package jp.nyatla.nyartoolkit.as3.core.raster.rgb 
{
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;
	
	public class NyARRgbRaster extends NyARRgbRaster_BasicClass
	{
		protected var _buf:Object;
		protected var _reader:INyARRgbPixelReader;
		/**
		 * バッファオブジェクトがアタッチされていればtrue
		 */
		protected var _is_attached_buffer:Boolean;

		
		public function NyARRgbRaster(...args:Array)
		{
			super(NyAS3Const_Inherited);
			switch(args.length) {
			case 1:
				if (args[0] is NyAS3Const_Inherited) {
					//blank
				}
				break;
			case 3:
				overload_NyARRgbRaster3(int(args[0]), int(args[1]),int(args[2]));
				break;
			case 4:
				overload_NyARRgbRaster4(int(args[0]), int(args[1]),int(args[2]),Boolean(args[3]));
				break;
			default:
				throw new NyARException();
			}			
		}
		
		/**
		 * 
		 * @param i_width
		 * @param i_height
		 * @param i_raster_type
		 * NyARBufferTypeに定義された定数値を指定してください。
		 * @param i_is_alloc
		 * @throws NyARException
		 */
		protected function overload_NyARRgbRaster4(i_width:int,i_height:int,i_raster_type:int,i_is_alloc:Boolean):void
		{
			super.overload_NyARRgbRaster_BasicClass(new NyARIntSize(i_width,i_height),i_raster_type);
			if(!initInstance(this._size,i_raster_type,i_is_alloc)){
				throw new NyARException();
			}
		}
		/**
		 * 
		 * @param i_width
		 * @param i_height
		 * @param i_raster_type
		 * NyARBufferTypeに定義された定数値を指定してください。
		 * @throws NyARException
		 */
		protected function overload_NyARRgbRaster3(i_width:int, i_height:int, i_raster_type:int):void
		{
			super.overload_NyARRgbRaster_BasicClass(new NyARIntSize(i_width,i_height),i_raster_type);
			if(!initInstance(this._size,i_raster_type,true)){
				throw new NyARException();
			}
		}
		protected function initInstance(i_size:NyARIntSize,i_raster_type:int,i_is_alloc:Boolean):Boolean
		{
			switch(i_raster_type)
			{
				case NyARBufferType.INT1D_X8R8G8B8_32:
					this._buf=i_is_alloc?new Vector.<int>(i_size.w*i_size.h):null;
					this._reader=new NyARRgbPixelReader_INT1D_X8R8G8B8_32(Vector.<int>(this._buf),i_size);
					break;
				case NyARBufferType.BYTE1D_B8G8R8X8_32:
				case NyARBufferType.BYTE1D_R8G8B8_24:
				default:
					return false;
			}
			this._is_attached_buffer=i_is_alloc;
			return true;
		}
		public override function getRgbPixelReader():INyARRgbPixelReader 
		{
			return this._reader;
		}
		public override function getBuffer():Object
		{
			return this._buf;
		}
		public override function hasBuffer():Boolean
		{
			return this._buf!=null;
		}
		public override function wrapBuffer(i_ref_buf:Object):void
		{
			NyAS3Utils.assert(!this._is_attached_buffer);//バッファがアタッチされていたら機能しない。
			this._buf=i_ref_buf;
			//ピクセルリーダーの参照バッファを切り替える。
			this._reader.switchBuffer(i_ref_buf);
		}
	}



}