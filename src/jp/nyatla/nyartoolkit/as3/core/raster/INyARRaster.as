package jp.nyatla.nyartoolkit.as3.core.raster {
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;			

	public interface INyARRaster
	{
		function getWidth():int;
		function getHeight():int;
		function getSize():NyARIntSize;
		/**
		 * バッファオブジェクトを返します。
		 * @return
		 */
		function getBuffer():Object;
		/**
		 * バッファオブジェクトのタイプを返します。
		 * @return
		 */
		function getBufferType():int;
		/**
		 * バッファのタイプがi_type_valueであるか、チェックします。
		 * この値は、NyARBufferTypeに定義された定数値です。
		 * @param i_type_value
		 * @return
		 */
		function isEqualBufferType(i_type_value:int):Boolean;
		/**
		 * getBufferがオブジェクトを返せるかの真偽値です。
		 * @return
		 */
		function hasBuffer():Boolean;
		/**
		 * i_ref_bufをラップします。できる限り整合性チェックを行います。
		 * バッファの再ラッピングが可能な関数のみ、この関数を実装してください。
		 * @param i_ref_buf
		 */
		function wrapBuffer(i_ref_buf:Object):void;
	}
}