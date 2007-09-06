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
 
package org.ascollada.io
{
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.EventDispatcher
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeReader extends EventDispatcher
	{
		public var document:DaeDocument;
		
		/**
		 * 
		 */
		public function DaeReader()
		{
			_animTimer = new Timer(100);
			_animTimer.addEventListener( TimerEvent.TIMER, loadNextAnimation );
		}
		
		/**
		 * 
		 * @param	filename
		 */
		public function read( filename:String ):void
		{
			Logger.trace( "reading: " + filename );
			
			if( _animTimer.running )
				_animTimer.stop();
				
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, completeHandler );
			loader.addEventListener( ProgressEvent.PROGRESS, progressHandler );
			loader.load( new URLRequest(filename) );
		}
		
		/**
		 * 
		 * @return
		 */
		public function readAnimations():void
		{
			if( this.document.numQueuedAnimations > 0 )
			{
				_animTimer.repeatCount = this.document.numQueuedAnimations + 1;
				_animTimer.delay = 100;
				_animTimer.start();
			}
		}
		
		public function loadDocument( data:* ):DaeDocument
		{
			this.document = new DaeDocument( data );
			
			_totalAnimations = this.document.numQueuedAnimations;
			
			dispatchEvent( new Event(Event.COMPLETE) );	
			
			return this.document;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function completeHandler( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			Logger.trace( "complete!" );

			loadDocument( loader.data );
		}
		
		private function progressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadNextAnimation( event:TimerEvent ):void
		{
			if( !this.document.readNextAnimation() )
			{
				_animTimer.stop();
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, _totalAnimations - this.document.numQueuedAnimations, _totalAnimations) );
			}
		}
		
		private var _totalAnimations:uint; 
		private var _animTimer:Timer; 
	}	
}
