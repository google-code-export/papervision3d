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
 
package org.papervision3d.core.animation.core
{
	import flash.events.EventDispatcher;	
	import flash.utils.getTimer;
	
	import org.papervision3d.core.animation.core.AnimationEngine;
	import org.papervision3d.core.animation.core.AnimationFrame;
	import org.papervision3d.core.proto.GeometryObject3D;
	
	/**
	 * @author Tim Knip
	 */
	public class AbstractController extends EventDispatcher
	{
		public var playing:Boolean;
		
		public var frames:Array;
		
		public var duration:uint = 0;
				
		protected var engine:AnimationEngine;
		
		/**
		 * 
		 * @return
		 */
		public function AbstractController():void
		{			
			this.frames = new Array();
			
			this.engine = AnimationEngine.getInstance();
			
			playing = false;
			currentFrame = 0;
			nextFrame = 1;
			firstFrame = uint.MAX_VALUE;
			lastFrame = uint.MIN_VALUE;
		}
		
		/**
		 * 
		 * @param	frame
		 * @return
		 */
		public function addFrame( frame:AnimationFrame ):void
		{
			this.frames[frame.frame] = frame;
			totalFrames++;
			
			firstFrame = Math.min(firstFrame, frame.frame);
			lastFrame = Math.max(lastFrame, frame.frame);
		}
		
		/**
		 * 
		 * @param	name
		 * @param	ignoreTrailingDigits
		 * @return
		 */
		public function findFrameByName( name:String, ignoreTrailingDigits:Boolean ):AnimationFrame
		{
			if( ignoreTrailingDigits )
			{
				var pattern:RegExp = /^([a-z]+)(\d+)$/i;
				var matches:Object = pattern.exec(name);
				if( matches && matches[1] && matches[2] )
					name = matches[1];
			}
			
			for each( var frame:AnimationFrame in this.frames )
			{
				if( frame.name == name )
					return frame;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	frame
		 * @return
		 */
		public function gotoAndPlay( frame:uint = 0 ):void
		{
			currentFrame = (frame) % this.frames.length;
			nextFrame = (frame + 1) % this.frames.length;
			playing = true;
		}
		
		/**
		 * 
		 * @param	frame
		 * @return
		 */
		public function gotoAndStop( frame:uint = 0 ):void
		{
			currentFrame = (frame) % this.frames.length;
			nextFrame = (frame + 1) % this.frames.length;
		}
		
		/**
		 * play animation.
		 * 
		 * @return
		 */
		public function play():void
		{
			gotoAndPlay(currentFrame);
		}
				
		/**
		 * stop animation.
		 * 
		 * @return
		 */
		public function stop():void
		{
			playing = false;
		}
		
		/**
		 * called by the animaition engine. @see org.papervision3d.animation.core.AnimationEngine
		 * 
		 * @param	dt
		 * @return
		 */
		public function tick( dt:Number ):void
		{
		}
		
		/** current keyframe. */
		protected var currentFrame:int = 0;
		
		/** next keyframe */
		protected var nextFrame:int = 0;
		
		/** total number of keyframes */
		protected var totalFrames:uint = 0;
		
		/** last keyframe */
		protected var lastFrame:uint = 0;
		
		/** first keyframe */
		protected var firstFrame:uint = 0;
		
		/** */
		protected var split:Number;
	}
}
