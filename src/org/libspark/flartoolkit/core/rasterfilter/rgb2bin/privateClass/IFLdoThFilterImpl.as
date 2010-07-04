package org.libspark.flartoolkit.core.rasterfilter.rgb2bin.privateClass
{
	import jp.nyatla.nyartoolkit.as3.core.raster.INyARRaster;
	import jp.nyatla.nyartoolkit.as3.core.raster.INyARRaster;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;
	
	/**
	 * 各ラスタ用のフィルタ実装
	 */
	public interface IFLdoThFilterImpl
	{
		function doThFilter(i_input:INyARRaster,i_output:INyARRaster,i_size:NyARIntSize,i_threshold:int):void;
	}
}