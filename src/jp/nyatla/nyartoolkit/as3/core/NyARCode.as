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
package jp.nyatla.nyartoolkit.as3.core
{
	import jp.nyatla.nyartoolkit.as3.core.match.*;
	import jp.nyatla.nyartoolkit.as3.core.raster.*;
	import jp.nyatla.as3utils.*;
	/**
	 * ARToolKitのマーカーコードを1個保持します。
	 * 
	 */
	public class NyARCode
	{
		private var _color_pat:Vector.<NyARMatchPattDeviationColorData>=new Vector.<NyARMatchPattDeviationColorData>(4);
		private var _bw_pat:Vector.<NyARMatchPattDeviationBlackWhiteData>=new Vector.<NyARMatchPattDeviationBlackWhiteData>(4);
		private var _width:int;
		private var _height:int;
		
		public function getColorData(i_index:int):NyARMatchPattDeviationColorData
		{
			return this._color_pat[i_index];
		}
		public function getBlackWhiteData(i_index:int):NyARMatchPattDeviationBlackWhiteData
		{
			return this._bw_pat[i_index];
		}
		public function getWidth():int
		{
			return _width;
		}

		public function getHeight():int
		{
			return _height;
		}
		public function NyARCode(i_width:int, i_height:int)
		{
			this._width = i_width;
			this._height = i_height;
			//空のラスタを4個作成
			for(var i:int=0;i<4;i++){
				this._color_pat[i]=new NyARMatchPattDeviationColorData(i_width,i_height);
				this._bw_pat[i]=new NyARMatchPattDeviationBlackWhiteData(i_width,i_height);
			}
			return;
		}
		public function loadARPattFromFile(i_stream:String):void
		{
			NyARCodeFileReader.loadFromARToolKitFormFile(i_stream,this);
			return;
		}
		public function setRaster(i_raster:Vector.<INyARRaster>):void
		{
			NyAS3Utils.assert(i_raster.length!=4);
			//ラスタにパターンをロードする。
			for(var i:int=0;i<4;i++){
				this._color_pat[i].setRaster(i_raster[i]);				
			}
			return;
		}
	}
}

import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.*;
import jp.nyatla.nyartoolkit.as3.*;
import jp.nyatla.nyartoolkit.as3.core.raster.*;
import jp.nyatla.nyartoolkit.as3.core.rasterreader.*;
import jp.nyatla.nyartoolkit.as3.core.types.*;
	
class NyARCodeFileReader
{
	/**
	 * ARコードファイルからデータを読み込んでo_codeに格納します。
	 * @param i_stream
	 * @param o_code
	 * @throws NyARException
	 */
	public static function loadFromARToolKitFormFile(i_stream:String,o_code:NyARCode):void
	{
		var width:int=o_code.getWidth();
		var height:int=o_code.getHeight();
		var tmp_raster:NyARRaster=new NyARRaster(width,height,NyARBufferType.INT1D_X8R8G8B8_32);
		//4個の要素をラスタにセットする。
		var token:Array = i_stream.match(/\d+/g);
		var buf:Vector.<int>=Vector.<int>(tmp_raster.getBuffer());
		//GBRAで一度読みだす。
		for (var h:int = 0; h < 4; h++){
			readBlock(token,width,height,buf);
			//ARCodeにセット(カラー)
			o_code.getColorData(h).setRaster(tmp_raster);
			o_code.getBlackWhiteData(h).setRaster(tmp_raster);
		}
		tmp_raster=null;//ポイ
		return;
	}
	 
	/**
	 * 1ブロック分のXRGBデータをi_stからo_bufへ読みだします。
	 * @param i_st
	 * @param o_buf
	 */
	private static function readBlock(i_st:Array, i_width:int, i_height:int, o_buf:Vector.<int>):void
	{
		var pixels:int = i_width * i_height;
		var i3:int;
		for (i3 = 0; i3 < 3; i3++) {
			for (var i2:int = 0; i2 < pixels; i2++){
				// 数値のみ読み出す
				var val:int = parseInt(i_st.shift());
				if(isNaN(val)){
					throw new NyARException("syntax error in pattern file.");
				}
				o_buf[i2]=(o_buf[i2]<<8)|((0x000000ff&(int)(val)));
			}
		}
		//GBR→RGB
		for(i3=0;i3<pixels;i3++){
			o_buf[i3]=((o_buf[i3]<<16)&0xff0000)|(o_buf[i3]&0x00ff00)|((o_buf[i3]>>16)&0x0000ff);
		}
		return;
	}
}
