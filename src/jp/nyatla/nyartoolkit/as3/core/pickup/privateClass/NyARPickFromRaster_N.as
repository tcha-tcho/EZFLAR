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
	 * 汎用ピックアップ関数
	 *
	 */
	public class NyARPickFromRaster_N implements IpickFromRaster_Impl
	{
		protected var _resolution:int;
		protected var _size_ref:NyARIntSize;
		protected var _lt_ref:NyARIntPoint2d;
		public function NyARPickFromRaster_N(i_lt:NyARIntPoint2d,i_resolution:int,i_source_size:NyARIntSize)
		{
			this._lt_ref=i_lt;
			this._resolution=i_resolution;
			this._size_ref=i_source_size;
			
			this._rgb_temp=new Vector.<int>(i_resolution*i_resolution*3);
			this._rgb_px=new Vector.<int>(i_resolution*i_resolution);
			this._rgb_py=new Vector.<int>(i_resolution*i_resolution);
			
			this._cp1cy_cp2=new Vector.<Number>(i_resolution);
			this._cp4cy_cp5=new Vector.<Number>(i_resolution);
			this._cp7cy_1=new Vector.<Number>(i_resolution);
			return;
		}
		private var _rgb_temp:Vector.<int>;
		private var _rgb_px:Vector.<int>;
		private var _rgb_py:Vector.<int>;
		private var _cp1cy_cp2:Vector.<Number>;
		private var _cp4cy_cp5:Vector.<Number>;
		private var _cp7cy_1:Vector.<Number>;
		
		public function pickFromRaster(i_cpara:Vector.<Number>,image:INyARRgbRaster,o_patt:Vector.<int>):void
		{
			var i2x:int,i2y:int;//プライム変数
			var x:int,y:int;
			var w:int;
			var r:int,g:int,b:int;
			
			var resolution:int=this._resolution;
			var res_pix:int=resolution*resolution;
			var img_x:int = image.getWidth();
			var img_y:int = image.getHeight();
			
			var rgb_tmp:Vector.<int> = this._rgb_temp;
			var rgb_px:Vector.<int>=this._rgb_px;
			var rgb_py:Vector.<int>=this._rgb_py;	
			
			var cp1cy_cp2:Vector.<Number>=this._cp1cy_cp2;
			var cp4cy_cp5:Vector.<Number>=this._cp4cy_cp5;
			var cp7cy_1:Vector.<Number>=this._cp7cy_1;		
			
			var cp0:Number=i_cpara[0];
			var cp3:Number=i_cpara[3];
			var cp6:Number=i_cpara[6];
			var cp1:Number=i_cpara[1];
			var cp2:Number=i_cpara[2];
			var cp4:Number=i_cpara[4];
			var cp5:Number=i_cpara[5];
			var cp7:Number=i_cpara[7];
			
			
			var pick_y:int=this._lt_ref.y;
			var pick_x:int=this._lt_ref.x;
			//ピクセルリーダーを取得
			var reader:INyARRgbPixelReader=image.getRgbPixelReader();
			var p:int=0;
			
			
			for(var iy:int=0;iy<this._size_ref.h*resolution;iy+=resolution){
				w=pick_y+iy;
				cp1cy_cp2[0]=cp1*w+cp2;
				cp4cy_cp5[0]=cp4*w+cp5;
				cp7cy_1[0]=cp7*w+1.0;			
				for(i2y=1;i2y<resolution;i2y++){
					cp1cy_cp2[i2y]=cp1cy_cp2[i2y-1]+cp1;
					cp4cy_cp5[i2y]=cp4cy_cp5[i2y-1]+cp4;
					cp7cy_1[i2y]=cp7cy_1[i2y-1]+cp7;
				}
				//解像度分の点を取る。
				
				for(var ix:int=0;ix<this._size_ref.w*resolution;ix+=resolution){
					var n:int=0;
					w=pick_x+ix;
					for(i2y=resolution-1;i2y>=0;i2y--){
						var cp0cx:Number=cp0*w+cp1cy_cp2[i2y];
						var cp6cx:Number=cp6*w+cp7cy_1[i2y];
						var cp3cx:Number=cp3*w+cp4cy_cp5[i2y];
						
						var m:Number=1/(cp6cx);
						var d:Number=-cp6/(cp6cx*(cp6cx+cp6));
						
						var m2:Number=cp0cx*m;
						var m3:Number=cp3cx*m;
						var d2:Number=cp0cx*d+cp0*(m+d);
						var d3:Number=cp3cx*d+cp3*(m+d);
						for(i2x=resolution-1;i2x>=0;i2x--){
							//1ピクセルを作成
							x=rgb_px[n]=(int)(m2);
							y=rgb_py[n]=(int)(m3);
							if(x<0||x>=img_x||y<0||y>=img_y){
								if(x<0){rgb_px[n]=0;}else if(x>=img_x){rgb_px[n]=img_x-1;}
								if(y<0){rgb_py[n]=0;}else if(y>=img_y){rgb_py[n]=img_y-1;}			
							}
							n++;
							m2+=d2;
							m3+=d3;
						}
					}
					reader.getPixelSet(rgb_px, rgb_py,res_pix, rgb_tmp);
					r=g=b=0;
					for(var i:int=res_pix*3-1;i>0;){
						b+=rgb_tmp[i--];
						g+=rgb_tmp[i--];
						r+=rgb_tmp[i--];
					}
					r/=res_pix;
					g/=res_pix;
					b/=res_pix;
					o_patt[p]=((r&0xff)<<16)|((g&0xff)<<8)|((b&0xff));
					p++;
				}
			}
			return;
		}
	}
}