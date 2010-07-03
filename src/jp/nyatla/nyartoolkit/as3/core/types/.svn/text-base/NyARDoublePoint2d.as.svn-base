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
	public class NyARDoublePoint2d
	{
		public var x:Number;
		public var y:Number;
		/**
		 * 配列ファクトリ
		 * @param i_number
		 * @return
		 */
		public static function createArray(i_number:int):Vector.<NyARDoublePoint2d>
		{
			var ret:Vector.<NyARDoublePoint2d>=new Vector.<NyARDoublePoint2d>(i_number);
			for(var i:int=0;i<i_number;i++)
			{
				ret[i]=new NyARDoublePoint2d();
			}
			return ret;
		}
		public function NyARDoublePoint2d(...args:Array)
		{
			switch(args.length) {
			case 0:
				{//public function NyARDoublePoint2d()
					this.x = 0;
					this.y = 0;
				}
				return;
			case 1:
				if(args[0] is NyARDoublePoint2d)
				{
					//public function NyARDoublePoint2d(i_src:NyARDoublePoint2d)
					this.x=args[0].x;
					this.y=args[0].y;
					return;
				}else if (args[0] is NyARIntPoint2d)
				{
					//public function NyARDoublePoint2d(i_src:NyARIntPoint2d)
					this.x=(Number)(args[0].x);
					this.y=(Number)(args[0].y);
					return;
				}
				break;
			case 2:
				{	//public function NyARDoublePoint2d(i_x:Number,i_y:Number)
					this.x = Number(args[0]);
					this.y = Number(args[1]);
					return;
				}
			default:
				break;
			}
			throw new NyARException();
		}	
		public function setValue_NyARDoublePoint2d(i_src:NyARDoublePoint2d):void
		{
			this.x=i_src.x;
			this.y=i_src.y;
			return;
		}
		public function setValue_NyARIntPoint2d(i_src:NyARIntPoint2d):void
		{
			this.x=Number(i_src.x);
			this.y=Number(i_src.y);
			return;
		}
		/**
		 * 格納値をベクトルとして、距離を返します。
		 * @return
		 */
		public function dist():Number
		{
			return Math.sqrt(this.x*this.x+this.y+this.y);
		}
		public function sqNorm():Number
		{
			return this.x*this.x+this.y+this.y;
		}
	}

}