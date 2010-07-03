package jp.nyatla.as3utils
{
    import flash.utils.*;
	import flash.net.*;
    import flash.events.*;

	public class NyMultiFileLoader extends EventDispatcher
	{
		public var _loaders:Array=new Array(); 
		public function NyMultiFileLoader()
		{
		}
		public function addTarget(i_fname:String,i_format:String,i_accept:Function):void
		{
			var loader:NyURLLoader = new NyURLLoader();
			loader.dataFormat =i_format;
			loader.addEventListener(Event.COMPLETE,NyMultiFileLoader.onCompleteTarget);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, this.dispatchEvent);
			//loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent);
            loader._parent=this;
            loader._accept=i_accept;
            loader._target=i_fname;
            loader._index=this._loaders.push(loader)-1;
            
		}
		public function multiLoad():void
		{
			//ダウンロードをまとめてGO
			for(var i:int;i<this._loaders.length;i++){
				this._loaders[i].load(new URLRequest(this._loaders[i]._target));
			}
		}
		public function complete(i_loader:NyURLLoader):void
		{
			i_loader.removeEventListener(Event.COMPLETE,NyMultiFileLoader.onCompleteTarget);
			this._loaders[i_loader._index]=null;
		}
		public function isComplete():Boolean
		{
			for(var i:int=0;i<this._loaders.length;i++){
				if(this._loaders[i]!=null){
					return false;
				}
			}
			return true;
		}
		private static function onCompleteTarget(e:Event):void
		{
			var loader:NyURLLoader=(NyURLLoader)(e.currentTarget);
			//受領要求
			loader._accept(loader.data);
			//対象を消す
			loader._parent.complete(loader);
			//で、全部終わった？
			if(loader._parent.isComplete()){
				//イベントを送信
				loader._parent.dispatchEvent(new Event(flash.events.Event.COMPLETE));			
			}
			return;
		}
	}
}


import flash.utils.*;
import flash.net.*;
import flash.events.*;
import jp.nyatla.as3utils.*;
class NyURLLoader extends URLLoader
{
	public var _parent:NyMultiFileLoader;
	public var _index:int;
	public var _accept:Function;
	public var _target:String;	
}
