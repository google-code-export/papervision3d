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
	// import papervision
	import org.ascollada.core.DaeBlendWeight;
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.AnimatedMesh3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.Sphere;

	/**
	 * <p>The Node3D class is used by the DAE class, and represents a node in a collada file.
	 * </p>
	 * @author Tim Knip
	 */	
	public class Node3D extends AnimatedMesh3D 
	{	
		/** */
		public static var DEBUG_SPHERE_COLOR:uint = 0xffff00;
		
		/** */
		public static var DEBUG_SPHERE_RADIUS:Number = 100;
		
		/** the collada ID. */
		public var daeID:String;
		
		/** the collada SID. */
		public var daeSID:String;
		
		/** array of blendvertices */
		public var blendVerts:Array;
		
		/** bindmatrix */
		public var bindMatrix:Matrix3D;
		
		/** */
		public var matrixStack:Array;
		
		/** */
		public var transforms:Array;
		
		/**
		 * Constructor.
		 *
		 * @param	daeName		The collada / DisplayObject3D name.
		 * @param	daeID		The collada ID for this node.
		 * @param	daeSID		The collada SID for this node.
		 * @param	showSphere	A boolean value indication whether to show a sphere to help debugging.
		 * @return
		 */
		public function Node3D( daeName:String, daeID:String, daeSID:String = null, showSphere:Boolean = false ):void 
		{
			super(new WireframeMaterial(), new Array(), new Array(), daeName);
			
			this.daeID = daeID;
			this.daeSID = daeSID || daeID;
			this.transform = Matrix3D.IDENTITY;
			this.world = Matrix3D.IDENTITY;
			this.bindMatrix = Matrix3D.IDENTITY;
			this.blendVerts = new Array();
			
			this.matrixStack = new Array();
			this.transforms = new Array();

			if( showSphere )
			{
				addChild( new Sphere(new WireframeMaterial(DEBUG_SPHERE_COLOR), DEBUG_SPHERE_RADIUS, 4, 3) );
			}
		}
		
		/**
		 * Clone.
		 */ 
		public override function clone():DisplayObject3D
		{
			var node:Node3D = new Node3D(this.name, this.daeID, this.daeSID);
			node.transform = Matrix3D.clone(this.transform);
			node.bindMatrix = Matrix3D.clone(this.bindMatrix);
			
			for(var i:int = 0; i < this.blendVerts.length; i++ )
			{
				var bw:DaeBlendWeight = new DaeBlendWeight();
				bw.weight = blendVerts[i].weight;
				bw.vertexIndex = blendVerts[i].vertexIndex;
				node.blendVerts.push(bw);
			}
			
			return node;
		}
		
	}
}
