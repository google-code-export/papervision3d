/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
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
 
package org.papervision3d.animation.core
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * 
	 */
	public class AnimationController
	{
		/** */
		private var channels:Array;
		
		/**
		 * 
		 * @return
		 */
		public function AnimationController():void
		{	
			this.channels = new Array();
		}
		
		/**
		 * 
		 * @param	channel
		 * @return
		 */
		public function addChannel( channel:AnimationChannel ):void
		{
			this.channels.push( channel );
		}
		
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		public function update( dt:Number ):void
		{
			for each( var channel:AnimationChannel in channels )
				channel.update(dt);
		}
	}
}
