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
 
package org.papervision3d.core.geom {
	import org.papervision3d.core.animation.core.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.events.AnimationEvent;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	 * @author Tim Knip 
	 */
	public class AnimatedMesh3D extends TriangleMesh3D
	{
		/**
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @return
		 */
		public function AnimatedMesh3D( material:MaterialObject3D, vertices:Array =  null, faces:Array = null, name:String = null ):void
		{
			vertices = vertices || new Array();
			faces = faces || new Array();
			super(material, vertices, faces, name);
		}
		
		/**
		 * Gets all controllers for this object.
		 * 
		 * @return
		 */
		public function get controllers():Array
		{
			return AnimationEngine.getControllers(this);
		}
		
		/**
		 * Adds a animation controller to this mesh.
		 * 
		 * @param	controller
		 * 
		 * @return	the newly added controller.
		 */
		public function addController( controller:AbstractController ):AbstractController
		{
			return AnimationEngine.addController(this, controller);	
		}
		
		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		override public function project( parent:DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			return super.project(parent, renderSessionData);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function animationCompleteHandler( event:AnimationEvent ):void
		{
			dispatchEvent(event.clone());
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function animationProgressHandler( event:AnimationEvent ):void
		{
			dispatchEvent(event.clone());
		}
	}
}
