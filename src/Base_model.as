package {
	//to the dae models
	import org.papervision3d.objects.parsers.MD2;
	//to flar
	import com.transmote.flar.FLARMarker;
	import com.transmote.utils.geom.FLARPVGeomUtils;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	//to swfs
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.VideoStreamMaterial;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import SWFconstructor;
	import FLVconstructor;
	import DAEconstructor;
	
	
	//it shouldnt be here
	import org.papervision3d.materials.utils.MaterialsList;	
	import org.papervision3d.materials.BitmapFileMaterial;
	
	

	public class Base_model extends Sprite {//Or BasicView
		//to use models dae
	private var _mMD2:MD2;
	private static const MODELSPATH:String = "../resources/models/";
	private var _universe:DisplayObject3D;
	private var _objectsToAdd:Array = new Array();

	// when you use cube
	private static const CUBE_SIZE:Number = 40;

	//initiate global vars
	private var _viewport3D:Viewport3D;
	private var _camera3D:FLARCamera3D;
	private var _scene3D:Scene3D;
	private var _renderEngine:LazyRenderEngine;
	private var _pointLight3D:PointLight3D;

	private var _objects:Array;
	private var _numPatterns:uint;
	private var url:String;

	private var _changes:Array = new Array();


	private var _markersByPatternId:Array;// FLARMarkers, arranged by patternId


	public function Base_model (objects:Array, numPatterns:uint, cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) {
		this._objects = objects;
		this._numPatterns = numPatterns;
		this.init();
		this.initPapervisionEnvironment(cameraParams, viewportWidth, viewportHeight);
	}

	public function addMarker (marker:FLARMarker) :void {
		//trace(":::::::::::::::: adicionei a : " + marker.patternId);
		var objectsToAdd:Array = new Array();
		for (var i:int = 0; i < _objectsToAdd.length; i++){
			objectsToAdd.push(_objectsToAdd[i])
			}
			//trace("marker: " + marker.patternId + "::" + _objects[marker.patternId][0][1] + "::" +_objects[marker.patternId][0][2] + "::" + _objects[marker.patternId][1]);
			objectsToAdd.push([constructURL([marker.patternId, _objects[marker.patternId][0][1], _objects[marker.patternId][0][2]]),_objects[marker.patternId][1]]);
				// associate container with corresponding marker
			var i:int = 0;
			var len:int = objectsToAdd.length;
			while(i < len) {
				if(objectsToAdd[i][0][0] == marker.patternId){
					this._markersByPatternId.push(new Array (objectsToAdd[i][0][0], marker, placeModels(objectsToAdd[i][0][0], objectsToAdd[i][0][1], objectsToAdd[i][0][2], objectsToAdd[i][1])));
				}
				i++;
			}
			trace(" ::: ADDED on " + marker.patternId + ": length: " + objectsToAdd.length + " ::::::::: still on scene: " + this._scene3D.numChildren);
		}
		public function removeMarker (marker:FLARMarker) :void {
			//trace(":::::::::::::::: removi: " + marker.patternId);
			// find and remove marker
			var markerList:Array = new Array();
			for (var i:int = 0; i < this._markersByPatternId.length; i++){
				markerList.push(this._markersByPatternId[i])
				}
				var markerList2:Array = new Array;
				for (var i:int = 0; i < this._markersByPatternId.length; i++ ) {
					if (markerList[i][0] == marker.patternId){
						this._scene3D.removeChild(markerList[i][2]);
					} else {
						markerList2.push(markerList[i])
						}
					}
					this._markersByPatternId = new Array();
					for (var i:int = 0; i < markerList2.length; i++){
						this._markersByPatternId.push(markerList2[i]);
					}
					trace(" ::: REMOVED on " + marker.patternId + ": length: " + markerList.length + " ::::::::: still on scene: " + this._scene3D.numChildren);
				}
				private function updateModels () :void {
					// update all Models containers according to the transformation matrix in their associated FLARMarkers
					var i:int = 0;
					var len:int = this._markersByPatternId.length;
					while(i < len) {
						if(_changes[0] == true){
							if (_changes[1] == this._markersByPatternId[i][0]){
								this._markersByPatternId[i][2].getChildByName(_changes[4])[_changes[2]] = _changes[3];
							};
						}
						this._markersByPatternId[i][2].transform = FLARPVGeomUtils.translateFLARMatrixToPVMatrix(this._markersByPatternId[i][1].transformMatrix);
						i++;
					}
					_changes[0] = false;
				}
				private function init () :void {
					this._markersByPatternId = new Array();
					_changes[0] = false;
				}

				private function initPapervisionEnvironment (cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) :void {
					this._scene3D = new Scene3D();
					this._camera3D = new FLARCamera3D(cameraParams);
					this._viewport3D = new Viewport3D(viewportWidth, viewportHeight);
					this.addChild(this._viewport3D);
					this._renderEngine = new LazyRenderEngine(this._scene3D, this._camera3D, this._viewport3D);

					this._pointLight3D = new PointLight3D();
					this._pointLight3D.x = 1000;
					this._pointLight3D.y = 1000;
					this._pointLight3D.z = -1000;

					this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
				}

				private function onEnterFrame (evt:Event) :void {
					this.updateModels();
					this._renderEngine.render();
				}
				private function placeModels(patternId:int, url:String = null, url2:String = null, objName:String = null):DisplayObject3D{
					var _format:String = url.toString();
					_format = _format.substring(_format.length - 3,_format.length).toUpperCase();
					switch (_format){
						//TODO: take of all the formats to external packages!
						case "SWF" ://*.swf
						var container : DisplayObject3D = new DisplayObject3D();
						var swf:SWFconstructor = new SWFconstructor(patternId, url, url2, objName)
						container.addChild( swf.object );
						this._scene3D.addChild(container);
						return container;
						break;

						case "FLV" ://*.flv
						var container : DisplayObject3D = new DisplayObject3D();
						var flv:FLVconstructor = new FLVconstructor(patternId, url, url2, objName);
						container.addChild( flv.object );
						this._scene3D.addChild(container);
						return container;
						break;

						case "DAE" : //*.dae
						var container : DisplayObject3D = new DisplayObject3D();
						var dae:DAEconstructor = new DAEconstructor(patternId, url, url2, objName);
						container.addChild( dae.object );
						this._scene3D.addChild(container);
						return container;
						break;

						case "MD2" ://*.md2
						var container : DisplayObject3D = new DisplayObject3D();
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
						this._universe = new DisplayObject3D();
						this._universe.z = 50;
						if(objName != null){
							this._universe.name = objName
						}else{
							this._universe.name = "universe"
						}
						this._universe.addChild(this._mMD2);
						container.addChild( this._universe );
						this._scene3D.addChild(container);
						return container;
						break;

						case "UBE" ://cube
						var container : DisplayObject3D = new DisplayObject3D();
						var cube:Cube;
						if (url2 != null){
							var cubeMaterial:BitmapFileMaterial = new BitmapFileMaterial(url2, true);
							cubeMaterial.doubleSided = true;
							var materialList:MaterialsList = new MaterialsList();
							materialList.addMaterial(cubeMaterial, 'all');
							cube = new Cube(materialList);
						} else {
							var materialList:MaterialsList = new MaterialsList();
							materialList.addMaterial(new WireframeMaterial(0xffff00), 'all');
							cube = new Cube(materialList);
						}
						cube.scale = 0.1;
						this._universe = new DisplayObject3D();
						this._universe.z = 30;
						if(objName != null){
							this._universe.name = objName
						}else{
							this._universe.name = "universe"
						}
						this._universe.addChild(cube);
						container.addChild( this._universe );
						this._scene3D.addChild(container);
						return container;
						break;

						case "URE" ://picture
						var container : DisplayObject3D = new DisplayObject3D();
						var front_plane:Plane;
						if (url2 != null){
							var pictureMaterial:BitmapFileMaterial = new BitmapFileMaterial(url2, true);
							pictureMaterial.doubleSided = true;
							front_plane = new Plane(pictureMaterial, 640, 480, 4, 4);
						} else {
							var wfm:WireframeMaterial = new WireframeMaterial(0xffff00);
							wfm.doubleSided = true;
							front_plane = new Plane(wfm);
						}
						front_plane.scale = 0.5;
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
						container.addChild( this._universe );
						this._scene3D.addChild(container);
						return container;
						break;

						case "IRE"://wire
						var container : DisplayObject3D = new DisplayObject3D();
						var wire:Plane;
						var wfm:WireframeMaterial = new WireframeMaterial(0xffff00);
						wfm.doubleSided = true;
						wire = new Plane(wfm);
						wire.scale = 0.16;
						this._universe = new DisplayObject3D();
						this._universe.z = 1;
						if(objName != null){
							this._universe.name = objName
						}else{
							this._universe.name = "universe"
						}
						this._universe.rotationY = 0;
						this._universe.rotationZ = -90;
						this._universe.addChild(wire);
						container.addChild( this._universe );
						this._scene3D.addChild(container);
						return container;
						break;

						case "PTY" :
						var container : DisplayObject3D = new DisplayObject3D();
						var emptyContainer : DisplayObject3D = new DisplayObject3D();							
						_universe = new DisplayObject3D();
						_universe.z = 50;
						if(objName != null){
							_universe.name = objName;
						} else {
							_universe.name = "universe";
						}
						container.addChild( this._universe );
						this._scene3D.addChild(container);
						return container;
						break;

						default :
						trace(_format + " WE CANT USE THIS ;( PLS, USE: *.swf, *.flv, *.dae, *.md2, cube, picture, wire or empty... DONT FORGET TO PUT IN RESOURCES/MODELS FOLDER");
						var container : DisplayObject3D = new DisplayObject3D();
						return container;					
						break;
					}
				}
				public function changeObjectProperty(marker:uint, propertyToChange:String, newValue:Number, thisName:String):void{
					_changes[0] = true;//prevent to process twice
					_changes[1] = marker;
					_changes[2] = propertyToChange;
					_changes[3] = newValue;
					_changes[4] = thisName;
					
				}
				public function addModelToStage(set1:Array, set2:Array = null):void {
					this._objectsToAdd.push([constructURL(set1), set2])
					}
					
					
				public function constructURL(income:Array):Array{
						var url1:String = new String();
						var url2:String = new String();
						if (income[1] != null){
							url1 = MODELSPATH + income[1];
						} else {
							url1 = null;
						}
						if (income[2] != null){
							url2 = MODELSPATH + income[2];
						} else {
							url2 = null;
						}
						return [income[0],url1,url2]
					}
				}
			}