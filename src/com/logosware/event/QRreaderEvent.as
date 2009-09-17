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
package com.logosware.event
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * QRコード画像の抽出完了イベントを送出します
	 */
	public class QRreaderEvent extends Event
	{
		// 定数( Class constants )
		
		/**
		 * QRコードの抽出完了を通知します。
		 * @eventType QR_IMAGE_READ_COMPLETE
		 **/
		public static const QR_IMAGE_READ_COMPLETE:String = "QR_IMAGE_READ_COMPLETE";

		// プロパティ( Proerties )
		
		/**
		 * 解析した結果のQRコード画像が格納されます
		 **/
		public var imageData:BitmapData;
		/**
		 * 解析した結果のQRコード画像のビットパターン配列が格納されます
		 **/
		public var data:Array;
		/**
		 * 入力した任意の配列が格納されます(デバッグ用)
		 **/
		public var checkArray:Array;

		// コンストラクタ( Constructor )
		
		/**
		 * コンストラクタ
		 * @param type イベントタイプ
		 * @param imageData 抽出したQRコード画像
		 * @param data 抽出したQRコードのビット列
		 * @param check 入力した任意のコード
		 **/
        public function QRreaderEvent(type:String, imageData:BitmapData, data:Array, checkArray:Array = null){
            super(type);
            // 新しいプロパティを設定する
           this.imageData = imageData;
           this.data = data;
           this.checkArray = checkArray;
        }

        // Eventからオーバーライドしたメソッド( Overridden Method: Event )

        /**
        * @private
        **/
        override public function clone():Event {
            return new QRreaderEvent(type, imageData, data, checkArray);
        }
	}
}