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
package jp.nyatla.nyartoolkit.as3.core.labeling 
{
	import jp.nyatla.nyartoolkit.as3.core.types.stack.*;
	
	public class NyARLabelInfoStack extends NyARObjectStack
	{
		public function NyARLabelInfoStack(i_length:int)
		{
			super(i_length);
		}
		protected override function createArray(i_length:int):Vector.<*>
		{
			var ret:Vector.<NyARLabelInfo>= new Vector.<NyARLabelInfo>(i_length);
			for (var i:int =0; i < i_length; i++){
				this._items[i] = new NyARLabelInfo();
			}
			return Vector.<*>(ret);
		}		

		/**
		 * エリアの大きい順にラベルをソートします。
		 */
		public function sortByArea():void
		{
			var len:int=this._length;
			if(len<1){
				return;
			}
			var h:int = len *13/10;
			var item:Vector.<*>=this._items;
			for(;;){
				var swaps:int = 0;
				for (var i:int = 0; i + h < len; i++) {
					if (item[i + h].area > item[i].area) {
						var temp:NyARLabelInfo = item[i + h];
						item[i + h] = item[i];
						item[i] = temp;
						swaps++;
					}
				}
				if (h == 1) {
					if (swaps == 0){
						break;
					}
				}else{
					h=h*10/13;
				}
			}
		}
	}
}