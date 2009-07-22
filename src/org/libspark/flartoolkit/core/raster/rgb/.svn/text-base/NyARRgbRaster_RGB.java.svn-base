/* 
 * PROJECT: FLARToolkit
 * --------------------------------------------------------------------------------
 * This work is based on the original ARToolKit developed by
 *   Hirokazu Kato
 *   Mark Billinghurst
 *   HITLab, University of Washington, Seattle
 * http://www.hitl.washington.edu/artoolkit/
 *
 * The FLARToolkit is Java version ARToolkit class library.
 * Copyright (C)2008 R.Iizuka
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact.
 *	http://nyatla.jp/nyatoolkit/
 *	<airmail(at)ebony.plala.or.jp>
 * 
 */
package org.libspark.flartoolkit.core.raster.rgb;

import org.libspark.flartoolkit.core.rasterreader.*;
import org.libspark.flartoolkit.core.types.FLARIntSize;

public class FLARRgbRaster_RGB extends FLARRgbRaster_BasicClass
{
	protected byte[] _ref_buf;

	private FLARRgbPixelReader_RGB24 _reader;
	private IFLARBufferReader _buffer_reader;
	
	public static FLARRgbRaster_RGB wrap(byte[] i_buffer, int i_width, int i_height)
	{
		return new FLARRgbRaster_RGB(i_buffer, i_width, i_height);
	}

	private FLARRgbRaster_RGB(byte[] i_buffer, int i_width, int i_height)
	{
		super(new FLARIntSize(i_width,i_height));
		this._ref_buf = i_buffer;
		this._reader = new FLARRgbPixelReader_RGB24(i_buffer, this._size);
		this._buffer_reader=new FLARBufferReader(i_buffer,IFLARBufferReader.BUFFERFORMAT_BYTE1D_R8G8B8_24);
		return;
	}
	public IFLARRgbPixelReader getRgbPixelReader()
	{
		return this._reader;
	}
	public IFLARBufferReader getBufferReader()
	{
		return this._buffer_reader;
	}	
}
