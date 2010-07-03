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
package jp.nyatla.nyartoolkit.as3.core.transmat
{
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.types.matrix.*;
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.rotmatrix.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.optimize.*;
	import jp.nyatla.nyartoolkit.as3.core.transmat.solver.*;
	/**
	 * This class calculates ARMatrix from square information and holds it. --
	 * 変換行列を計算して、結果を保持するクラス。
	 * 
	 */
	public class NyARTransMat implements INyARTransMat
	{	
		private var _projection_mat_ref:NyARPerspectiveProjectionMatrix;
		protected var _rotmatrix:NyARRotMatrix;
		protected var _transsolver:INyARTransportVectorSolver;
		protected var _mat_optimize:NyARPartialDifferentiationOptimize;


		private var _ref_dist_factor:NyARCameraDistortionFactor;


		public function NyARTransMat(i_param:NyARParam)
		{
			var dist:NyARCameraDistortionFactor=i_param.getDistortionFactor();
			var pmat:NyARPerspectiveProjectionMatrix=i_param.getPerspectiveProjectionMatrix();
			this._transsolver=new NyARTransportVectorSolver(pmat,4);
			//互換性が重要な時は、NyARRotMatrix_ARToolKitを使うこと。
			//理屈はNyARRotMatrix_NyARToolKitもNyARRotMatrix_ARToolKitも同じだけど、少しだけ値がずれる。
			this._rotmatrix = new NyARRotMatrix(pmat);
			this._mat_optimize=new NyARPartialDifferentiationOptimize(pmat);
			this._ref_dist_factor=dist;
			this._projection_mat_ref=pmat;
		}

		private var __transMat_vertex_2d:Vector.<NyARDoublePoint2d> = NyARDoublePoint2d.createArray(4);
		private var __transMat_vertex_3d:Vector.<NyARDoublePoint3d> = NyARDoublePoint3d.createArray(4);
		private var __transMat_trans:NyARDoublePoint3d=new NyARDoublePoint3d();
		
		/**
		 * 頂点情報を元に、エラー閾値を計算します。
		 * @param i_vertex
		 */
		private function makeErrThreshold(i_vertex:Vector.<NyARDoublePoint2d>):Number
		{
			var a:Number,b:Number,l1:Number,l2:Number;
			a=i_vertex[0].x-i_vertex[2].x;
			b=i_vertex[0].y-i_vertex[2].y;
			l1=a*a+b*b;
			a=i_vertex[1].x-i_vertex[3].x;
			b=i_vertex[1].y-i_vertex[3].y;
			l2=a*a+b*b;
			return (Math.sqrt(l1>l2?l1:l2))/200;
		}
		
		/**
		 * double arGetTransMat( ARMarkerInfo *marker_info,double center[2], double width, double conv[3][4] )
		 * 
		 * @param i_square
		 * 計算対象のNyARSquareオブジェクト
		 * @param i_direction
		 * @param i_width
		 * @return
		 * @throws NyARException
		 */
		public function transMat(i_square:NyARSquare,i_offset:NyARRectOffset,o_result_conv:NyARTransMatResult):void
		{
			var trans:NyARDoublePoint3d=this.__transMat_trans;
			
			var err_threshold:Number=makeErrThreshold(i_square.sqvertex);
			
			//平行移動量計算機に、2D座標系をセット
			var vertex_2d:Vector.<NyARDoublePoint2d>=this.__transMat_vertex_2d;
			var vertex_3d:Vector.<NyARDoublePoint3d>=this.__transMat_vertex_3d;
			this._ref_dist_factor.ideal2ObservBatch(i_square.sqvertex, vertex_2d,4);		
			this._transsolver.set2dVertex(vertex_2d,4);
			
			//回転行列を計算
			this._rotmatrix.initRotBySquare(i_square.line,i_square.sqvertex);
			
			//回転後の3D座標系から、平行移動量を計算
			this._rotmatrix.getPoint3dBatch(i_offset.vertex,vertex_3d,4);
			this._transsolver.solveTransportVector(vertex_3d,trans);
			
			//計算結果の最適化(平行移動量と回転行列の最適化)
			o_result_conv.error=this.optimize(this._rotmatrix, trans, this._transsolver,i_offset.vertex, vertex_2d,err_threshold);
			
			// マトリクスの保存
			this.updateMatrixValue(this._rotmatrix, trans,o_result_conv);
			return;
		}

		/*
		 * (non-Javadoc)
		 * @see jp.nyatla.nyartoolkit.core.transmat.INyARTransMat#transMatContinue(jp.nyatla.nyartoolkit.core.NyARSquare, int, double, jp.nyatla.nyartoolkit.core.transmat.NyARTransMatResult)
		 */
		public function transMatContinue(i_square:NyARSquare,i_offset:NyARRectOffset,o_result_conv:NyARTransMatResult):void
		{
			var trans:NyARDoublePoint3d=this.__transMat_trans;

			// io_result_convが初期値なら、transMatで計算する。
			if (!o_result_conv.has_value) {
				this.transMat(i_square,i_offset, o_result_conv);
				return;
			}
			
			//最適化計算の閾値を決定
			var err_threshold:Number=makeErrThreshold(i_square.sqvertex);

			
			//平行移動量計算機に、2D座標系をセット
			var vertex_2d:Vector.<NyARDoublePoint2d>=this.__transMat_vertex_2d;
			var vertex_3d:Vector.<NyARDoublePoint3d>=this.__transMat_vertex_3d;
			this._ref_dist_factor.ideal2ObservBatch(i_square.sqvertex, vertex_2d,4);		
			this._transsolver.set2dVertex(vertex_2d,4);
			
			//回転行列を計算
			this._rotmatrix.initRotByPrevResult(o_result_conv);
			
			//回転後の3D座標系から、平行移動量を計算
			this._rotmatrix.getPoint3dBatch(i_offset.vertex,vertex_3d,4);
			this._transsolver.solveTransportVector(vertex_3d,trans);

			//現在のエラーレートを計算しておく
			var min_err:Number=errRate(this._rotmatrix,trans,i_offset.vertex, vertex_2d,4,vertex_3d);
			var rot:NyARDoubleMatrix33=this.__rot;
			//エラーレートが前回のエラー値より閾値分大きかったらアゲイン
			if(min_err<o_result_conv.error+err_threshold){
				rot.setValue_NyARDoubleMatrix33(this._rotmatrix);
				//最適化してみる。
				for (var i:int = 0;i<5; i++) {
					//変換行列の最適化
					this._mat_optimize.modifyMatrix(rot, trans, i_offset.vertex, vertex_2d, 4);
					var err:Number=errRate(rot,trans,i_offset.vertex, vertex_2d,4,vertex_3d);
					//System.out.println("E:"+err);
					if(min_err-err<err_threshold/2){
						//System.out.println("BREAK");
						break;
					}
					this._transsolver.solveTransportVector(vertex_3d, trans);
					this._rotmatrix.setValue_NyARDoubleMatrix33(rot);
					min_err=err;
				}
				this.updateMatrixValue(this._rotmatrix,  trans,o_result_conv);
			}else{
				//回転行列を計算
				this._rotmatrix.initRotBySquare(i_square.line,i_square.sqvertex);
				
				//回転後の3D座標系から、平行移動量を計算
				this._rotmatrix.getPoint3dBatch(i_offset.vertex,vertex_3d,4);
				this._transsolver.solveTransportVector(vertex_3d,trans);
				
				//計算結果の最適化(平行移動量と回転行列の最適化)
				min_err=this.optimize(this._rotmatrix, trans, this._transsolver,i_offset.vertex, vertex_2d,err_threshold);
				this.updateMatrixValue(this._rotmatrix, trans,o_result_conv);
			}
			o_result_conv.error=min_err;
			return;
		}
		private var __rot:NyARDoubleMatrix33=new NyARDoubleMatrix33();
		private function optimize(io_rotmat:NyARRotMatrix,io_transvec:NyARDoublePoint3d,i_solver:INyARTransportVectorSolver,i_offset_3d:Vector.<NyARDoublePoint3d>,i_2d_vertex:Vector.<NyARDoublePoint2d>,i_err_threshold:Number):Number
		{
			//System.out.println("START");
			var vertex_3d:Vector.<NyARDoublePoint3d>=this.__transMat_vertex_3d;
			//初期のエラー値を計算
			var min_err:Number=errRate(io_rotmat, io_transvec, i_offset_3d, i_2d_vertex,4,vertex_3d);
			var rot:NyARDoubleMatrix33=this.__rot;
			rot.setValue_NyARDoubleMatrix33(io_rotmat);
			for (var i:int = 0;i<5; i++) {
				//変換行列の最適化
				this._mat_optimize.modifyMatrix(rot, io_transvec, i_offset_3d, i_2d_vertex, 4);
				var err:Number=errRate(rot,io_transvec, i_offset_3d, i_2d_vertex,4,vertex_3d);
				//System.out.println("E:"+err);
				if(min_err-err<i_err_threshold){
					//System.out.println("BREAK");
					break;
				}
				i_solver.solveTransportVector(vertex_3d, io_transvec);
				io_rotmat.setValue_NyARDoubleMatrix33(rot);
				min_err=err;
			}
			//System.out.println("END");
			return min_err;
		}
		
		//エラーレート計算機
		public function errRate(io_rot:NyARDoubleMatrix33,i_trans:NyARDoublePoint3d,i_vertex3d:Vector.<NyARDoublePoint3d>,i_vertex2d:Vector.<NyARDoublePoint2d>,i_number_of_vertex:int,o_rot_vertex:Vector.<NyARDoublePoint3d>):Number
		{
			var cp:NyARPerspectiveProjectionMatrix = this._projection_mat_ref;
			var cp00:Number=cp.m00;
			var cp01:Number=cp.m01;
			var cp02:Number=cp.m02;
			var cp11:Number=cp.m11;
			var cp12:Number=cp.m12;

			var err:Number=0;
			for(var i:int=0;i<i_number_of_vertex;i++){
				var x3d:Number,y3d:Number,z3d:Number;
				o_rot_vertex[i].x=x3d=io_rot.m00*i_vertex3d[i].x+io_rot.m01*i_vertex3d[i].y+io_rot.m02*i_vertex3d[i].z;
				o_rot_vertex[i].y=y3d=io_rot.m10*i_vertex3d[i].x+io_rot.m11*i_vertex3d[i].y+io_rot.m12*i_vertex3d[i].z;
				o_rot_vertex[i].z=z3d=io_rot.m20*i_vertex3d[i].x+io_rot.m21*i_vertex3d[i].y+io_rot.m22*i_vertex3d[i].z;
				x3d+=i_trans.x;
				y3d+=i_trans.y;
				z3d+=i_trans.z;
				
				//射影変換
				var x2d:Number=x3d*cp00+y3d*cp01+z3d*cp02;
				var y2d:Number=y3d*cp11+z3d*cp12;
				var h2d:Number=z3d;
				
				//エラーレート計算
				var t1:Number=i_vertex2d[i].x-x2d/h2d;
				var t2:Number=i_vertex2d[i].y-y2d/h2d;
				err+=t1*t1+t2*t2;
				
			}
			return err/i_number_of_vertex;
		}		
		
		
		
		/**
		 * パラメータで変換行列を更新します。
		 * 
		 * @param i_rot
		 * @param i_off
		 * @param i_trans
		 */
		public function updateMatrixValue(i_rot:NyARRotMatrix,i_trans:NyARDoublePoint3d,o_result:NyARTransMatResult):void
		{
			o_result.m00=i_rot.m00;
			o_result.m01=i_rot.m01;
			o_result.m02=i_rot.m02;
			o_result.m03=i_trans.x;

			o_result.m10 =i_rot.m10;
			o_result.m11 =i_rot.m11;
			o_result.m12 =i_rot.m12;
			o_result.m13 =i_trans.y;

			o_result.m20 = i_rot.m20;
			o_result.m21 = i_rot.m21;
			o_result.m22 = i_rot.m22;
			o_result.m23 = i_trans.z;

			o_result.has_value = true;
			return;
		}	
	}

}