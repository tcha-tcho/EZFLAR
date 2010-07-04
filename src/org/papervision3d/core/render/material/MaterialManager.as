package org.papervision3d.core.render.material
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class MaterialManager
	{
		private static var instance:MaterialManager;
		private var materials:Dictionary;
	
		
		public function MaterialManager():void
		{
			if(instance){
				throw new Error("Only 1 instance of materialmanager allowed");
			}
			init();
		}
		
		private function init():void
		{
			materials = new Dictionary(true);
		}
		
		private function _registerMaterial(material:MaterialObject3D):void
		{
			materials[material] = material;
		
		}
		
		private function _unRegisterMaterial(material:MaterialObject3D):void
		{
			delete materials[material];
		}
		
		public function updateMaterialsBeforeRender(renderSessionData:RenderSessionData):void
		{
			var um:IUpdateBeforeMaterial;
			var m:MaterialObject3D;
			for each(m in materials){
				if(m is IUpdateBeforeMaterial){
					um = m as IUpdateBeforeMaterial;
					um.updateBeforeRender(renderSessionData);
				}
			}
		}
		
		public function updateMaterialsAfterRender(renderSessionData:RenderSessionData):void
		{
			var um:IUpdateAfterMaterial;
			var m:MaterialObject3D;
			for each(m in materials){
				if(m is IUpdateAfterMaterial){
					um = m as IUpdateAfterMaterial;
					um.updateAfterRender(renderSessionData);
				}
			}
		}
		
		public static function registerMaterial(material:MaterialObject3D):void
		{
			getInstance()._registerMaterial(material);
		}
		
		public static function unRegisterMaterial(material:MaterialObject3D):void
		{
			getInstance()._unRegisterMaterial(material);
		}
		
		public static function getInstance():MaterialManager
		{
			if(!instance){
				instance = new MaterialManager;
			}
			return instance;
		}
		
	}
}