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
package jp.nyatla.nyartoolkit.as3.core.transmat.solver 
{
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	/**
	 * 並進ベクトル[T]を３次元座標[b]と基点の回転済行列[M]から計算します。
	 * 
	 * アルゴリズムは、ARToolKit 拡張現実プログラミング入門 の、P207のものです。
	 * 
	 * 計算手順
	 * [A]*[T]=bを、[A]T*[A]*[T]=[A]T*[b]にする。
	 * set2dVertexで[A]T*[A]=[M]を計算して、Aの3列目の情報だけ保存しておく。
	 * getTransportVectorで[M]*[T]=[A]T*[b]を連立方程式で解いて、[T]を得る。
	 */
	public class NyARTransportVectorSolver implements INyARTransportVectorSolver
	{
		private var _cx:Vector.<Number>;
		private var _cy:Vector.<Number>;	
		private var _projection_mat:NyARPerspectiveProjectionMatrix;
		private var _nmber_of_vertex:int;
		public function NyARTransportVectorSolver(i_projection_mat_ref:NyARPerspectiveProjectionMatrix,i_max_vertex:int)
		{
			this._projection_mat=i_projection_mat_ref;
			this._cx=new Vector.<Number>(i_max_vertex);
			this._cy=new Vector.<Number>(i_max_vertex);	
			return;
		}
		private var _a00:Number,_a01_10:Number,_a02_20:Number,_a11:Number,_a12_21:Number,_a22:Number;
		/**
		 * 画面上の座標群を指定します。
		 * @param i_ref_vertex_2d
		 * 歪み矯正済の画面上の頂点座標群への参照値を指定します。
		 * @throws NyARException
		 * 
		 */
		public function set2dVertex(i_ref_vertex_2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int):void
		{
			//3x2nと2n*3の行列から、最小二乗法計算するために3x3マトリクスを作る。		
			//行列[A]の3列目のキャッシュ
			var cx:Vector.<Number>=this._cx;
			var cy:Vector.<Number>=this._cy;
			
			var m22:Number;
			var p00:Number=this._projection_mat.m00;
			var p01:Number=this._projection_mat.m01;
			var p11:Number=this._projection_mat.m11;
			var p12:Number=this._projection_mat.m12;
			var p02:Number=this._projection_mat.m02;
			var w1:Number,w2:Number,w3:Number,w4:Number;
			
			this._a00=i_number_of_vertex*p00*p00;
			this._a01_10=i_number_of_vertex*p00*p01;
			this._a11=i_number_of_vertex*(p01*p01+p11*p11);
			
			//[A]T*[A]の計算
			m22=0;
			w1=w2=0;
			for(var i:int=0;i<i_number_of_vertex;i++){
				//座標を保存しておく。
				w3=p02-(cx[i]=i_ref_vertex_2d[i].x);
				w4=p12-(cy[i]=i_ref_vertex_2d[i].y);
				w1+=w3;
				w2+=w4;
				m22+=w3*w3+w4*w4;
			}
			this._a02_20=w1*p00;
			this._a12_21=p01*w1+p11*w2;
			this._a22=m22;

			this._nmber_of_vertex=i_number_of_vertex;
			return;
		}
		
		/**
		 * 画面座標群と3次元座標群から、平行移動量を計算します。
		 * 2d座標系は、直前に実行したset2dVertexのものを使用します。
		 * @param i_vertex_2d
		 * 直前のset2dVertexコールで指定したものと同じものを指定してください。
		 * @param i_vertex3d
		 * 3次元空間の座標群を設定します。頂点の順番は、画面座標群と同じ順序で格納してください。
		 * @param o_transfer
		 * @throws NyARException
		 */
		public function solveTransportVector(i_vertex3d:Vector.<NyARDoublePoint3d>,o_transfer:NyARDoublePoint3d):void
		{
			var number_of_vertex:int=this._nmber_of_vertex;
			var p00:Number=this._projection_mat.m00;
			var p01:Number=this._projection_mat.m01;
			var p02:Number=this._projection_mat.m02;
			var p11:Number=this._projection_mat.m11;
			var p12:Number=this._projection_mat.m12;
			//行列[A]の3列目のキャッシュ
			var cx:Vector.<Number>=this._cx;
			var cy:Vector.<Number>=this._cy;			
			
			//回転行列を元座標の頂点群に適応
			//[A]T*[b]を計算
			var b1:Number, b2:Number, b3:Number;
			b1 = b2 = b3 = 0;
			for(var i:int=0;i<number_of_vertex;i++)
			{
				var w1:Number=i_vertex3d[i].z*cx[i]-p00*i_vertex3d[i].x-p01*i_vertex3d[i].y-p02*i_vertex3d[i].z;
				var w2:Number=i_vertex3d[i].z*cy[i]-p11*i_vertex3d[i].y-p12*i_vertex3d[i].z;
				b1+=w1;
				b2+=w2;
				b3+=cx[i]*w1+cy[i]*w2;
			}
			//[A]T*[b]を計算
			b3=p02*b1+p12*b2-b3;//順番変えたらダメよ
			b2=p01*b1+p11*b2;
			b1=p00*b1;
			//([A]T*[A])*[T]=[A]T*[b]を方程式で解く。
			//a01とa10を0と仮定しても良いんじゃないかな？
			var a00:Number=this._a00;
			var a01:Number=this._a01_10;
			var a02:Number=this._a02_20;
			var a11:Number=this._a11;
			var a12:Number=this._a12_21;
			var a22:Number=this._a22;
			
			var t1:Number=a22*b2-a12*b3;
			var t2:Number=a12*b2-a11*b3;
			var t3:Number=a01*b3-a02*b2;
			var t4:Number=a12*a12-a11*a22;
			var t5:Number=a02*a12-a01*a22;
			var t6:Number=a02*a11-a01*a12;
			var det:Number=a00*t4-a01*t5 + a02*t6;
			o_transfer.x= (a01*t1 - a02*t2 +b1*t4)/det;
			o_transfer.y=-(a00*t1 + a02*t3 +b1*t5)/det;
			o_transfer.z= (a00*t2 + a01*t3 +b1*t6)/det;
			
		
			return;
		}
	}

}