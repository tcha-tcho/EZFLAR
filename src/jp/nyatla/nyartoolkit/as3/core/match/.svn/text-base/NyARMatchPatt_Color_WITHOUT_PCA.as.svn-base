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
package jp.nyatla.nyartoolkit.as3.core.match
{
	import jp.nyatla.nyartoolkit.as3.core.*;
	import jp.nyatla.nyartoolkit.as3.*;
	import jp.nyatla.as3utils.*;

	public class NyARMatchPatt_Color_WITHOUT_PCA implements INyARMatchPatt
	{
		protected var _code_patt:NyARCode;

		protected var _optimize_for_mod:int;
		protected var _rgbpixels:int;

		public function NyARMatchPatt_Color_WITHOUT_PCA(...args:Array)
		{
			switch(args.length){
			case 1:
				{	//public function NyARMatchPatt_Color_WITHOUT_PCA(i_code_ref:NyARCode)
					var i_code_ref:NyARCode=NyARCode(args[0]);
					var w:int=i_code_ref.getWidth();
					var h:int=i_code_ref.getHeight();
					//最適化定数の計算
					this._rgbpixels=w*h*3;
					this._optimize_for_mod=this._rgbpixels-(this._rgbpixels%16);
					this.setARCode(i_code_ref);
					return;
				}
				break;
			case 2:
				{	//public function NyARMatchPatt_Color_WITHOUT_PCA(i_width:int,i_height:int)
				
					var i_width:int = int(args[0]), i_height:int = int(args[1]);
					//最適化定数の計算
					this._rgbpixels=i_height*i_width*3;
					this._optimize_for_mod=this._rgbpixels-(this._rgbpixels%16);		
					return;				
				}
				break;
			default:
				break;
			}
			throw new NyARException();
		}
		/**
		 * 比較対象のARCodeをセットします。
		 * @throws NyARException
		 */
		public function setARCode(i_code_ref:NyARCode):void
		{
			this._code_patt=i_code_ref;
			return;
		}
		/**
		 * 現在セットされているARコードとi_pattを比較します。
		 */
		public function evaluate(i_patt:NyARMatchPattDeviationColorData,o_result:NyARMatchPattResult):Boolean
		{
			NyAS3Utils.assert(this._code_patt!=null);
			//
			var linput:Vector.<int> = i_patt.refData();
			var sum:int;
			var max:Number = Number.MIN_VALUE;
			var res:int = NyARMatchPattResult.DIRECTION_UNKNOWN;
			var for_mod:int=this._optimize_for_mod;
			for (var j:int = 0; j < 4; j++) {
				//合計値初期化
				sum=0;
				var code_patt:NyARMatchPattDeviationColorData=this._code_patt.getColorData(j);
				var pat_j:Vector.<int> = code_patt.refData();
				//<全画素について、比較(FORの1/16展開)>
				var i:int;
				for(i=this._rgbpixels-1;i>=for_mod;i--){
					sum += linput[i] * pat_j[i];
				}
				for (;i>=0;) {
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
					sum += linput[i] * pat_j[i];i--;
				}
				//<全画素について、比較(FORの1/16展開)/>
				var sum2:Number = sum / code_patt.getPow();// sum2 = sum / patpow[k][j]/ datapow;
				if (sum2 > max) {
					max = sum2;
					res = j;
				}
			}
			o_result.direction = res;
			o_result.confidence= max/i_patt.getPow();
			return true;		
		}
	}
}