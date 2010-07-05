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
package jp.nyatla.nyartoolkit.as3.core.param 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	public class NyARObserv2IdealMap
	{
		protected var _stride:int;
		protected var _mapx:Vector.<Number>;
		protected var _mapy:Vector.<Number>;
		public function NyARObserv2IdealMap(i_distfactor:NyARCameraDistortionFactor,i_screen_size:NyARIntSize)
		{
			var opoint:NyARDoublePoint2d=new NyARDoublePoint2d();
			this._mapx=new Vector.<Number>(i_screen_size.w*i_screen_size.h);
			this._mapy=new Vector.<Number>(i_screen_size.w*i_screen_size.h);
			this._stride=i_screen_size.w;
			var ptr:int=i_screen_size.h*i_screen_size.w-1;
			//歪みマップを構築
			for(var i:int=i_screen_size.h-1;i>=0;i--)
			{
				for(var i2:int=i_screen_size.w-1;i2>=0;i2--)
				{
					i_distfactor.observ2Ideal(i2,i, opoint);
					this._mapx[ptr]=opoint.x;
					this._mapy[ptr]=opoint.y;
					ptr--;
				}
			}
			return;
		}
		public function observ2Ideal(ix:int,iy:int,o_point:NyARDoublePoint2d):void
		{
			var idx:int=ix+iy*this._stride;
			o_point.x=this._mapx[idx];
			o_point.y=this._mapy[idx];
			return;
		}
		public function observ2IdealBatch(i_x_coord:Vector.<int>,i_y_coord:Vector.<int>,i_start:int,i_num:int,o_x_coord:Vector.<Number>,o_y_coord:Vector.<Number>,i_out_start_index:int):void
		{
			var idx:int;
			var ptr:int=i_out_start_index;
			var mapx:Vector.<Number>=this._mapx;
			var mapy:Vector.<Number>=this._mapy;
			var stride:int=this._stride;
			for (var j:int = 0; j < i_num; j++){
				idx=i_x_coord[i_start + j]+i_y_coord[i_start + j]*stride;
				o_x_coord[ptr]=mapx[idx];
				o_y_coord[ptr]=mapy[idx];
				ptr++;
			}
			return;
		}	
	}


}