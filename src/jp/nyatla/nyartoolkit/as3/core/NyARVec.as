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
package jp.nyatla.nyartoolkit.as3.core
{

	public class NyARVec
	{
		private var clm:int;
		public function NyARVec(i_clm:int)
		{
			this.v = new Vector.<Number>(i_clm);
			clm = i_clm;
		}

		private var v:Vector.<Number>;

		public function getClm():int
		{
			return clm;
		}
		public function getArray():Vector.<Number>
		{
			return v;
		}

//		*****************************
//		There are not used by NyARToolKit.
//		*****************************
//		public function realloc(i_clm:int):void
//		public function arVecDisp():int
//		public function vecInnerproduct(y:NyARVec,i_start:int):Number
//		public function vecHousehold(i_start:int):Number
//		public function setNewArray(double[] i_array:Vector.<Number>,i_clm:int):void
	}
}