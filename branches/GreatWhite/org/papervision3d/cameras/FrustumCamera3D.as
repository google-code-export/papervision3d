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
	
	import org.papervision3d.core.culling.IObjectCuller;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * @author Tim Knip 
	 */
	public class FrustumCamera3D extends CameraObject3D implements IObjectCuller
	{
		
		public static const TYPE:String = "FRUSTRUMCAMERA3D";
		/** constant used to set projection type. @see #projection */
		public static const PERSPECTIVE_PROJECTION:uint = 0;
		
		/** constant used to set projection type. @see #projection */
		public static const ORTHO_PROJECTION:uint = 1;
		
		public static const INSIDE:int = 1;
		public static const OUTSIDE:int = -1;
		public static const INTERSECT:int = 0;
		
		public static const NEAR:uint 	= 0;
		public static const LEFT:uint 	= 1;
		public static const RIGHT:uint 	= 2;
		public static const TOP:uint 	= 3;
		public static const BOTTOM:uint = 4;		
		public static const FAR:uint 	= 5;
	
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
	
		/** Gets or sets the projection type */
		public function get projection():uint { return _projectionType; }
		public function set projection( type:uint ):void
		{
			_projectionType = type;
			init();
		}
				
		/** frustum planes */
		public var planes:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param	fov	Field of view in degrees.
		 * @param	near	Distance to near plane.
		 * @param	far		Distance to far plane.
		 * @param	viewport	Viewport to render to. @see flash.geom.Rectangle.
		 * @return
		 */
		public function FrustumCamera3D(viewport3D:Viewport3D, fov:Number = 90, near:Number = 10, far:Number = 2000):void
		{			
			super();
			
			_fov = fov;
			_near = near;
			_far = far;
			
			this.viewport3D = viewport3D;
			
			init();
		}
		
		/**
		 * [internal-use] Transforms world coordinates into camera space.
		 */
		override public function transformView( trans:Matrix3D=null ):void
		{
			super.transformView();
			
			this.eye.calculateMultiply4x4(_projection, this.eye);
	
			extractPlanes(this.eye);
		}
		
		/**
		 * Checks whether a sphere is inside, outside or intersecting the frustum.
		 * 
		 * @param	center	center of sphere
		 * @param	radius 	radius of sphere
		 * 
		 * @return
		 */
		public function sphereInFrustum( center:Vertex3D, radius:Number ):int
		{
			var result:int = INSIDE;
			
			for( var i:int = 0; i < planes.length; i++ )
			{
				var distance:Number = planes[i].distance(center);
				if (distance < -radius) // early out!
					return OUTSIDE;
				else if (distance < radius)
					result = INTERSECT;
			}
			return result;
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
		
			var radius:Number = obj.geometry.boundingSphere2;
			
			_objpos.x = obj.world.n14;
			_objpos.y = obj.world.n24;
			_objpos.z = obj.world.n34;
				
			return sphereInFrustum(_objpos, radius * radius);
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
		 * Initializes the camera with current values.
		 * 
		 * @return
		 */
		private function init():void
		{			
			_objpos = new Vertex3D();
			
			_rotation = Quaternion.createFromMatrix(Matrix3D.IDENTITY);
			
			_viewport = this.viewport;
			
			_aspect = _viewport.width / _viewport.height;
			
			// setup projection
			if( _projectionType == PERSPECTIVE_PROJECTION )
			{
				_projection = createPerspectiveMatrix(_fov, _aspect, _near, _far);
			}
			else
			{
				var w:Number = _viewport.width / 2;
				var h:Number = _viewport.height / 2;
				
				_projection = createOrthoMatrix(-w, w, -h, h, -_far, _far);
			}
			
			// setup frustum planes
			this.planes = new Array(6);
			for( var i:int = 0; i < 6; i++ )
				this.planes[i] = new Plane3D();
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
	
		/** projection matrix */
		public var _projection:Matrix3D;
		
		/** field of view */
		private var _fov:Number = 50;
		
		/** distance to near plane */
		private var _near:Number = 10;
		
		/** distance to far plane */
		private var _far:Number = 1000;
	
		/** */
		private var _projectionType:uint = 0;
				
		/** viewport */
		private var _viewport:Rectangle;
		
		/** aspect ratio */
		private var _aspect:Number;
		
		/** ortho projection? */
		private var _ortho:Boolean = false;
		
		/** rotation */
		private var _rotation:Quaternion;
		
		/** target */
		private var _target:Vertex3D;
		
		/** */
		private var _objpos:Vertex3D;
		
		/** */
		private var _viewport3D:Viewport3D;
		
		public function set viewport3D(viewport3D:Viewport3D):void
		{
			_viewport3D = viewport3D;
			viewport = viewport3D.sizeRectangle;
		}
		
		public function get viewport3D():Viewport3D
		{
			return _viewport3D;
		}
	}
}
