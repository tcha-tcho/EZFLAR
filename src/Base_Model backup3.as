package {
	//to the dae models
	import org.papervision3d.objects.parsers.DAE;
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
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.BitmapFileMaterial;
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



	public class Base_model extends Sprite {//Or BasicView
		//to use models dae
	private var _mCollada:DAE;
	private var _mMD2:MD2;
	private static const MODELSPATH:String = "../resources/models/";
	private var _universe:DisplayObject3D;
	private var _url:String;
	private var _url2:String;
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
		this.init(_numPatterns);
		this.initPapervisionEnvironment(cameraParams, viewportWidth, viewportHeight);
	}

	public function addMarker (marker:FLARMarker) :void {
		// associate container with corresponding marker
			this._markersByPatternId.push(new Array (marker.patternId, marker, placeModels(marker.patternId)));
		
		//again for the added models
		var i:int = 0;
		var len:int = this._objectsToAdd.length;
	    while(i < len) {
			if(marker.patternId == _objectsToAdd[i][0]){
				this._markersByPatternId.push(new Array (_objectsToAdd[i][0], marker, placeModels(_objectsToAdd[i][0], _objectsToAdd[i][1], _objectsToAdd[i][2])));
			}
	        i++;
	    }
	}

	public function removeMarker (marker:FLARMarker) :void {
		trace("removi");
		// find and remove marker
		var i:int = 0;
		var len:int = this._markersByPatternId.length;
	    while(i < len) {
		trace("indice no markers: " + i + " ::: simbolo: " + this._markersByPatternId[i][0]);
			if (this._markersByPatternId[i][0] == marker.patternId){
				// find and remove corresponding container
				this._scene3D.removeChild(this._markersByPatternId[i][2]);
				trace(this._scene3D.numChildren)
				delete this._markersByPatternId[i];
			}
	        i++;
	    }
	}
	private function updateModels () :void {
		// update all Models containers according to the transformation matrix in their associated FLARMarkers
		var i:int = 0;
		var len:int = this._markersByPatternId.length;
	    while(i < len) {
			if (_changes[3] == true && _changes[0] == this._markersByPatternId[i][0]){
				this._markersByPatternId[i][2].getChildByName("universe")[_changes[1]] = _changes[2];
				_changes[3] = false;
			};
			this._markersByPatternId[i][2].transform = FLARPVGeomUtils.translateFLARMatrixToPVMatrix(this._markersByPatternId[i][1].transformMatrix);
	        i++;
	    }
	}
	private function init (numPatterns:uint) :void {
		this._markersByPatternId = new Array();
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
		private function placeModels(patternId:int, url:String = null, url2:String = null):DisplayObject3D{
			var ModelID:int = patternId % 5;
			if (url != null) {
				_url = MODELSPATH + url;
			} else {
				_url = MODELSPATH + _objects[ModelID][1];
			}
			if (url2 != null || _objects[ModelID][2] != null){
				if(url2 != null){
					_url2 = MODELSPATH + url2
					} else {
						_url2 = MODELSPATH + _objects[ModelID][2];
					}
				}
				var _format:String = _url.toString();
				_format = _format.substring(_format.length - 3,_format.length).toUpperCase();
				switch (_format){
					//TODO: take of all the formats to external packages!
					case "SWF" ://*.swf
					var container : DisplayObject3D = new DisplayObject3D();
					var skinMaterial:MovieClip = new SWFconstructor(_url);
					var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
					front_material.interactive = true;
					front_material.animated = true;
					front_material.doubleSided = true;
					var front_plane:Plane;
					front_plane = new Plane(front_material, 640, 480, 4, 4);
					front_plane.scale = 0.5;
					this._universe = new DisplayObject3D();
					this._universe.z = 3;
					this._universe.name = "universe"
						this._universe.rotationY = 0;
					this._universe.rotationZ = -90;
					this._universe.addChild(front_plane);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;

					case "FLV" ://*.flv
					var container : DisplayObject3D = new DisplayObject3D();
					var flv:FLVconstructor = new FLVconstructor(_url);
					var front_videomaterial:VideoStreamMaterial = flv.getVideoMaterial();
					var front_plane:Plane;
					front_plane = new Plane(front_videomaterial, 640, 480, 4, 4);
					front_plane.scale = 0.3;
					this._universe = new DisplayObject3D();
					this._universe.z = 3;
					this._universe.name = "universe"
						this._universe.rotationY = 0;
					this._universe.rotationZ = -90;
					this._universe.addChild(front_plane);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;

					case "DAE" : //*.dae
					var container : DisplayObject3D = new DisplayObject3D();
					this._mCollada = new DAE( true, "myCollada", true);//last true is the loop in the constructor
					if (_objects[ModelID][2] != null){
						var materialDAE:BitmapFileMaterial = new BitmapFileMaterial(_url2, true); 
						materialDAE.doubleSided = true;
						var materialList:MaterialsList = new MaterialsList();
						materialList.addMaterial(materialDAE);
						this._mCollada.load(_url, materialList);					
					} else {
						this._mCollada.load(_url);
					}
					this._mCollada.rotationZ = 270;
					this._mCollada.scale = 0.5;
					this._universe = new DisplayObject3D();
					this._universe.z = 50;				
					this._universe.name = "universe"
						this._universe.addChild(this._mCollada);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					//TODO: make collada animation support
					this._mCollada.play();
					return container;
					break;

					case "MD2" ://*.md2
					var container : DisplayObject3D = new DisplayObject3D();
					this._mMD2 = new MD2();
					if (_objects[ModelID][2] != null){
						var materialMD2:BitmapFileMaterial = new BitmapFileMaterial(_url2, true); 
						materialMD2.doubleSided = false;
						this._mMD2.load(_url, materialMD2);
					} else {
						this._mMD2.load(_url);
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
					this._universe.name = "universe"
						this._universe.addChild(this._mMD2);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;

					case "UBE" ://cube
					var container : DisplayObject3D = new DisplayObject3D();
					var cube:Cube;
					if (_objects[ModelID][2] != null){
						var cubeMaterial:BitmapFileMaterial = new BitmapFileMaterial(_url2, true);
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
					this._universe.name = "universe"
						this._universe.addChild(cube);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;

					case "URE" ://picture
					var container : DisplayObject3D = new DisplayObject3D();
					var front_plane:Plane;
					if (_objects[ModelID][2] != null){
						var pictureMaterial:BitmapFileMaterial = new BitmapFileMaterial(_url2, true);
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
					this._universe.name = "universe"
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
					this._universe.name = "universe"
						this._universe.rotationY = 0;
					this._universe.rotationZ = -90;
					this._universe.addChild(wire);
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;


					//TODO: make support to empty containers to add models later
					case "PTY" :
					var container : DisplayObject3D = new DisplayObject3D();
					_universe = new DisplayObject3D();
					_universe.z = 50;
					_universe.name = "universe";
					container.addChild( this._universe );
					this._scene3D.addChild(container);
					return container;
					break;

					default :
					trace(_format + " IS A WRONG FORMAT!: PLS, USE: *.swf, *.flv, *.dae, *.md2, cube, picture, wire or empty... IN THE MODELS FOLDER");
					var container : DisplayObject3D = new DisplayObject3D();
					return container;					
					break;
				}
			}
			public function changeObjectProperty(marker:uint, propertyToChange:String, newValue:Number):void{
				_changes[0] = marker;
				_changes[1] = propertyToChange;
				_changes[2] = newValue;
				_changes[3] = true;//avoid repeat changes every frame
			}
			public function addModelToStage(markerID:int, pathToModel:String, secondPath:String):void {
				this._objectsToAdd.push(new Array(markerID, pathToModel, secondPath))
				}
			}
		}