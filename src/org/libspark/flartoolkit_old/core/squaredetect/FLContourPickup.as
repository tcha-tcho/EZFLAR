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
	import flash.display.BitmapData;
	import jp.nyatla.nyartoolkit.as3.core.squaredetect.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import org.libspark.flartoolkit.core.raster.*;
	import jp.nyatla.as3utils.*;
	import jp.nyatla.nyartoolkit.as3.*;
	
	public class FLContourPickup extends NyARContourPickup
	{
		
		public function FLContourPickup() 
		{
			
		}
		public function getContour_FLARBinRaster(i_raster:FLARBinRaster,i_entry_x:int,i_entry_y:int,i_array_size:int,o_coord_x:Vector.<int>,o_coord_y:Vector.<int>):int
		{
			var xdir:Vector.<int> = _getContour_xdir;// static int xdir[8] = { 0, 1, 1, 1, 0,-1,-1,-1};
			var ydir:Vector.<int> = _getContour_ydir;// static int ydir[8] = {-1,-1, 0, 1, 1, 1, 0,-1};

			var i_buf:BitmapData=BitmapData(i_raster.getBuffer());
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
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
						dir++;
						if (i_buf.getPixel(c + xdir[dir], r + ydir[dir]) >0) {
							break;
						}
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
							if (i_buf[(y)*width+(x)] >0) {
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