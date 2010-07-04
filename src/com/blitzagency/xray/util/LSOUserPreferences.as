package com.blitzagency.xray.util
{	
	import flash.net.SharedObject;
	import mx.core.Application;
	
	public class LSOUserPreferences
	{
		
	// Public Properties
		public static var app:Object = mx.core.Application.application;
		public static var loaded:Boolean = false;
		public static var persistent:Boolean = true;
	
	// Private Properties
		private static var preferences:Object = {};
		private static var storedObject:SharedObject;
		
		// Retrieve Preference
		public static function getPreference(p_key:String):*
		{
			var r:* = preferences[p_key] != undefined ? preferences[p_key] : null;
			return r;
		}
		
		public static function getAllPreferences():Object 
		{
			return preferences;
		}
	
		// Set Local/LSO Preference
		public static function setPreference(p_key:String, p_value:Object, p_persistent:Boolean):void 
		{
			preferences[p_key] = p_value;
	
			// Optionally save to LSO
			if (p_persistent) 
			{
				
				storedObject.data[p_key] = p_value;
				var r:String = storedObject.flush();
				var m:String;
				//app.output.text += "writing SO :: " + r +  "\n";
				switch (r) 
				{
					case "pending": 	
						//app.output.text += "case pending \n";
						m = "Flush is pending, waiting on user interaction"; 			
						break;
					case true: 		
						//app.output.text += "case true \n";
						m = "Flush was successful.  Requested Storage Space Approved"; 	
						break;
					case false: 	
						//app.output.text += "case false \n";
						m = "Flush failed.  User denied request for additional space."; 	
						break;
				}
			}
		}
	
		// Load from LSO for now
		public static function load(p_path:String):void 
		{
			storedObject = SharedObject.getLocal("userPreferences" + p_path, "/");
			for (var i:String in storedObject.data)
			{
				preferences[i] = storedObject.data[i];
			}
			loaded = true;
		}
	
		// Clear LSO and reset preferences
		public static function clear():void 
		{
			storedObject.clear();
			storedObject.flush();
			storedObject = null;
			preferences = {};
		}
	}
}