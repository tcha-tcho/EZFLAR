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
package jp.nyatla.nyartoolkit.as3.core.utils 
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	public class NyARPerspectiveParamGenerator_O1
	{
		protected var _local_x:int;
		protected var _local_y:int;
		protected var _width:int;
		protected var _height:int;
		public function NyARPerspectiveParamGenerator_O1(i_local_x:int,i_local_y:int,i_width:int,i_height:int)
		{
			this._height=i_height;
			this._width=i_width;
			this._local_x=i_local_x;
			this._local_y=i_local_y;
			return;
		}
		final public function getParam(i_vertex:Vector.<NyARIntPoint2d>,o_param:Vector.<Number>):Boolean
		{
			var G:Number,H:Number;
			var w1:Number,w2:Number,w3:Number,w4:Number;
			var x0:Number=i_vertex[0].x;
			var x1:Number=i_vertex[1].x;
			var x2:Number=i_vertex[2].x;
			var x3:Number=i_vertex[3].x;
			var y0:Number=i_vertex[0].y;
			var y1:Number=i_vertex[1].y;
			var y2:Number=i_vertex[2].y;
			var y3:Number=i_vertex[3].y;
			var ltx:Number=this._local_x;
			var lty:Number=this._local_y;
			var rbx:Number=ltx+this._width;
			var rby:Number=lty+this._height;

			
			w1=-y3+y0;
			w2= y2-y1;
			var la2_33:Number=ltx*w1+rbx*w2;//これが0になるのはまずい。
			var la2_34:Number=(rby*(-y3+y2)+lty*(y0-y1))/la2_33;
			var ra2_3:Number =(-w1-w2)/la2_33;
			
			w1=-x3+x0;
			w2=x2-x1;
			var la1_33:Number=ltx*w1+rbx*w2;//これが0になるのはまずい。
			
			//GHを計算
			H=(ra2_3-((-w1-w2)/la1_33))/(la2_34-((rby*(-x3+x2)+lty*(x0-x1))/la1_33));
			G=ra2_3-la2_34*H;
			o_param[7]=H;
			o_param[6]=G;

			//残りを計算
			w3=rby-lty;
			w4=rbx-ltx;
			w1=(y2-y1-H*(-rby*y2+lty*y1)-G*(-rbx*y2+rbx*y1))/w3;
			w2=(y1-y0-H*(-lty*y1+lty*y0)-G*(-rbx*y1+ltx*y0))/w4;
			o_param[5]=y0*(1+H*lty+G*ltx)-w1*lty-w2*ltx;
			o_param[4]=w1;
			o_param[3]=w2;
			
			
			w1=(x2-x1-H*(-rby*x2+lty*x1)-G*(-rbx*x2+rbx*x1))/w3;
			w2=(x1-x0-H*(-lty*x1+lty*x0)-G*(-rbx*x1+ltx*x0))/w4;
			o_param[2]=x0*(1+H*lty+G*ltx)-w1*lty-w2*ltx;
			o_param[1]=w1;
			o_param[0]=w2;
			return true;
		}		
	}

}