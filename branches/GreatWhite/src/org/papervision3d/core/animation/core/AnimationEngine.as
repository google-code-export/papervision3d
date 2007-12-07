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
 
package org.papervision3d.core.animation.core {
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	 * @author Tim Knip 
	 */
	public class AnimationEngine 
	{
		/** total number of frames */
		public static var NUM_FRAMES:uint = 100;
		
		/** frame duration in milliseconds */
		public static var TICK:Number = 50;
		
		/** current time in milliseconds. */
		public var time:Number = 0;
				
		/** current frame */
		public var currentFrame:uint = 0;
		
		/** maximum time in milliseconds (effectively NUM_FRAMES * TICK). */
		public var maxTime:Number = NUM_FRAMES * TICK;
		
		/** */
		private static var instance:AnimationEngine = new AnimationEngine();
		
		/**
		 * constructor.
		 * 
		 * @return
		 */
		public function AnimationEngine():void
		{
			if( instance )
				throw new Error( "org.papervision3d.animation.AnimationEngine is a singleton class!" );
			
			_animatedObjects = new Dictionary();
			_controllers = new Array();
			_time = getTimer();
			
			Papervision3D.log( "[AnimationEngine] initialized => NUM_FRAMES:" + NUM_FRAMES + " TICK:" + TICK ); 
		}
		
		/**
		 * Adds a controller to the animation engine.
		 * 
		 * @param	object		the object the controller targets. @see org.papervision3d.objects.DisplayObject3D
		 * @param	controller	the controller. @see org.papervision3d.animation.core.AbstractController
		 * @return
		 */
		public static function addController( object:DisplayObject3D, controller:AbstractController ):AbstractController
		{
			var nframes:uint = NUM_FRAMES;
			
			if( !_animatedObjects[ object ] )
				_animatedObjects[ object ] = new Array();
							
			for each( var frame:AnimationFrame in controller.frames )
			{
				var framenum:uint = frame.frame;
				if( framenum > NUM_FRAMES )
					NUM_FRAMES = framenum;
			}
			
			instance.maxTime = NUM_FRAMES * TICK;
			
			if( NUM_FRAMES > nframes )
				Papervision3D.log( "[AnimationEngine] resizing timeline to " + NUM_FRAMES + " frames" );
						
			_animatedObjects[ object ].push(controller);
			
			return controller;
		}
		
		/**
		 * Gets all controllers for the specified object. @see org.papervision3d.animation.core.AbstractController
		 * 
		 * @param	object
		 * @return
		 */
		public static function getControllers( object:DisplayObject3D ):Array
		{
			if( _animatedObjects[ object ] )
				return _animatedObjects[ object ];
			else
				return null;
		}
		
		/**
		 * Sets all controllers for the specified object.
		 * 
		 * @param	object		the object the controller targets. @see org.papervision3d.objects.DisplayObject3D
		 * @param	controllers	the object the controllers target. @see org.papervision3d.animation.core.AbstractController
		 * @param	overwrite	a boolean value indicating whether to overwrite all previous controllers.
		 * @return
		 */
		public static function setControllers( object:DisplayObject3D, controllers:Array, overwrite:Boolean = false ):void
		{
			if(overwrite)
				_animatedObjects[ object ] = new Array();
				
			for( var i:int = 0; i < controllers.length; i++ )
				addController(object, controllers[i]);
		}
		
		/**
		 * tick.
		 * 
		 * @return
		 */
		public function tick():void
		{							
			time = (getTimer() - _time);
			if( time > TICK )
			{
				_time = getTimer();
				currentFrame = currentFrame < NUM_FRAMES - 1 ? currentFrame + 1 : 0;
			}
			
			for( var obj:* in _animatedObjects )
			{
				var controllers:Array = _animatedObjects[ obj ];
				for( var i:int = 0; i < controllers.length; i++ )
					controllers[i].tick( time );
			}
		}
		
		/**
		 * getInstance.
		 * 
		 * @return
		 */
		public static function getInstance():AnimationEngine
		{
			return instance;
		}

		/**
		 * Converts milliseconds to frames.
		 * 
		 * @param	millis	milliseconds.
		 * 
		 * @return 	frame number
		 */
		public static function millisToFrame( millis:Number ):uint
		{
			return Math.floor(millis / TICK);
		}
		
		/**
		 * Converts seconds to frames.
		 * 
		 * @param	seconds	seconds
		 * 
		 * @return	frame number
		 */
		public static function secondsToFrame( seconds:Number ):uint
		{
			return millisToFrame(seconds * 1000);
		}

		/** */
		private static var _time:Number;
		
		private static var _controllers:Array;
		
		private static var _animatedObjects:Dictionary;
	}	
}
