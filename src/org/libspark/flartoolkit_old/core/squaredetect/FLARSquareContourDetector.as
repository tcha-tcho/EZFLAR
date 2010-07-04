/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
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
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 */
package org.libspark.flartoolkit.core.squaredetect
{
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	import jp.nyatla.nyartoolkit.as3.core.types.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.labeling.*;
	import jp.nyatla.nyartoolkit.as3.core.labeling.rlelabeling.*;
	
	import org.libspark.flartoolkit.core.labeling.fllabeling.*;
	import org.libspark.flartoolkit.core.labeling.*;
	import org.libspark.flartoolkit.core.raster.*;
	
	public class FLARSquareContourDetector extends NyARSquareContourDetector
	{
		private static const AR_AREA_MAX:int = 100000;// #define AR_AREA_MAX 100000
		private static const AR_AREA_MIN:int = 70;// #define AR_AREA_MIN 70
		private var _width:int;
		private var _height:int;

		private var _labeling:FLARLabeling;

		private var _overlap_checker:NyARLabelOverlapChecker = new NyARLabelOverlapChecker(32);
		private var _cpickup:FLContourPickup=new FLContourPickup();
		private var _stack:NyARRleLabelFragmentInfoStack;
		private var _coord2vertex:NyARCoord2SquareVertexIndexes=new NyARCoord2SquareVertexIndexes();
		
		private var _max_coord:int;
		private var _xcoord:Vector.<int>;
		private var _ycoord:Vector.<int>;
		/**
		 * 最大i_squre_max個のマーカーを検出するクラスを作成する。
		 * 
		 * @param i_param
		 */
		public function FLARSquareContourDetector(i_dist_factor_ref:NyARCameraDistortionFactor,i_size:NyARIntSize)
		{
			this._width = i_size.w;
			this._height = i_size.h;
			//ラベリングのサイズを指定したいときはsetAreaRangeを使ってね。
			this._labeling = new FLARLabeling(this._width,this._height);
			this._stack=new NyARRleLabelFragmentInfoStack(i_size.w*i_size.h*2048/(320*240)+32);//検出可能な最大ラベル数
			

			// 輪郭の最大長は画面に映りうる最大の長方形サイズ。
			var number_of_coord:int= (this._width + this._height) * 2;

			// 輪郭バッファ
			this._max_coord = number_of_coord;
			this._xcoord = new Vector.<int>(number_of_coord);
			this._ycoord = new Vector.<int>(number_of_coord);
			return;
		}

		private var __detectMarker_mkvertex:Vector.<int> = new Vector.<int>(4);
		
		public override function detectMarkerCB(i_raster:NyARBinRaster ,i_callback:NyARSquareContourDetector_IDetectMarkerCallback):void
		{
			var flagment:NyARRleLabelFragmentInfoStack=this._stack;
			var overlap:NyARLabelOverlapChecker = this._overlap_checker;

			// ラベル数が0ならここまで
			var label_num:int=this._labeling.labeling(i_raster, flagment);
			if (label_num < 1) {
				return;
			}
			//ラベルをソートしておく
			flagment.sortByArea();
			//ラベルリストを取得
			var labels:Vector.<NyARRleLabelFragmentInfo>=Vector.<NyARRleLabelFragmentInfo>(flagment.getArray());

			var xsize:int = this._width;
			var ysize:int = this._height;
			var xcoord:Vector.<int> = this._xcoord;
			var ycoord:Vector.<int> = this._ycoord;
			var coord_max:int = this._max_coord;
			var mkvertex:Vector.<int> =this.__detectMarker_mkvertex;


			//重なりチェッカの最大数を設定
			overlap.setMaxLabels(label_num);

			for (var i:int=0; i < label_num; i++) {
				var label_pt:NyARRleLabelFragmentInfo=labels[i];
				var label_area:int = label_pt.area;
			
				// クリップ領域が画面の枠に接していれば除外
				if (label_pt.clip_l == 0 || label_pt.clip_r == xsize-1){
					continue;
				}
				if (label_pt.clip_t == 0 || label_pt.clip_b == ysize-1){
					continue;
				}
				// 既に検出された矩形との重なりを確認
				if (!overlap.check(label_pt)) {
					// 重なっているようだ。
					continue;
				}
				
				//輪郭を取得
				var coord_num:int = _cpickup.getContour_FLARBinRaster(FLARBinRaster(i_raster),label_pt.entry_x,label_pt.clip_t, coord_max, xcoord, ycoord);
				if (coord_num == coord_max) {
					// 輪郭が大きすぎる。
					continue;
				}
				//輪郭線をチェックして、矩形かどうかを判定。矩形ならばmkvertexに取得
				if (!this._coord2vertex.getVertexIndexes(xcoord, ycoord,coord_num,label_area, mkvertex)) {
					// 頂点の取得が出来なかった
					continue;
				}
				//矩形を発見したことをコールバック関数で通知
				i_callback.onSquareDetect(this,xcoord,ycoord,coord_num,mkvertex);

				// 検出済の矩形の属したラベルを重なりチェックに追加する。
				overlap.push(label_pt);
			
			}
			return;
		}
	}
}
