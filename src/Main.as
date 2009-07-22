package {
	import Objects;
	import flash.display.Sprite;
	import com.transmote.flar.FLARMarkerEvent;	
		
	public class Main extends Sprite {
		private var _objects:Objects;
		private var _symbols:Array = new Array();
		
		public function Main() {
			/*_symbols.push(new Array("patt.hiro","Scout/modelo.DAE"));// 0*/
			/*_symbols.push(new Array("patt.hiro","fdsfd.fds"));// formato errado*/
			/*_symbols.push(new Array("patt.hiro","MD2/horse/horse.md2","MD2/horse/horse.jpg"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.swf"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.flv"));// 0*/
			/*_symbols.push(new Array("patt.hiro","cube"));// 0*/
			_symbols.push(["patt.hiro", "empty"],["myempty"]);// 0
			_symbols.push(["patt2.hiro", "cube"],["mycube"]);// 1
			/*_symbols.push(new Array("patt2.hiro","eiffel/models/eiffel.dae", "eiffel/images/eiffel2.png"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","MD2/horse/horse.md2", "MD2/horse/horse.jpg"));// 0*/
			
			//TODO: place 2 models in the same symbol...
			//TODO: handle loading models and no camera message...
			_objects = new Objects(_symbols/*, 320, 270*/);
			
			stage.addChild(_objects);
			_objects.viewFrameRate();
			
			_objects.onStarted(function():void {
				_objects.addModelTo([0,"picture", "imagem1.jpg"],["mypicture"]);
				_objects.addModelTo([0,"wire"],["mywire"]);
				/*_objects.addModelTo([0,"picture", "imagem2.jpg"],["mypicture2"]);*/
				
				trace(">>>>>>>>>>>>> inicio");
				_objects.mirror();
				/*_objects.moveTo(640,0);*/
				});
			_objects.onAdded(function(marker:FLARMarkerEvent):void {
				/*trace(">>>>>>>>>>>>> adicionado: " + marker.marker.patternId );*/
				/*_objects.object(0,"scale",0.2);*/				
				});
			_objects.onUpdated(function(marker:FLARMarkerEvent):void {
				/*trace("["+ marker.marker.patternId+"]>>" +
					  "X:" + marker.x() + " || " +
					  "Y:" + marker.y() + " || " +
					  "Z:" + marker.z() + " || " +
					  "RX:" + marker.rotationX() + " || " +
					  "RY:" + marker.rotationY() + " || " +
					  "RZ:" + marker.rotationZ() + " || "
				);*/				
				});
			_objects.onRemoved(function(marker:FLARMarkerEvent):void {
				/*trace(">>>>>>>>>>>>> removido: " + marker.marker.patternId);*/
				});
		}
	}
}