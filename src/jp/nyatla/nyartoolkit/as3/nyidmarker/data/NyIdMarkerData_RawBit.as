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
package jp.nyatla.nyartoolkit.as3.nyidmarker.data 
{
	import jp.nyatla.nyartoolkit.as3.utils.as3.*;
	public class NyIdMarkerData_RawBit implements INyIdMarkerData
	{
		public var packet:Vector.<int>=new Vector.<int>(22);
		public var length:int;
		public function isEqual(i_target:INyIdMarkerData):Boolean
		{
			var s:NyIdMarkerData_RawBit=NyIdMarkerData_RawBit(i_target);
			if(s.length!=this.length){
				return false;
			}
			for(var i:int=s.length-1;i>=0;i--){
				if(s.packet[i]!=this.packet[i]){
					return false;
				}
			}
			return true;
		}
		public function copyFrom(i_source:INyIdMarkerData):void
		{
			var s:NyIdMarkerData_RawBit=NyIdMarkerData_RawBit(i_source);
			ArrayUtils.copyInt(s.packet,0,this.packet,0,s.length);
			this.length=s.length;
			return;
		}
	}

}