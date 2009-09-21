package qrcode {
  import flash.display.*;
  import flash.geom.*;
  
  public class AlignmentPattern {
    public static function findPattern(pixels:BitmapData, finderPattern:Object,
                                       debug:BitmapData):Array {
      if (finderPattern.roughVersion<=6) {
        var mapper:PixelMapper = new PixelMapper(finderPattern);
        var point:Point=mapper.mapPixel(finderPattern.sideLength-6,
                                        finderPattern.sideLength-6);
        point = adjustPosition(point, pixels, finderPattern.moduleWidth);
        FinderPattern.drawLine(debug, {endPoint:point, offset:6},
                               0xff0000, FinderPattern.HORIZONTAL);
        FinderPattern.drawLine(debug, {endPoint:point, offset:6},
                               0xff0000, FinderPattern.VERTICAL);
        return new Array(point);
      }
      return new Array();
    }


    private static function adjustPosition(point:Point, pixels:BitmapData,
                                           moduleWidth:Number):Point {
      var radius:int = moduleWidth*2;
      var current:int;
      for (var d:int=1; d<radius; d++) {
        if (pixels.getPixel(point.x-d, point.y-d)==0) {
          return findCenter(point.x-d, point.y-d, pixels);
        }
        if (pixels.getPixel(point.x+d, point.y+d)==0) {
          return findCenter(point.x+d, point.y+d, pixels);
        }
      }
      return point;
    }

    private static function findCenter(x:int, y:int, pixels:BitmapData):Point {
      var last:int, current:int;
      var leftX:int=x, rightX:int=x, topY:int=y, bottomY:int=y;
      var p:int;

      for (p=1,last=0; x-p>=0; p++) {
        current = pixels.getPixel(x-p, y);
        if (current==0 && last!=0) { leftX=x-p; break; }
        last = current;
      }
    
      for (p=1,last=0; x+p<pixels.width; p++) {
        current = pixels.getPixel(x+p, y);
        if (current==0 && last!=0) { rightX=x+p; break; }
        last = current;
      }
    
      for (p=1,last=0; y-p>=0; p++) {
        current = pixels.getPixel(x, y-p);
        if (current==0 && last!=0) { topY=y-p; break; }
        last = current;
      }
        
      for (p=1,last=0; y+p<pixels.height; p++) {
        current = pixels.getPixel(x, y+p);
        if (current==0 && last!=0) { bottomY=y+p; break; }
        last = current;
      }
      return new Point((leftX+rightX)/2, (topY+bottomY)/2);
    }
  }
}

