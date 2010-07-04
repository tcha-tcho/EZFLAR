package org.papervision3d.core.components.as3.collections
{
	/**
	 * MaterialsListItem is used by the component to provided settings for materials to be used in a collada scene.  The 3 Material types it supports are "File", "Bitmap" and "MovieClip".
	 * </p>
	 * <p>When setting a material to "File", the external bitmap will be loaded at Design-time.</p>
	 * <p>When setting a meterial to "MovieClip" or "Bitmap", a ColorMaterial (green) will be used to represent the material at design-time.  At run-time, you should see your material used on the models.</p>
	 * <p>One feature of the MaterialsListItem is that you can set the properties for a Bitmap or MovieClip and still setup up a temporary File location for Designtime.
	 * <ol>
	 * <li>Create a new texture by hitting the "+" sign after you bring up the dialog.</li>
	 * <li>Define your properties for the Material</li>
	 * <li>Include not only the LinkageID, but a file location as well.  The file location would point to a bitmap for designtime adjustments and rendering.</li>
	 * <li>When you're ready to compile, change the materialType back to it's intended type ("Bitmap" or "MovieClip").</li>
	 * </ol>
	 * </p>
	 * <p>
	 * This allows you to keep all of your settings while allowing a stand-in bitmap to be loaded at designtime.
	 * </p>
	 */	
	public class MaterialsListItem
	{
		[Inspectable (name="materialName", type="String")]
		/**
		 * The name given to a texture after importing into a 3D application (IE: 3D Studio Max, Maya, Blender).  
		 * The Collada object will use this as reference as to which material to use for texturing the objects that have been assigned the same material.
		 */		
		public var materialName				:String = "";
		
		[Inspectable (name="materialLocation", type="String")]
		/**
		 * If an external file is being used, this is the relative or absolute URL of the file
		 */		
		public var materialLocation		:String = "";
		
		[Inspectable (name="materialType", defaultValue="Bitmap", type="String")]
		//[Inspectable (name="materialType", defaultValue="Bitmap", enumeration="Bitmap, File, MovieClip", type="list")]
		/**
		 * There are 3 types of materials that can be used with this component:
		 * </p>
		 * <p>
		 * <ul>
		 * <li>BitmapAssetMaterial: BitmapAssetMaterial - a bitmap defined in the library</li>
		 * <li>BitmapFileMaterial: BitmapFileMaterial - an external bitmap file</li>
		 * <li>MovieMaterial: MovieMaterial - an external bitmap file</li>
		 * <li>MovieAssetMaterial: MovieAssetMaterial - a MovieClip defined in the library</li>
		 * </ul>
		 * </p>
		 */
		public var materialType				:String = "BitmapAssetMaterial";
		
		[Inspectable (name="animated", defaultValue=false, type="Boolean")]
		/**
		* Boolean flag indicating whether or not the material should be redrawn in the render loop
		*/		
		public var animated					:Boolean = true;
		
		[Inspectable (name="singleSided", defaultValue=true, type="Boolean")]
		/**
		* Boolean flag indicating whether or not the material should be drawn on both sides
		*/		
		public var singleSided				:Boolean = true;
		
		[Inspectable (name="transparent", defaultValue=true, type="Boolean")]
		/**
		* If set to true, preserves the alpha information of the Material being used
		*/		
		public var transparent				:Boolean = true;
		
		[Inspectable (name="interactive", defaultValue=false, type="Boolean")]
		/**
		* Boolean flag indicating whether or not the material is Interactive.  If set to true, the DisplayObject3D this material
		 * is assigned to will dispatch mouse events.
		*/	
		public var interactive				:Boolean = false;
		
		[Inspectable (name="precision", defaultValue=1, type="Number")]
		/**
		* If you're using a precision material, this is the setting for how precise you want it to be.  A setting of one is pretty accurate.
		*/	
		public var precision				:Number = 1;
		
		[Inspectable (name="minimumRenderSize", defaultValue=2, type="Number")]
		/**
		* If you're using a precision material, this is the setting for how small your triangles can be before the recursion loop will draw the face
		*/	
		public var minimumRenderSize		:Number = 2;
		
		[Inspectable (name="precisionMaterial", defaultValue=false, type="Boolean")]
		/**
		* Boolean flag indicating whether or not the material is Interactive.  If set to true, the DisplayObject3D this material
		 * is assigned to will dispatch mouse events.
		*/	
		public var precisionMaterial		:Boolean = false;
		
		/**
		 * whether or not to apply smoothing to the bitmap fill on the triangles of this material
		 */
		[Inspectable (name="smooth", defaultValue=false, type="Boolean")]
		public var smooth					:Boolean = false;
	}
}