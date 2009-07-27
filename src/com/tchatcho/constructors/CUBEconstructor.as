package com.tchatcho.constructors {
	import org.papervision3d.objects.primitives.Cube;

	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;

	import org.papervision3d.objects.DisplayObject3D;
	
	import org.papervision3d.materials.WireframeMaterial;
	
	//TODO: handle clicks in objects
	//import org.papervision3d.events.InteractiveScene3DEvent;
	

	public class CUBEconstructor extends DisplayObject3D {
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _cube:Cube;
		public function CUBEconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {

			if (url2 != null){
				var cubeMaterial:BitmapFileMaterial = new BitmapFileMaterial(url2, true);
				cubeMaterial.doubleSided = true;
				var materialList:MaterialsList = new MaterialsList();
				materialList.addMaterial(cubeMaterial, 'all');
				_cube = new Cube(materialList);
			} else {
				var materialList:MaterialsList = new MaterialsList();
				materialList.addMaterial(new WireframeMaterial(0xffff00), 'all');
				_cube = new Cube(materialList);
			}
			_cube.scale = 0.1;
			this._universe.z = 30;
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.addChild(_cube);
			//TODO: implement loader handler of CUBE
			loaderComplete("CUBE Loaded");
				}
				public function loaderComplete(evt:String):void{
					trace("CUBELoader: Complete");
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
			}
		}