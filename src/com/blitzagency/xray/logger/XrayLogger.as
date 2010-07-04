package com.blitzagency.xray.logger {
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import com.blitzagency.xray.logger.Debug;
	import com.blitzagency.xray.logger.Log;
	import com.blitzagency.xray.logger.Logger;
	import com.blitzagency.xray.logger.util.ObjectTools;
	import com.blitzagency.xray.logger.util.PropertyTools;	

	/**
	 * @author John Grden
	 */
	public class XrayLogger extends EventDispatcher implements Logger
	{		
		public static var DEBUG:Number = 0;
		
		public static var INFO:Number = 1;
		
		public static var WARN:Number = 2;
		
		public static var ERROR:Number = 3;
		
		public static var FATAL:Number = 4;
		
		public static var NONE:Number = 5;
		
		public static function resolveLevelAsName(p_level:Number):String
		{
			switch(p_level)
			{
				case 0:
					return "debug";
				break;
				
				case 1:
					return "info";
				break;
				
				case 2:
					return "warn";
				break;
				
				case 3:
					return "error";
				break;
				
				case 4:
					return "fatal";
				break;
				
				default:
					return "debug";
			}
		}
		
		private static var _instance:XrayLogger = null;
		
		private var level:Number = 0; // set to DEBUG by default
		private var displayObjectRecursionDepth:Number = 3;
		private var objectRecursionDepth:Number = 254;
		private var indentation:Number = 0;
		private var filters:Array = [];
		
		
		public static function getInstance():XrayLogger
		{
			if(_instance == null)
			{
				_instance = new XrayLogger();
			}
			
			return _instance;
		}

		public function setDisplayClipRecursionDepth(p_recursionDepth:Number):void
		{
			displayObjectRecursionDepth = p_recursionDepth;
		}
		
		public function setObjectRecursionDepth(p_recursionDepth:Number):void
		{
			objectRecursionDepth = p_recursionDepth;
		}
		
		public function setIndentation(p_indentation:Number = 0):void
		{
			indentation = p_indentation;
		}
		
		public function setLevel(p_level:Number = 0):void
		{
			level = p_level;
		}
		
		public function setFilters(p_filters:Array):void
		{
			filters = p_filters;
		}
		
		public function debug(obj:Log):void
		{
			if(obj.getLevel() == level) 
			{
				log(obj.getMessage(), obj.getCaller(), obj.getClassPackage(), 0, obj.getDump());
			}
		}
		
		public function info(obj:Log):void
		{
			if(obj.getLevel() >= level) 
			{
				log(obj.getMessage(), obj.getCaller(), obj.getClassPackage(), 1, obj.getDump());
			}
		}
		
		public function warn(obj:Log):void
		{
			if(obj.getLevel() >= level) 
			{
				log(obj.getMessage(), obj.getCaller(), obj.getClassPackage(), 2, obj.getDump());
			}
		}
		
		public function error(obj:Log):void
		{
			if(obj.getLevel() >= level) 
			{
				log(obj.getMessage(), obj.getCaller(), obj.getClassPackage(), 3, obj.getDump());
			}
		}
		
		public function fatal(obj:Log):void
		{
			if(obj.getLevel() >= level) 
			{
				log(obj.getMessage(), obj.getCaller(), obj.getClassPackage(), 4, obj.getDump());
			}
		}
		
		/**
		 * Logs the {@code message} using the {@code Debug.trace} method if
		 * {@code traceObject} is turned off or if the {@code message} is of type
		 * {@code "string"}, {@code "number"}, {@code "boolean"}, {@code "undefined"} or
		 * {@code "null"} and using the {@code Debug.traceObject} method if neither of the
		 * above cases holds {@code true}.
		 *
		 * @param message the message to log
		 */
		public function log(message:String, caller:String, classPackage:String, level:Number, dump:Object=null):void 
		{		
			
			// add time stamp
			var traceMessage:String = "(" + getTimer() + ") ";
			if(classPackage.length > 0) traceMessage += caller + "\n";
			traceMessage += message;

			if(message.length > 0) Debug.trace(traceMessage, classPackage, level);
			
			if(dump == null) return;
			
			// check to see if dump is an object or not
			var type:String = typeof(dump);
			if (type == "string" || type == "number" || type == "boolean" || type == "undefined" || type == "null") 
			{
				Debug.trace(dump, classPackage, level);
			}else if(type == "xml")
			{
				Debug.trace(dump.toString(), classPackage, level);
			}else
			{
				var objType:String = ObjectTools.getImmediateClassPath(dump);
				if(objType == "Object" || objType == "Object.Array")
				{
					// regular object types like Objects and Arrays can go straight to Debug
					Debug.traceObject(dump, objectRecursionDepth, indentation, classPackage, level);
				}else
				{
					// if we have something like a sprite/movieclip/component etc, we'll get it's props first, then send to Debug
					var obj:Object = PropertyTools.getProperties(dump);
					Debug.traceObject(obj, displayObjectRecursionDepth, indentation, classPackage, level);
				}
			}
			
		}
		
		public function checkFilters():Boolean
		{
			if(filters.length == 0) return true;
			
			for(var i:uint=0;i<filters.length;i++)
			{
				
			}
			return true;
		}
	}
}