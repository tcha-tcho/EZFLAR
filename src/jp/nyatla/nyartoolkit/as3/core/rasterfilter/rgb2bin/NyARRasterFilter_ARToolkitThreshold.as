package jp.nyatla.nyartoolkit.as3.core.rasterfilter.rgb2bin
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;


	/**
	 * 定数閾値による2値化をする。
	 * 
	 */
	public class NyARRasterFilter_ARToolkitThreshold implements INyARRasterFilter_Rgb2Bin
	{
		private var _threshold:int;
		private var _do_threshold_impl:IdoThFilterImpl;

		public function NyARRasterFilter_ARToolkitThreshold(i_threshold:int, i_input_raster_type:int)
		{
			this._threshold = i_threshold;
			switch (i_input_raster_type) {
			case NyARBufferType.INT1D_X8R8G8B8_32:
				this._do_threshold_impl=new doThFilterImpl_BUFFERFORMAT_INT1D_X8R8G8B8_32();
				break;
			default:
				throw new NyARException();
			}

			
		}
		/**
		 * 画像を２値化するための閾値。暗点<=th<明点となります。
		 * @param i_threshold
		 */
		public function setThreshold(i_threshold:int ):void 
		{
			this._threshold = i_threshold;
		}
		public function doFilter(i_input:INyARRgbRaster,i_output:NyARBinRaster):void
		{
			NyAS3Utils.assert (i_output.isEqualBufferType(NyARBufferType.INT1D_BIN_8));
			NyAS3Utils.assert (i_input.getSize().isEqualSize_NyARIntSize(i_output.getSize()) == true);
			this._do_threshold_impl.doThFilter(i_input,i_output,i_output.getSize(), this._threshold);
			return;
		}
	}
}
import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.rasterfilter.*;
import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
import jp.nyatla.nyartoolkit.as3.core.types.*;
import jp.nyatla.as3utils.*;
/*
 * ここから各ラスタ用のフィルタ実装
 */
interface IdoThFilterImpl
{
	function doThFilter(i_input:INyARRaster,i_output:INyARRaster,i_size:NyARIntSize,i_threshold:int):void;
}


class doThFilterImpl_BUFFERFORMAT_INT1D_X8R8G8B8_32 implements IdoThFilterImpl
{
	public function doThFilter(i_input:INyARRaster,i_output:INyARRaster,i_size:NyARIntSize,i_threshold:int):void
	{
		NyAS3Utils.assert (i_output.isEqualBufferType(NyARBufferType.INT1D_BIN_8));
		var out_buf:Vector.<int> = (Vector.<int>)(i_output.getBuffer());
		var in_buf:Vector.<int> = (Vector.<int>)(i_input.getBuffer());
		
		var th:int=i_threshold*3;
		var w:int;
		var xy:int;
		var pix_count:int=i_size.h*i_size.w;
		var pix_mod_part:int=pix_count-(pix_count%8);

		for(xy=pix_count-1;xy>=pix_mod_part;xy--){
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
		}
		//タイリング
		for (;xy>=0;) {
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
			w=in_buf[xy];
			out_buf[xy]=(((w>>16)&0xff)+((w>>8)&0xff)+(w&0xff))<=th?0:1;
			xy--;
		}			
	}		
}