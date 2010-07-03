/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import Papervision3D_2_1_920;
/*	import org.papervision3d.objects.parsers.MD2;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.objects.DisplayObject3D;
*/	import flash.events.Event;

	import com.tchatcho.constructors.LoadingEZFLAR;

	public class MD2constructor extends MD2 {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _mMD2:MD2;
		public function MD2constructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {

			startLoader();

			this._mMD2 = new MD2();
			if (url2 != null){
				var materialMD2:BitmapFileMaterial = new BitmapFileMaterial(url2, true); 
				materialMD2.doubleSided = false;
				this._mMD2.load(url, materialMD2);
			} else {
				this._mMD2.load(url);
			};
			//TODO: MD2 animations support
			//__player = new MD2(materialMD2, "assets/supermale.md2", 12);
			//__playerControler = new AbstractController(); 
			//__player.addController(__playerControler);
			//__playerControler.play();    
			//__mainHolder.addChild(__player);    

			this._mMD2.rotationZ = 270;
			this._mMD2.scale = 2;
			this._mMD2.addEventListener( FileLoadEvent.LOAD_COMPLETE , loaderComplete );
			this._universe.z = 50;
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}

				}
				public function startLoader():void{
					this._universe.addChild(_ldr.ldrObject);
				}
				public function loaderComplete(evt:Event):void{
					this._universe.removeChild(_ldr.ldrObject);
					this._universe.addChild(this._mMD2);
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
			}
		}
