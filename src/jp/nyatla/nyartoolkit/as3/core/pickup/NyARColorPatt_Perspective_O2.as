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
	import jp.nyatla.nyartoolkit.as3.core.pickup.privateClass.IpickFromRaster_Impl;
	import jp.nyatla.nyartoolkit.as3.core.pickup.privateClass.NyARPickFromRaster_1;
	import jp.nyatla.nyartoolkit.as3.core.pickup.privateClass.NyARPickFromRaster_2x;
	import jp.nyatla.nyartoolkit.as3.core.pickup.privateClass.NyARPickFromRaster_4x;
	import jp.nyatla.nyartoolkit.as3.core.pickup.privateClass.NyARPickFromRaster_N;
	
	public class NyARColorPatt_Perspective_O2 extends NyARColorPatt_Perspective
	{
		private var _pickup:IpickFromRaster_Impl;
		
		public function NyARColorPatt_Perspective_O2(i_width:int,i_height:int,i_resolution:int,i_edge_percentage:int)
		{
			super(i_width,i_height,i_resolution,i_edge_percentage);
			switch(i_resolution){
			case 1:
				this._pickup=new NyARPickFromRaster_1(this._pickup_lt,this._size);
				break;
			case 2:
				this._pickup=new NyARPickFromRaster_2x(this._pickup_lt,this._size);
				break;
			case 4:
				this._pickup=new NyARPickFromRaster_4x(this._pickup_lt,this._size);
				break;
			default:
				this._pickup=new NyARPickFromRaster_N(this._pickup_lt,i_resolution,this._size);
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
