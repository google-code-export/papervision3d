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
 
package org.papervision3d.core.animation
{
	import org.papervision3d.core.geom.Joint3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.*;
	
	/**
	 * @author	Tim Knip
	 */  
	public class Animation3D
	{
		/** The target for this animation */
		public var target:DisplayObject3D;
		
		/** */
		public var minTime:Number;
		
		/** */
		public var maxTime:Number;
		
		/** */
		public var interpolate:Boolean;
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function Animation3D(target:DisplayObject3D, interpolate:Boolean = true)
		{
			this.target = target;
			this.minTime = this.maxTime = 0;
			this.interpolate = interpolate;
			
			_channels = new Array();
			
			if(this.target is MD2)
			{
				var md2:MD2 = this.target as MD2;
				
				if(!md2.channel)
					throw new Error("MD2 wasn't loaded completely, please wait for Event.COMPLETE...");
					
				addChannel(md2.channel);
			}
			else if(this.target is DAE)
			{
				var dae:DAE = this.target as DAE;
				
				var animatables:Array = dae.getAnimatedChildren();
				
				for each(var joint:Joint3D in animatables)
				{
					for(var i:int = 0; i < joint.channels.length; i++)
						addChannel(joint.channels[i]);
				}
			}
			
			_currentKeyFrame = 0;
			_nextKeyFrame = 0;
		}
		
		public function tick(time:Number = 0):void
		{
			if(!_channels.length)
				return;
			
			var toRadians:Number = (Math.PI/180);
			
			for each(var channel:AnimationChannel3D in _channels)
			{
				var target:Joint3D = channel.target as Joint3D;
				if(!target)
					continue;
				
				// move channel to correct keyframe
				channel.tick(time);
				
				// the channel's keyframes
				var keyframes:Array = channel.keyframes;
				
				// the channel's current keyframe
				var cur:AnimationKeyFrame3D = keyframes[channel.current];

				// get the output array
				var output:Array = cur.output.concat();
				
				if(!output || !output.length)
					continue;
					
				if(interpolate)
				{
					var next:AnimationKeyFrame3D = keyframes[channel.current+1];
					var noutput:Array = next.output;
					
					var t:Number = time % channel.maxTime;
					
					var elapsed:Number = t > cur.time ? t - cur.time : 0;
					var total:Number = next.time - cur.time;
					var change:Number = elapsed/total;
					
					for(var i:int = 0; i < output.length; i++)
					{
						output[i] = output[i] + (change * (noutput[i] - output[i]));
					}
				}
				
				if(channel.type == AnimationChannel3D.TYPE_SINGLE_PROPERTY)
				{
					
				}
				else if(channel.type == AnimationChannel3D.TYPE_MORPH)
				{
					
				}
				else
				{
					// build matrix (this can be more efficient if AnimationKeyFrame3D#output is of type Matrix3D)
					var matrix:Matrix3D = null;
		
					switch(channel.type)
					{
						case AnimationChannel3D.TYPE_ROTATE:
							matrix = Matrix3D.rotationMatrix(output[0], output[1], output[2], output[3] * toRadians);
							break;
						case AnimationChannel3D.TYPE_SCALE:
							matrix = Matrix3D.scaleMatrix(output[0], output[1], output[2]);
							break;
						case AnimationChannel3D.TYPE_TRANSLATE:
							matrix = Matrix3D.translationMatrix(output[0], output[1], output[2]);
							break;
						case AnimationChannel3D.TYPE_MATRIX:
						default:
							matrix = new Matrix3D(output);
							break;
					}
									
					// update the object's transform
					target.updateTransformByID(matrix, channel.transformID);
				}
			}
		}
		
		/**
		 * Adds an AnimationChannel3D. @see org.papervision3d.core.animation.AnimationChannel3D
		 * 
		 * @param	channel	The channel to add.
		 * 
		 * @return	the added channel.
		 */ 
		public function addChannel(channel:AnimationChannel3D):AnimationChannel3D
		{
			_channels.push(channel);
			
			this.minTime = AnimationChannel3D(_channels[0]).minTime;
			this.maxTime = AnimationChannel3D(_channels[0]).maxTime;
			
			for(var i:int = 0; i < _channels.length; i++)
			{
				this.minTime = Math.min(this.minTime, _channels[i].minTime);
				this.maxTime = Math.max(this.maxTime, _channels[i].maxTime);
			}
			
			return channel;
		}
		
		/**
		 * Removes an AnimationChannel3D. @see org.papervision3d.core.animation.AnimationChannel3D
		 * 
		 * @param	channel	The channel to remove.
		 * 
		 * @return	the removed channel or null on failure.
		 */ 
		public function removeChannel(channel:AnimationChannel3D):AnimationChannel3D
		{
			var removed:AnimationChannel3D = null;	
			var idx:int = -1;
			
			for(var i:int = 0; i < _channels.length; i++)
			{
				if(_channels[i] === channel)
				{
					i = idx;
					removed = _channels.splice(i, 1)[0] as AnimationChannel3D;
					break;	
				}
			}
			
			if(_channels.length)
			{
				this.minTime = AnimationChannel3D(_channels[0]).minTime;
				this.maxTime = AnimationChannel3D(_channels[0]).maxTime;
			}
			else
			{
				this.minTime = this.maxTime = 0;
			}
			
			for(var j:int = 0; j < _channels.length; j++)
			{
				this.minTime = Math.min(this.minTime, _channels[j].minTime);
				this.maxTime = Math.max(this.maxTime, _channels[j].maxTime);
			}
			
			return removed;	
		}
		
		/** */
		private var _channels:Array;
		
		private var _currentKeyFrame:int;
		
		private var _nextKeyFrame:int;
	}
}