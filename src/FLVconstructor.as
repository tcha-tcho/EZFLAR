package {

	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	import flash.events.NetStatusEvent;
	import org.papervision3d.materials.VideoStreamMaterial;

	import org.papervision3d.objects.primitives.Plane;	
	import org.papervision3d.objects.DisplayObject3D;

	public class FLVconstructor extends Video {
		private var _video:Video;
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _universe:DisplayObject3D = new DisplayObject3D();

		public function FLVconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {

			// Create a NetConnection. 2-way _connection not necessary: connect to null
			_connection = new NetConnection();
			_connection.connect(null);

			// Create a new NetStream to obtain the flv _stream. Ignore client messages so use a simple Object
			_stream = new NetStream(_connection);
			_stream.client = new Object();

			// create a new _video player
			_video = new Video();

			// start _streaming the _video from the given URL and play it on the _video player
			_stream.play(url);
			_video.attachNetStream(_stream);

			var ncConection:NetConnection = new NetConnection(); // création d'une _connectionncConection.connect(null);

			_stream.addEventListener(NetStatusEvent.NET_STATUS, this.loaderComplete);
			
			var front__videomaterial:VideoStreamMaterial = new VideoStreamMaterial(_video,_stream,true);
			front__videomaterial.interactive = true;
			front__videomaterial.animated = true;
			front__videomaterial.doubleSided = true;

			var front__videomaterial:VideoStreamMaterial = front__videomaterial;
			var front_plane:Plane;
			front_plane = new Plane(front__videomaterial, 640, 480, 4, 4);
			front_plane.scale = 0.3;
			this._universe = new DisplayObject3D();
			this._universe.z = 3;
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.rotationY = 0;
					this._universe.rotationZ = -90;
					this._universe.addChild(front_plane);

				}
				public function loaderComplete(evt:NetStatusEvent):void{
					/*if (evt.info == "NetStream.Play.Stop"){*/
						trace("FLVLoader: Startin Streaming" /*+ evt.info*/);
					/*}					*/
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
			}

		}