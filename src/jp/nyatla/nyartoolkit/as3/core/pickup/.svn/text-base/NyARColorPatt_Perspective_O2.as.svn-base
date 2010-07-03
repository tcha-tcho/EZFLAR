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
package jp.nyatla.nyartoolkit.as3.core.pickup 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	public class NyARColorPatt_Perspective_O2 extends NyARColorPatt_Perspective
	{
		private var _pickup:IpickFromRaster_Impl;
		public function NyARColorPatt_Perspective_O2(i_width:int,i_height:int,i_resolution:int,i_edge_percentage:int)
		{
			super(i_width,i_height,i_resolution,i_edge_percentage);
			switch(i_resolution){
			case 1:
				this._pickup=new pickFromRaster_1(this._pickup_lt,this._size);
				break;
			case 2:
				this._pickup=new pickFromRaster_2x(this._pickup_lt,this._size);
				break;
			case 4:
				this._pickup=new pickFromRaster_4x(this._pickup_lt,this._size);
				break;
			default:
				this._pickup=new pickFromRaster_N(this._pickup_lt,i_resolution,this._size);
			}		
			return;
		}
		/**
		 * @see INyARColorPatt#pickFromRaster
		 */
		public override function pickFromRaster(image:INyARRgbRaster ,i_vertexs:Vector.<NyARIntPoint2d>):Boolean
		{
			//遠近法のパラメータを計算
			var cpara:Vector.<Number> = this.__pickFromRaster_cpara;
			if (!this._perspective_gen.getParam(i_vertexs, cpara)) {
				return false;
			} 		
			this._pickup.pickFromRaster(cpara, image,this._patdata);
			return true;
		}
	}
}

import jp.nyatla.nyartoolkit.as3.core.types.*;
import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;

interface IpickFromRaster_Impl
{
	function pickFromRaster(i_cpara:Vector.<Number>,image:INyARRgbRaster,o_patt:Vector.<int>):void
}

/**
 * 汎用ピックアップ関数
 *
 */
class pickFromRaster_N implements IpickFromRaster_Impl
{
	protected var _resolution:int;
	protected var _size_ref:NyARIntSize;
	protected var _lt_ref:NyARIntPoint2d;
	public function pickFromRaster_N(i_lt:NyARIntPoint2d,i_resolution:int,i_source_size:NyARIntSize)
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
/**
 * チェックデジット:4127936236942444153655776299710081208144715171590159116971715177917901890204024192573274828522936312731813388371037714083
 *
 */
class pickFromRaster_1 implements IpickFromRaster_Impl
{
	protected var _size_ref:NyARIntSize;
	protected var _lt_ref:NyARIntPoint2d;
	public function pickFromRaster_1(i_lt:NyARIntPoint2d,i_source_size:NyARIntSize)
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

/**
 * 2x2
 * チェックデジット:207585881161241401501892422483163713744114324414474655086016467027227327958629279571017
 *
 */
class pickFromRaster_2x implements IpickFromRaster_Impl
{
	protected var _size_ref:NyARIntSize;
	protected var _lt_ref:NyARIntPoint2d;
	public function pickFromRaster_2x(i_lt:NyARIntPoint2d,i_source_size:NyARIntSize)
	{
		this._lt_ref=i_lt;
		this._size_ref=i_source_size;
		
		this._rgb_temp=new Vector.<int>(i_source_size.w*4*3);
		this._rgb_px=new Vector.<int>(i_source_size.w*4);
		this._rgb_py=new Vector.<int>(i_source_size.w*4);
		

		return;
	}
	private var _rgb_temp:Vector.<int>;
	private var _rgb_px:Vector.<int>;
	private var _rgb_py:Vector.<int>;


	public function pickFromRaster(i_cpara:Vector.<Number>,image:INyARRgbRaster,o_patt:Vector.<int>):void
	{
		
		var d0:Number,m0:Number,d1:Number,m1:Number;
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


		var cp0cx1:Number,cp3cx1:Number;
		var cp1cy_cp21:Number=cp1cy_cp20+cp1;
		var cp4cy_cp51:Number=cp4cy_cp50+cp4;
		var cp7cy_11:Number=cp7cy_10+cp7;
		
		var cw0:Number=cp1+cp1;
		var cw7:Number=cp7+cp7;
		var cw4:Number=cp4+cp4;
		
		for(var iy:int=this._size_ref.h-1;iy>=0;iy--){			
			cp0cx0=cp1cy_cp20;
			cp3cx0=cp4cy_cp50;
			cp0cx1=cp1cy_cp21;
			cp3cx1=cp4cy_cp51;

			m0=1.0/(cp7cy_10);
			d0=-cp6/(cp7cy_10*(cp7cy_10+cp6));			
			m1=1.0/(cp7cy_11);
			d1=-cp6/(cp7cy_11*(cp7cy_11+cp6));			
			
			var n:int=patt_w*2*2-1;
			var ix:int;
			for(ix=patt_w*2-1;ix>=0;ix--){
				//[n,0]
				x=rgb_px[n]=(int)(cp0cx0*m0);
				y=rgb_py[n]=(int)(cp3cx0*m0);
				if(x<0||x>=img_x||y<0||y>=img_y){
					if(x<0){rgb_px[n]=0;}else if(x>=img_x){rgb_px[n]=img_x-1;}
					if(y<0){rgb_py[n]=0;}else if(y>=img_y){rgb_py[n]=img_y-1;}			
				}
				cp0cx0+=cp0;
				cp3cx0+=cp3;
				m0+=d0;
				n--;
				//[n,1]
				x=rgb_px[n]=(int)(cp0cx1*m1);
				y=rgb_py[n]=(int)(cp3cx1*m1);
				if(x<0||x>=img_x||y<0||y>=img_y){
					if(x<0){rgb_px[n]=0;}else if(x>=img_x){rgb_px[n]=img_x-1;}
					if(y<0){rgb_py[n]=0;}else if(y>=img_y){rgb_py[n]=img_y-1;}			
				}
				cp0cx1+=cp0;
				cp3cx1+=cp3;
				m1+=d1;
				n--;			
			}
			cp7cy_10+=cw7;
			cp7cy_11+=cw7;

			cp1cy_cp20+=cw0;
			cp4cy_cp50+=cw4;
			cp1cy_cp21+=cw0;
			cp4cy_cp51+=cw4;



			reader.getPixelSet(rgb_px, rgb_py,patt_w*4, rgb_tmp);
			for(ix=patt_w-1;ix>=0;ix--){
				var idx:int=ix*12;//3*2*2
				var r:int=(rgb_tmp[idx+0]+rgb_tmp[idx+3]+rgb_tmp[idx+6]+rgb_tmp[idx+ 9])/4;
				var g:int=(rgb_tmp[idx+1]+rgb_tmp[idx+4]+rgb_tmp[idx+7]+rgb_tmp[idx+10])/4;
				var b:int=(rgb_tmp[idx+2]+rgb_tmp[idx+5]+rgb_tmp[idx+8]+rgb_tmp[idx+11])/4;
				o_patt[p]=(r<<16)|(g<<8)|((b&0xff));
				p++;
			}
		}

		return;
	}
}

/**
 * 4x4
 *
 */
class pickFromRaster_4x implements IpickFromRaster_Impl
{
	protected var _size_ref:NyARIntSize;
	protected var _lt_ref:NyARIntPoint2d;
	public function pickFromRaster_4x(i_lt:NyARIntPoint2d,i_source_size:NyARIntSize)
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
