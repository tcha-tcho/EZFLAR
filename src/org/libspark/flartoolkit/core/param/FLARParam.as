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
package org.libspark.flartoolkit.core.param 
{
	import jp.nyatla.nyartoolkit.as3.core.param.*;
	
	/**
	 * typedef struct { int xsize, ysize; double mat[3][4]; double dist_factor[4]; } ARParam;
	 * NyARの動作パラメータを格納するクラス
	 * 
	 * @see jp.nyatla.nyartoolkit.as3.core.param.NyARParam
	 */
	public class FLARParam extends NyARParam
	{
		
		public function FLARParam() 
		{
			this._screen_size.w = 640;
			this._screen_size.h = 480;
			var dist:Vector.<Number> = new Vector.<Number>();
			dist.push(318.5, 263.5, 26.2, 1.0127565206658486);
			
			var projection:Vector.<Number> = new Vector.<Number>();
			projection.push(700.9514702992245, 0, 316.5,
						      0,               0, 726.0941816535367,
						    241.5,             0,   0,
						      0,               1,   0);
			this.setValue(dist, projection);
		}
	}

}