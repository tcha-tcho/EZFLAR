package {

	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import org.papervision3d.materials.VideoStreamMaterial;
	import org.papervision3d.materials.MovieMaterial;

	public class FLVconstructor extends Video {
		private var loader:Loader;
		private var video:Video;
	    private var stream:NetStream;
	    private var connection:NetConnection;
		private var _videoMaterial:VideoStreamMaterial;

		public function FLVconstructor(url:String) {
				
		  // Create a NetConnection. 2-way connection not necessary: connect to null
	      connection = new NetConnection();
	      connection.connect(null);

	      // Create a new NetStream to obtain the flv stream. Ignore client messages so use a simple Object
	      stream = new NetStream(connection);
	      stream.client = new Object();

	      // create a new video player
	      video = new Video();

	      // start streaming the video from the given URL and play it on the video player
	      stream.play(url);
	      video.attachNetStream(stream);
			
			var front_videomaterial:VideoStreamMaterial = new VideoStreamMaterial(video,stream,true);
			front_videomaterial.interactive = true;
			front_videomaterial.animated = true;
			front_videomaterial.doubleSided = true;
			_videoMaterial = front_videomaterial;
		}
		public function loaderComplete(evt:Event):void{
			trace("SWFLoader: Complete");
		}
		public function getVideoMaterial():VideoStreamMaterial{
			return _videoMaterial;
		}
	}

}