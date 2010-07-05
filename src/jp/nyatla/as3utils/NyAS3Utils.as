
package jp.nyatla.as3utils{
    import flash.utils.*;
	import flash.net.*;
    import flash.events.*;

	public class NyAS3Utils
	{
		public static function assert(e:Boolean, mess:String=null):void
		{
			if(!e){throw new Error("NyAS3Utils.assert:"+mess!=null?mess:"");}
		};
	}

}

