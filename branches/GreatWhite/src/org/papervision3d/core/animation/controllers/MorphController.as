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
	import org.papervision3d.core.animation.controllers.*;
	import org.papervision3d.core.animation.core.*;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.proto.GeometryObject3D;
	
	/**
	 * 
	 */
	public class MorphController extends KeyFrameController
	{				
		/**
		 * constructor.
		 * 
		 * @param	the targeted geometry.
		 * 
		 * @return
		 */
		public function MorphController( geometry:GeometryObject3D ):void
		{
			super(geometry);
		}
		
		/**
		 * Tick. Called by the animation engine on each frame.
		 * 
		 * @param	dt	current time in milliseconds
		 * 
		 * @return
		 */
		override public function tick( dt:Number ):void
		{
			super.tick(dt);
		
			updateVertices( this.split / this.duration );
		}
	
		/**
		 * Updates all vertices.
		 * 
		 * @param	split	current time split as a value between 0 (currentFrame) and 1 (nextFrame).
		 * 
		 * @return
		 */
		protected function updateVertices( split:Number ):Boolean
		{				
			split = Math.min( split, 1 );
			
			var verts:Array = this.geometry.vertices;
			var i:int = verts.length;
			var v:Vertex3D;
			
			var startFrame:AnimationFrame = this.frames[ currentFrame ];
			var endFrame:AnimationFrame = this.frames[ nextFrame ];
			
			if( !startFrame )
				return false;
			
			var sv:Array = startFrame.values;
			
			if( !endFrame )
			{
				while( v = verts[--i] )
				{
					v.x = sv[i].x;
					v.y = sv[i].y;
					v.z = sv[i].z;
				}
				return true;
			}
			
			var ev:Array = endFrame.values;
			
			while( v = verts[--i] )
				interpolateVertices(v, sv[i], ev[i], split);
				
			return true;
		}
		
		/**
		 * simple lineair interpolation.
		 * 
		 * @param	v
		 * @param	sv
		 * @param	ev
		 * @param	alpha
		 * @return
		 */
		private function interpolateVertices( v:Vertex3D, sv:Vertex3D, ev:Vertex3D, alpha:Number ):void
		{
			v.x = sv.x + alpha * (ev.x - sv.x);
			v.y = sv.y + alpha * (ev.y - sv.y);
			v.z = sv.z + alpha * (ev.z - sv.z);
		}
	}	
}
