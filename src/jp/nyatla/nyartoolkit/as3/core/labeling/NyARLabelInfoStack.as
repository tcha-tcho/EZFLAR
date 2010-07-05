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
//	import jp.nyatla.nyartoolkit.as3.core.types.stack.*;
	import jp.nyatla.as3utils.NyAS3Utils;
	import jp.nyatla.nyartoolkit.as3.NyARException;
	
	public class NyARLabelInfoStack // extends NyARObjectStack
	{
		protected var _items:Vector.<NyARLabelInfo>;
		protected var _length:int;

		public function NyARLabelInfoStack(i_length:int)
		{
			//領域確保
			this._items = createArray(i_length);
			//使用中個数をリセット
			this._length = 0;
			return;
		}
		protected function createArray(i_length:int):Vector.<NyARLabelInfo>
		{
			var ret:Vector.<NyARLabelInfo>= new Vector.<NyARLabelInfo>(i_length);
			for (var i:int =0; i < i_length; i++){
				this._items[i] = new NyARLabelInfo();
			}
			return Vector.<NyARLabelInfo>(ret);
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
			var item:Vector.<NyARLabelInfo>=this._items;
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
		
		/**
		 * 新しい領域を予約します。
		 * @return
		 * 失敗するとnull
		 * @throws NyARException
		 */
		public function prePush():*
		{
			// 必要に応じてアロケート
			if (this._length >= this._items.length){
				return null;
			}
			// 使用領域を+1して、予約した領域を返す。
			var ret:* = this._items[this._length];
			this._length++;
			return ret;
		}
		/**
		 * スタックを初期化します。
		 * @param i_reserv_length
		 * 使用済みにするサイズ
		 * @return
		 */
		public function init(i_reserv_length:int):void
		{
			// 必要に応じてアロケート
			if (i_reserv_length >= this._items.length){
				throw new NyARException();
			}
			this._length=i_reserv_length;
		}	
		
		/** 
		 * 見かけ上の要素数を1減らして、そのオブジェクトを返します。
		 * 返却したオブジェクトの内容は、次回のpushまで有効です。
		 * @return
		 */
		public function pop():*
		{
			NyAS3Utils.assert(this._length>=1);
			this._length--;
			return this._items[this._length];
		}
		/**
		 * 見かけ上の要素数をi_count個減らします。
		 * @param i_count
		 * @return
		 */
		public function pops(i_count:int):void
		{
			NyAS3Utils.assert(this._length>=i_count);
			this._length-=i_count;
			return;
		}	
		/**
		 * 配列を返します。
		 * 
		 * @return
		 */
		public function getArray():Vector.<NyARLabelInfo>
		{
			return this._items;
		}
		public function getItem(i_index:int):NyARLabelInfo
		{
			return this._items[i_index];
		}
		/**
		 * 配列の見かけ上の要素数を返却します。
		 * @return
		 */
		public function getLength():int
		{
			return this._length;
		}
		/**
		 * 見かけ上の要素数をリセットします。
		 */
		public function clear():void
		{
			this._length = 0;
		}
	}
}