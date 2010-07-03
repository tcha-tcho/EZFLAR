/**
* @Author tcha-tcho and alexfreitas
*/
package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import libs.Papervision3D_2_1_920.objects.primitives.Plane;
	import libs.Papervision3D_2_1_920.materials.MovieMaterial;
	import libs.Papervision3D_2_1_920.objects.DisplayObject3D;
	import com.tchatcho.constructors.LoadingEZFLAR;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;

	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import com.tchatcho.constructors.MP3Events;

	public class MP3constructor extends MovieClip {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _loader:Loader = new Loader();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _front_plane:Plane;

		private var _snd:Sound = new Sound();
		private var _channel:SoundChannel = new SoundChannel();
		private var _soundTrans:SoundTransform = new SoundTransform();
		// private var mp3events:MP3Events = new MP3Events();

		public function MP3constructor(patternId:int, mp3events:MP3Events, url:String = null, url2:String = null, objName:String = null) {
			startLoader();
			

			var request2:URLRequest=new URLRequest("com/tchatcho/constructors/soundicon.swf");
			_loader.load(request2);
			_loader.scaleY = 0.7;
			_loader.scaleX = 0.7;
			addChild(_loader);
			var skinMaterial:MovieClip = this;
			var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
			front_material.interactive = true;
			front_material.animated = true;
			front_material.doubleSided = true;
			_front_plane = new Plane(front_material, 640, 640, 4, 4);
			_front_plane.scale = 0.3;
			this._universe.z = 3;
			this._universe.x = -55;
			this._universe.y = -55;
			
			var request:URLRequest=new URLRequest(url);
			_snd.load(request);
			_snd.addEventListener(Event.COMPLETE, loaderComplete);
			_channel = _snd.play(0, int.MAX_VALUE);
			_soundTrans.volume = 1;
			_channel.soundTransform = _soundTrans;
			
			mp3events.addEventListener(MP3Events.STOPSOUND, stopTheSound)
			
			function stopTheSound(event:Event):void{
				_channel.stop();
				
			}

			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.rotationY = 0;
					this._universe.rotationZ = -90;

				}
				public function startLoader():void{
					this._universe.addChild(_ldr.ldrObject);
				}
				public function loaderComplete(evt:Event):void{
					this._universe.removeChild(_ldr.ldrObject);
					this._universe.addChild(_front_plane);
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
				
				//TODO: enable 3d emulation sound!
				/*_ezflar.onUpdated(function(marker:FLARMarkerEvent):void {
				_model = _ezflar.getModel(0, "gloss")[0];
				if(_model != null){
				_model.rotationX += 1;
				};
				soundTrans.volume = 1 - (marker.z()/1200);
				soundTrans.pan = ((marker.x() * 0.008 - 0.3) - 1) * -1;
				channel.soundTransform = soundTrans;
				});
				_ezflar.onRemoved(function(marker:FLARMarkerEvent):void {
				soundTrans.volume = 0;
				channel.soundTransform = soundTrans;  
				});*/
				}
			}