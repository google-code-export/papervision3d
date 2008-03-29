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
 
package org.papervision3d.core.geom
{
	import org.papervision3d.core.geom.controller.AbstractController;
	import org.papervision3d.core.geom.controller.IControlledObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class ControlledMesh3D extends TriangleMesh3D implements IControlledObject3D
	{	
		/**
		 * Gets all controllers.
		 */ 
		public function get controllers():Array { return _controllers; }
		
		/**
		 * Constructor.
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 */ 
		public function ControlledMesh3D(material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null)
		{
			super(material, vertices, faces, name, initObject);
			
			_controllers = new Array();
		}
		
		/**
		 * Adds a controller.
		 * 
		 * @param	controller	The controller to add.
		 * 
		 * return	The added controller or null on failure.
		 */ 
		public function addController(controller:AbstractController):AbstractController
		{
			_controllers.push(controller);
			return controller;
		}
		
		/**
		 * Applies all controllers on the object.
		 */ 
		public function applyControllers():void
		{
			for(var i:int = 0; i < _controllers.length; i++)
				_controllers[i].apply();
		}
		
		/**
		 * Project.
		 *
		 * @param	parent
		 * @param	renderSessionData
		 *
		 * @return
		 */
		public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			applyControllers();
			return super.project(parent, renderSessionData);
		}
		
		/**
		 * Removes the specified controller.
		 * 
		 * @param	controller
		 * 
		 * return	The removed controller or null on failure.
		 */ 
		public function removeController(controller:AbstractController):AbstractController
		{
			return null;
		}
		
		/** */
		private var _controllers:Array;
	}
}