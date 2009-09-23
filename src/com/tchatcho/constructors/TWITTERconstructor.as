/**
* @Author tcha-tcho
*/
package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import com.tchatcho.constructors.LoadingEZFLAR;
	
	import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import flash.xml.XMLNodeType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	

	
	public class TWITTERconstructor extends MovieClip {
		private var _ldr:LoadingEZFLAR = new LoadingEZFLAR();
		private var _loader:Loader = new Loader();
		private var _universe:DisplayObject3D = new DisplayObject3D();
		private var _front_plane:Plane;
		private var _xml:XML;
		private var _myXMLloader:URLLoader = new URLLoader();
		private var _txt:TextField = new TextField();
		

		public function TWITTERconstructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {
			startLoader();
			var cleanURL:String = url2.split("/").pop();
			trace("accessing twitter of " + cleanURL);
			if (url2 == null) {
				_myXMLloader.load(new URLRequest("http://www.twitter.com/users/ezflar"))
			} else {
				_myXMLloader.load(new URLRequest("http://www.twitter.com/users/" + cleanURL))
			}
			_myXMLloader.addEventListener(Event.COMPLETE, loaderComplete);
			var request2:URLRequest=new URLRequest("com/tchatcho/constructors/twitterballon.swf");
			
			_loader.load(request2);			
			_loader.scaleY = 0.7;
			_loader.scaleX = 0.7;
			addChild(_loader);
			var skinMaterial:MovieClip = this;
			var front_material:MovieMaterial = new MovieMaterial(skinMaterial, true);
			front_material.interactive = true;
			front_material.animated = true;
			front_material.doubleSided = true;
			_front_plane = new Plane(front_material, 640, 480, 4, 4);
			_front_plane.scale = 0.5;
			this._universe.z = 3;
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.rotationY = 0;
					this._universe.rotationZ = 180;
					this._universe.y = -50;

				}
				public function startLoader():void{
					this._universe.addChild(_ldr.ldrObject);
				}
				public function loaderComplete(evt:Event):void{
					_xml = new XML(evt.target.data);
					if (_xml.status.text == null){
						_txt.text = "Twitter not found ;(\nsorry!"
					} else {
						_txt.text = _xml.status.text
					}
					_txt.wordWrap = true;
					_txt.multiline = true;
					_txt.width = 210;
					var format:TextFormat                = new TextFormat();
						format.size                          = 14;
						format.align                         = "center";
						_txt.setTextFormat(format);
						_txt.x = 10;
						_txt.y = 33;
						addChild(_txt);

					this._universe.removeChild(_ldr.ldrObject);
					this._universe.addChild(_front_plane);
					
				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
				}
			}