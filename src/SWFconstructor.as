package {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;

	public class SWFconstructor extends MovieClip {
		private var loader:Loader;
		
		public function SWFconstructor(url:String) {
			var request:URLRequest=new URLRequest(url);
			loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			loader.scaleY = 0.7;
			loader.scaleX = 0.7;
			addChild(loader);
			}
			public function loaderComplete(evt:Event):void{
				trace("SWFLoader: Complete");
			}

		}

	}