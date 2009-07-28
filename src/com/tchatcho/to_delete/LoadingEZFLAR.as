package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	
	import org.papervision3d.objects.DisplayObject3D;
	import com.tchatcho.constructors.LoadingEZFLAR;
	
	public class LoadingEZFLAR extends MovieClip {
		private static const LOADINGPATH:String = "../resources/flar/loading.swf";
		private var _loader:Loader = new Loader();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		public function LoadingEZFLAR() {
			var request:URLRequest=new URLRequest(LOADINGPATH);
			_loader.load(request);
			_loader.scaleY = 0.7;
			_loader.scaleX = 0.7;
			addChild(_loader);
			var skinMaterial:MovieClip = this;
			var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
			front_material.animated = true;
			front_material.doubleSided = true;
			var front_plane:Plane;
			front_plane = new Plane(front_material, 400, 400, 2, 2);
			front_plane.scale = 0.3;
			front_plane.x = 12;
			this._universe.addChild(front_plane);
			}
			public function get ldrObject():DisplayObject3D{
				return this._universe;
			}
		}
	}