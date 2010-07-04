package org.papervision3d.materials.shadematerials
{
	import org.papervision3d.core.proto.LightObject3D;
	import org.papervision3d.materials.utils.LightMaps;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class PhongMaterial extends EnvMapMaterial
	{
		public function PhongMaterial(light3D:LightObject3D, lightColor:int, ambientColor:int, specular:int)
		{
			super(light3D, LightMaps.getPhongMap(lightColor, ambientColor, specular));
		}
		
	}
}