/**
* ...
* @author John Grden
* @version 0.1
*/

package org.papervision3d.core.components.as3.utils 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;

	public class StageTools 
	{		
		public static var stage:Stage;
		
		public static function buildObjectFromString(target:String):Object
		{
			var obj:Object;
			
			try
			{
				//obj = stage.root;
				obj = stage.getChildByName("root1") as DisplayObjectContainer;
			}catch(e:Error)
			{
				trace("stage is not initialized");
			}
			
			var ary:Array = target.split(".");
			
			for(var i:Number=0;i<ary.length;i++)
			{
				var temp:*;
				if(obj.hasOwnProperty("getChildByName")){
					temp = obj.getChildByName(ary[i]);
				};
				if(temp == null) temp = obj[ary[i]];
                if(temp == obj) continue;
                obj = temp;
            }

			return obj;
		}
		
	}
	
}
