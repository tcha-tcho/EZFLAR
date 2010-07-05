/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.objects.DisplayObject3D;

	import flash.events.Event;
	import com.tchatcho.constructors.LoadingEZFLAR;
	
	public class DAEconstructor extends DAE {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _mCollada:DAE;
		public function DAEconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {

			startLoader();

/*			this._mCollada = new DAE( true, "dae", true);//last true is the loop in the constructor*/
			this._mCollada = new DAE( true, "dae");//last true is the loop in the constructor
			if (url2 != null){
				var materialDAE:BitmapFileMaterial = new BitmapFileMaterial(url2, true); 
				materialDAE.doubleSided = true;
				var materialList:MaterialsList = new MaterialsList();
				materialList.addMaterial(materialDAE);
				this._mCollada.load(url, materialList);					
			} else {
				this._mCollada.load(url);
			}
			this._mCollada.rotationZ = 270;
			this._mCollada.scale = 0.5;
			this._mCollada.addEventListener( FileLoadEvent.LOAD_COMPLETE , loaderComplete );
			
			this._universe = new DisplayObject3D();
			this._universe.z = 50;				
			if(objName != null){
				this._universe.name = objName
			}else{
				this._universe.name = "universe"
			}


			//TODO: make collada animation support
			this._mCollada.play();


			}
			public function startLoader():void{
				this._universe.addChild(_ldr.ldrObject);
			}
			public function loaderComplete(evt:Event):void{
				this._universe.removeChild(_ldr.ldrObject);
				this._universe.addChild(this._mCollada);
			}
			public function get object():DisplayObject3D{
				return this._universe;
			}
		}
	}