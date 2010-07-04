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
package org.libspark.flartoolkit.core.labeling.fllabeling
{
	import org.libspark.flartoolkit.core.types.*;
	import org.libspark.flartoolkit.core.raster.*;
	import org.libspark.flartoolkit.*;
	import jp.nyatla.nyartoolkit.as3.core.labeling.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.nyartoolkit.as3.core.labeling.rlelabeling.*;
	

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class FLARLabeling
	{
		private static const AR_AREA_MAX:int = 100000;// #define AR_AREA_MAX 100000
		private static const AR_AREA_MIN:int = 70;// #define AR_AREA_MIN 70
		
		private static const ZERO_POINT:Point = new Point();
		private static const ONE_POINT:Point = new Point(1, 1);
		
	    private var hSearch:BitmapData;
	    private var hLineRect:Rectangle;
		private var _tmp_bmp:BitmapData;
		public function FLARLabeling(i_width:int,i_height:int)
		{
			this._tmp_bmp = new BitmapData(i_width, i_height, false,0x00);
			this.hSearch = new BitmapData(i_width, 1, false, 0x000000);
			this.hLineRect = new Rectangle(0, 0, 1, 1);			
			return;
		}

		public function labeling(i_bin_raster:NyARBinRaster,o_stack:NyARRleLabelFragmentInfoStack):int
		{
			var label_img:BitmapData = this._tmp_bmp;
			label_img.fillRect(label_img.rect, 0x0);
			var rect:Rectangle = label_img.rect.clone();
			rect.inflate(-1, -1);
			label_img.copyPixels(BitmapData(i_bin_raster.getBuffer()), rect, ONE_POINT);
			
			var currentRect:Rectangle = label_img.getColorBoundsRect(0xffffff, 0xffffff, true);
			hLineRect.y = 0;
			hLineRect.width = label_img.width;
			var hSearchRect:Rectangle;
			var labelRect:Rectangle;
			var index:int = 0;
			var label:NyARRleLabelFragmentInfo;
			o_stack.clear();
			try {
				while (!currentRect.isEmpty()) {
					hLineRect.y = currentRect.top;
					hSearch.copyPixels(label_img, hLineRect, ZERO_POINT);
					hSearchRect = hSearch.getColorBoundsRect(0xffffff, 0xffffff, true);
					
					label_img.floodFill(hSearchRect.x, hLineRect.y, ++index);
					labelRect = label_img.getColorBoundsRect(0xffffff, index, true);
					label = o_stack.prePush() as NyARRleLabelFragmentInfo;
					var area:int = labelRect.width * labelRect.height;
					//エリア規制
					if (area <= AR_AREA_MAX && area >= AR_AREA_MIN){
						label.area = area;
						label.clip_l = labelRect.left;
						label.clip_r = labelRect.right - 1;
						label.clip_t = labelRect.top;
						label.clip_b = labelRect.bottom - 1;
						label.pos_x = (labelRect.left + labelRect.right - 1) * 0.5;
						label.pos_y = (labelRect.top + labelRect.bottom - 1) * 0.5;
						//エントリ・ポイントを探す
						label.entry_x=getTopClipTangentX(label_img,index,label);
					}else {
						o_stack.pop();
					}
					currentRect = label_img.getColorBoundsRect(0xffffff, 0xffffff, true);
				}
			} catch (e:Error){
				trace('Too many labeled area!! gave up....');
			}
			return o_stack.getLength();
		}
		private function getTopClipTangentX(i_image:BitmapData, i_index:int, i_label:NyARRleLabelFragmentInfo):int
		{
			var w:int;
			const clip1:int = i_label.clip_r;
			var i:int;
			for (i = i_label.clip_l; i <= clip1; i++) { // for( i = clip[0]; i <=clip[1]; i++, p1++ ) {
				w = i_image.getPixel(i, i_label.clip_t);
				if (w > 0 && w == i_index) {
					return i;
				}
			}
			//あれ？見つからないよ？
			throw new FLARException();
		}		
	}
}