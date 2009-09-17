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
package com.logosware.utils
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ラベリングを行うクラスです
	 */
	public class LabelingClass
	{
		private var _bmp:BitmapData;
		private var _minSize:uint;
		private var _startColor:uint;
		private var _pickedRects:Array = [];
		private var _pickedColor:Array = [];
		/**
		 * コンストラクタ
		 * @param bmp 入力画像(0x0, 0xFFFFFFFFでニ値化されたもの)
		 * @param minSize 画素として認める最低サイズ(ノイズ対策)
		 * @param startColor 塗り開始色
		 * @param isChangeOriginal 入力画像を実際に塗るかどうか 
		 **/
		public function Labeling(bmp:BitmapData, minSize:uint = 10, startColor:uint = 0xFFFFFFFE, isChangeOriginal:Boolean = true):void{
			_minSize = minSize;
			_startColor = startColor;
			if( isChangeOriginal ){
				_bmp = bmp;
			} else {
				_bmp = bmp.clone();
			}
			_process();
		}
		/**
		 * ラベリングした結果得られた範囲の矩形情報を返します
		 * @return 矩形の配列
		 **/
		public function getRects():Array{
			return _pickedRects;
		} 
		/**
		 * ラベリングした結果得られた範囲を塗った色情報を返します
		 * @return 色の配列
		 **/
		public function getColors():Array{
			return _pickedColor;
		}
		/**
		 * コア関数
		 **/
		private function _process():void {
			var _fillColor:uint = _startColor;
			var _rect:Rectangle;
			while (_paintNextLabel( _bmp, 0xFF000000, _fillColor ) ){
				_rect = _bmp.getColorBoundsRect( 0xFFFFFFFF, _fillColor );
				if ( ( _rect.width > _minSize) && ( _rect.height > _minSize ) ) {
					var _tempRect:Rectangle = _rect.clone();
					_pickedRects.push( _tempRect );
					_pickedColor.push( _fillColor );
				}
				_fillColor --;
			}
		}
		/**
		 * 次のpickcolor色の領域をfillcolor色に塗る。pickcolorが見つからなければfalseを返す
		 * @param bmp 画像
		 * @param pickcolor 次の色
		 * @param fillcolor 塗る色
		 * @return 目的の色があったかどうか
		 **/
		private function _paintNextLabel( bmp:BitmapData, pickcolor:uint, fillcolor:uint ):Boolean {
			var rect:Rectangle = bmp.getColorBoundsRect( 0xFFFFFFFF, pickcolor );
			if( (rect.width > 0) && (rect.height> 0) ){
				var tempBmp:BitmapData = new BitmapData( rect.width, 1 );
				tempBmp.copyPixels( bmp, new Rectangle(rect.topLeft.x, rect.topLeft.y, rect.width, 1 ), new Point(0, 0) );
				var rect2:Rectangle = tempBmp.getColorBoundsRect( 0xFFFFFFFF, pickcolor );
				bmp.floodFill( rect2.topLeft.x + rect.topLeft.x, rect2.topLeft.y + rect.topLeft.y, fillcolor );
				return true;
			}
			return false;
		}
	}
}