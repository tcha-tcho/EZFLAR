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
package jp.nyatla.nyartoolkit.as3.core.utils 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	public class NyARMath
	{
		/**
		 * p2-p1ベクトルのsquare normを計算する。
		 * @param i_p1
		 * @param i_p2
		 * @return
		 */
		public static function sqNorm_NyARDoublePoint2d(i_p1:NyARDoublePoint2d,i_p2:NyARDoublePoint2d ):Number
		{
			var x:Number,y:Number;
			x=i_p2.x-i_p1.x;
			y=i_p2.y-i_p1.y;
			return x*x+y*y;
		}
		public static function sqNorm_Number(i_p1x:Number,i_p1y:Number,i_p2x:Number,i_p2y:Number):Number
		{
			var x:Number,y:Number;
			x=i_p2x-i_p1x;
			y=i_p2y-i_p1y;
			return x*x+y*y;
		}
		/**
		 * p2-p1ベクトルのsquare normを計算する。
		 * @param i_p1
		 * @param i_p2
		 * @return
		 */	
		public static function sqNorm_NyARDoublePoint3d(i_p1:NyARDoublePoint3d,i_p2:NyARDoublePoint3d):Number
		{
			var x:Number, y:Number, z:Number;
			x=i_p2.x-i_p1.x;
			y=i_p2.y-i_p1.y;
			z=i_p2.z-i_p1.z;
			return x*x+y*y+z*z;
		}
		/**
		 * 3乗根を求められないシステムで、３乗根を求めます。
		 * http://aoki2.si.gunma-u.ac.jp/JavaScript/src/3jisiki.html
		 * @param i_in
		 * @return
		 */
		public static function cubeRoot(i_in:Number):Number
		{
			var res:Number = Math.pow(Math.abs(i_in), 1.0 / 3.0);
			return (i_in >= 0) ? res : -res;
		}

	}


}