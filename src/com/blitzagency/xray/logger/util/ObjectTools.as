package com.blitzagency.xray.logger.util
{
	import flash.utils.*;
	import com.blitzagency.xray.logger.XrayLog;
	
	public class ObjectTools
	{
		private static var log:XrayLog = new XrayLog();
		
		public static function getFullClassPath(obj:Object):String
		{
			var xmlDoc:XML = describeType(obj);
			var ary:Array = [];
			
			
			// add the className of the actual object
			var className:String = getQualifiedClassName(obj);
			className = className.indexOf("::") > -1 ? className.split("::").join(".") : className;
			
			ary.push(className);
			
			// loop the extendsClass nodes
			for each(var item:XML in xmlDoc.extendsClass)
			{
				var extClass:String = item.@type.toString().indexOf("::") > -1 ? item.@type.toString().split("::")[1] : item.@type.toString();
				ary.push(extClass);
			}
			
			// return the full path as dot separated
			
			return ary.join(".");
		}
		
		public static function getImmediateClassPath(obj:Object):String
		{
			var className:String = getQualifiedClassName(obj);
			var superClassName:String = getQualifiedSuperclassName(obj);
			className = className.indexOf("::") > -1 ? className.split("::").join(".") : className;
			if(superClassName == null) return className; 
			
			superClassName = superClassName.indexOf("::") > -1 ? superClassName.split("::").join(".") : superClassName;
			return superClassName + "." + className;
		}
		
		public function resolveBaseType(obj:Object):String
		{
			return "";
		}
	}
}