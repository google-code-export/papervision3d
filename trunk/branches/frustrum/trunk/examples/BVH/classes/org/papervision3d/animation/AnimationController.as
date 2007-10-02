/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

/*
 * Copyright 2006-2007 (c) Carlos Ulloa Matesanz, noventaynueve.com.
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
 
package org.papervision3d.animation 
{
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.animation.curves.*;
	
	/**
	 * @author Tim Knip 
	 */
	public class AnimationController extends EventDispatcher
	{
		/** */
		public var channels:Array;
		
		/**
		 * constructor.
		 * 
		 * @return
		 */
		public function AnimationController():void
		{
			this.channels = new Array();
			
			_curFrame = _totalFrames = 0;
			_curTime = 0;
			
			_frameTimer = new Timer(30);
			_frameTimer.addEventListener( TimerEvent.TIMER, timerHandler );
			_frameTimer.addEventListener( TimerEvent.TIMER_COMPLETE, timerCompleteHandler );
		}
		
		/**
		 * Frame time in milliseconds.
		 * 
		 * @return
		 */
		public function get frameTime():Number { return _frameTimer.delay; }
		public function set frameTime( value:Number ):void 
		{ 
			_frameTimer.delay = value; 
		}
		
		/**
		 * Number of times the animation is repeated.
		 * 
		 * @return
		 */
		public function get repeatCount():int { return _frameTimer.repeatCount; }
		public function set repeatCount( repeat:int ):void
		{ 
			_frameTimer.repeatCount = repeat;
		}
		
		/**
		 * Current frame.
		 * 
		 * @return
		 */
		public function get currentFrame():uint { return _curFrame; }
		public function set currentFrame( frame:uint ):void 
		{ 
			_curFrame = frame; 
			_curFrame = _curFrame < _totalFrames ? _curFrame : 0;
		}
		
		/**
		 * Boolean value indication whether an animation is running.
		 * 
		 * @return
		 */
		public function get running():Boolean { return _frameTimer.running; }
		
		/**
		 * Total number of frames.
		 * 
		 * @return
		 */
		public function get totalFrames():uint { return _totalFrames; }
		
		/**
		 * Adds the specified channel to the controller.
		 * 
		 * @param	channel
		 * @return
		 */
		public function addChannel( channel:AnimationChannel ):AnimationChannel
		{
			this.channels.push( channel );
			
			channel.bakeMatrices();
			
			for each( var curve:AbstractCurve in channel.curves )
			{
				_totalFrames = Math.max( _totalFrames, curve.keys.length );
			}
						
			return channel;
		}
		
		/**
		 * Play the animation.
		 * 
		 * @param	frame	frame number from which playing should start.
		 * 
		 * @return
		 */
		public function gotoAndPlay( frame:uint = 0 ):void
		{
			currentFrame = frame;
			play();
		}
		
		/**
		 * 
		 * @param	frame
		 * @return
		 */
		public function gotoAndStop( frame:uint ):void
		{
			stop();
			currentFrame = frame;
		}
		
		/**
		 * Move playhead to next frame.
		 * 
		 * @return
		 */
		public function nextFrame():uint
		{
			_curFrame++;
			_curFrame = _curFrame < _totalFrames ? _curFrame : 0;
			_curTime = _curFrame * (_frameTimer.delay * 0.001);
			return _curFrame;
		}
		
		/**
		 * Play the animation.
		 * 
		 * @return
		 */
		public function play():void
		{
			if( _frameTimer.running )
				_frameTimer.stop();
			_frameTimer.start();
		}
		
		/**
		 * Move playhead to previous frame.
		 * 
		 * @return
		 */
		public function previousFrame():uint
		{
			_curFrame--;
			_curFrame = _curFrame < 0 ? _totalFrames - 1 : _curFrame;
			return _curFrame;
		}
		
		/**
		 * Stop the animation.
		 * 
		 * @return
		 */
		public function stop():void
		{
			if( _frameTimer.running )
				_frameTimer.stop();
		}
		
		/**
		 * Removes the specified channel from the controller.
		 * 
		 * @param	channel
		 * @return
		 */
		public function removeChannel( channel:AnimationChannel ):AnimationChannel
		{
			var tmp:Array = new Array();
			var removed:AnimationChannel;
			
			for( var i:int = 0; i < channels.length; i++ )
			{
				if( channels[i] === channel )
					removed = channels[i];
				else
					tmp.push(channels[i]);
			}
			
			channels = tmp;
			return removed;
		}
		
		/**
		 * Updates the controller.
		 * 
		 * @param	dt
		 * @return
		 */
		public function update():void
		{
			_curTime = _curFrame * (_frameTimer.delay * 0.001);
			
			for( var i:int = 0; i < this.channels.length; i++ )
				this.channels[i].update(_curTime);
				
			nextFrame();
		}
	
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function timerHandler( event:TimerEvent ):void
		{
			update();
				
			dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, _curFrame+1, _totalFrames) );
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function timerCompleteHandler( event:TimerEvent ):void
		{
			dispatchEvent(event);
		}
		
		private var _curTime:Number = 0;
		private var _curFrame:uint = 0;
		private var _totalFrames:uint = 0;
		private var _frameTimer:Timer;
	}
}
