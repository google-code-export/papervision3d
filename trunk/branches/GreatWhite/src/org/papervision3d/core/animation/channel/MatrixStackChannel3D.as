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
	import org.papervision3d.core.animation.AnimationKeyFrame3D;
	import org.papervision3d.core.animation.IAnimationDataProvider;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip
	 */ 
	public class MatrixStackChannel3D extends AbstractChannel3D
	{
		/**
		 * Constructor.
		 * 
		 * @param	parent
		 * @param	defaultTarget
		 * @param	name
		 */ 
		public function MatrixStackChannel3D(parent:IAnimationDataProvider, defaultTarget:DisplayObject3D, name:String=null)
		{
			super(parent, defaultTarget, name);
			
			_matrixStack = new Array();
		}
		
		/**
		 * Adds a MatrixChannel3D to this channel.
		 *  
		 * @param	channel
		 */
		public function addMatrixChannel(channel:MatrixChannel3D):void
		{
			if(_matrixStack.length)
			{
				this.minTime = Math.min(this.minTime, channel.minTime);
				this.maxTime = Math.max(this.maxTime, channel.maxTime);
			}
			else
			{
				this.minTime = channel.minTime;
				this.maxTime = channel.maxTime;
			}

			_matrixStack.push(channel);
		}
		
		/**
		 * Adds a new keyframe.
		 * 
		 * @param	keyframe
		 * 
		 * @return	The added keyframe.
		 */ 
		public override function addKeyFrame(keyframe:AnimationKeyFrame3D):AnimationKeyFrame3D
		{
			throw new Error("You can't add keyframes to a MatrixStackChannel3D!");
		}
		
		/**
		 * Updates this channel.
		 * 
		 * @param	keyframe
		 * @param	target
		 */ 
		public override function updateToFrame(keyframe:uint, target:DisplayObject3D=null):void
		{
			super.updateToFrame(keyframe, target);	
			
			target = target || this.defaultTarget;
			
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			
			for(var i:int = 0; i < _matrixStack.length; i++)
			{
				var channel:MatrixChannel3D = _matrixStack[i];
				
				channel.updateToFrame(keyframe, target);
				
				matrix = Matrix3D.multiply(matrix, channel.output[0]);
			}
			
			this.output = [matrix];
			
			target.copyTransform(this.output[0]);
		}
		
		private var _matrixStack:Array;
	}
}