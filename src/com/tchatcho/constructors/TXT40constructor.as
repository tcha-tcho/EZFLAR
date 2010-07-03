/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Shape;
	import Papervision3D_2_1_920;
/*	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
*/
	public class TXT40constructor extends MovieClip {
		private var _universe:DisplayObject3D = new DisplayObject3D();


		public function TXT40constructor(patternId:int, url:String = null, url2:String = null, objName:String = null) {
			var cleanURL:String = url2.split("/").pop();
			var child:Shape = new Shape();
			child.graphics.beginFill(0xb3e600);
			child.graphics.lineStyle(2, 0xFFFFFF);
			child.graphics.drawRoundRect(0, 0, 450, 40, 20);
			child.graphics.endFill();
			this.addChild(child);

			var noCamMsg:TextField               = new TextField();
			noCamMsg.text                        = cleanURL;	
			noCamMsg.width						 = 440;
			var format:TextFormat                = new TextFormat();
			format.size                          = 19;
			format.align                         = "center";
			noCamMsg.setTextFormat(format);
			noCamMsg.x = 10;
			noCamMsg.y = 7;
			this.addChild(noCamMsg);

			var front_material:MovieMaterial     = new MovieMaterial(this, true);
			front_material.doubleSided           = true;
			var front_plane:Plane = new Plane(front_material, 1000, 400, 2, 2);
			front_plane.scale                    = 0.2;
			front_plane.x                        = 1;
			front_plane.y                        = -120;
			this._universe.addChild(front_plane);
			
			if(objName != null){
				this._universe.name = objName
				}else{
					this._universe.name = "universe"
					}
					this._universe.rotationY = 0;
					this._universe.rotationZ = -90;

				}
				public function get object():DisplayObject3D{
					return this._universe;
				}
		}
	}