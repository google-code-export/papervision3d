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

// _______________________________________________________________________ FRUSTUMCAMERA3D

package org.papervision3d.cameras
{
import flash.geom.Rectangle;
import org.papervision3d.core.Matrix3D;
import org.papervision3d.core.Number3D;
import org.papervision3d.core.Plane3D;
import org.papervision3d.core.culling.IObjectCuller;
import org.papervision3d.core.geom.Vertex3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.core.proto.GeometryObject3D;
import org.papervision3d.objects.DisplayObject3D;

/**
* The FrustumCamera3D class creates a camera that uses a frustum to cull any object outside the frustum.
* <p/>
* A camera defines the view from which a scene will be rendered. Different camera settings would present a scene from different points of view.
* <p/>
* 3D cameras simulate still-image, motion picture, or video cameras of the real world. When rendering, the scene is drawn as if you were looking through the camera lens.
*/
public class FrustumCamera3D extends CameraObject3D implements IObjectCuller
{
	public static var DEFAULT_VIEWPORT:Rectangle = new Rectangle(0, 0, 800, 600);
	
	public static const INSIDE:int = 1;
	public static const OUTSIDE:int = -1;
	public static const INTERSECT:int = 0;
	
	public static const TOP:uint = 0;
	public static const BOTTOM:uint = 1;
	public static const LEFT:uint = 2;
	public static const RIGHT:uint = 3;
	public static const NEAR:uint = 4;
	public static const FAR:uint = 5;
		
	public static const NTL:uint = 0;
	public static const NTR:uint = 1;
	public static const NBL:uint = 2;
	public static const NBR:uint = 3;
	public static const FTL:uint = 4;
	public static const FTR:uint = 5;
	public static const FBL:uint = 6;
	public static const FBR:uint = 7;
	public static const FC:uint = 8;
	
	/**
	 * Holds the six planes of the camera frustum.
	 */
	public var planes:Array;
	
	/**
	 * Holds the vertices of the camera frustum.
	 */
	public var vertices:Array;
	
	/**
	 * Gets or sets the distance to the far plane.
	 * 
	 * @return
	 */
	public function get far():Number { return _far; }
	public function set far( distance:Number ):void
	{
		distance = distance > _near ? distance : _near + 1;
		init(_fov, _near, distance, _viewport);
	}
	
	/**
	 * Gets or sets the camera's field of view.
	 * 
	 * @return
	 */
	public function get fov():Number { return _fov; }
	public function set fov( degrees:Number ):void
	{
		degrees = degrees > 0 ? degrees : 0; 
		init(degrees, _near, _far, _viewport);
	}
	
	/**
	 * Gets or sets the distance to the near plane.
	 * 
	 * @return
	 */
	public function get near():Number { return _near; }
	public function set near( distance:Number ):void
	{
		distance = distance >= 0 ? distance : 0; 
		init(_fov, distance, _far, _viewport);
	}
	
	/**
	 * Gets or sets the camera's viewport.
	 * 
	 * @return
	 */
	public function get viewport():Rectangle { return _viewport; }
	public function set viewport( vp:Rectangle ):void
	{
		init(_fov, _near, _far, vp);
	}
	
	// ___________________________________________________________________ NEW

	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* The FrustumCamera3D constructor lets you create a camera that culls all objects outside the camera's frustum.
	*
	* Its initial position can be specified in the initObject.
	*
	* @param	fov		This value specifies the field of view (FOV).
	* <p/>
	* @param	near	This value is a positive number representing the distance to the near plane.
	* <p/>
	* @param	far		This value is a positive number representing the distance to the far plane.
	* <p/>
	* @param	viewport	This value is a Rectangle representing the camera's viewport.
	* <p/>
	* @param	initObject	An optional object that contains user defined properties with which to populate the newly created DisplayObject3D.
	* <p/>
	* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
	* <p/>
	* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	* <p/>
	* The following initObject property is also recognized by the constructor:
	* <ul>
	* <li><b>sort</b>: A Boolean value that determines whether the 3D objects are z-depth sorted between themselves when rendering. The default value is true.</li>
	* </ul>
	*/
	public function FrustumCamera3D( fov:Number = 60, near:Number = 10, far:Number = 2000, viewport:Rectangle = null, initObject:Object=null )
	{
		super( 3, 10, initObject );
		
		_objpos = new Vertex3D();
		
		init(fov, near, far, viewport);		
	}

	/**
	 * implementation of IObjectCuller#testObject.
	 * 
	 * @param	obj
	 * @return
	 */
	public function testObject( obj:DisplayObject3D ):int
	{				
		var radius:Number = obj.geometry.boundingSphere2;
		
		_objpos.x = obj.x;
		_objpos.y = obj.y;
		_objpos.z = obj.z;
			
		return sphereInFrustum(_objpos, radius);
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
	* [internal-use] Transforms world coordinates into camera space.
	*/
	// TODO OPTIMIZE (LOW)
	public override function transformView( trans:Matrix3D=null ):void
	{
		super.transformView();
		
		// add perspective matrix
		this.view.calculateMultiply4x4(_matP, this.view);

		// update planes of frustum
		var vertices:Array = this.vertices;
			
		// TODO: hmmm... use geometry.vertices? i hate cloning.
		var ntl:Number3D = vertices[NTL].clone();
		var ntr:Number3D = vertices[NTR].clone();
		var nbl:Number3D = vertices[NBL].clone();
		var nbr:Number3D = vertices[NBR].clone();
		var ftl:Number3D = vertices[FTL].clone();
		var ftr:Number3D = vertices[FTR].clone();
		var fbl:Number3D = vertices[FBL].clone();
		var fbr:Number3D = vertices[FBR].clone();

		// transform frustum verts
		Matrix3D.multiplyVector(transform, ntl);
		Matrix3D.multiplyVector(transform, ntr);
		Matrix3D.multiplyVector(transform, nbl);
		Matrix3D.multiplyVector(transform, nbr);
		Matrix3D.multiplyVector(transform, ftl);
		Matrix3D.multiplyVector(transform, ftr);
		Matrix3D.multiplyVector(transform, fbl);
		Matrix3D.multiplyVector(transform, fbr);
		
		// update planes
		planes[TOP].setThreePoints(ntr,ntl,ftl);
		planes[BOTTOM].setThreePoints(nbl,nbr,fbr);
		planes[LEFT].setThreePoints(ntl,nbl,fbl);
		planes[RIGHT].setThreePoints(nbr,ntr,fbr);
		planes[NEAR].setThreePoints(ntl,ntr,nbr);
		planes[FAR].setThreePoints(ftr,ftl,fbl);
	}
	
	/**
	 *
	 * @param	fov
	 * @param	near
	 * @param	far
	 * @param	viewport
	 */
	public function init(fov:Number = 60, near:Number = 10, far:Number = 2000, viewport:Rectangle = null):void
	{
		var i:int;
		
		_fov = fov;
		_near = near;
		_far = far;
		_viewport = viewport || new Rectangle(0, 0, 800, 600);
		_aspect = _viewport.width / _viewport.height;
		
		// setup perspective matrix
		_matP = perspectiveMatrix(_fov, _aspect, _near, _far);
		
		planes = new Array(6);
		for( i = 0; i < 6; i++ )
			planes[i] = new Plane3D();
			
		this.vertices = new Array();
		for( i = 0; i < 10; i++ )
			this.vertices.push(new Number3D());
		
		// compute width and height of the near and far plane sections
		var tang:Number = Math.tan((Math.PI/180.0) * _fov * 0.5) ;
		
		_nh = _near * tang;
		_nw = _nh * _aspect; 
		_fh = _far  * tang;
		_fw = _fh * _aspect;
		
		_vx = new Number3D(1,0,0);
		_vy = new Number3D(0,1,0);
		_vz = new Number3D(0,0,1);
		
		_nc = new Number3D();
		_fc = new Number3D();
		
		_nc.x = _vz.x * _near;
		_nc.y = _vz.y * _near;
		_nc.z = _vz.z * _near;
		
		_fc.x = _vz.x * _far;
		_fc.y = _vz.y * _far;
		_fc.z = _vz.z * _far;
		
		var Xnw:Number3D = scaledNumber3D(_vx, _nw);
		var Ynh:Number3D = scaledNumber3D(_vy, _nh);
		var Xfw:Number3D = scaledNumber3D(_vx, _fw);
		var Yfh:Number3D = scaledNumber3D(_vy, _fh);
		
		// compute the 4 corners of the frustum on the near plane
		vertices[NTL].x = _nc.x + Ynh.x - Xnw.x;
		vertices[NTL].y = _nc.y + Ynh.y - Xnw.y;
		vertices[NTL].z = _nc.z + Ynh.z - Xnw.z;
		
		vertices[NTR].x = _nc.x + Ynh.x + Xnw.x;
		vertices[NTR].y = _nc.y + Ynh.y + Xnw.y;
		vertices[NTR].z = _nc.z + Ynh.z + Xnw.z;
		
		vertices[NBL].x = _nc.x - Ynh.x - Xnw.x;
		vertices[NBL].y = _nc.y - Ynh.y - Xnw.y;
		vertices[NBL].z = _nc.z - Ynh.z - Xnw.z;
		
		vertices[NBR].x = _nc.x - Ynh.x + Xnw.x;
		vertices[NBR].y = _nc.y - Ynh.y + Xnw.y;
		vertices[NBR].z = _nc.z - Ynh.z + Xnw.z;
		
		// compute the 4 corners of the frustum on the far plane
		vertices[FTL].x = _fc.x + Yfh.x - Xfw.x;
		vertices[FTL].y = _fc.y + Yfh.y - Xfw.y;
		vertices[FTL].z = _fc.z + Yfh.z - Xfw.z;
		
		vertices[FTR].x = _fc.x + Yfh.x + Xfw.x;
		vertices[FTR].y = _fc.y + Yfh.y + Xfw.y;
		vertices[FTR].z = _fc.z + Yfh.z + Xfw.z;
		
		vertices[FBL].x = _fc.x - Yfh.x - Xfw.x;
		vertices[FBL].y = _fc.y - Yfh.y - Xfw.y;
		vertices[FBL].z = _fc.z - Yfh.z - Xfw.z;
		
		vertices[FBR].x = _fc.x - Yfh.x + Xfw.x;
		vertices[FBR].y = _fc.y - Yfh.y + Xfw.y;
		vertices[FBR].z = _fc.z - Yfh.z + Xfw.z;
	}
	
	/**
	 * 
	 * @param	fov
	 * @param	aspect
	 * @param	near
	 * @param	far
	 * @return
	 */
	private function perspectiveMatrix( fov:Number, aspect:Number, near:Number, far:Number ):Matrix3D
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
	 * 
	 * @param	num
	 * @param	scale
	 * @return
	 */
	private function scaledNumber3D( num:Number3D, scale:Number ):Number3D
	{
		var n:Number3D = num.clone();
		n.x *= scale;
		n.y *= scale;
		n.z *= scale;
		return n;
	}
			
	private var _viewport:Rectangle;
	private var _fov:Number;
	private var _near:Number;
	private var _far:Number;
	private var _aspect:Number;
	
	private var _matP:Matrix3D;
	
	private var _nc:Number3D;
	private var _fc:Number3D;
	
	private var _vx:Number3D;
	private var _vy:Number3D;
	private var _vz:Number3D;
	
	private var _fw:Number;
	private var _fh:Number;
	private var _nw:Number;
	private var _nh:Number;	
	
	private var _objpos:Vertex3D;
}
}