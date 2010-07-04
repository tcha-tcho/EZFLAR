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
package org.libspark.flartoolkit.core 
{
	import jp.nyatla.nyartoolkit.as3.core.NyARCode;
	
	public class FLARCode extends NyARCode
	{
		private var _markerPercentWidth:uint;
		private var _markerPercentHeight:uint;

		/**
		 * 
		 * @param	i_width					幅方向の分割数
		 * @param	i_height				高さ方向の分割数
		 * @param	i_markerPercentWidth	マーカ全体(本体＋枠)における、マーカ本体部分の割合(幅)
		 * @param	i_markerPercentHeight	マーカ全体(本体＋枠)における、マーカ本体部分の割合(高さ)
		 */
		public function FLARCode(i_width:int, i_height:int,i_markerPercentWidth:uint = 50,  i_markerPercentHeight:uint = 50)
		{
			super(i_width, i_height);
			this._markerPercentWidth = i_markerPercentWidth;
			this._markerPercentHeight = i_markerPercentHeight;
		}
		
		public function loadARPatt(i_stream:String):void
		{
			super.loadARPattFromFile(i_stream);
			return;
		}
		
		public function get markerPercentWidth():uint {
			return _markerPercentWidth;
		}
		
		public function get markerPercentHeight():uint {
			return _markerPercentHeight;
		}
	}

}