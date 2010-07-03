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
package jp.nyatla.nyartoolkit.as3.core.types
{
	import jp.nyatla.nyartoolkit.as3.*;
	public class NyARIntSize
	{
		public var h:int;
		public var w:int;
		/*	public function NyARIntSize()
		 * 	public function NyARIntSize(i_width:int,i_height:int)
		 *	public function NyARIntSize(i_ref_object:NyARIntSize)
		*/
		public function NyARIntSize(...args:Array)
		{
			switch(args.length) {
			case 0:
				{//public function NyARIntSize()
					this.w = 0;
					this.h = 0;
					return;
				}
			case 1:
				if(args[0] is NyARIntSize)
				{
					
					{	//public function NyARIntSize(i_width:int,i_height:int)
						this.w=args[0].w;
						this.h = args[0].h;
						return;
					}
				}
				break;
			case 2:
				{	//public function NyARIntSize(i_ref_object:NyARIntSize)
					this.w=int(args[0]);
					this.h=int(args[1]);
					return;
				}
				break;
			default:
				break;
			}
			throw new NyARException();
		}

		/**
		 * サイズが同一であるかを確認する。
		 * 
		 * @param i_width
		 * @param i_height
		 * @return
		 * @throws NyARException
		 */
		public function isEqualSize_int(i_width:int,i_height:int):Boolean
		{
			if (i_width == this.w && i_height == this.h) {
				return true;
			}
			return false;
		}

		/**
		 * サイズが同一であるかを確認する。
		 * 
		 * @param i_width
		 * @param i_height
		 * @return
		 * @throws NyARException
		 */
		public function isEqualSize_NyARIntSize(i_size:NyARIntSize):Boolean
		{
			if (i_size.w == this.w && i_size.h == this.h) {
				return true;
			}
			return false;

		}
	}
}