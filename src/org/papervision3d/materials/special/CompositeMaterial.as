package org.papervision3d.materials.special
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	import org.papervision3d.objects.DisplayObject3D;

	public class CompositeMaterial extends TriangleMaterial implements ITriangleDrawer
	{	
		public var materials:Array;
		
		public function CompositeMaterial()
		{
			init();
		}
		
		private function init():void
		{
			materials = new Array();
		}
		
		public function addMaterial(material:MaterialObject3D):void
		{
			materials.push(material);
			for each(var do3d:DisplayObject3D in objects){
				material.registerObject(do3d);
			}
		}
		
		public function removeMaterial(material:MaterialObject3D):void
		{
			materials.splice(materials.indexOf(material),1);
		}
		
		public function removeAllMaterials(material:MaterialObject3D):void
		{
			materials = new Array();
		}
		
		override public function registerObject(displayObject3D:DisplayObject3D):void
		{
			super.registerObject(displayObject3D);
			for each(var material:MaterialObject3D in materials){
				material.registerObject(displayObject3D);
			}
		}
		
		override public function unregisterObject(displayObject3D:DisplayObject3D):void
		{
			super.unregisterObject(displayObject3D);
			for each(var material:MaterialObject3D in materials){
				material.unregisterObject(displayObject3D);
			}
		}
		
		override public function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix = null):void
		{
			var num:int = 0;
			for each(var n:MaterialObject3D in materials){
				n.drawTriangle(face3D, graphics, renderSessionData);
			}
		}
		
	}
}