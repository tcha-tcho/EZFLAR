/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import Papervision3D_2_1_920;
/*	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
*/	import com.tchatcho.constructors.LoadingEZFLAR;

	public class SWFconstructor extends MovieClip {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _loader:Loader = new Loader();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _front_plane:Plane;

		public function SWFconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {
			startLoader();

			var request:URLRequest=new URLRequest(url);
			_loader.load(request);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			_loader.scaleY = 0.7;
			_loader.scaleX = 0.7;
			addChild(_loader);
			var skinMaterial:MovieClip = this;
			var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
			front_material.interactive = true;
			front_material.animated = true;
			front_material.doubleSided = true;
			_front_plane = new Plane(front_material, 640, 480, 4, 4);
			_front_plane.scale = 0.5;
			this._universe.z = 3;
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
			}
		}