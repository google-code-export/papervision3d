/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org • blog.papervision3d.org • osflash.org/papervision3d
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
 
package org.papervision3d.core.culling 
{
	import org.papervision3d.core.geom.renderables.Vertex3D;
	
	/**
	 * Bounding Sphere.
	 * <p>The average of the vertices is the center of the sphere, 
	 * and the radius is the distance to the farthest vertex.</p>
	 * 
	 * @author Tim Knip 
	 */
	public class BoundingSphere 
	{
		/** origin of sphere */
		public var origin:Vertex3D;
		
		/** radius of sphere */
		public var radius:Number;
		
		/**
		 * constructor.
		 * 
		 * @param	vertices the vertices to create the bounding sphere from.
		 * @return
		 */
		public function BoundingSphere( vertices:Array = null ):void
		{
			update(vertices);
		}
		
		/**
		 * updates the bounding sphere.
		 * 
		 * @param	vertices the vertices to create the bounding sphere from.
		 * @return
		 */
		public function update( vertices:Array ):void
		{
			origin = new Vertex3D();
			radius = 0;
			
			if( !vertices || !vertices.length )
				return;
				
			var v:Vertex3D;
			
			// find origin of sphere
			for each( v in vertices )
			{
				origin.x += v.x;
				origin.y += v.y;
				origin.z += v.z;
			}
	
			origin.x /= vertices.length;
			origin.y /= vertices.length;
			origin.z /= vertices.length;
			
			var pt:Vertex3D = new Vertex3D();
			
			// find radius of sphere
			for each( v in vertices )
			{
				pt.x = v.x - origin.x;
				pt.y = v.y - origin.y;
				pt.z = v.z - origin.z;
				
				radius = Math.max(radius, Math.sqrt((pt.x*pt.x)+(pt.y*pt.y)+(pt.z*pt.z)));
			}
		}
		
		/**
		 * toString.
		 * 
		 * @return
		 */
		public function toString():String
		{
			return "[BoundingSphere x:" + origin.x + " y:" + origin.y + " z:" + origin.z + " radius:" + radius + "]";
		}
	}	
}
