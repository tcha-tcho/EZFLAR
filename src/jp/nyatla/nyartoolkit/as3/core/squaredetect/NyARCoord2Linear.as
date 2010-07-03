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
	import jp.nyatla.nyartoolkit.as3.core.pca2d.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	
	public class NyARCoord2Linear
	{
		private var _xpos:Vector.<Number>;
		private var _ypos:Vector.<Number>;	
		private var _pca:INyARPca2d;
		private var __getSquareLine_evec:NyARDoubleMatrix22=new NyARDoubleMatrix22();
		private var __getSquareLine_mean:Vector.<Number> = new Vector.<Number>(2);
		private var __getSquareLine_ev:Vector.<Number> = new Vector.<Number>(2);
		private var _dist_factor:NyARObserv2IdealMap;
		public function NyARCoord2Linear(i_size:NyARIntSize,i_distfactor_ref:NyARCameraDistortionFactor)
		{
			//歪み計算テーブルを作ると、8*width/height*2の領域を消費します。
			//領域を取りたくない場合は、i_dist_factor_refの値をそのまま使ってください。
			this._dist_factor = new NyARObserv2IdealMap(i_distfactor_ref,i_size);


			// 輪郭バッファ
			this._pca=new NyARPca2d_MatrixPCA_O2();
			this._xpos=new Vector.<Number>(i_size.w+i_size.h);//最大辺長はthis._width+this._height
			this._ypos=new Vector.<Number>(i_size.w+i_size.h);//最大辺長はthis._width+this._height
			return;
		}


		/**
		 * 輪郭点集合からay+bx+c=0の直線式を計算します。
		 * @param i_st
		 * @param i_ed
		 * @param i_xcoord
		 * @param i_ycoord
		 * @param i_cood_num
		 * @param o_line
		 * @return
		 * @throws NyARException
		 */
		public function coord2Line(i_st:int,i_ed:int,i_xcoord:Vector.<int>,i_ycoord:Vector.<int>,i_cood_num:int,o_line:NyARLinear):Boolean
		{
			//頂点を取得
			var n:int,st:int,ed:int;
			var w1:Number;
		
			//探索区間の決定
			if(i_ed>=i_st){
				//頂点[i]から頂点[i+1]までの輪郭が、1区間にあるとき
				w1 = (Number) (i_ed - i_st + 1) * 0.05 + 0.5;
				//探索区間の決定
				st = (int) (i_st+w1);
				ed = (int) (i_ed - w1);
			}else{
				//頂点[i]から頂点[i+1]までの輪郭が、2区間に分かれているとき
				w1 = (Number) (i_ed+i_cood_num-i_st+1)%i_cood_num * 0.05 + 0.5;
				//探索区間の決定
				st = (int) (i_st+w1)%i_cood_num;
				ed = (int) (i_ed+i_cood_num-w1)%i_cood_num;
			}
			//探索区間数を確認
			if(st<=ed){
				//探索区間は1区間
				n = ed - st + 1;
				this._dist_factor.observ2IdealBatch(i_xcoord, i_ycoord, st, n,this._xpos,this._ypos,0);
			}else{
				//探索区間は2区間
				n=ed+1+i_cood_num-st;
				this._dist_factor.observ2IdealBatch(i_xcoord, i_ycoord, st,i_cood_num-st,this._xpos,this._ypos,0);
				this._dist_factor.observ2IdealBatch(i_xcoord, i_ycoord, 0,ed+1,this._xpos,this._ypos,i_cood_num-st);
			}
			//要素数の確認
			if (n < 2) {
				// nが2以下でmatrix.PCAを計算することはできないので、エラー
				return false;
			}
			//主成分分析する。
			var evec:NyARDoubleMatrix22=this.__getSquareLine_evec;
			var mean:Vector.<Number>=this.__getSquareLine_mean;

			
			this._pca.pca(this._xpos,this._ypos,n,evec, this.__getSquareLine_ev,mean);
			o_line.dy = evec.m01;// line[i][0] = evec->m[1];
			o_line.dx = -evec.m00;// line[i][1] = -evec->m[0];
			o_line.c = -(o_line.dy * mean[0] + o_line.dx * mean[1]);// line[i][2] = -(line[i][0]*mean->v[0] + line[i][1]*mean->v[1]);

			return true;
		}
	}

}