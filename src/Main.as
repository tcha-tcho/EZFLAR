//you can use this approach to write as outside flash (this let me use my TextMate  :)
// to use this you have to write "Main" in /properties(tab)/Document Class... remember to take off the code placed at frame 1
package {
	import com.tchatcho.EZflar;//tcha-tcho.com
	import flash.display.MovieClip;
	import com.transmote.flar.marker.FLARMarkerEvent;	

	public class Main extends MovieClip {
		private var _ezflar:EZflar;
		private var _symbols:Array = new Array();

		public function Main() {
			_symbols.push([["EZFLAR0.pat", "text", "1234567890123456789012345678901234567890"],["mytext"]]);// 0
			_symbols.push([["EZFLAR1.pat", "Example_PNG.png"],["mypng"]]);// 0
			_symbols.push([["EZFLAR2.pat", "Example_JPG.jpg"],["myjpg"]]);// 0
			_symbols.push([["EZFLAR3.pat", "Example_GIF.gif"],["mygif"]]);// 0
			_symbols.push([["EZFLAR4.pat", "url", "http://www.google.com.br"],["mygoogle"]]);// 0
			_ezflar = new EZflar(_symbols);
			_ezflar.mirror();
			_ezflar.initializer(stage);
			_ezflar.onStarted(function():void {
				_ezflar.addModelTo([0,"Example_FLV.flv"], ["myflv"]);
				_ezflar.addModelTo([0,"twitter", "ezflar"], ["mytwitter"]);
				});
			_ezflar.onAdded(function(marker:FLARMarkerEvent):void {
				_ezflar.getObject(0,"mygif").rotationX = 90;
				trace(">>>>>>>>>>>>> added: " + marker.marker.patternId);
			});
			_ezflar.onUpdated(function(marker:FLARMarkerEvent):void {
				trace("["+ marker.marker.patternId+"]>>" +
					  "X:" + marker.x() + " || " +
					  "Y:" + marker.y() + " || " +
					  "Z:" + marker.z() + " || " +
					  "RX:" + marker.rotationX() + " || " +
					  "RY:" + marker.rotationY() + " || " +
					  "RZ:" + marker.rotationZ() + " || "
				);	
			});
			_ezflar.onRemoved(function(marker:FLARMarkerEvent):void {
				trace(">>>>>>>>>>>>> removed: " + marker.marker.patternId);
			});

			}
		}
	}