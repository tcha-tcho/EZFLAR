/**
 * @Author tcha-tcho
 */
package com.tchatcho.constructors {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Shape;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	public class LoadingEZFLAR extends MovieClip {
		private var _universe:DisplayObject3D = new DisplayObject3D();


		public function LoadingEZFLAR() {
			var child:Shape = new Shape();
			child.graphics.beginFill(0xCCCCCC);
			child.graphics.lineStyle(2, 0xFFFFFF);
			child.graphics.drawRoundRect(0, 0, 100, 50, 20);
			child.graphics.endFill();
			this.addChild(child);

			var noCamMsg:TextField               = new TextField();
			noCamMsg.text                        = "LOADING\n...";			
			var format:TextFormat                = new TextFormat();
			format.size                          = 19;
			format.align                         = "center";
			noCamMsg.setTextFormat(format);
			noCamMsg.x = 1;
			noCamMsg.y = 7;
			this.addChild(noCamMsg);

			var front_material:MovieMaterial     = new MovieMaterial(this, true);
			front_material.doubleSided           = true;
			var front_plane:Plane = new Plane(front_material, 400, 400, 2, 2);
			front_plane.scale                    = 0.2;
			front_plane.x                        = 1;
			this._universe.addChild(front_plane);
		}
		public function get ldrObject():DisplayObject3D{
			return this._universe;
		}
	}
}