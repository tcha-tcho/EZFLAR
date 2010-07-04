package org.papervision3d.core.geom {
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.culling.ITriangleCuller;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Triangle3DInstance;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.core.render.command.RenderTriangle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	* The Mesh3D class lets you create and display solid 3D objects made of vertices and triangular polygons.
	*/
	public class TriangleMesh3D extends Vertices3D
	{
		// ___________________________________________________________________________________________________
		//                                                                                               N E W
		// NN  NN EEEEEE WW    WW
		// NNN NN EE     WW WW WW
		// NNNNNN EEEE   WWWWWWWW
		// NN NNN EE     WWW  WWW
		// NN  NN EEEEEE WW    WW
	
		/**
		* Creates a new Mesh object.
		*
		* The Mesh DisplayObject3D class lets you create and display solid 3D objects made of vertices and triangular polygons.
		* <p/>
		* @param	material	A MaterialObject3D object that contains the material properties of the object.
		* <p/>
		* @param	vertices	An array of Vertex3D objects for the vertices of the mesh.
		* <p/>
		* @param	faces		An array of Face3D objects for the faces of the mesh.
		* <p/>
		* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created DisplayObject3D.
		* <p/>
		* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
		* <p/>
		* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
		* <ul>
		* <li><b>sortFaces</b>: Z-depth sorting when rendering. Some objects might not need it. Default is false (faster).</li>
		* <li><b>showFaces</b>: Use only if each face is on a separate MovieClip container. Default is false.</li>
		* </ul>
		*
		*/
		public function TriangleMesh3D( material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null )
		{
			super( vertices, name, initObject );
			this.geometry.faces = faces || new Array();
			this.material       = material || MaterialObject3D.DEFAULT;
		}
	
		/**
		 * Clones this object.
		 * 
		 * @return	The cloned DisplayObject3D.
		 */ 
		public override function clone():DisplayObject3D
		{
			var object:DisplayObject3D = super.clone();
			var mesh:TriangleMesh3D = new TriangleMesh3D(this.material, [], [], object.name);
			
			if(this.materials)
				mesh.materials = this.materials.clone();
				
			if(object.geometry)
				mesh.geometry = object.geometry.clone(mesh);
				
			mesh.copyTransform(this.transform);
			
			return mesh;
		}
		
		// ___________________________________________________________________________________________________
		//                                                                                       P R O J E C T
		// PPPPP  RRRRR   OOOO      JJ EEEEEE  CCCC  TTTTTT
		// PP  PP RR  RR OO  OO     JJ EE     CC  CC   TT
		// PPPPP  RRRRR  OO  OO     JJ EEEE   CC       TT
		// PP     RR  RR OO  OO JJ  JJ EE     CC  CC   TT
		// PP     RR  RR  OOOO   JJJJ  EEEEEE  CCCC    TT
	
		/**
		* Projects three dimensional coordinates onto a two dimensional plane to simulate the relationship of the camera to subject.
		*
		* This is the first step in the process of representing three dimensional shapes two dimensionally.
		*
		* @param	camera	Camera3D object to render from.
		*/
		public override function project( parent :DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			// Vertices
			super.project(parent, renderSessionData);
			if(!this.culled){
				// Faces
				
				var faces:Array  = this.geometry.faces, 
									screenZs:Number = 0, 
									visibleFaces :Number = 0, 
									triCuller:ITriangleCuller = renderSessionData.triangleCuller, 
									vertex0:Vertex3DInstance, 
									vertex1:Vertex3DInstance, 
									vertex2:Vertex3DInstance, 
									iFace:Triangle3DInstance, 
									face:Triangle3D,
									mat:MaterialObject3D,
									rc:RenderTriangle;
				
				for each(face in faces){
					mat = face.material ? face.material : material;
					iFace = face.face3DInstance;
					vertex0 = face.v0.vertex3DInstance;
					vertex1 = face.v1.vertex3DInstance;
					vertex2 = face.v2.vertex3DInstance;
					if((iFace.visible = triCuller.testFace(face, vertex0, vertex1, vertex2))){
						switch(meshSort)
						{
							case DisplayObject3D.MESH_SORT_CENTER:
								screenZs += iFace.screenZ = (vertex0.z + vertex1.z + vertex2.z)/3;
								break;
							
							case DisplayObject3D.MESH_SORT_FAR:
								screenZs += iFace.screenZ = Math.max(vertex0.z,vertex1.z,vertex2.z);
								break;
								
							case DisplayObject3D.MESH_SORT_CLOSE:
								screenZs += iFace.screenZ = Math.min(vertex0.z,vertex1.z,vertex2.z);
								break;
						}
						rc = face.renderCommand;
						visibleFaces++;
						rc.renderer = mat as ITriangleDrawer;
						rc.screenDepth = iFace.screenZ;
						renderSessionData.renderer.addToRenderList(rc);
					}else{
						renderSessionData.renderStatistics.culledTriangles++;
					}
				}
				return this.screenZ = screenZs / visibleFaces;
			}else{
				return 0;
			}
		}
	
	
		/**
		* Planar projection from the specified plane.
		*
		* @param	u	The texture horizontal axis. Can be "x", "y" or "z". The default value is "x".
		* @param	v	The texture vertical axis. Can be "x", "y" or "z". The default value is "y".
		*/
		public function projectTexture( u:String="x", v:String="y" ):void
		{
			var faces	:Array  = this.geometry.faces, 
				bBox	:Object = this.boundingBox(), 
				minX	:Number = bBox.min[u], 
				sizeX 	:Number = bBox.size[u],
				minY  	:Number = bBox.min[v],
				sizeY 	:Number = bBox.size[v];
	
			var objectMaterial :MaterialObject3D = this.material;
	
			for( var i:String in faces )
			{
				var myFace     :Triangle3D = faces[Number(i)],
					myVertices :Array  = myFace.vertices,
					a :Vertex3D = myVertices[0],
					b :Vertex3D = myVertices[1],
					c :Vertex3D = myVertices[2],
					uvA :NumberUV = new NumberUV( (a[u] - minX) / sizeX, (a[v] - minY) / sizeY ),
					uvB :NumberUV = new NumberUV( (b[u] - minX) / sizeX, (b[v] - minY) / sizeY ),
					uvC :NumberUV = new NumberUV( (c[u] - minX) / sizeX, (c[v] - minY) / sizeY );
	
				myFace.uv = [ uvA, uvB, uvC ];
			}
		}
	
		/**
		 * Divides all faces into 4.
		 */
		public function quarterFaces():void
		{
			var newverts:Array = new Array();
			var newfaces:Array = new Array();
			var faces:Array = this.geometry.faces;
			var face:Triangle3D;
			var i:int = faces.length;
			
			while( face = faces[--i] )
			{
				var v0:Vertex3D = face.v0;
				var v1:Vertex3D = face.v1;
				var v2:Vertex3D = face.v2;
				
				var v01:Vertex3D = new Vertex3D((v0.x+v1.x)/2, (v0.y+v1.y)/2, (v0.z+v1.z)/2);
				var v12:Vertex3D = new Vertex3D((v1.x+v2.x)/2, (v1.y+v2.y)/2, (v1.z+v2.z)/2);
				var v20:Vertex3D = new Vertex3D((v2.x+v0.x)/2, (v2.y+v0.y)/2, (v2.z+v0.z)/2);
				
				this.geometry.vertices.push(v01, v12, v20);
				
				var t0:NumberUV = face.uv[0];
				var t1:NumberUV = face.uv[1];
				var t2:NumberUV = face.uv[2];
				
				var t01:NumberUV = new NumberUV((t0.u+t1.u)/2, (t0.v+t1.v)/2);
				var t12:NumberUV = new NumberUV((t1.u+t2.u)/2, (t1.v+t2.v)/2);
				var t20:NumberUV = new NumberUV((t2.u+t0.u)/2, (t2.v+t0.v)/2);
				
				var f0:Triangle3D = new Triangle3D(this, [v0, v01, v20], face.material, [t0, t01, t20]);
				var f1:Triangle3D = new Triangle3D(this, [v01, v1, v12], face.material, [t01, t1, t12]);
				var f2:Triangle3D = new Triangle3D(this, [v20, v12, v2], face.material, [t20, t12, t2]);
				var f3:Triangle3D = new Triangle3D(this, [v01, v12, v20], face.material, [t01, t12, t20]);
			
				newfaces.push(f0, f1, f2, f3);
			}
			
			this.geometry.faces = newfaces;
			this.mergeVertices();
			this.geometry.ready = true;
		}
		
		/**
		* Merges duplicated vertices.
		*/
		public function mergeVertices():void
		{
			var uniqueDic  :Dictionary = new Dictionary(),
				uniqueList :Array = new Array();
	
			// Find unique vertices
			for each( var v:Vertex3D in this.geometry.vertices )
			{
				for each( var vu:Vertex3D in uniqueDic )
				{
					if( v.x == vu.x && v.y == vu.y && v.z == vu.z )
					{
						uniqueDic[ v ] = vu;
						break;
					}
				}
				
				if( ! uniqueDic[ v ] )
				{
					uniqueDic[ v ] = v;
					uniqueList.push( v );
				}
			}
	
			// Use unique vertices list
			this.geometry.vertices = uniqueList;
	
			// Update faces
			for each( var f:Triangle3D in geometry.faces )
			{
				f.v0 = uniqueDic[ f.v0 ];
				f.v1 = uniqueDic[ f.v1 ];
				f.v2 = uniqueDic[ f.v2 ];
			}
		}
		
		override public function set material(material:MaterialObject3D):void
		{
			super.material = material;
			for each(var triangle:Triangle3D in geometry.faces){
				triangle.material = material;
			}
		}
	}
}