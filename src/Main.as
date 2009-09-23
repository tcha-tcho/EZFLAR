package {
	import com.tchatcho.EZflar;//tcha-tcho.com
	import flash.display.MovieClip;
	import com.transmote.flar.FLARMarkerEvent;	
		
	public class Main extends MovieClip {
		private var _ezflar:EZflar;
		private var _symbols:Array = new Array();
		
		public function Main() {
			//*.swf, *.flv, *.dae, *.md2, cube, picture, wire or empty
			/*_symbols.push(new Array("patt.hiro","Scout/modelo.DAE"));// 0*/
			/*_symbols.push(new Array("p	att.hiro","fdsfd.fds"));// formato errado*/
			/*_symbols.push(new Array("patt.hiro","MD2/horse/horse.md2","MD2/horse/horse.jpg"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.swf"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","test.flv"));// 0*/
			/*_symbols.push(new Array("patt.hiro","cube"));// 0*/
			_symbols.push([["patt.hiro", "testedaniel/baleia3.dae", "testedaniel/texturafinal.jpg"],["mybaleia"]]);// 0
			_symbols.push([["patt2.hiro", "empty"]]);// 1
			/*_symbols.push(new Array("patt2.hiro","eiffel/models/eiffel.dae", "eiffel/images/eiffel2.png"));// 0*/
			/*_symbols.push(new Array("patt2.hiro","MD2/horse/horse.md2", "MD2/horse/horse.jpg"));// 0*/
			_ezflar = new EZflar(_symbols/*, 320, 270*/);
			_ezflar.initializer(stage, "./resources/");
			_ezflar.customizeNoCam("Precisamos de uma webcam", 0xFFFFFF, 0xCCCCCC);
			_ezflar.viewFrameRate();
			_ezflar.mirror();
			
			
			_ezflar.onStarted(function():void {
				/*_ezflar.addModelTo([0,"picture", "imagem1.jpg"],["myimage"]);*/
				/*_ezflar.addModelTo([0,"cube"],["mycube"]);*/
				_ezflar.addModelTo([0,"wire"], ["mywire"]);
				_ezflar.addModelTo([1,"cube"], ["thecube"]);
				trace(_ezflar.getModel(0, "mywire"));
				trace(">>>>>>>>>>>>> inicio");
				/*_ezflar.moveTo(640,0);*/
				});
			_ezflar.onAdded(function(marker:FLARMarkerEvent):void {
				/*trace(">>>>>>>>>>>>> adicionado: " + marker.marker.patternId );*/
				_ezflar.getObject(0,"mybaleia").rotationX = 90;
				_ezflar.object(0,"rotationX", 90, "mybaleia");
				/*_ezflar.object(1,"scale",2,"thecube");*/
				/*_ezflar.object(1,"scale",2);*/
				/*_ezflar.object(1,"rotationX",45,"mytest");*/
				/*_ezflar.object(1,"scale",0.2, "mypicture2");*/
				
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