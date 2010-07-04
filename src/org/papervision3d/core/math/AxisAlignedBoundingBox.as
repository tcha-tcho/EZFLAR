package org.papervision3d.core.math
{
	import org.papervision3d.core.geom.renderables.Vertex3D;
	
	public class AxisAlignedBoundingBox
	{
		public var minX:Number;
		public var minY:Number;
		public var minZ:Number;
		public var maxX:Number;
		public var maxY:Number;
		public var maxZ:Number;
		
		protected var _vertices:Array;
		
		/**
		 * @Author Ralph Hauwert
		 */
		public function AxisAlignedBoundingBox(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number)
		{
			this.minX = minX;
			this.minY = minY;
			this.minZ = minZ;
			this.maxX = maxX;
			this.maxY = maxY;
			this.maxZ = maxZ;
			createBoxVertices();
		}
		
		protected function createBoxVertices():void
		{
			_vertices = new Array();
			_vertices.push(new Vertex3D(minX, minY, minZ));
			_vertices.push(new Vertex3D(minX, minY, maxZ));
			_vertices.push(new Vertex3D(minX, maxY, minZ));
			_vertices.push(new Vertex3D(minX, maxY, maxZ));
			_vertices.push(new Vertex3D(maxX, minY, minZ));
			_vertices.push(new Vertex3D(maxX, minY, maxZ));
			_vertices.push(new Vertex3D(maxX, maxY, minZ));
			_vertices.push(new Vertex3D(maxX, maxY, maxZ));
		}
		
		public function getBoxVertices():Array
		{
			return _vertices;
		}
		
		public static function createFromVertices(vertices:Array):AxisAlignedBoundingBox
		{
			var minX:Number = 0;
			var maxX:Number = 0;
			var minY:Number = 0;
			var maxY:Number = 0;
			var minZ:Number = 0;
			var maxZ:Number = 0;
			var v:Vertex3D;
			for each( v in vertices )
			{
				minX = (v.x < minX) ? v.x : minX;
				minY = (v.y < minY) ? v.y : minY;
				minZ = (v.z < minZ) ? v.z : minZ;
				maxX = (v.x > maxX) ? v.x : maxX;
				maxY = (v.y > maxY) ? v.y : maxY;
				maxZ = (v.z > maxZ) ? v.z : maxZ;
			}
			
			return new AxisAlignedBoundingBox(minX, minY, minZ, maxX, maxY, maxZ);
		}

	}
}