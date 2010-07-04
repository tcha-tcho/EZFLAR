/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.papervision3d.cameras 
{
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.culling.FrustumTestMethod;
	import org.papervision3d.core.culling.IObjectCuller;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.math.util.ClassificationUtil;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * @author Tim Knip 
	 */
	public class FrustumCamera3D extends CameraObject3D implements IObjectCuller
	{
		
		public static const TYPE:String = "FRUSTRUMCAMERA3D";
		
		public static const INSIDE:int = 1;
		public static const OUTSIDE:int = -1;
		public static const INTERSECT:int = 0;
		
		public static const NEAR:uint 	= 0;
		public static const LEFT:uint 	= 1;
		public static const RIGHT:uint 	= 2;
		public static const TOP:uint 	= 3;
		public static const BOTTOM:uint = 4;		
		public static const FAR:uint 	= 5;
		
		/** projection matrix */
		public var _projection:Matrix3D;
		
		/** field of view */
		private var _fov:Number = 50;
		
		/** distance to near plane */
		private var _near:Number = 10;
		
		/** distance to far plane */
		private var _far:Number = 1000;
		
		/** viewport */
		private var _viewport:Rectangle;
		
		/** aspect ratio */
		private var _aspect:Number;
		
		/** ortho projection? */
		private var _ortho:Boolean = false;
		
		/** target */
		private var _target:DisplayObject3D;
		
		/** */
		private var _objpos:Vertex3D;
		
		/** */
		private var _orthoScale : Number = 0.1;
		
		/** */
		private var _orthoScaleMatrix : Matrix3D;
		
		/** */
		private var _viewport3D:Viewport3D;
		
		/** */
		private var _rightHanded:Boolean = false;
	
		/** frustum planes */
		public var planes:Array;
		
		/**
		 * FrustumCamera3D
		 *
		 * @param viewport	Viewport to render to. @see org.papervision3d.view.Viewport3D 
		 * @param fov		Field of view in degrees.
		 * @param near	Distance to near plane.
		 * @param far		Distance to far plane.
		 */
		public function FrustumCamera3D(viewport3D:Viewport3D, fov:Number = 90, near:Number = 10, far:Number = 1000):void
		{			
			super();
		
			_fov = fov;
			_near = near;
			_far = far;
			_target = DisplayObject3D.ZERO;
			
			this.viewport3D = viewport3D;
			
			init();
		}
		
		/**
		 * Initializes the camera with current values.
		 * 
		 * @return
		 */
		public function init():void
		{			
			_objpos = new Vertex3D();
			
			_viewport = this.viewport;

			_aspect = _viewport.width / _viewport.height;
			
			// setup projection
			if( _ortho )
			{
				var w:Number = _viewport.width / 2;
				var h:Number = _viewport.height / 2;
				
				_projection = createOrthoMatrix(-w, w, -h, h, -_far, _far);
				
				_orthoScaleMatrix = Matrix3D.scaleMatrix(_orthoScale, _orthoScale, _orthoScale);
				
				_projection = Matrix3D.multiply(_orthoScaleMatrix, _projection);
			}
			else
			{
				_projection = createPerspectiveMatrix(_fov, _aspect, _near, _far);
			}
			
			// setup frustum planes
			this.planes = new Array(6);
			for( var i:int = 0; i < 6; i++ )
				this.planes[i] = new Plane3D();
		}
		
		/**
		 * [internal-use] Transforms world coordinates into camera space.
		 */
		override public function transformView( transform:Matrix3D = null ):void
		{
			if(_rightHanded)
				this.eye = Matrix3D.inverse(transform || this.transform);
			else
				super.transformView(transform);
						
			this.eye.calculateMultiply4x4(_projection, this.eye);

			extractPlanes(this.eye);
		}

		/**
		 * Orbits the camera around a target.
		 * 
		 * @param target	The target to orbit around.
		 * @param pitch		Pitch (up/down).
		 * @param yaw		Yaw (left/right).
		 * @param distance	Distance to target.
		 */
		public function orbit( target:DisplayObject3D, pitch:Number, yaw:Number, distance:Number=1000 ) : void
		{				
			var x : Number = Math.cos(yaw) * Math.sin(pitch);
			var z : Number = Math.sin(yaw) * Math.sin(pitch);
			var y : Number = Math.cos(pitch);
			
			this.x = target.world.n14 + (x * distance);
			this.y = target.world.n24 + (y * distance);
			this.z = target.world.n34 + (z * distance);

			this.lookAt(target);
			
		}
		
		/**
		 * 
		 * @param	obj
		 * @return
		 */
		public function testObject( obj:DisplayObject3D ):int
		{	
			if(!obj.geometry || !obj.geometry.vertices || !obj.geometry.vertices.length)
				return INSIDE;		
			
			
			
			switch(obj.frustumTestMethod){
				case FrustumTestMethod.BOUNDING_SPHERE:
					return sphereInFrustum(obj, obj.geometry.boundingSphere);
				case FrustumTestMethod.BOUNDING_BOX:
					return aabbInFrustum(obj, obj.geometry.aabb);
				default:
					return sphereInFrustum(obj, obj.geometry.boundingSphere);
			}
			
			return INSIDE;
		}
			
		/**
		 * Checks whether a sphere is inside, outside or intersecting the frustum.
		 * 
		 * @param	center	center of sphere
		 * @param	radius 	radius of sphere
		 * 
		 * @return
		 */
		public function sphereInFrustum( object:DisplayObject3D, boundingSphere:BoundingSphere ):int
		{
			var center:Vertex3D = new Vertex3D(object.world.n14,object.world.n24,object.world.n34);
			var radius:Number = boundingSphere.radius;
			var result:int = INSIDE;
			for( var i:int = 0; i < planes.length; i++ )
			{
				var distance:Number = planes[i].distance(center);
				if (distance < -radius){
					return OUTSIDE;
				}else if (distance < radius){
					result = INTERSECT;
				}
			}
			
			return result;
		}
		
		
		/**
		 * Checks whether an axis aligned boundingbox is inside, outside or intersecting the frustum.
		 */
		public function aabbInFrustum(object:DisplayObject3D, aabb:AxisAlignedBoundingBox):int
		{
			var plane:Plane3D;
			var vertex:Vertex3D;
			var side:int;
			var perPlaneInside:int = 0;
			var totalInside:int = 0;
			var waabb:Array = new Array();
			var num:Number3D;
			
			var vertices:Array = aabb.getBoxVertices();
			
			/**
			 * Transform the boundingbox to world
			 */
			for each(vertex in vertices){
				num = vertex.getPosition();
				Matrix3D.multiplyVector4x4(object.world, num);
				waabb.push(num);
			}
			
			//Check all planes against all points.
			for( var i:int = 0; i < planes.length; i++ )
			{
				plane = planes[i];
				//Check the individual points
				perPlaneInside = 0;
				for(var p:int = 0; p < waabb.length; p++){
					num = waabb[p];
					side = plane.pointOnSide(num);
					if(side == ClassificationUtil.FRONT){
						perPlaneInside++;
					}
				}
		
				if(perPlaneInside <= 0){
					//It's completely outside of the plane...and thus the frustum
					return OUTSIDE;
				}else if(perPlaneInside >= 8){
					totalInside++;
					if(totalInside >= 6){
						//The object is completely inside the frustrum
						return INSIDE;
					}
				}
			}
			
			return INTERSECT;
		}
	
		
		
		/**
		 * Creates a transformation that produces a parallel projection.
		 * 
		 * @param	left
		 * @param	right
		 * @param	bottom
		 * @param	top
		 * @param	near
		 * @param	far
		 * @return
		 */
		public static function createOrthoMatrix( left:Number, right:Number, bottom:Number, top:Number, near:Number, far:Number):Matrix3D
		{
			var tx:Number = (right+left)/(right-left);
			var ty:Number = (top+bottom)/(top-bottom);
			var tz:Number = (far+near)/(far-near);
				
			var matrix:Matrix3D = new Matrix3D( [
				2/(right-left), 0, 0, tx,
				0, 2/(top-bottom), 0, ty,
				0, 0, -2/(far-near), tz,
				0, 0, 0, 1 
			] );
			
			matrix.calculateMultiply(Matrix3D.scaleMatrix(1,1,-1), matrix);
			
			return matrix;
		}
			
		/**
		 * Creates a transformation that produces a perspective projection.
		 * 
		 * @param	fov
		 * @param	aspect
		 * @param	near
		 * @param	far
		 * @return
		 */
		public static function createPerspectiveMatrix( fov:Number, aspect:Number, near:Number, far:Number ):Matrix3D
		{
			var fov2:Number = (fov/2) * (Math.PI/180);
			var tan:Number = Math.tan(fov2);
			var f:Number = 1 / tan;
			
			return new Matrix3D( [
				f/aspect, 0, 0, 0,
				0, f, 0, 0,
				0, 0, -((near+far)/(near-far)), (2*far*near)/(near-far),
				0, 0, 1, 0 
			] );
		}	
		
		
		
		/**
		 * Extract the frustum planes. 
		 * 
		 * @param	m
		 * @return
		 */
		public function extractPlanes( m:Matrix3D ):void
		{		
			var m11 :Number = m.n11,
				m12 :Number = m.n12,
				m13 :Number = m.n13,
				m14 :Number = m.n14,
				m21 :Number = m.n21,
				m22 :Number = m.n22,
				m23 :Number = m.n23,
				m24 :Number = m.n24,
				m31 :Number = m.n31,
				m32 :Number = m.n32,
				m33 :Number = m.n33,
				m34 :Number = m.n34,
				m41 :Number = m.n41,
				m42 :Number = m.n42,
				m43 :Number = m.n43,
				m44 :Number = m.n44;
				
			planes[NEAR].setCoefficients(   m31+m41,  m32+m42,  m33+m43,  m34+m44);
			planes[FAR].setCoefficients(   -m31+m41, -m32+m42, -m33+m43, -m34+m44);
			planes[BOTTOM].setCoefficients( m21+m41,  m22+m42,  m23+m43,  m24+m44);
			planes[TOP].setCoefficients(   -m21+m41, -m22+m42, -m23+m43, -m24+m44);
			planes[LEFT].setCoefficients(   m11+m41,  m12+m42,  m13+m43,  m14+m44);
			planes[RIGHT].setCoefficients( -m11+m41, -m12+m42, -m13+m43, -m14+m44);
		}
	
		/** Gets or sets the field of view in degrees. */
		public function get fov():Number { return _fov; }
		public function set fov( degrees:Number ):void
		{
			_fov = degrees;
			init();
		}
		
		/** Gets or sets the distance to far plane. */
		public function get far():Number { return _far; }
		public function set far( distance:Number ):void
		{
			_far = distance;
			init();
		}
		
		/** Gets or sets the distance to near plane (positive number). */
		public function get near():Number { return _near; }
		public function set near( distance:Number ):void
		{
			_near = Math.abs(distance);
			init();
		}
	
		/** Gets or sets ortho projection or not. */
		public function get ortho() : Boolean { return _ortho; }
		public function set ortho( value : Boolean ) : void
		{
			if(_ortho != value)
			{
				_ortho = value;
				init();
			}
		}

		/** Gets or sets the scale when in ortho mode. */
		public function get orthoScale() : Number { return _orthoScale; }
		public function set orthoScale( scale : Number ) : void
		{
			if(scale != _orthoScale && scale > 0)
			{
				_orthoScale = scale;
				init();
			}
		}
		
		/** Gets or sets the projection matrix */
		public function get projection() : Matrix3D { return _projection; }
		public function set projection( matrix : Matrix3D ) : void
		{
			_projection = matrix;
		}
		
		/** */
		public function get rightHanded():Boolean { return _rightHanded; }
		public function set rightHanded( right:Boolean ):void { _rightHanded = right; }
		
		/**
		 * Sets the viewport. @see org.papervision3d.view.Viewport3D
		 */
		public function set viewport3D(viewport3D:Viewport3D):void
		{
			if(viewport3D){
				viewport = viewport3D.sizeRectangle;
			}
			_viewport3D = viewport3D;
			
		}
		
		/**
		 * Gets the viewport. @see org.papervision3d.view.Viewport3D
		 */
		public function get viewport3D():Viewport3D
		{
			return _viewport3D;
		}
		
	}
}
