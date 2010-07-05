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
	 * 4x4
	 *
	 */
	public class NyARPickFromRaster_4x implements IpickFromRaster_Impl
	{
		protected var _size_ref:NyARIntSize;
		protected var _lt_ref:NyARIntPoint2d;
		
		public function NyARPickFromRaster_4x(i_lt:NyARIntPoint2d,i_source_size:NyARIntSize)
		{
			this._lt_ref=i_lt;
			this._size_ref=i_source_size;
			
			this._rgb_temp=new Vector.<int>(4*4*3);
			this._rgb_px=new Vector.<int>(4*4);
			this._rgb_py=new Vector.<int>(4*4);
			return;
		}
		private var _rgb_temp:Vector.<int>;
		private var _rgb_px:Vector.<int>;
		private var _rgb_py:Vector.<int>;
		
		public function pickFromRaster(i_cpara:Vector.<Number>, image:INyARRgbRaster, o_patt:Vector.<int>):void
		{
			var x:int,y:int;
			var d:Number,m:Number;
			var cp6cx:Number,cp0cx:Number,cp3cx:Number;
			var rgb_px:Vector.<int>=this._rgb_px;
			var rgb_py:Vector.<int>=this._rgb_py;
			
			var r:int,g:int,b:int;		
			//遠近法のパラメータを計算
			
			var img_x:int = image.getWidth();
			var img_y:int = image.getHeight();
			var rgb_tmp:Vector.<int> = this._rgb_temp;
			var cp0:Number=i_cpara[0];
			var cp3:Number=i_cpara[3];
			var cp6:Number=i_cpara[6];
			var cp1:Number=i_cpara[1];
			var cp2:Number=i_cpara[2];
			var cp4:Number=i_cpara[4];
			var cp5:Number=i_cpara[5];
			var cp7:Number=i_cpara[7];
			
			var pick_lt_x:int=this._lt_ref.x;
			//ピクセルリーダーを取得
			var reader:INyARRgbPixelReader=image.getRgbPixelReader();
			
			var p:int=0;
			var py:int=this._lt_ref.y;
			for(var iy:int=this._size_ref.h-1;iy>=0;iy--,py+=4){
				var cp1cy_cp2_0:Number=cp1*py+cp2;
				var cp4cy_cp5_0:Number=cp4*py+cp5;
				var cp7cy_1_0:Number  =cp7*py+1.0;
				
				var cp1cy_cp2_1:Number=cp1cy_cp2_0+cp1;
				var cp1cy_cp2_2:Number=cp1cy_cp2_1+cp1;
				var cp1cy_cp2_3:Number=cp1cy_cp2_2+cp1;
				
				var cp4cy_cp5_1:Number=cp4cy_cp5_0+cp4;
				var cp4cy_cp5_2:Number=cp4cy_cp5_1+cp4;
				var cp4cy_cp5_3:Number=cp4cy_cp5_2+cp4;
				
				var px:int=pick_lt_x;
				//解像度分の点を取る。
				for(var ix:int=this._size_ref.w-1;ix>=0;ix--,px+=4){
					
					cp6cx=cp6*px;
					cp0cx=cp0*px;				
					cp3cx=cp3*px;
					
					cp6cx+=cp7cy_1_0;
					m=1/cp6cx;
					d=-cp7/((cp6cx+cp7)*cp6cx);			
					
					//1ピクセルを作成[0,0]
					x=rgb_px[0]=(int)((cp0cx+cp1cy_cp2_0)*m);
					y=rgb_py[0]=(int)((cp3cx+cp4cy_cp5_0)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[0]=0;} else if(x>=img_x){rgb_px[0]=img_x-1;}
						if(y<0){rgb_py[0]=0;} else if(y>=img_y){rgb_py[0]=img_y-1;}			
					}
					
					//1ピクセルを作成[0,1]
					m+=d;				
					x=rgb_px[4]=(int)((cp0cx+cp1cy_cp2_1)*m);
					y=rgb_py[4]=(int)((cp3cx+cp4cy_cp5_1)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[4]=0;}else if(x>=img_x){rgb_px[4]=img_x-1;}
						if(y<0){rgb_py[4]=0;}else if(y>=img_y){rgb_py[4]=img_y-1;}			
					}				
					//1ピクセルを作成[0,2]
					m+=d;
					x=rgb_px[8]=(int)((cp0cx+cp1cy_cp2_2)*m);
					y=rgb_py[8]=(int)((cp3cx+cp4cy_cp5_2)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[8]=0;}else if(x>=img_x){rgb_px[8]=img_x-1;}
						if(y<0){rgb_py[8]=0;}else if(y>=img_y){rgb_py[8]=img_y-1;}			
					}
					
					//1ピクセルを作成[0,3]
					m+=d;
					x=rgb_px[12]=(int)((cp0cx+cp1cy_cp2_3)*m);
					y=rgb_py[12]=(int)((cp3cx+cp4cy_cp5_3)*m);				
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[12]=0;}else if(x>=img_x){rgb_px[12]=img_x-1;}
						if(y<0){rgb_py[12]=0;}else if(y>=img_y){rgb_py[12]=img_y-1;}			
					}
					
					cp6cx+=cp6;
					cp0cx+=cp0;
					cp3cx+=cp3;
					
					m=1/cp6cx;
					d=-cp7/((cp6cx+cp7)*cp6cx);				
					
					//1ピクセルを作成[1,0]
					x=rgb_px[1]=(int)((cp0cx+cp1cy_cp2_0)*m);
					y=rgb_py[1]=(int)((cp3cx+cp4cy_cp5_0)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[1]=0;}else if(x>=img_x){rgb_px[1]=img_x-1;}
						if(y<0){rgb_py[1]=0;}else if(y>=img_y){rgb_py[1]=img_y-1;}
					}
					//1ピクセルを作成[1,1]
					m+=d;
					x=rgb_px[5]=(int)((cp0cx+cp1cy_cp2_1)*m);
					y=rgb_py[5]=(int)((cp3cx+cp4cy_cp5_1)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[5]=0;}else if(x>=img_x){rgb_px[5]=img_x-1;}
						if(y<0){rgb_py[5]=0;}else if(y>=img_y){rgb_py[5]=img_y-1;}
					}
					//1ピクセルを作成[1,2]
					m+=d;
					x=rgb_px[9]=(int)((cp0cx+cp1cy_cp2_2)*m);
					y=rgb_py[9]=(int)((cp3cx+cp4cy_cp5_2)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[9]=0;}else if(x>=img_x){rgb_px[9]=img_x-1;}
						if(y<0){rgb_py[9]=0;}else if(y>=img_y){rgb_py[9]=img_y-1;}
					}
					//1ピクセルを作成[1,3]
					m+=d;
					x=rgb_px[13]=(int)((cp0cx+cp1cy_cp2_3)*m);
					y=rgb_py[13]=(int)((cp3cx+cp4cy_cp5_3)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[13]=0;}else if(x>=img_x){rgb_px[13]=img_x-1;}
						if(y<0){rgb_py[13]=0;}else if(y>=img_y){rgb_py[13]=img_y-1;}
					}
					
					cp6cx+=cp6;
					cp0cx+=cp0;
					cp3cx+=cp3;
					
					m=1/cp6cx;
					d=-cp7/((cp6cx+cp7)*cp6cx);
					
					//1ピクセルを作成[2,0]
					x=rgb_px[2]=(int)((cp0cx+cp1cy_cp2_0)*m);
					y=rgb_py[2]=(int)((cp3cx+cp4cy_cp5_0)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[2]=0;}else if(x>=img_x){rgb_px[2]=img_x-1;}
						if(y<0){rgb_py[2]=0;}else if(y>=img_y){rgb_py[2]=img_y-1;}
					}				
					//1ピクセルを作成[2,1]
					m+=d;
					x=rgb_px[6]=(int)((cp0cx+cp1cy_cp2_1)*m);
					y=rgb_py[6]=(int)((cp3cx+cp4cy_cp5_1)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[6]=0;}else if(x>=img_x){rgb_px[6]=img_x-1;}
						if(y<0){rgb_py[6]=0;}else if(y>=img_y){rgb_py[6]=img_y-1;}
					}
					//1ピクセルを作成[2,2]
					m+=d;
					x=rgb_px[10]=(int)((cp0cx+cp1cy_cp2_2)*m);
					y=rgb_py[10]=(int)((cp3cx+cp4cy_cp5_2)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[10]=0;}else if(x>=img_x){rgb_px[10]=img_x-1;}
						if(y<0){rgb_py[10]=0;}else if(y>=img_y){rgb_py[10]=img_y-1;}
					}
					//1ピクセルを作成[2,3](ここ計算ずれします。)
					m+=d;
					x=rgb_px[14]=(int)((cp0cx+cp1cy_cp2_3)*m);
					y=rgb_py[14]=(int)((cp3cx+cp4cy_cp5_3)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[14]=0;}else if(x>=img_x){rgb_px[14]=img_x-1;}
						if(y<0){rgb_py[14]=0;}else if(y>=img_y){rgb_py[14]=img_y-1;}
					}
					cp6cx+=cp6;
					cp0cx+=cp0;
					cp3cx+=cp3;
					
					m=1/cp6cx;
					d=-cp7/((cp6cx+cp7)*cp6cx);
					
					//1ピクセルを作成[3,0]
					x=rgb_px[3]=(int)((cp0cx+cp1cy_cp2_0)*m);
					y=rgb_py[3]=(int)((cp3cx+cp4cy_cp5_0)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[3]=0;}else if(x>=img_x){rgb_px[3]=img_x-1;}
						if(y<0){rgb_py[3]=0;}else if(y>=img_y){rgb_py[3]=img_y-1;}
					}
					//1ピクセルを作成[3,1]
					m+=d;
					x=rgb_px[7]=(int)((cp0cx+cp1cy_cp2_1)*m);
					y=rgb_py[7]=(int)((cp3cx+cp4cy_cp5_1)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[7]=0;}else if(x>=img_x){rgb_px[7]=img_x-1;}
						if(y<0){rgb_py[7]=0;}else if(y>=img_y){rgb_py[7]=img_y-1;}
					}
					//1ピクセルを作成[3,2]
					m+=d;
					x=rgb_px[11]=(int)((cp0cx+cp1cy_cp2_2)*m);
					y=rgb_py[11]=(int)((cp3cx+cp4cy_cp5_2)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[11]=0;}else if(x>=img_x){rgb_px[11]=img_x-1;}
						if(y<0){rgb_py[11]=0;}else if(y>=img_y){rgb_py[11]=img_y-1;}
					}
					//1ピクセルを作成[3,3]
					m+=d;
					x=rgb_px[15]=(int)((cp0cx+cp1cy_cp2_3)*m);
					y=rgb_py[15]=(int)((cp3cx+cp4cy_cp5_3)*m);
					if(x<0||x>=img_x||y<0||y>=img_y){
						if(x<0){rgb_px[15]=0;}else if(x>=img_x){rgb_px[15]=img_x-1;}
						if(y<0){rgb_py[15]=0;}else if(y>=img_y){rgb_py[15]=img_y-1;}
					}
					
					reader.getPixelSet(rgb_px, rgb_py,4*4, rgb_tmp);
					
					r=(rgb_tmp[ 0]+rgb_tmp[ 3]+rgb_tmp[ 6]+rgb_tmp[ 9]+rgb_tmp[12]+rgb_tmp[15]+rgb_tmp[18]+rgb_tmp[21]+rgb_tmp[24]+rgb_tmp[27]+rgb_tmp[30]+rgb_tmp[33]+rgb_tmp[36]+rgb_tmp[39]+rgb_tmp[42]+rgb_tmp[45])/16;
					g=(rgb_tmp[ 1]+rgb_tmp[ 4]+rgb_tmp[ 7]+rgb_tmp[10]+rgb_tmp[13]+rgb_tmp[16]+rgb_tmp[19]+rgb_tmp[22]+rgb_tmp[25]+rgb_tmp[28]+rgb_tmp[31]+rgb_tmp[34]+rgb_tmp[37]+rgb_tmp[40]+rgb_tmp[43]+rgb_tmp[46])/16;
					b=(rgb_tmp[ 2]+rgb_tmp[ 5]+rgb_tmp[ 8]+rgb_tmp[11]+rgb_tmp[14]+rgb_tmp[17]+rgb_tmp[20]+rgb_tmp[23]+rgb_tmp[26]+rgb_tmp[29]+rgb_tmp[32]+rgb_tmp[35]+rgb_tmp[38]+rgb_tmp[41]+rgb_tmp[44]+rgb_tmp[47])/16;
					o_patt[p]=((r&0xff)<<16)|((g&0xff)<<8)|((b&0xff));
					p++;
					
				}
			}
			return;
		}
	}
}