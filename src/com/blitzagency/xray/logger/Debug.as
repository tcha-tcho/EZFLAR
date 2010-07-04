package com.blitzagency.xray.logger
{
	/*
    Debug class for use with bit-101 Flash Debug Panel
    See www.bit-101.com/DebugPanel
    This work is licensed under a Creative Commons Attribution 2.5 License.
    See http://creativecommons.org/licenses/by/2.5/
    
    Authors: Keith Peters and Tim Walling
    www.bit-101.com
    www.timwalling.com
	
	Modified for Xray:
	John Grden
	neoRiley@gmail.com
	www.osflash.org/xray
*/
	import flash.utils.*;
	import com.blitzagency.xray.logger.events.DebugDispatcher;
	import flash.net.LocalConnection;
	import flash.events.StatusEvent;
	
	public class Debug
	{    
		private static var xrayLC:LocalConnection;
		private static var connected:Boolean = false;
		private static var ed:DebugDispatcher = new DebugDispatcher();
		//private static var initialized:Boolean = initialize();
		
		private static function initialize():Boolean
		{
			ed = new DebugDispatcher();
			return true;
		}
		
		private static function makeConnection():void
		{
			var err:LogError;
			xrayLC = new LocalConnection();
			xrayLC.addEventListener("status", statusHandler);
			xrayLC.allowDomain("*");
			try
			{				
				xrayLC.connect("_xray_standAlone_debug" + getTimer());
				connected = true;
			}
			catch (e:Error)
			{
				err = new LogError("log");
				//xrayLC.close();
				setTimeout(makeConnection, 1000);
			}
			finally
			{
				
			}
		}
		
		private static function statusHandler(event:StatusEvent):void
		{
			if(event.code == null && event.level == "error" && connected) 
			{
				connected = false;
			}else
			{
				if(event.level == "status" && event.code == null)
				{
					connected = true;
				}
			}
		}
		
		public static function addEventListener(type:String, listener:Function):void
		{
			ed.addEventListener(type, listener);
		}
		
		/**
		 *	Traces any value to the debug panel, with an optional message level.
		 *	@param pMsg The value to trace.
		 *	@param pLvl Optional. The level for this message. Values are 0 through 4, or Debug.Debug, Debug.INFO, Debug.WARN, Debug.ERROR, Debug.FATAL.
		 */
		public static function trace(pMsg:Object, pPackage:String = "", pLevel:Number = 0):void
		{	
			// trace to the Flash IDE output window
			ed.sendEvent(DebugDispatcher.TRACE, {message:pMsg, classPackage:pPackage});
			//trace(pMsg);

			if(!connected) 
			{
				makeConnection();
			}

			if(connected)
			{
				try
				{
					var msg:String = String(pMsg).length >= 39995 ? String(pMsg).substr(0, 39995) + "..." : String(pMsg);
					xrayLC.send("_xray_view_conn", "setTrace", msg, pLevel, pPackage);
				}catch (e:LogError)
				{
					LogError("No Xray Interface running");
				}
			}
		}

		/**
		 *	Recursively traces an object's value to the debug panel.
		 *	@param o The object to trace.
		 *	@param pRecurseDepth Optional. How many levels deep to recursively trace. Defaults to 0, which traces only the top level value.
		 *	@param pIndent Optional. Number of spaces to indent each new level of recursion.
		 * 	@param pPackage - passed in via XrayLogger.  Package info sent along to Xray's interface for package filtering
		 */
		public static function traceObject(o:Object, pRecurseDepth:Number = 254, pIndent:Number = 0, pPackage:String = "", pLevel:Number = 0):void 
		{
			try
			{
				var recurseDepth:Number = pRecurseDepth;
				var indent:Number = pIndent;
	
				for (var prop:String in o)
				{
					var lead:String = "";
					for (var i:Number=0; i<indent; i++) 
					{
						lead += "    ";
					}
					var obj:String = o[prop].toString();
					if (o[prop] is Array) 
					{
						obj = "[Array]";
					}
					if (obj == "[object Object]") 
					{
						obj = "[Object]";
					}
					Debug.trace(lead + prop + ": " + obj, pPackage, pLevel);
					if (recurseDepth > 0) 
					{
						Debug.traceObject(o[prop], recurseDepth-1, indent+1, pPackage, pLevel);
					}
				}
			}catch(e:Error)
			{
				//
			}
		}
	}
}

class LogError extends Error
{
	public function LogError(message:String)
	{
		// constructor
		super(message);
	}
}