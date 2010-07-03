/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import Papervision3D_2_1_920;
/*	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
*/
	public class WIREconstructor extends Plane {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _wire:Plane;
		public function WIREconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {
			startLoader();
			if (url2 != null){
				var wfm:WireframeMaterial = new WireframeMaterial(uint(url2));
			} else {
				trace("HEY!, YOU CAN USE COLORS IN HEXA TOO ;) . PUT ANOTHER ARGUMENT TO DO THAT. IM GONNA USE THIS ONE: 0xffff00");
				var wfm:WireframeMaterial = new WireframeMaterial(0xffff00);
			}

			wfm.doubleSided = true;
			_wire = new Plane(wfm);
			_wire.scale = 0.16;
			this._universe.z = 1;
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.rotationY = 0;
					this._universe.rotationZ = -90;
					//TODO: implement loader handler to Wire
					loaderComplete("Wire.complete");
					
				}
				public function startLoader():void{
					this._universe.addChild(_ldr.ldrObject);
				}
				public function loaderComplete(evt:String):void{
					this._universe.removeChild(_ldr.ldrObject);
					this._universe.addChild(_wire);
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
			}
		}
