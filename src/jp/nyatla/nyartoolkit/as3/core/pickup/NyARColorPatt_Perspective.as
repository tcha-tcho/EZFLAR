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
	import jp.nyatla.as3utils.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.rgb.*;
	import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
	import jp.nyatla.nyartoolkit.as3.core.utils.*;
	import jp.nyatla.nyartoolkit.as3.*;
	public class NyARColorPatt_Perspective implements INyARColorPatt
	{
		protected var _patdata:Vector.<int>;
		protected var _pickup_lt:NyARIntPoint2d=new NyARIntPoint2d();	
		protected var _resolution:int;
		protected var _size:NyARIntSize;
		protected var _perspective_gen:NyARPerspectiveParamGenerator_O1;
		private var _pixelreader:NyARRgbPixelReader_INT1D_X8R8G8B8_32;
		private static const LOCAL_LT:int=1;
		private static const BUFFER_FORMAT:int=NyARBufferType.INT1D_X8R8G8B8_32;
		
		private function initializeInstance(i_width:int,i_height:int,i_point_per_pix:int):void
		{
			NyAS3Utils.assert(i_width>2 && i_height>2);
			this._resolution=i_point_per_pix;	
			this._size=new NyARIntSize(i_width,i_height);
			this._patdata = new Vector.<int>(i_height*i_width);
			this._pixelreader=new NyARRgbPixelReader_INT1D_X8R8G8B8_32(this._patdata,this._size);
			return;		
		}
		/**
		 * 例えば、64
		 * @param i_width
		 * 取得画像の解像度幅
		 * @param i_height
		 * 取得画像の解像度高さ
		 */
		/**
		 * 例えば、64
		 * @param i_width
		 * 取得画像の解像度幅
		 * @param i_height
		 * 取得画像の解像度高さ
		 * @param i_point_per_pix
		 * 1ピクセルあたりの縦横サンプリング数。2なら2x2=4ポイントをサンプリングする。
		 * @param i_edge_percentage
		 * エッジ幅の割合(ARToolKit標準と同じなら、25)
		 */
		public function NyARColorPatt_Perspective(i_width:int,i_height:int,i_point_per_pix:int,i_edge_percentage:int=-1)
		{
			if (i_edge_percentage == -1) {
				initializeInstance(i_width,i_height,i_point_per_pix);
				setEdgeSize(0,0,i_point_per_pix);
			}else{
				//入力制限
				initializeInstance(i_width,i_height,i_point_per_pix);
				setEdgeSizeByPercent(i_edge_percentage, i_edge_percentage, i_point_per_pix);
			}
			return;
		}	
		/**
		 * 矩形領域のエッジサイズを指定します。
		 * エッジの計算方法は以下の通りです。
		 * 1.マーカ全体を(i_x_edge*2+width)x(i_y_edge*2+height)の解像度でパラメタを計算します。
		 * 2.ピクセルの取得開始位置を(i_x_edge/2,i_y_edge/2)へ移動します。
		 * 3.開始位置から、width x height個のピクセルを取得します。
		 * 
		 * ARToolKit標準マーカの場合は、width/2,height/2を指定してください。
		 * @param i_x_edge
		 * @param i_y_edge
		 */
		public function setEdgeSize(i_x_edge:int,i_y_edge:int,i_resolution:int):void
		{
			NyAS3Utils.assert(i_x_edge>=0);
			NyAS3Utils.assert(i_y_edge>=0);
			//Perspectiveパラメタ計算器を作成
			this._perspective_gen=new NyARPerspectiveParamGenerator_O1(
				LOCAL_LT,LOCAL_LT,
				(i_x_edge*2+this._size.w)*i_resolution,
				(i_y_edge*2+this._size.h)*i_resolution);
			//ピックアップ開始位置を計算
			this._pickup_lt.x=i_x_edge*i_resolution+LOCAL_LT;
			this._pickup_lt.y=i_y_edge*i_resolution+LOCAL_LT;
			return;
		}
		public function setEdgeSizeByPercent(i_x_percent:int,i_y_percent:int,i_resolution:int):void
		{
			NyAS3Utils.assert(i_x_percent>=0);
			NyAS3Utils.assert(i_y_percent>=0);
			setEdgeSize(this._size.w*i_x_percent/50,this._size.h*i_y_percent/50,i_resolution);
			return;
		}

		
		public final function getWidth():int
		{
			return this._size.w;
		}
		public final function getHeight():int
		{
			return this._size.h;
		}
		public final function getSize():NyARIntSize
		{
			return 	this._size;
		}
		public final function getRgbPixelReader():INyARRgbPixelReader
		{
			return this._pixelreader;
		}
		public final function getBuffer():Object
		{
			return this._patdata;
		}
		public final function hasBuffer():Boolean
		{
			return this._patdata!=null;
		}
		public final function wrapBuffer(i_ref_buf:Object):void
		{
			NyARException.notImplement();
		}
		public final function getBufferType():int
		{
			return BUFFER_FORMAT;
		}
		public final function isEqualBufferType(i_type_value:int):Boolean
		{
			return BUFFER_FORMAT==i_type_value;
		}
		
		private var __pickFromRaster_rgb_tmp:Vector.<int> = new Vector.<int>(3);
		protected var __pickFromRaster_cpara:Vector.<Number> = new Vector.<Number>(8);
		
		/**
		 * @see INyARColorPatt#pickFromRaster
		 */
		public function pickFromRaster(image:INyARRgbRaster,i_vertexs:Vector.<NyARIntPoint2d>):Boolean
		{
			//遠近法のパラメータを計算
			var cpara:Vector.<Number> = this.__pickFromRaster_cpara;
			if (!this._perspective_gen.getParam(i_vertexs, cpara)) {
				return false;
			}
			
			var resolution:int=this._resolution;
			var img_x:int = image.getWidth();
			var img_y:int = image.getHeight();
			var res_pix:int=resolution*resolution;

			var rgb_tmp:Vector.<int> = this.__pickFromRaster_rgb_tmp;

			//ピクセルリーダーを取得
			var reader:INyARRgbPixelReader =image.getRgbPixelReader();
			var p:int=0;
			for(var iy:int=0;iy<this._size.h*resolution;iy+=resolution){
				//解像度分の点を取る。
				for(var ix:int=0;ix<this._size.w*resolution;ix+=resolution){
					var r:int,g:int,b:int;
					r=g=b=0;
					for(var i2y:int=iy;i2y<iy+resolution;i2y++){
						var cy:int=this._pickup_lt.y+i2y;
						for(var i2x:int=ix;i2x<ix+resolution;i2x++){
							//1ピクセルを作成
							var cx:int=this._pickup_lt.x+i2x;
							var d:Number=cpara[6]*cx+cpara[7]*cy+1.0;
							var x:int=(int)((cpara[0]*cx+cpara[1]*cy+cpara[2])/d);
							var y:int=(int)((cpara[3]*cx+cpara[4]*cy+cpara[5])/d);
							if(x<0){x=0;}
							if(x>=img_x){x=img_x-1;}
							if(y<0){y=0;}
							if(y>=img_y){y=img_y-1;}
							
							reader.getPixel(x, y, rgb_tmp);
							r+=rgb_tmp[0];
							g+=rgb_tmp[1];
							b+=rgb_tmp[2];
						}
					}
					r/=res_pix;
					g/=res_pix;
					b/=res_pix;
					this._patdata[p]=((r&0xff)<<16)|((g&0xff)<<8)|((b&0xff));
					p++;
				}
			}
				//ピクセル問い合わせ
				//ピクセルセット
			return true;
		}

	}
}
