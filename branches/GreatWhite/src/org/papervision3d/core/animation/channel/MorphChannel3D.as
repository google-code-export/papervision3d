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
 
package org.papervision3d.core.animation.channel
{
	import org.papervision3d.core.animation.channel.AbstractChannel3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class MorphChannel3D extends AbstractChannel3D
	{
		/**
		 * Constructor.
		 * 
		 * @param	defaultTarget
		 * @param	name
		 */ 
		public function MorphChannel3D(defaultTarget:DisplayObject3D, name:String=null)
		{
			super(defaultTarget, name);
		}	
		
		/**
		 * Updates this channel.
		 * 
		 * @param	keyframe
		 * @param	target
		 */ 
		override public function updateToFrame(keyframe:uint, target:DisplayObject3D=null):void
		{
			super.updateToFrame(keyframe, target);	
			
			target = target || this.defaultTarget;
			
			if(!target.geometry || !target.geometry.vertices)
				return;
				
			if(this.output.length != target.geometry.vertices.length)
				return;
				
			for(var i:int = 0; i < target.geometry.vertices.length; i++)
			{
				var v:Vertex3D = target.geometry.vertices[i];
				var w:Vertex3D = this.output[i];
				
				v.x = w.x;
				v.y = w.y;
				v.z = w.z;
			}
		}
	}
}