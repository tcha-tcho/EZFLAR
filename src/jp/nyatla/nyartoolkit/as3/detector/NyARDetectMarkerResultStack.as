package jp.nyatla.nyartoolkit.as3.detector
{
	import jp.nyatla.nyartoolkit.as3.core.types.stack.NyARObjectStack;
	
	internal class NyARDetectMarkerResultStack extends NyARObjectStack
	{
		public function NyARDetectMarkerResultStack(i_length:int)
		{
			super(i_length);
		}
		
		protected override function createArray(i_length:int):Vector.<Object>
		{
			var ret:Vector.<NyARDetectMarkerResult>= new Vector.<NyARDetectMarkerResult>(i_length);
			for (var i:int =0; i < i_length; i++){
				ret[i] = new NyARDetectMarkerResult();
			}
			return Vector.<Object>(ret);
		}
	}
}