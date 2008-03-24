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
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class ControllerMesh3D extends TriangleMesh3D
	{
		/** */
		public var controllers:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 */ 
		public function ControllerMesh3D(material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null)
		{
			super(material, vertices, faces, name, initObject);
			
			controllers = new Array();
		}
		
		/**
		 * Adds a controller.
		 * 
		 * @param	controller
		 */ 
		public function addController(controller:AbstractController):void
		{
			controllers.push(controller);
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
			var num:Number = super.project(parent, renderSessionData);
			
			try
			{
				for(var i:int = 0; i < controllers.length; i++)
					controllers[i].apply(this, renderSessionData);
			}
			catch(e:Error)
			{
				
			}
			return num; //super.project(parent, renderSessionData);
		}
	}
}