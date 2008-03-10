/*
 * PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 * AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 * PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 * ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 * RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 * ______________________________________________________________________
 * papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 *
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
 
package org.papervision3d.objects.parsers.ascollada
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;

	/**
	 * @author Tim Knip 
	 */
	public class Skin3D extends AnimatedMesh3D
	{
		public var bindPose:Matrix3D;
		
		public var joints:Array;
		
		public var skeletons:Array;
		
		/** 
		 *
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @return
		 */
		public function Skin3D(material:MaterialObject3D, vertices:Array, faces:Array, name:String = null, yUp:Boolean = true):void
		{
			super(material, vertices, faces, name);
			
			this.bindPose = Matrix3D.IDENTITY;
			this.joints = new Array();
		}
		
		/**
		 * 
		 */ 
		public function clone() : Skin3D
		{
			var skin : Skin3D = new Skin3D(this.material, [], [], this.name);
				
			skin.bindPose = Matrix3D.clone(this.bindPose);
			
			var vs:Dictionary = new Dictionary();
			for each(var v:Vertex3D in this.geometry.vertices)
			{
				vs[ v ] = v.clone();
				skin.geometry.vertices.push(vs[v]);
			}
			
			for each(var f:Triangle3D in this.geometry.faces)
			{
				var v0:Vertex3D = vs[ f.v0 ];
				var v1:Vertex3D = vs[ f.v1 ];
				var v2:Vertex3D = vs[ f.v2 ];
				
				var t0:NumberUV = f.uv0.clone();
				var t1:NumberUV = f.uv1.clone();
				var t2:NumberUV = f.uv2.clone();
				
				var tri:Triangle3D = new Triangle3D(skin, [v0, v1, v2], f.material, [t0, t1, t2]);
				
				skin.geometry.faces.push(tri);
			}
			
			skin.geometry.ready = true;
			
			return skin;
		}
	}
}