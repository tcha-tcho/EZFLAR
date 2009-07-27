package {
	import com.tchatcho.EZflar;//tcha-tcho.com
	import flash.display.Sprite;
	import com.transmote.flar.FLARMarkerEvent;	
		
	public class Main extends Sprite {
		private var _ezflar:EZflar;
		private var _symbols:Array = new Array();
		
		public function Main() {
			//*.swf, *.flv, *.dae, *.md2, cube, picture, wire or empty
			/*_symbols.push(new Array("patt.hiro","Scout/modelo.DAE"));// 0*/
			/*_symbols.push(new Array("patt.hiro","fdsfd.fds"));// formato errado*/
			/*_symbols.push(new Array("patt.hiro","MD2/horse/horse.md2","MD2/horse/horse.jpg"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.swf"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.flv"));// 0*/
			/*_symbols.push(new Array("patt.hiro","cube"));// 0*/
			_symbols.push([["patt.hiro", "empty"]]);// 0
			_symbols.push([["patt2.hiro", "wire"],["mypicture"]]);// 1
			/*_symbols.push(new Array("patt2.hiro","eiffel/models/eiffel.dae", "eiffel/images/eiffel2.png"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","MD2/horse/horse.md2", "MD2/horse/horse.jpg"));// 0*/
			
			//TODO: fixbug place 2 models in the same symbol...
			//TODO: handle loading models and no camera message...
			_ezflar = new EZflar(_symbols/*, 320, 270*/);
			/*_ezflar.noCameraMessage("VC nao tem camera");*/
			stage.addChild(_ezflar);
			_ezflar.viewFrameRate();
			_ezflar.mirror();
			
			
			_ezflar.onStarted(function():void {
				/*_ezflar.addModelTo([0,"picture", "imagem2.jpg"],["mypicture2"]);*/
				/*_ezflar.addModelTo([0,"wire"]);*/
				trace(">>>>>>>>>>>>> inicio");
				/*_ezflar.moveTo(640,0);*/
				});
			_ezflar.onAdded(function(marker:FLARMarkerEvent):void {
				/*trace(">>>>>>>>>>>>> adicionado: " + marker.marker.patternId );*/
				/*_ezflar.object(0,"scale",0.1,"mypicture2");*/
				_ezflar.object(1,"scale",0.8,"mypicture");
				});
			_ezflar.onUpdated(function(marker:FLARMarkerEvent):void {
				/*trace("["+ marker.marker.patternId+"]>>" +
					  "X:" + marker.x() + " || " +
					  "Y:" + marker.y() + " || " +
					  "Z:" + marker.z() + " || " +
					  "RX:" + marker.rotationX() + " || " +
					  "RY:" + marker.rotationY() + " || " +
					  "RZ:" + marker.rotationZ() + " || "
				);*/				
				});
			_ezflar.onRemoved(function(marker:FLARMarkerEvent):void {
				/*trace(">>>>>>>>>>>>> removido: " + marker.marker.patternId);*/
				});
		}
	}
}