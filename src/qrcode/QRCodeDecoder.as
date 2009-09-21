package qrcode {
  import flash.display.*;
  import flash.geom.*;
  import flash.utils.*;
  import flash.errors.*;

  public class QRCodeDecoder {
    public static function decode(pixels:BitmapData,
        debug:BitmapData=null):DecodeResult {
      var binaryPixels:BitmapData = createBinaryPixels(pixels);
      debug.fillRect(new Rectangle(0,0,debug.width,debug.height), 0x00000000);
      debug.draw(binaryPixels);

      var result:DecodeResult = new DecodeResult();

      try {
        var finderPattern:Object = FinderPattern.findPattern(binaryPixels, debug);
        result.pos.leftTop = finderPattern.leftTop; 
        result.pos.rightTop = finderPattern.rightTop; 
        result.pos.leftBottom = finderPattern.leftBottom; 
        result.text = "roughVersion: "+finderPattern.roughVersion;
        if (finderPattern.roughVersion<=6) {
          var alignmentPattern:Array;
          if (finderPattern.roughVersion>=2) {
            alignmentPattern = AlignmentPattern.findPattern(binaryPixels,
                                                            finderPattern, debug);
          }
          var sampledPixels:BitmapData =
            SamplingGrid.samplePixels(pixels, finderPattern, alignmentPattern,
                                      debug);

          var doubleScale:Matrix = new Matrix();
          doubleScale.scale(2, 2);
          debug.draw(sampledPixels, doubleScale);
        } else {
          result.text = "error: version 7 or higher is not supported yet.";
        }
      } catch(errorObject:IOError) {
        result.text = "error: "+errorObject.message;
      }

      return result;
    }

    private static function createBinaryPixels(pixels:BitmapData):BitmapData {
      var nDivision:int = 4;
      var binaryPixels:BitmapData = new BitmapData(pixels.width, pixels.height);

      var areaWidth:int=binaryPixels.width/nDivision;
      var areaHeight:int=binaryPixels.height/nDivision;
      
      for (var ay:int=0; ay<nDivision; ay++) {
        for (var ax:int=0; ax<nDivision; ax++) {
          var rectangle:Rectangle = new Rectangle(ax*areaWidth, ay*areaHeight, 
              areaWidth, areaHeight);

          var samples:ByteArray = pixels.getPixels(rectangle);
          var i:int;
          var offset:int;
          var threshold:uint=0;
          for (i=0,offset=0; i<samples.length; i++,
              offset+=samples.length/(nDivision*nDivision)) {
            threshold+=samples[offset] & 0xff;
          }
          threshold = threshold/i+0x40;
          var color:uint = 0x00000000;
          var maskColor:uint = 0x000000ff;
        
          binaryPixels.threshold(pixels, rectangle, new Point(ax*areaWidth,
                ay*areaHeight), "<=", threshold, color, maskColor, false);
        }
      }
      return binaryPixels;
    }
  }
}
