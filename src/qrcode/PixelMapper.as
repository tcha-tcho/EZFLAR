package qrcode {
  import flash.geom.*;
  public class PixelMapper {
    private var leftTop:Point;
    private var rightTop:Point;
    private var leftBottom:Point;
    private var rightBottom:Point;
    private var sideLength:int;
    private var scaleX:Number;
    private var scaleY:Number;
    private var scaleTopX:Number;
    private var scaleLeftY:Number;
    private var scaleBottomX:Number;
    private var scaleRightY:Number;
    private var sin:Number;
    private var cos:Number;

    public function PixelMapper(finderPattern:Object,
                                alignmentPattern:Array=null):void {
      this.leftTop = finderPattern.leftTop;
      this.rightTop = finderPattern.rightTop;
      this.leftBottom = finderPattern.leftBottom;
      if (alignmentPattern!=null) {
        this.rightBottom = alignmentPattern[0];
      }
      
      this.sideLength = 17+finderPattern.roughVersion*4;
      var r:Number = Point.distance(finderPattern.leftTop, finderPattern.rightTop);
      this.cos = (this.rightTop.x-this.leftTop.x)/r;
      this.sin = (this.rightTop.y-this.leftTop.y)/r;
      this.scaleX = Point.distance(this.leftTop, this.rightTop);
      this.scaleY = Point.distance(this.leftTop, this.leftBottom);
      this.scaleTopX = Point.distance(this.leftTop, this.rightTop);
      this.scaleLeftY = Point.distance(this.leftTop, this.leftBottom);
      if (this.rightBottom) {
        this.scaleBottomX = Point.distance(this.leftBottom, this.rightBottom);
        this.scaleRightY = Point.distance(this.rightTop, this.rightBottom);
      }
    }

    public function mapPixel(x:Number, y:Number):Point {
      var map:Point = this.leftTop.clone();
      map.x+=(this.scaleX*(x-3)*this.cos-this.scaleX*(y-3)*this.sin)/
        (this.sideLength-7);
      map.y+=(this.scaleY*(y-3)*this.cos+this.scaleY*(x-3)*this.sin)/
        (this.sideLength-7);
      return map;
    }
  }
}
