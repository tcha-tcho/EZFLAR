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
package jp.nyatla.nyartoolkit.as3.core.rasterreader {

	/**
	 * R8G8B8でピクセルを読み出すインタフェイス
	 * 
	 */
	public interface INyARRgbPixelReader {

		/**
		 * 1ピクセルをint配列にして返します。
		 * 
		 * @param i_x
		 * @param i_y
		 * @param o_rgb
		 */
		function getPixel(i_x:int, i_y:int, o_rgb:Vector.<int>):void;

		/**
		 * 複数のピクセル値をi_rgbへ返します。
		 * 
		 * @param i_x
		 * xのインデックス配列
		 * @param i_y
		 * yのインデックス配列
		 * @param i_num
		 * 返すピクセル値の数
		 * @param i_rgb
		 * ピクセル値を返すバッファ
		 */
		function getPixelSet(i_x:Vector.<int>, i_y:Vector.<int>, i_num:int, o_rgb:Vector.<int>):void
		/**
		 * 1ピクセルを設定します。
		 * @param i_x
		 * @param i_y
		 * @param i_rgb
		 * @throws NyARException
		 */
		function setPixel(i_x:int, i_y:int, i_rgb:Vector.<int>):void;
		/**
		 * 複数のピクセル値をint配列から設定します。
		 * @param i_x
		 * @param i_y
		 * @param i_num
		 * @param i_intrgb
		 * @throws NyARException
		 */
		function setPixels(i_x:Vector.<int>, i_y:Vector.<int>, i_num:int, i_intrgb:Vector.<int>):void;
		function switchBuffer(i_ref_buffer:Object):void;

	}
}