package com.blitzagency.xray.logger {
	import com.blitzagency.xray.logger.util.ObjectTools;	

	public class Log
	{
		private var message:String;
		private var dump:Object;
		private var level:Number;
		private var classPackage:String;
		private var caller:String = "";
		
		/*
		* I generate an error in the constructor as to force the debugger to give me the stackTrace
		* Supposedly, this won't work in the regular player, and as of 8/28/2006, I haven't tried it ;) 
		* 
		*/
		
		public function Log(p_message:String, p_dump:Object, p_level:Number, ...rest)
		{
			var err:LogError;
			var nullArray:Array;
			try
			{
				nullArray.push("bogus");
			}
			catch(e:Error)
			{
				err = new LogError("log");
			}
			finally
			{
				if(err.hasOwnProperty("getStackTrace"))
				{
					var str:String = err.getStackTrace();
					//Debug.trace(err.getStackTrace());
					setCaller(resolveCaller(str));
				}else
				{
					setCaller("");
				}
				setMessage(p_message);
				setDump(p_dump);
				setLevel(p_level);
				setClassPackage(p_dump);
			}
			
		}
		
		public function setMessage(p_message:String):void
		{
			message = p_message;
		}
		
		public function setDump(p_dump:Object):void
		{
			dump = p_dump;
		}
		
		public function setLevel(p_level:Number):void
		{
			level = p_level;
		}
		
		public function getMessage():String
		{
			return message;
		}
		
		public function getDump():Object
		{
			return dump;
		}
		
		public function getLevel():Number
		{
			return level;
		}
		
		public function getClassPackage():String
		{
			return classPackage;
		}
		
		public function setClassPackage(obj:Object):void
		{
			//classPackage = ObjectTools.getFullClassPath(obj);
			classPackage = ObjectTools.getImmediateClassPath(obj);
		}
		
		private function resolveCaller(str:String):String
		{
			var ary:Array = [];
			//Debug.trace("resolveCaller", str);
			try
			{
				str = str.split("\n").join("");
				ary = str.split("	at ");
				str = ary[3];
			}catch(e:Error)
			{
				
			}finally
			{
				str = "";
			}
			
			return str;
		}
		
		public function setCaller(p_caller:String):void
		{
			caller = p_caller;
		}
		
		public function getCaller():String
		{
			return caller;
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