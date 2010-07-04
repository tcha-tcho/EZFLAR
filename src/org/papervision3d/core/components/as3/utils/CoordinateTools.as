/**
* @private
*/
package org.papervision3d.core.components.as3.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class CoordinateTools
	{
		public static function localToLocal(containerFrom:DisplayObject, containerTo:DisplayObject, origin:Point=null):Point
		{
			var point:Point = origin ? origin : new Point();
			point = containerFrom.localToGlobal(point);
			point = containerTo.globalToLocal(point);
			return point;
		}
		
		// zero based random range returned
		public static function random(range:Number):Number
		{
			return Math.floor(Math.random()*range);
		} 
	}
}