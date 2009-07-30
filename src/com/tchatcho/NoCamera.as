/**
 * @Author tcha-tcho
 */

package com.tchatcho {
	import flash.display.Sprite;
   	import flash.text.TextField;
   	import flash.text.TextFormat;
    import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter
    
	/*import flash.display.*;*/
	/*import flash.net.URLRequest;*/

	public class NoCamera extends Sprite {
		/*private static const LOADINGPATH:String = "../resources/flar/nocam.swf";*/
		
        private var borderColor:uint  = 0xFFFFFF;
        private var borderSize:uint   = 4;
        private var cornerRadius:uint = 30;
        private var gutter:uint       = 5;

		private var size:uint         = 80;
		private var offset:uint       = 50;


		public function NoCamera(width:int, height:int, message:String, colorTxt:uint, colorBackground:uint) {
			
			var child:Shape = new Shape();
			            child.graphics.beginFill(colorBackground);
			            child.graphics.lineStyle(borderSize, borderColor);
			            child.graphics.drawRoundRect(0, 0, width - 50, height/5, cornerRadius);
			            child.graphics.endFill();
						child.x = 50/2;
						child.y = height/5*2;
			            addChild(child);
			
			
			var noCamMsg:TextField = new TextField();
			noCamMsg.text = message;			
			/*noCamMsg.autoSize = TextFieldAutoSize.CENTER;			*/
			var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = colorTxt;
            format.size = width/20;
			format.align = "center";
			noCamMsg.setTextFormat(format);
			noCamMsg.width = width - 80;
			noCamMsg.x = 80/2;
			noCamMsg.y = height/5*2.3;
			//finally the dropshadow
			var filter:BitmapFilter = getBitmapFilter();
            var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters;
            
			
			addChild(noCamMsg)
			//TODO: add support to no cam with a swf, PC problems(im a mac)
			/*var ldr:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(LOADINGPATH);
			ldr.load(urlReq);
			addChild(ldr);
			ldr.x = (width - 550)/2;
			ldr.y = (height - 400)/2;			*/
		}
	    private function getBitmapFilter():BitmapFilter {
            var color:Number = 0x000000;
            var angle:Number = 45;
            var alpha:Number = 0.6;
            var blurX:Number = 8;
            var blurY:Number = 8;
            var distance:Number = 5;
            var strength:Number = 0.65;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;
            return new DropShadowFilter(distance,
                                        angle,
                                        color,
                                        alpha,
                                        blurX,
                                        blurY,
                                        strength,
                                        quality,
                                        inner,
                                        knockout);
        }

    
	}
}