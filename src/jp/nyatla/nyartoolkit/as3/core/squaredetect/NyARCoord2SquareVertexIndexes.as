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
package jp.nyatla.nyartoolkit.as3.core.squaredetect 
{
	public class NyARCoord2SquareVertexIndexes
	{
		private static const VERTEX_FACTOR:Number = 1.0;// 線検出のファクタ	
		private var __getSquareVertex_wv1:NyARVertexCounter= new NyARVertexCounter();
		private var __getSquareVertex_wv2:NyARVertexCounter= new NyARVertexCounter();
		public function NyARCoord2SquareVertexIndexes()
		{
			return;
		}
		/**
		 * 座標集合から、頂点候補になりそうな場所を４箇所探して、そのインデクス番号を返します。
		 * @param i_x_coord
		 * @param i_y_coord
		 * @param i_coord_num
		 * @param i_area
		 * @param o_vertex
		 * @return
		 */
		public function getVertexIndexes(i_x_coord:Vector.<int> ,i_y_coord:Vector.<int>,i_coord_num:int, i_area:int,o_vertex:Vector.<int>):Boolean
		{
			var wv1:NyARVertexCounter = this.__getSquareVertex_wv1;
			var wv2:NyARVertexCounter = this.__getSquareVertex_wv2;
			var vertex1_index:int=getFarPoint(i_x_coord,i_y_coord,i_coord_num,0);
			var prev_vertex_index:int=(vertex1_index+i_coord_num)%i_coord_num;
			var v1:int=getFarPoint(i_x_coord,i_y_coord,i_coord_num,vertex1_index);
			var thresh:Number = (i_area / 0.75) * 0.01 * VERTEX_FACTOR;

			o_vertex[0] = vertex1_index;

			if (!wv1.getVertex(i_x_coord, i_y_coord,i_coord_num, vertex1_index, v1, thresh)) {
				return false;
			}
			if (!wv2.getVertex(i_x_coord, i_y_coord,i_coord_num, v1,prev_vertex_index, thresh)) {
				return false;
			}

			var v2:int;
			if (wv1.number_of_vertex == 1 && wv2.number_of_vertex == 1) {
				o_vertex[1] = wv1.vertex[0];
				o_vertex[2] = v1;
				o_vertex[3] = wv2.vertex[0];
			} else if (wv1.number_of_vertex > 1 && wv2.number_of_vertex == 0) {
				//頂点位置を、起点から対角点の間の1/2にあると予想して、検索する。
				if(v1>=vertex1_index){
					v2 = (v1-vertex1_index)/2+vertex1_index;
				}else{
					v2 = ((v1+i_coord_num-vertex1_index)/2+vertex1_index)%i_coord_num;
				}
				if (!wv1.getVertex(i_x_coord, i_y_coord,i_coord_num, vertex1_index, v2, thresh)) {
					return false;
				}
				if (!wv2.getVertex(i_x_coord, i_y_coord,i_coord_num, v2, v1, thresh)) {
					return false;
				}
				if (wv1.number_of_vertex == 1 && wv2.number_of_vertex == 1) {
					o_vertex[1] = wv1.vertex[0];
					o_vertex[2] = wv2.vertex[0];
					o_vertex[3] = v1;
				} else {
					return false;
				}
			} else if (wv1.number_of_vertex == 0 && wv2.number_of_vertex > 1) {
				//v2 = (v1+ end_of_coord)/2;
				if(v1<=prev_vertex_index){
					v2 = (v1+prev_vertex_index)/2;
				}else{
					v2 = ((v1+i_coord_num+prev_vertex_index)/2)%i_coord_num;
					
				}
				if (!wv1.getVertex(i_x_coord, i_y_coord,i_coord_num, v1, v2, thresh)) {
					return false;
				}
				if (!wv2.getVertex(i_x_coord, i_y_coord,i_coord_num, v2, prev_vertex_index, thresh)) {
					return false;
				}
				if (wv1.number_of_vertex == 1 && wv2.number_of_vertex == 1) {
					o_vertex[1] = v1;
					o_vertex[2] = wv1.vertex[0];
					o_vertex[3] = wv2.vertex[0];
				} else {
					
					return false;
				}
			} else {
				return false;
			}
			return true;
		}
		/**
		 * i_pointの輪郭座標から、最も遠方にある輪郭座標のインデクスを探します。
		 * @param i_xcoord
		 * @param i_ycoord
		 * @param i_coord_num
		 * @return
		 */
		private static function getFarPoint(i_coord_x:Vector.<int>,i_coord_y:Vector.<int>,i_coord_num:int,i_point:int):int
		{
			//
			var sx:int = i_coord_x[i_point];
			var sy:int = i_coord_y[i_point];
			var d:int = 0;
			var w:int, x:int, y:int;
			var ret:int = 0;
			var i:int;
			for (i = i_point+1; i < i_coord_num; i++) {
				x = i_coord_x[i] - sx;
				y = i_coord_y[i] - sy;
				w = x * x + y * y;
				if (w > d) {
					d = w;
					ret = i;
				}
			}
			for (i= 0; i < i_point; i++) {
				x = i_coord_x[i] - sx;
				y = i_coord_y[i] - sy;
				w = x * x + y * y;
				if (w > d) {
					d = w;
					ret = i;
				}
			}		
			return ret;
		}	
	}
}



/**
 * get_vertex関数を切り離すためのクラス
 * 
 */
final class NyARVertexCounter
{
	public var vertex:Vector.<int> = new Vector.<int>(10);// 6まで削れる

	public var number_of_vertex:int;

	private var thresh:Number;

	private var x_coord:Vector.<int>;

	private var y_coord:Vector.<int>;

	public function getVertex(i_x_coord:Vector.<int>, i_y_coord:Vector.<int>,i_coord_len:int,st:int,ed:int,i_thresh:Number):Boolean
	{
		this.number_of_vertex = 0;
		this.thresh = i_thresh;
		this.x_coord = i_x_coord;
		this.y_coord = i_y_coord;
		return get_vertex(st, ed,i_coord_len);
	}

	/**
	 * static int get_vertex( int x_coord[], int y_coord[], int st, int ed,double thresh, int vertex[], int *vnum) 関数の代替関数
	 * 
	 * @param x_coord
	 * @param y_coord
	 * @param st
	 * @param ed
	 * @param thresh
	 * @return
	 */
	private function get_vertex(st:int,ed:int,i_coord_len:int):Boolean
	{
		var i:int;
		var d:Number;
		//メモ:座標値は65536を超えなければint32で扱って大丈夫なので変更。
		//dmaxは4乗なのでやるとしてもint64じゃないとマズイ
		var v1:int = 0;
		var lx_coord:Vector.<int> = this.x_coord;
		var ly_coord:Vector.<int> = this.y_coord;
		var a:int = ly_coord[ed] - ly_coord[st];
		var b:int = lx_coord[st] - lx_coord[ed];
		var c:int = lx_coord[ed] * ly_coord[st] - ly_coord[ed] * lx_coord[st];
		var dmax:Number = 0;
		if(st<ed){
			//stとedが1区間
			for (i = st + 1; i < ed; i++) {
				d = a * lx_coord[i] + b * ly_coord[i] + c;
				if (d * d > dmax) {
					dmax = d * d;
					v1 = i;
				}
			}
		}else{
			//stとedが2区間
			for (i = st + 1; i < i_coord_len; i++) {
				d = a * lx_coord[i] + b * ly_coord[i] + c;
				if (d * d > dmax) {
					dmax = d * d;
					v1 = i;
				}
			}
			for (i = 0; i < ed; i++) {
				d = a * lx_coord[i] + b * ly_coord[i] + c;
				if (d * d > dmax) {
					dmax = d * d;
					v1 = i;
				}
			}
		}

		
		if (dmax / (Number)(a * a + b * b) > thresh) {
			if (!get_vertex(st, v1,i_coord_len)) {
				return false;
			}
			if (number_of_vertex > 5) {
				return false;
			}
			vertex[number_of_vertex] = v1;// vertex[(*vnum)] = v1;
			number_of_vertex++;// (*vnum)++;

			if (!get_vertex(v1, ed,i_coord_len)) {
				return false;
			}
		}
		return true;
	}
}