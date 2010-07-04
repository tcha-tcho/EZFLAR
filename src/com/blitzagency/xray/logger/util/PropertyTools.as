package com.blitzagency.xray.logger.util
{
	import flash.utils.*;
	public class PropertyTools
	{
		public static function getProperties(obj:Object):Array
		{
			
			var ary:Array = [];
			try
			{	
				var xmlDoc:XML = describeType(obj);
				// loop the extendsClass nodes
				for each(var item:XML in xmlDoc.variable)
				{
					var name:String = item.@name.toString();
					var type:String = item.@type.toString();
					var value:Object = obj[name] != null ? obj[name] : "";
					ary.push({name:name, type:type, value:value});
					//log.debug("my object", item.@type.toString());
				}
			}catch(e:Error)
			{
				
			}
			
			
			// return the full path as dot separated
			
			return ary;
		}
		
		private static function getVariables():void
		{
			
		}
		
		private static function getMethods():void
		{
			
		}
	}
	
	
}