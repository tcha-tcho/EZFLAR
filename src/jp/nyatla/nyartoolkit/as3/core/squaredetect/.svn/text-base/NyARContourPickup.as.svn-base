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
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.labeling.*;
	import jp.nyatla.nyartoolkit.as3.*;
	public class NyARContourPickup
	{
		//巡回参照できるように、テーブルを二重化
		//                                           0  1  2  3  4  5  6  7   0  1  2  3  4  5  6
		protected static const _getContour_xdir:Vector.<int> = Vector.<int>([0, 1, 1, 1, 0, -1, -1, -1 , 0, 1, 1, 1, 0, -1, -1]);
		protected static const _getContour_ydir:Vector.<int> = Vector.<int>([-1,-1, 0, 1, 1, 1, 0,-1 ,-1,-1, 0, 1, 1, 1, 0]);
		public function getContour_NyARBinRaster(i_raster:NyARBinRaster,i_entry_x:int,i_entry_y:int,i_array_size:int,o_coord_x:Vector.<int>,o_coord_y:Vector.<int>):int
		{
			return impl_getContour(i_raster,0,i_entry_x,i_entry_y,i_array_size,o_coord_x,o_coord_y);
		}
		/**
		 * 
		 * @param i_raster
		 * @param i_th
		 * 画像を２値化するための閾値。暗点<=i_th<明点となります。
		 * @param i_entry_x
		 * 輪郭の追跡開始点を指定します。
		 * @param i_entry_y
		 * @param i_array_size
		 * @param o_coord_x
		 * @param o_coord_y
		 * @return
		 * @throws NyARException
		 */
		public function getContour_NyARGrayscaleRaster(i_raster:NyARGrayscaleRaster,i_th:int,i_entry_x:int,i_entry_y:int,i_array_size:int,o_coord_x:Vector.<int>,o_coord_y:Vector.<int>):int
		{
			return impl_getContour(i_raster,i_th,i_entry_x,i_entry_y,i_array_size,o_coord_x,o_coord_y);
		}

		/**
		 * ラスタのエントリポイントから辿れる輪郭線を配列に返します。
		 * @param i_raster
		 * @param i_th
		 * 暗点<=th<明点
		 * @param i_entry_x
		 * @param i_entry_y
		 * @param i_array_size
		 * @param o_coord_x
		 * @param o_coord_y
		 * @return
		 * 輪郭線の長さを返します。
		 * @throws NyARException
		 */
		private function impl_getContour(i_raster:INyARRaster,i_th:int,i_entry_x:int,i_entry_y:int,i_array_size:int,o_coord_x:Vector.<int>,o_coord_y:Vector.<int>):int
		{
			var xdir:Vector.<int> = _getContour_xdir;// static int xdir[8] = { 0, 1, 1, 1, 0,-1,-1,-1};
			var ydir:Vector.<int> = _getContour_ydir;// static int ydir[8] = {-1,-1, 0, 1, 1, 1, 0,-1};

			var i_buf:Vector.<int>=Vector.<int>(i_raster.getBuffer());
			var width:int=i_raster.getWidth();
			var height:int=i_raster.getHeight();
			//クリップ領域の上端に接しているポイントを得る。


			var coord_num:int = 1;
			o_coord_x[0] = i_entry_x;
			o_coord_y[0] = i_entry_y;
			var dir:int = 5;

			var c:int = i_entry_x;
			var r:int = i_entry_y;
			for (;;) {
				dir = (dir + 5) % 8;//dirの正規化
				//ここは頑張ればもっと最適化できると思うよ。
				//4隅以外の境界接地の場合に、境界チェックを省略するとかね。
				if(c>=1 && c<width-1 && r>=1 && r<height-1){
					for(;;){//gotoのエミュレート用のfor文
						//境界に接していないとき(暗点判定)
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
						dir++;
						if (i_buf[(r + ydir[dir])*width+(c + xdir[dir])] <= i_th) {
							break;
						}
	/*
						try{
							BufferedImage b=new BufferedImage(width,height,ColorSpace.TYPE_RGB);
							NyARRasterImageIO.copy(i_raster, b);
						ImageIO.write(b,"png",new File("bug.png"));
						}catch(Exception e){
							
						}*/
						//8方向全て調べたけどラベルが無いよ？
						throw new NyARException();			
					}
				}else{
					//境界に接しているとき				
					var i:int;
					for (i = 0; i < 8; i++){				
						var x:int=c + xdir[dir];
						var y:int=r + ydir[dir];
						//境界チェック
						if(x>=0 && x<width && y>=0 && y<height){
							if (i_buf[(y)*width+(x)] <= i_th) {
								break;
							}
						}
						dir++;//倍長テーブルを参照するので問題なし
					}
					if (i == 8) {
						//8方向全て調べたけどラベルが無いよ？
						throw new NyARException();// return(-1);
					}				
				}
				
				dir=dir% 8;//dirの正規化

				// xcoordとycoordをc,rにも保存
				c = c + xdir[dir];
				r = r + ydir[dir];
				o_coord_x[coord_num] = c;
				o_coord_y[coord_num] = r;
				// 終了条件判定
				if (c == i_entry_x && r == i_entry_y){
					coord_num++;
					break;
				}
				coord_num++;
				if (coord_num == i_array_size) {
					//輪郭が末端に達した
					return coord_num;
				}
			}
			return coord_num;
		}
	}
}