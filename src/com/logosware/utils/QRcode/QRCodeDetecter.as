/**************************************************************************
* LOGOSWARE Class Library.
*
* Copyright 2009 (c) LOGOSWARE (http://www.logosware.com) All rights reserved.
*
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the GNU General Public License as published by the Free Software
* Foundation; either version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this program; if not, write to the Free Software Foundation, Inc., 59 Temple
* Place, Suite 330, Boston, MA 02111-1307 USA
*
**************************************************************************/ 
package com.logosware.utils.QRcode 
{
	import com.logosware.utils.LabelingClass;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * @author UENO Kenichi
	 */
	public class QRCodeDetecter extends Sprite
	{
		private var image:DisplayObject;
		private var bd:BitmapData;
		private var bd2:BitmapData;
		private var threshold:uint = 0xFF888888;
		private var grayConst:Array = [
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0, 0, 0, 0, 255
		];
		/**
		 * 画像からQRコードを見つけ出します
		 * @param	imageSource
		 */
		public function QRCodeDetecter(imageSource:DisplayObject) 
		{
			image = imageSource;
			bd = new BitmapData(image.width, image.height, true, 0x0);
			bd2 = new BitmapData(image.width, image.height, true, 0x0);
// debug code
/*
			var bmp:Bitmap = new Bitmap( bd );
			image.parent.addChild( bmp );
			bmp.x = image.width;
*/
		}
		/**
		 * 見つかったQRコードの位置情報を返します
		 * @return マーカー配列
		 * 	[
		 * 		{
		 * 			image:BitmapData,
		 * 			borderColors:[
		 * 				0: uint color of topleft marker
		 * 				1: uint color of topright marker
		 * 				2: uint color of bottomleft marker
		 * 			],
		 * 			originalLocation:[
		 * 				0: Rectangle of topleft marker
		 * 				1: Rectangle of topright marker
		 * 				2: Rectangle of bottomleft marker
		 * 			]
		 * 		}
		 * 		...
		 * 	]
		 */
		public function detect():Array {
			var ret:Array = [];
			bd.lock();
			bd.draw(image);
			
			// グレー化
			bd.applyFilter(bd, bd.rect, new Point(), new ColorMatrixFilter(grayConst));
			bd.applyFilter(bd, bd.rect, new Point(), new ConvolutionFilter(5, 5, [
				0, -1, -1, -1, 0,
				-1, -1, -2, -1, -1,
				-1, -2, 25, -2, -1,
				-1, -1, -2, -1, -1,
				0, -1, -1, -1, 0
			]));
			bd.applyFilter(bd, bd.rect, new Point(), new BlurFilter(3, 3));
			
			// 二値化
			bd.threshold(bd, bd.rect, new Point(), ">", threshold, 0xFFFFFFFF, 0x0000FF00);
			bd.threshold(bd, bd.rect, new Point(), "!=", 0xFFFFFFFF, 0xFF000000);
			
			// ラベリング
			var LabelingObj:LabelingClass = new LabelingClass(); 
			LabelingObj.Labeling( bd, 10, 0xFF88FFFE, true ); // ラベリング実行
			
			var pickedRects:Array = LabelingObj.getRects();
			var pickedColor:Array = LabelingObj.getColors();
			
			LabelingObj = null;
			
			// マーカー候補の矩形を取得
			var borders:Array = _searchBorders( bd, pickedRects, pickedColor );
			
			// 直角の位置にあるコードを検索
			var codes:Array = _searchCode( borders );
			
			// 適切な角度で切り抜き
			var images:Array = _clipCodes( bd, codes );
			
			for ( var i:int = 0; i < images.length; i++ ) {
				ret.push( { image:images[i], borderColors:[codes[i][0].borderColor, codes[i][1].borderColor, codes[i][2].borderColor], originalLocation:[codes[i][0].borderRect, codes[i][1].borderRect, codes[i][2].borderRect] } );
			}
			bd.unlock();
			return ret;
		}
		private function _clipCodes( bd:BitmapData, codes:Array):Array {
			var ret:Array = [];
			for ( var i:int = 0; i < codes.length; i++ ) {
				var marker1:Rectangle = codes[i][0].borderRect; // top left
				var marker2:Rectangle = codes[i][1].borderRect; // top right
				var marker3:Rectangle = codes[i][2].borderRect; // bottom left
				var vector12:Point = marker2.topLeft.subtract( marker1.topLeft ); // vector: top left -> top right
				var vector13:Point = marker3.topLeft.subtract( marker1.topLeft ); // vector: top left -> bottom left
				var theta:Number = -Math.atan2( vector12.y, vector12.x ); // 平面状の回転角
				
				var matrix:Matrix = new Matrix();
				var d:Number = (0.5 * marker1.width) / (Math.abs(Math.cos( theta )) + Math.abs(Math.sin( theta ) ) ); // マーカーの一辺の長さの半分
				
				matrix.translate( -(marker1.topLeft.x + marker1.width * 0.5), -(marker1.topLeft.y + marker1.height * 0.5) );
				matrix.rotate( theta );
				matrix.translate( 20 + d, 20 + d );
				
				var matrix2:Matrix = new Matrix();
				matrix2.rotate( theta );
				var vector13r:Point = matrix2.transformPoint( vector13 );
				
				matrix2 = new Matrix(1.0, 0, -vector13r.x/vector13r.y, vector12.length / vector13r.y );
				
				matrix.concat( matrix2 );
				
				var len:Number = ( vector12.length + 2 * d ); // QRコードの一辺の長さ
				var bd2:BitmapData = new BitmapData( 40 + len, 40 + len );
				bd2.draw( bd, matrix );
				ret.push( bd2 );
			}
			return ret;
		}
		/**
		 * マーカーの候補をピックアップする
		 * @param	bmp ラベリング済みの画像
		 * @param	rectArray 矩形情報
		 * @param	colorArray 矩形の色情報
		 * @return 候補の配列
		 */
		private function _searchBorders(bmp:BitmapData, rectArray:Array, colorArray:Array):Array {
			function isMarker( ary:Array ):Boolean {
				var c:Number = 0.75;
				var ave:Number = (ary[0] + ary[1] + ary[2] + ary[3] + ary[4]) / 7;
				return(
					ary[0] > ((1.0-c)*ave) && ary[0] < ((1.0+c)*ave) &&
					ary[1] > ((1.0-c)*ave) && ary[1] < ((1.0+c)*ave) &&
					ary[2] > ((3.0-c)*ave) && ary[2] < ((3.0+c)*ave) &&
					ary[3] > ((1.0-c)*ave) && ary[3] < ((1.0+c)*ave) &&
					ary[4] > ((1.0-c) * ave) && ary[4] < ((1.0+c) * ave)
				);
			}
			var retArray:Array = [];
			for ( var i:int = 0; i < rectArray.length; i++ ) {
				var count:int = 0;
				var target:Number = 0;
				var tempRect:Rectangle = rectArray[i];// 外側
				if( colorArray[i] != bmp.getPixel( rectArray[i].topLeft.x + rectArray[i].width*0.5, rectArray[i].topLeft.y + rectArray[i].height*0.5) ){
					var oldFlg:uint = 0;
					var tempFlg:uint = 0;
					var index:int = -1;
					var countArray:Array = [0.0, 0.0, 0.0, 0.0, 0.0];
					var j:int;
					var constNum:Number;

					// 横方向
					constNum = rectArray[i].topLeft.y + rectArray[i].height*0.5;
					for ( j = 0; j < rectArray[i].width; j++ ){
						tempFlg = (bmp.getPixel( rectArray[i].topLeft.x + j, constNum ) == 0xFFFFFF)?0:1;
						if( (index == -1) && (tempFlg == 0) ){
							//go next
						} else {
							if( tempFlg != oldFlg ){
								index++;
								oldFlg = tempFlg;
								if( index >= 5 ){
									break;
								}
							} 
							countArray[index]++;
						}
					}

					if ( isMarker(countArray) ) {
						// 縦方向
						countArray = [0.0, 0.0, 0.0, 0.0, 0.0];
						oldFlg = tempFlg = 0;
						index = -1;

						constNum = rectArray[i].topLeft.x + rectArray[i].width*0.5;
						for ( j = 0; j < rectArray[i].width; j++ ) {
							tempFlg = (bmp.getPixel( constNum, rectArray[i].topLeft.y + j ) == 0xFFFFFF)?0:1;
							if( (index == -1) && (tempFlg == 0) ){
								//go next
							} else {
								if( tempFlg != oldFlg ){
									index++;
									oldFlg = tempFlg;
									if( index >= 5 ){
										break;
									}
								} 
								countArray[index]++;
							}
						}
						if ( isMarker(countArray) ) {
							retArray.push( {borderColor:colorArray[i], borderRect:rectArray[i]} );
						}
					}

				}
			}
			return retArray;
		}
		/**
		 * 直角関係にあるマーカーを探します
		 * @param	borders 候補の配列
		 * @return
		 */
		private function _searchCode( borders:Array ):Array {
			function isNear( p1:Point, p2:Point, d:Number ):Boolean {
				return(
					(p1.x + d) > p2.x &&
					(p1.x - d) < p2.x &&
					(p1.y + d) > p2.y &&
					(p1.y - d) < p2.y
				);
			}
			var ret:Array = [];
			var loop:int = borders.length;
			for ( var i:int = 0; i < (loop-2); i++ ) {
				for ( var j:int = i + 1; j < (loop-1); j++ ) {
					var vec:Point = borders[i].borderRect.topLeft.subtract( borders[j].borderRect.topLeft );
					for ( var k:int = j + 1; k < loop; k++ ) {
						if( isNear( borders[k].borderRect.topLeft, new Point( borders[i].borderRect.topLeft.x + vec.y, borders[i].borderRect.topLeft.y - vec.x ), 0.125 * vec.length ))
							ret.push( [borders[i], borders[j], borders[k]] );
						else if ( isNear( borders[k].borderRect.topLeft, new Point( borders[i].borderRect.topLeft.x - vec.y, borders[i].borderRect.topLeft.y + vec.x ), 0.125 * vec.length ))
							ret.push( [borders[i], borders[k], borders[j]] );
						else if ( isNear( borders[k].borderRect.topLeft, new Point( borders[j].borderRect.topLeft.x + vec.y, borders[j].borderRect.topLeft.y - vec.x ), 0.125 * vec.length ))
							ret.push( [borders[j], borders[k], borders[i]] );
						else if ( isNear( borders[k].borderRect.topLeft, new Point( borders[j].borderRect.topLeft.x - vec.y, borders[j].borderRect.topLeft.y + vec.x ), 0.125 * vec.length ))
							ret.push( [borders[j], borders[i], borders[k]] );
					}
				}
			}
			return ret;
		}
	}
	
}