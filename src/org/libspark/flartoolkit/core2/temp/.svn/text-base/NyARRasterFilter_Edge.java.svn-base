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
package org.libspark.flartoolkit.core2.temp;

import org.libspark.flartoolkit.FLARException;
import org.libspark.flartoolkit.core.raster.*;
import org.libspark.flartoolkit.core.rasterfilter.IFLARRasterFilter;
import org.libspark.flartoolkit.core.rasterreader.IFLARBufferReader;
import org.libspark.flartoolkit.core.types.FLARIntSize;

/**
 * エッジ検出フィルタ 入力 BUFFERFORMAT_INT2D 出力 BUFFERFORMAT_INT2D
 */
public class FLARRasterFilter_Edge implements IFLARRasterFilter
{
	public void doFilter(IFLARRaster i_input, IFLARRaster i_output) throws FLARException
	{
		IFLARBufferReader in_buffer_reader=i_input.getBufferReader();	
		IFLARBufferReader out_buffer_reader=i_output.getBufferReader();	
		assert (in_buffer_reader.isEqualBufferType(IFLARBufferReader.BUFFERFORMAT_INT2D_GLAY_8));
		assert (out_buffer_reader.isEqualBufferType(IFLARBufferReader.BUFFERFORMAT_INT2D_GLAY_8));
		assert (i_input.getSize().isEqualSize(i_output.getSize()) == true);

		int[][] out_buf = (int[][]) out_buffer_reader.getBuffer();
		int[][] in_buf = (int[][]) in_buffer_reader.getBuffer();

		int bp = 0;
		FLARIntSize size = i_output.getSize();
		for (int y = 1; y < size.h; y++) {
			int prev = 128;
			for (int x = 1; x < size.w; x++) {
				int w = in_buf[y][x];
				out_buf[y][x] = (Math.abs(w - prev) + Math.abs(w - in_buf[y - 1][x])) / 2;
				prev = w;
				bp += 3;
			}
		}
		return;
	}
}
