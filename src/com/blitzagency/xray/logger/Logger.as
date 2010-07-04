/**
 * @author John Grden
 */
package com.blitzagency.xray.logger
{
	import com.blitzagency.xray.logger.Log;
	public interface Logger 
	{	
		function setLevel(p_level:Number = 0):void;
		function debug(obj:Log):void;
		function info(obj:Log):void;
		function warn(obj:Log):void;
		function error(obj:Log):void;
		function fatal(obj:Log):void;
		function log(message:String, caller:String, classPackage:String, level:Number, dump:Object=null):void;
		
	}
}