package org.papervision3d.materials.utils
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class LightMaps
	{
		private static var origin:Point = new Point();
		
		public static function getFlatMapArray(lightColor:int, ambientColor:int, specularLevel:int):Array
		{
			var array:Array = new Array();
			var tempmap:BitmapData = new BitmapData(255,1,false,0);
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(255,1,0,0,0);
			s.graphics.beginGradientFill(GradientType.LINEAR, [lightColor,ambientColor],[1,1],[0,255],m);
			s.graphics.drawRect(0,0,255,1);
			s.graphics.endFill();
			tempmap.draw(s);
			
			var i:int = 255;
			while(i--){
				array.push(tempmap.getPixel(i,0));
			}
			
			return array;
		}
		
		public static function getFlatMap(lightColor:int, ambientColor:int, specularLevel:int):BitmapData
		{
			var array:Array = new Array();
			var tempmap:BitmapData = new BitmapData(255,1,false,0);
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(255,1,0,0,0);
			s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0,255],m);
			s.graphics.drawRect(0,0,255,1);
			s.graphics.endFill();
			tempmap.draw(s);
			return tempmap;
		}
		
		public static function getPhongMap(lightColor:int, ambientColor:int, specularLevel:int, height:int = 255, width:int = 255):BitmapData
		{
			var lw:Number = height;
			var lh:Number = width;	
			var s:Sprite = new Sprite();
			var mat:Matrix = new Matrix();
			mat.createGradientBox(lw,lw,0,0,0);
			s.graphics.beginGradientFill(GradientType.RADIAL, [lightColor,ambientColor,ambientColor], [1,1,1], [0,255-specularLevel,255], mat);
			s.graphics.drawRect(0,0,lw,lw);
			s.graphics.endFill();
			var bmp:BitmapData = new BitmapData(lw,lw,false,0x0000FF);
			bmp.draw(s);
			return bmp;
		}
		
		public static function getGouraudMap(lightColor:int, ambientColor:int):BitmapData
		{
			var gouraudMap:BitmapData = new BitmapData(256,3,false,0xFFFFFF);
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(256,3,0,0,0);
			s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0,255],m);
			s.graphics.drawRect(0,0,256,3);
			s.graphics.endFill();
			gouraudMap.draw(s);
			return gouraudMap;
		}
		
		public static function getCellMap(color_1:int, color_2:int, steps:int):BitmapData
		{
			/**
			 * Posterize Code derived from Mario Klingeman.
			 */
			var bmp:BitmapData = LightMaps.getPhongMap(color_1,color_2,0,255,255);
			var n:Number = 0;
			var r_1:int = (color_1&0xFF0000)>>16;
			var r_2:int = (color_2&0xFF0000)>>16;
			var rStep:int = r_2-r_1;
			var rlut:Array  = new Array();
      		var glut:Array  = new Array();
      		var blut:Array  = new Array();
	      	for (var i:int = 0; i <= 255; i++) {
	      		rlut[i] = (i-(i % Math.round(256/steps))) << 16;
	        	glut[i] = (i-(i % Math.round(256/steps))) << 8;
	        	blut[i] = (i-(i % Math.round(256/steps)));
	        }
			bmp.paletteMap(bmp,bmp.rect,origin, rlut, glut, blut);
			bmp.applyFilter(bmp, bmp.rect, origin, new BlurFilter(2,2,2));
			return bmp;
		}
	}
}