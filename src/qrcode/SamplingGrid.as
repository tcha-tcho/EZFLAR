package qrcode {
  import flash.display.*;
  import flash.geom.*;

  public class SamplingGrid {
    public static function samplePixels(pixels:BitmapData, finderPattern:Object,
        alignmentPattern:Array=null, debug:BitmapData=null):BitmapData {
      // based on table 1 on JIS-X-0510:2004 p.13
      var sampledPixels:BitmapData = new BitmapData(finderPattern.sideLength,
                                                    finderPattern.sideLength);

      var mapper:PixelMapper = new PixelMapper(finderPattern, alignmentPattern);

      for (var y:int=0; y<finderPattern.sideLength; y++) {
        for (var x:int=0; x<finderPattern.sideLength; x++) {
          var srcPoint:Point = mapper.mapPixel(x, y);
          var sampledPattern:uint = pixels.getPixel(srcPoint.x, srcPoint.y);
          sampledPixels.setPixel(x, y, sampledPattern);
          debug.setPixel(srcPoint.x, srcPoint.y, 0xff0000);
        }
      }
      return sampledPixels;
    }
  }    
}
