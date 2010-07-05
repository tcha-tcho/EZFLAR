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
package jp.nyatla.nyartoolkit.as3.utils.as3
{
	public class ArrayUtils
	{
		public static function create2dInt(height:int, width:int):Vector.<Vector.<int>>
		{
			var r:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(height); 
			for (var i:int = 0; i < height; i++){
				r[i] = new Vector.<int>(width);
			}
			return r;
		}
		public static function create2dNumber(height:int, width:int):Vector.<Vector.<Number>>
		{
			var r:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(height); 
			for (var i:int = 0; i < height; i++){
				r[i] = new Vector.<Number>(width);
			}
			return r;
		}
		public static function copyInt(src:Vector.<int>, srcPos:int, dest:Vector.<int>, destPos:int, length:int):void {
			for (var i:int = 0; i < length; i++) {
				dest[destPos + i] = src[srcPos + i]; 
			}
		}
	}
}