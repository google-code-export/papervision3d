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
 
package org.papervision3d.core.animation.controllers
{
	import org.papervision3d.core.*;
	import org.papervision3d.core.animation.core.KeyFrameController;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.parsers.ascollada.Node3D;
	import org.papervision3d.objects.parsers.ascollada.Skin3D;
	
	/**
	 * @author Tim Knip 
	 */
	public class SkinController extends KeyFrameController
	{
		public var skin:Skin3D;
		
		/**
		 * Constructor.
		 * 
		 * @param	skin
		 * @param	yUp
		 * @return
		 */
		public function SkinController( skin:Skin3D, yUp:Boolean = true ):void
		{
			super(skin.geometry);
			
			_yUp = yUp;
			
			this.skin = skin;
		}
		
		/**
		 * 
		 * @param	dt	current time in milliseconds
		 * @return
		 */
		override public function tick( dt:Number ):void
		{
			if( this.skin && (!_cached || this.skin.geometry.dirty) )
				cacheVertices();
				
			var joints:Array = this.skin.joints;
			var verts:Array = this.skin.geometry.vertices;
			var i:int = verts.length;
			var v:Vertex3D;
			
			// reset verts to 0
			while( v = verts[ --i ] )
				v.x = v.y = v.z = 0;
			
			for each( var joint:Node3D in joints )
				skinMesh(joint, _cached, verts);
		}
		
		/**
		 * cache original vertices.
		 * 
		 * @return
		 */
		private function cacheVertices():void
		{
			var vertices:Array = this.skin.geometry.vertices;
			var i:int;
			
			_cached = new Array(vertices.length);
			
			for( i = 0; i < vertices.length; i++ )
			{
				_cached[i] = new Number3D(vertices[i].x, vertices[i].y, vertices[i].z);
				
				Matrix3D.multiplyVector(this.skin.bindPose, _cached[i]);
			}
		}

		/**
		 * skins the mesh.
		 * 
		 * @param	joint
		 * @param	meshVerts
		 * @param	skinnedVerts
		 * @return
		 */
		private function skinMesh( joint:Node3D, meshVerts:Array, skinnedVerts:Array ):void
		{
			var i:int;
			var pos:Number3D = new Number3D();
			var original:Number3D;
			var skinned:Vertex3D;
			var blendVerts:Array = joint.blendVerts;
			
			var matrix:Matrix3D = Matrix3D.multiply(joint.world, joint.bindMatrix);
		
			for( i = 0; i < blendVerts.length; i++ )
			{
				var weight:Number = blendVerts[i].weight;
				var vertexIndex:int = blendVerts[i].vertexIndex;

				if( weight <= 0.0001 || weight >= 1.0001) continue;
				
				original = meshVerts[ vertexIndex ];	
				skinned = skinnedVerts[ vertexIndex ];
				
				pos.x = original.x;
				pos.y = original.y;
				pos.z = original.z;
							
				// joint transform
				Matrix3D.multiplyVector( matrix, pos );	

				//update the vertex
				skinned.x += (pos.x * weight) ;
				if(_yUp) 
				{
					skinned.y += (pos.y * weight) ;
					skinned.z += (pos.z * weight) ;
				} 
				else 
				{
					skinned.y += (pos.z * weight) ;
					skinned.z += (pos.y * weight) ;
				}
			}
		}
		
		private var _cached:Array;
		
		private var _yUp:Boolean;
	}
}
