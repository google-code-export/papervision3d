/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org ? blog.papervision3d.org ? osflash.org/papervision3d
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

// ______________________________________________________________________
//                                                               Plane3D

package org.papervision3d.core.math
{
import org.papervision3d.core.geom.renderables.Vertex3D;

/**
* The Plane3D class represents a plane in 3D space.
*
*/
public class Plane3D
{
	/**
	* The plane normal (A, B, C).
	*/
	public var normal: Number3D;

	/**
	* D.
	*/
	public var d: Number;


	/**
	* Creates a new Plane3D object.
	*/
	public function Plane3D()
	{
		this.normal = new Number3D();
		this.d = 0;
	}
	
	public static function fromThreePoints( n0:*, n1:*, n2:* ):Plane3D
	{
		var plane:Plane3D = new Plane3D();
		plane.setThreePoints(new Number3D(n0.x,n0.y,n0.z), new Number3D(n1.x,n1.y,n1.z), new Number3D(n2.x,n2.y,n2.z));
		return plane;
	}
	
	/**
	 * distance of point to plane.
	 * 
	 * @param	v
	 * @return
	 */
	public function distance( pt:* ):Number
	{
		var p:Number3D = pt is Vertex3D ? pt.toNumber3D() : pt;
		return Number3D.dot(p, normal) + d;
	}
	
	/**
	 * normalize.
	 * 
	 * @return
	 */
	public function normalize():void
	{
		var n:Number3D = this.normal;
		
		//compute the length of the vector
		var len:Number = Math.sqrt(n.x*n.x + n.y*n.y + n.z*n.z);
		
		// normalize
		n.x /= len;
		n.y /= len;
		n.z /= len;
		this.d /= len;
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 * @param	d
	 * @return
	 */
	public function setCoefficients( a:Number, b:Number, c:Number, d:Number ):void
	{
		// set the normal vector
		this.normal.x = a;
		this.normal.y = b;
		this.normal.z = c;
		this.d = d;
		
		normalize();
	}
	
	/**
	 * 
	 * @param	normal
	 * @param	pt
	 * @return
	 */
	public function setNormalAndPoint( normal:Number3D, pt:Number3D ):void
	{
		this.normal = normal;
		this.d = -Number3D.dot(normal, pt);
	}
	
	/**
	 * 
	 * @param	n0
	 * @param	n1
	 * @param	n2
	 */
	public function setThreePoints( n0:Number3D, n1:Number3D, n2:Number3D ):void
	{				
		var ab:Number3D = Number3D.sub(n1, n0);
		var ac:Number3D = Number3D.sub(n2, n0);
			
		this.normal = Number3D.cross(ab, ac);
		this.normal.normalize();
		this.d = -Number3D.dot(normal, n0);
	}
	
	public function toString():String
	{
		return "[a:" + normal.x  +" b:" +normal.y + " c:" +normal.z + " d:" + d + "]";
	}
}
}