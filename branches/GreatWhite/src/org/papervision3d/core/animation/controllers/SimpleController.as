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
	import org.papervision3d.core.animation.core.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * <p>This class controls the animation of simple properties of a DisplayObject3D.</p>
	 * 
	 * @author Tim Knip 
	 */
	public class SimpleController extends KeyFrameController
	{
		public static const ROTATION_X		:String = "rotationX";
		public static const ROTATION_Y		:String = "rotationY";
		public static const ROTATION_Z		:String = "rotationZ";
		public static const TRANSLATION_X	:String = "x";
		public static const TRANSLATION_Y	:String = "y";
		public static const TRANSLATION_Z	:String = "z";
		public static const SCALE_X			:String = "scaleX";
		public static const SCALE_Y			:String = "scaleY";
		public static const SCALE_Z			:String = "scaleZ";
		public static const SCALE			:String = "scale";
		public static const TRANSFORM		:String = "transform";
		
		/** the targeted DisplayObject3D */
		public var target:DisplayObject3D;
		
		/** the targeted property  */
		public var property:String;
		
		/**
		 * constructor.
		 * 
		 * @param	target		the object this controller targets.
		 * @param	property	the targeted property.
		 * @return
		 */
		public function SimpleController(target:DisplayObject3D, property:String):void
		{
			super(target.geometry);
			
			this.target = target;
			this.property = property;
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
			
			//if(engine.currentFrame != currentFrame )
			//return;
				
			dt = this.split / this.duration;

			var startFrame:AnimationFrame = this.frames[ currentFrame ];
			var endFrame:AnimationFrame = this.frames[ nextFrame ];
			
			if( !startFrame )
				return;
			
			var sv:Array = startFrame.values;
			var ev:Array;
			
			if( endFrame )
			{
				ev = endFrame.values;
			}
			else
			{
				ev = sv;
				dt = 0;
			}
			
			if( this.property == SimpleController.TRANSFORM )
			{
				var matrix:Matrix3D = target.transform;
				
				if( sv[0] is Matrix3D && ev[0] is Matrix3D )
				{
					var ms:Matrix3D = sv[0];
					var me:Matrix3D = ev[0];
					matrix.n11 = ms.n11 + dt * (me.n11 - ms.n11);
					matrix.n12 = ms.n12 + dt * (me.n12 - ms.n12);
					matrix.n13 = ms.n13 + dt * (me.n13 - ms.n13);
					matrix.n14 = ms.n14 + dt * (me.n14 - ms.n14);
					matrix.n21 = ms.n21 + dt * (me.n21 - ms.n21);
					matrix.n22 = ms.n22 + dt * (me.n22 - ms.n22);
					matrix.n23 = ms.n23 + dt * (me.n23 - ms.n23);
					matrix.n24 = ms.n24 + dt * (me.n24 - ms.n24);
					matrix.n31 = ms.n31 + dt * (me.n31 - ms.n31);
					matrix.n32 = ms.n32 + dt * (me.n32 - ms.n32);
					matrix.n33 = ms.n33 + dt * (me.n33 - ms.n33);
					matrix.n34 = ms.n34 + dt * (me.n34 - ms.n34);
				}
				else
				{
					matrix.n11 = sv[0] + dt * (ev[0] - sv[0]);
					matrix.n12 = sv[1] + dt * (ev[1] - sv[1]);
					matrix.n13 = sv[2] + dt * (ev[2] - sv[2]);
					matrix.n14 = sv[3] + dt * (ev[3] - sv[3]);
					matrix.n21 = sv[4] + dt * (ev[4] - sv[4]);
					matrix.n22 = sv[5] + dt * (ev[5] - sv[5]);
					matrix.n23 = sv[6] + dt * (ev[6] - sv[6]);
					matrix.n24 = sv[7] + dt * (ev[7] - sv[7]);
					matrix.n31 = sv[8] + dt * (ev[8] - sv[8]);
					matrix.n32 = sv[9] + dt * (ev[9] - sv[9]);
					matrix.n33 = sv[10] + dt * (ev[10] - sv[10]);
					matrix.n34 = sv[11] + dt * (ev[11] - sv[11]);
				}
			}
			else
			{
				this.target[this.property] = sv[0] + dt * (ev[0] - sv[0]);
			}
		}
	}
}
