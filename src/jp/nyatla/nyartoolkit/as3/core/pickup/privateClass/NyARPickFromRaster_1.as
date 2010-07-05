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
package jp.nyatla.nyartoolkit.as3.core.pickup.privateClass
{
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.INyARRgbRaster;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.INyARRgbPixelReader;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntPoint2d;
	import jp.nyatla.nyartoolkit.as3.core.types.NyARIntSize;
	
	/**
	 * チェックデジット:4127936236942444153655776299710081208144715171590159116971715177917901890204024192573274828522936312731813388371037714083
	 *
	 */
	public class NyARPickFromRaster_1 implements IpickFromRaster_Impl
	{
		protected var _size_ref:NyARIntSize;
		protected var _lt_ref:NyARIntPoint2d;
		
		public function NyARPickFromRaster_1(i_lt:NyARIntPoint2d,i_source_size:NyARIntSize)
		{
			this._lt_ref=i_lt;
			this._size_ref=i_source_size;
			
			this._rgb_temp=new Vector.<int>(i_source_size.w*3);
			this._rgb_px=new Vector.<int>(i_source_size.w);
			this._rgb_py=new Vector.<int>(i_source_size.w);
			
			return;
		}
		private var _rgb_temp:Vector.<int>;
		private var _rgb_px:Vector.<int>;
		private var _rgb_py:Vector.<int>;
		
		
		public function pickFromRaster(i_cpara:Vector.<Number>, image:INyARRgbRaster, o_patt:Vector.<int>):void
		{
			var d0:Number,m0:Number;
			var x:int,y:int;
			
			var img_x:int = image.getWidth();
			var img_y:int = image.getHeight();
			var patt_w:int=this._size_ref.w;
			
			var rgb_tmp:Vector.<int> = this._rgb_temp;
			var rgb_px:Vector.<int>=this._rgb_px;
			var rgb_py:Vector.<int>=this._rgb_py;	
			
			
			
			var cp0:Number=i_cpara[0];
			var cp3:Number=i_cpara[3];
			var cp6:Number=i_cpara[6];
			var cp1:Number=i_cpara[1];
			var cp4:Number=i_cpara[4];
			var cp7:Number=i_cpara[7];
			
			
			var pick_y:int=this._lt_ref.y;
			var pick_x:int=this._lt_ref.x;
			//ピクセルリーダーを取得
			var reader:INyARRgbPixelReader=image.getRgbPixelReader();
			var p:int=0;
			
			
			var cp0cx0:Number,cp3cx0:Number;
			var cp1cy_cp20:Number=cp1*pick_y+i_cpara[2]+cp0*pick_x;
			var cp4cy_cp50:Number=cp4*pick_y+i_cpara[5]+cp3*pick_x;
			var cp7cy_10:Number=cp7*pick_y+1.0+cp6*pick_x;
			
			
			for(var iy:int=this._size_ref.h-1;iy>=0;iy--){
				m0=1/(cp7cy_10);
				d0=-cp6/(cp7cy_10*(cp7cy_10+cp6));			
				
				cp0cx0=cp1cy_cp20;
				cp3cx0=cp4cy_cp50;
				
				//ピックアップシーケンス
				
				//0番目のピクセル(検査対象)をピックアップ
				
				var ix:int;
				for(ix=patt_w-1;ix>=0;ix--){
					//1ピクセルを作成
					x=rgb_px[ix]=(int)(cp0cx0*m0);
					y=rgb_py[ix]=(int)(cp3cx0*m0);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[ix]=0;}else if(x>=img_x){rgb_px[ix]=img_x-1;}
						if(y<0){rgb_py[ix]=0;}else if(y>=img_y){rgb_py[ix]=img_y-1;}			
					}
					cp0cx0+=cp0;
					cp3cx0+=cp3;
					m0+=d0;
				}
				
				cp1cy_cp20+=cp1;
				cp4cy_cp50+=cp4;
				cp7cy_10+=cp7;
				
				reader.getPixelSet(rgb_px, rgb_py,patt_w, rgb_tmp);
				for(ix=patt_w-1;ix>=0;ix--){
					var idx:int=ix*3;
					o_patt[p]=(rgb_tmp[idx]<<16)|(rgb_tmp[idx+1]<<8)|((rgb_tmp[idx+2]&0xff));
					p++;
				}
			}
			
			return;
		}
	}
}