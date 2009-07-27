package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;

	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class LoadingEZFLAR extends MovieClip {
		private static const LOADINGPATH:String = "../resources/flar/loading.swf";
		
		private var _loader:Loader = new Loader();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		public function LoadingEZFLAR() {
			
			var request:URLRequest=new URLRequest(LOADINGPATH);
			_loader.load(request);
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			_loader.scaleY = 0.7;
			_loader.scaleX = 0.7;
			addChild(_loader);
			var skinMaterial:MovieClip = this;
			var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
			front_material.interactive = true;
			front_material.animated = true;
			front_material.doubleSided = true;
			var front_plane:Plane;
			front_plane = new Plane(front_material, 640, 480, 4, 4);
			front_plane.scale = 0.5;
			this._universe.z = 3;
			this._universe.name = "loading"
			this._universe.rotationY = 0;
			this._universe.rotationZ = -90;
			this._universe.addChild(front_plane);
			
			}
			public function get loading():DisplayObject3D{
				return this._universe;
			}
		}
	}