package org.papervision3d.core.math.util {
	import flash.geom.Rectangle;			/**	 * @author Seb Lee-Delisle
	 * 
	 * Some handy rectangle tools that are faster than the built in Rectangle methods. 
	 * 	 */	public class FastRectangleTools 
	{
		
		
				
		/* 
		 * 
		 * in my tests runs 1/3 faster the Rectangle.intersects
		 * Rectangle.intersects() Test: 71.4499
		 * Fast intersect Test: 54.199
		 * 
		 * @Author Seb Lee-Delisle
		 * 
		 * @param	rect1 
		 * @param	rect2  
		 * @return  true if the rectangles intersect. 
		 */ 
		 
		public static function intersects(rect1 : Rectangle, rect2 :Rectangle) : Boolean
		{
			
			if(!((rect1.right<rect2.left)||(rect1.left>rect2.right)))
				if(!((rect1.bottom<rect2.top)||(rect1.top>rect2.bottom)))
					return true; 
					
			return false; 
			
		}
			
		
		/* benchmarks compared to Rectangle.intersection : 
		Rectangle.intersects() Test			: 146.89999999999998
		this function (without targetrect)  	: 133.45
		this function (with targetrect)  	    : 72.55*/
		
		public static function intersection(rect1:Rectangle, rect2: Rectangle, targetrect:Rectangle = null) : Rectangle
		{
		
			if(!targetrect) targetrect = new Rectangle(); 
			if(!intersects(rect1, rect2)) 
			{
				targetrect.x = 
					targetrect.y = 
					targetrect.width = 
					targetrect.height = 0;
					
				return targetrect; 
				
			}
			targetrect.left = (rect1.left>rect2.left) ? rect1.left : rect2.left; 
			targetrect.right = (rect1.right<rect2.right) ? rect1.right : rect2.right; 
			targetrect.top = (rect1.top>rect2.top) ? rect1.top : rect2.top; 
			targetrect.bottom = (rect1.bottom<rect2.bottom) ? rect1.bottom : rect2.bottom; 
			
			return targetrect; 
			
			
			
			
			
			
		}
		
			}}