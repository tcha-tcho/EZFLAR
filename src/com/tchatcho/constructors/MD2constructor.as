package com.tchatcho.constructors {
	import org.papervision3d.objects.parsers.MD2;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.events.FileLoadEvent;
	import flash.events.Event;

	import org.papervision3d.objects.DisplayObject3D;

	public class MD2constructor extends MD2 {
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _mMD2:MD2;
		public function MD2constructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {


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
					this._universe.addChild(this._mMD2);

				}
				public function loaderComplete(evt:Event):void{
					trace("MD2Loader: Complete");
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
			}
		}
