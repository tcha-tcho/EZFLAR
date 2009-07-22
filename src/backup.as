package {
	import com.transmote.flar.FLARMarker;
	import com.transmote.utils.geom.FLARPVGeomUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	//to the dae models
	import org.papervision3d.objects.parsers.DAE;

	//to the cube
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;

	public class Base_model extends Sprite {
		//to use models dae
		private var _mCollada:DAE;
		private var _universe:DisplayObject3D;

		// when you use cube
		private static const CUBE_SIZE:Number = 40;

		//initiate global vars
		private var viewport3D:Viewport3D;
		private var camera3D:FLARCamera3D;
		private var scene3D:Scene3D;
		private var renderEngine:LazyRenderEngine;
		private var pointLight3D:PointLight3D;

		private var markersByPatternId:Array;// FLARMarkers, arranged by patternId
		private var containersByMarker:Dictionary;// Model containers, hashed by corresponding FLARMarker


		public function Base_model (numPatterns:uint, cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) {
			this.init(numPatterns);
			this.initPapervisionEnvironment(cameraParams, viewportWidth, viewportHeight);
		}

		public function addMarker (marker:FLARMarker) :void {
			// store marker
			var markerList:Array = this.markersByPatternId[marker.patternId];
			markerList.push(marker);

					// create a new Cube, and place it inside a container (DisplayObject3D) for manipulation
						

			// associate container with corresponding marker
			this.containersByMarker[marker] = place_DAEs(marker.patternId);
		}

		public function removeMarker (marker:FLARMarker) :void {
			// find and remove marker
			var markerList:Array = this.markersByPatternId[marker.patternId];
			var markerIndex:uint = markerList.indexOf(marker);
			if (markerIndex != -1) {
				markerList.splice(markerIndex, 1);
			}

			// find and remove corresponding container
			var container:DisplayObject3D = this.containersByMarker[marker];
			if (container) {
				this.scene3D.removeChild(container);
			}
			delete this.containersByMarker[marker]
		}

		private function init (numPatterns:uint) :void {
			this.markersByPatternId = new Array(numPatterns);
			while (numPatterns--) {
				this.markersByPatternId[numPatterns] = new Array();
			}

			// prepare hashtable for associating Cube containers with FLARMarkers
			this.containersByMarker = new Dictionary(true);
		}

		private function initPapervisionEnvironment (cameraParams:FLARParam, viewportWidth:Number, viewportHeight:Number) :void {
			this.scene3D = new Scene3D();
			this.camera3D = new FLARCamera3D(cameraParams);
			this.viewport3D = new Viewport3D(viewportWidth, viewportHeight);
			this.addChild(this.viewport3D);
			this.renderEngine = new LazyRenderEngine(this.scene3D, this.camera3D, this.viewport3D);

			this.pointLight3D = new PointLight3D();
			this.pointLight3D.x = 1000;
			this.pointLight3D.y = 1000;
			this.pointLight3D.z = -1000;

			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}

		private function onEnterFrame (evt:Event) :void {
			this.updateModels();
			this.renderEngine.render();
		}
		private function place_DAEs(patternId:int):DisplayObject3D{
			var DAEId:int = patternId % 5;
			switch (DAEId) {
				case 0:////////////////
				var container:DisplayObject3D = new DisplayObject3D();
				var materialsList:MaterialsList = new MaterialsList({all: this.transformById(patternId)});
				var cube:Cube = new Cube(materialsList, CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
				cube.z = 20;
				container.addChild(cube);
				this.scene3D.addChild(container);
				return container;
				case 1:///////////////////////////
				var container:DisplayObject3D = new DisplayObject3D();
				var materialsList:MaterialsList = new MaterialsList({all: this.transformById(patternId)});
				var cube:Cube = new Cube(materialsList, CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
				cube.z = 20;
				container.addChild(cube);
				this.scene3D.addChild(container);
				return container;
				default://////////////////////////
				var container:DisplayObject3D = new DisplayObject3D();
				var materialsList:MaterialsList = new MaterialsList({all: this.transformById(patternId)});
				var cube:Cube = new Cube(materialsList, CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
				cube.z = 20;
				container.addChild(cube);
				this.scene3D.addChild(container);
				return container;		
				}
		}

		//TODO: make this function simplier
		private function updateModels () :void {
			// update all Models containers according to the transformation matrix in their associated FLARMarkers
			var i:int = this.markersByPatternId.length;
			var markerList:Array;
			var marker:FLARMarker;
			var container:DisplayObject3D;
			var j:int;
			while (i--) {
				markerList = this.markersByPatternId[i];
				j = markerList.length;
				while (j--) {
					marker = markerList[j];
					container = this.containersByMarker[marker];
					container.transform = FLARPVGeomUtils.translateFLARMatrixToPVMatrix(marker.transformMatrix);
				}
			}
		}
		//ISSO TAMBEM
		private function transformById (patternId:int) :FlatShadeMaterial {
			var colorId:int = patternId % 5;
			switch (colorId) {
				case 0:
				return new FlatShadeMaterial(this.pointLight3D, 0x47b200, 0x1B4200);
				case 1:
				return new FlatShadeMaterial(this.pointLight3D, 0x990000, 0x420000);
				case 2:
				return new FlatShadeMaterial(this.pointLight3D, 0xFF7F00, 0x472400);
				case 3:
				return new FlatShadeMaterial(this.pointLight3D, 0xFFCC33, 0x47390E);
				case 4:
				default:
				return new FlatShadeMaterial(this.pointLight3D, 0xF2F2B2, 0x4A4A37);
			}
		}
	}
}