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
 
package org.papervision3d.objects 
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.papervision3d.core.geom.Lines3D;
	import org.papervision3d.core.Number3D;
	
	import mx.utils.StringUtil;

	import org.papervision3d.Papervision3D;
	import org.papervision3d.animation.*;
	import org.papervision3d.animation.curves.*;
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	
	/**
	 * class BVH.
	 * <p>This class attempts to parse a BioVision motion capture file.<br/>
	 * See: http://www.cs.wisc.edu/graphics/Courses/cs-838-1999/Jeff/BVH.html</p>
	 * 
	 * @author Tim Knip 
	 */
	public class BVH extends DisplayObject3D
	{	
		/** */
		public static const MODE_OBJECT:uint = 0;
		
		/** */
		public static const MODE_POSE:uint = 1;
		
		/** degrees to radians */
		public static const DEG2RAD:Number = (Math.PI/180);
		
		/** default root material */
		public static var DEFAULT_ROOT_MATERIAL:MaterialObject3D = new WireframeMaterial(0xffff00);
		
		/** default joint material */
		public static var DEFAULT_JOINT_MATERIAL:MaterialObject3D = new WireframeMaterial(0xff0000);
		
		/** default endsite material */
		public static var DEFAULT_ENDSITE_MATERIAL:MaterialObject3D = new WireframeMaterial(0x00ff00);
		
		/** the root of the BVH */
		public var rootNode:DisplayObject3D;
		
		/** frame data */
		public var frames:Array;
		
		/** frame time in seconds.  */
		public var frameTime:Number = 0.03;
		
		/** */
		public var controller:AnimationController;
		
		/**
		 * 
		 */
		public function get mode():uint { return _mode; }
		public function set mode( modus:uint ):void
		{
			if( modus != _mode )
			{
				_mode = modus;
				if( _mode == MODE_POSE )
					setPoseMode(this);
			}
		}
		
		/**
		 * constructor.
		 * 
		 * @param	asset		url, bytearray or string.
		 * @param	hierarchy	an optional tree of DisplayObject3D's to form the BVH hierarchy.
		 * 
		 * @return
		 */
		public function BVH( asset:*, hierarchy:DisplayObject3D = null ):void
		{
			super("ROOT");
	
			this.controller = new AnimationController();
			
			if( asset is String )
				parse(String(asset));
			else if( asset is ByteArray )
				parse(ByteArray(asset).toString());
			else
				throw new Error( "[ERROR] unknown asset passed to BVH constructor" );
		}
		
		/**
		 * Returns the child display object that exists with the specified name.
		 * </p>
		 * If more that one child display object has the specified name, the method returns the first object in the child list.
		 * </p>
		 * @param	name	The name of the child to return.
		 * @return	The child display object with the specified name.
		 */
		override public function getChildByName( name:String ):DisplayObject3D
		{
			return findChildByName(name);
		}
		
		/**
		 * Loads a BVH from a url.
		 * 
		 * @param	url
		 * @return
		 */
		public function load( url:String ):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loadCompleteHandler );
			loader.addEventListener( ProgressEvent.PROGRESS, loadProgressHandler );
			loader.load( new URLRequest(url) );
		}

				/**
		 * Plays the animation.
		 * 
		 * @param	repeatCount
		 * @return
		 */
		public function play( repeatCount:int = 0 ):void
		{
			// need milliseconds
			this.controller.frameTime = this.frameTime * 1000;
			
			// repeat aninamtions
			this.controller.repeatCount = repeatCount * frames.length;
			
			// play!
			this.controller.play();
		}
		
		/**
		 * Stops the animation.
		 * 
		 * @return
		 */
		public function stop():void
		{
			this.controller.stop();
		}
		
		/**
		 * Creates the EndSite displayobject3d. Override this one in subclasses to provide your own object.
		 * 
		 * @param	material
		 * @return
		 */
		protected function createEndSite( material:MaterialObject3D = null ):DisplayObject3D
		{
			material = material || DEFAULT_ENDSITE_MATERIAL;
			
			return new DisplayObject3D();
		}
		
		/**
		 * Creates a JOINT displayobject3d. Override this one in subclasses to provide your own object.
		 * 
		 * @param	material
		 * @return
		 */
		protected function createJoint( material:MaterialObject3D = null ):DisplayObject3D
		{
			material = material || DEFAULT_JOINT_MATERIAL;
	
			return new Sphere(material, 1, 3, 2);
		}
		
		/**
		 * Creates a ROOT displayobject3d. Override this one in subclasses to provide your own object.
		 * 
		 * @param	material
		 * @return
		 */
		protected function createRoot( material:MaterialObject3D = null ):DisplayObject3D
		{
			material = material || DEFAULT_ROOT_MATERIAL;
			
			return new Sphere(material, 1, 3, 2);
		}
			
		/**
		 * Parses the BVH.
		 * 
		 * @param	raw
		 * @return
		 */
		private function parse( raw:String ):void
		{
			raw = StringUtil.trim(raw);
			
			if( !raw.length )
				return;
				
			// we may be dealing with a url!
			if( !isBVH(raw) )
			{
				load( raw );
				return;
			}
			
			var instance:DisplayObject3D;
			var parent:DisplayObject3D = this;
			var totalChannels:int = 0;
			var numChannels:int = 0;
			var instances:Array = new Array();
			var i:int, j:int;				
			var state:String = "";
			var lines:Array = raw.split("\n");
			var lastName:String = "";
	
			frames = new Array();
			
			_poses = new Dictionary();
			
			for( i = 0; i < lines.length; i++ )
			{
				lines[i] = StringUtil.trim(lines[i]);
				
				var parts:Array = lines[i].split(/\s+/);
				
				var cmd:String = parts[0];
				
				var isNumeric:Boolean = !isNaN(parseFloat(cmd));
				
				switch( cmd.toUpperCase() )
				{
					case "{":
						instances.push(parent);
						parent = instance;
						break;
						
					case "}":
						parent = instances.pop() as DisplayObject3D;
						break;
						
					case "HIERARCHY":
						state = cmd;
						break;
						
					case "ROOT":
						stickModel = new Lines3D(new LineMaterial(0xffff00));
						
						instance = parent.addChild( createRoot(), parts[1] );
						instance.name = parts[1];
						instance.extra = new Object();
						rootNode = instance;
						rootNode.addChild( stickModel );
						break;
						
					case "OFFSET":
						instance.extra[cmd] = new Vertex3D();
						instance.x = parseFloat( parts[1] );
						instance.y = parseFloat( parts[2] );
						instance.z = parseFloat( parts[3] );
						_poses[ instance ] = new Vertex3D(instance.x, instance.y, instance.z);
						break;
					
					case "CHANNELS":
						numChannels = parseInt(parts[1], 10);
						instance.extra[cmd] = new Array();
						for( j = 0; j < numChannels; j++ )
						{							
							var target:String = parts[j+2];
							var curve:AbstractCurve;
							
							switch( target )
							{
								case "Xposition":
									curve = new TranslationCurve(instance, TranslationCurve.TRANSLATION_X);
									break;
								case "Yposition":
									curve = new TranslationCurve(instance, TranslationCurve.TRANSLATION_Y);
									break;
								case "Zposition":
									curve = new TranslationCurve(instance, TranslationCurve.TRANSLATION_Z);
									break;curves
								case "Xrotation":
									curve = new RotationCurve(instance, RotationCurve.ROTATION_X);
									break;
								case "Yrotation":
									curve = new RotationCurve(instance, RotationCurve.ROTATION_Y);
									break;
								case "Zrotation":
									curve = new RotationCurve(instance, RotationCurve.ROTATION_Z);
									break;
								default:
									break;
							}
							
							instance.extra[cmd][j] = {channel:(totalChannels+j), target:target, curve:curve};
						}

						totalChannels += numChannels;
						break;
					
					case "JOINT":
						instance = parent.addChild( createJoint(), parts[1] );
						instance.name = lastName = parts[1];
						instance.extra = new Object();
						break;
						
					case "MOTION":
						state = cmd;
						break;
						
					case "END":
						if( parts[1].toUpperCase() == "SITE" )
						{
							// End Site
							instance = instance.addChild( createEndSite() );
							instance.extra = new Object();
							instance.name = lastName + "_EndSite"; 
						}
						break;
					
					case "FRAME":
						if( parts[1].toUpperCase() == "TIME:" && parts.length > 2 )
							this.frameTime = parseFloat(parts[2]);
						break;
						
					case "FRAMES":
						break;
						
					default:
						if( state == "MOTION" && isNumeric )
						{
							var frames:Array = new Array();
							for( j = 0; j < parts.length; j++ )
								frames.push( parseFloat(parts[j]) );
							this.frames.push(frames);
						}
						break;
				}
			}
						
			createStickModel( this.rootNode );
			
			createAnimation( this );
			
			_delayTimer = new Timer(500, 1);
			_delayTimer.addEventListener( TimerEvent.TIMER_COMPLETE, dispatchFileComplete );
			_delayTimer.start();
		}
		
		/**
		 * 
		 * @param	obj
		 * @return
		 */
		private function createAnimation( obj:DisplayObject3D ):void
		{			
			if( obj.extra && obj.extra["CHANNELS"] is Array )
			{	
				var channel:AnimationChannel = new AnimationChannel(obj);
				
				for( var i:int = 0; i < obj.extra["CHANNELS"].length; i++ )
				{
					var channelID:int = obj.extra["CHANNELS"][i].channel;	
					var curve:AbstractCurve = obj.extra["CHANNELS"][i].curve;

					if( curve )
					{
						curve.keys = createCurveKeys();
						curve.values = createCurveValues(channelID);
						channel.addCurve(curve);
					}
				}
				
				this.controller.addChannel(channel);
			}
			
			for each( var child:DisplayObject3D in obj.children )
				createAnimation(child);
		}
		
		/**
		 * 
		 * @return
		 */
		private function createCurveKeys():Array
		{
			var keys:Array = new Array();
			var dt:Number = 0;
			
			for( var i:int = 0; i < this.frames.length; i++ )
			{
				keys.push(dt);
				dt += this.frameTime;
			}
			return keys;
		}
		
		/**
		 * 
		 * @param	channelID
		 * @return
		 */
		private function createCurveValues( channelID:int ):Array
		{
			var result:Array = new Array();
			for( var i:int = 0; i < this.frames.length; i++ )
				result.push( this.frames[i][channelID] );
			return result;
		}
		
		/**
		 * 
		 * @param	obj
		 * @param	parent
		 * @return
		 */
		private function createStickModel( obj:DisplayObject3D, parent:DisplayObject3D = null ):void
		{
			if( parent && !(obj is Lines3D) && !(parent is Lines3D) && obj.numChildren)
			{
				var instance:Lines3D = new Lines3D(new LineMaterial(0xffff00), "Stick_"+parent.name+"_"+obj.name);
				
				instance.addNewLine(0, 0, 0, 0, obj.x, obj.y, obj.z);
				
				parent.addChild(instance);
			}
			
			for each( var child:DisplayObject3D in obj.children )
				createStickModel( child, obj );
		}
		
		/**
		 * 
		 * @param	name
		 * @param	obj
		 * @return
		 */
		private function findChildByName( name:String, obj:DisplayObject3D = null ):DisplayObject3D
		{
			obj = obj || this;
	
			if( obj.name.toLowerCase() == name.toLowerCase() )
				return obj;
				
			for each( var child:DisplayObject3D in obj.children )
			{
				var c:DisplayObject3D = findChildByName(name, child);
				if( c )
					return c;
			}
			return null;
		}
	
		/**
		 * 
		 * @param	raw
		 * @return
		 */
		private function isBVH( raw:String ):Boolean
		{
			return (raw.indexOf("HIERARCHY") != -1 && 
					raw.indexOf("ROOT") != -1 &&
					raw.indexOf("MOTION") != -1);
		}

		/**
		 * 
		 * @param	obj
		 * @return
		 */
		private function setPoseMode( obj:DisplayObject3D ):void
		{
			if( _poses[ obj] )
			{
				var v:Vertex3D = _poses[ obj ];
				obj.x = v.x;
				obj.y = v.y;
				obj.z = v.z;
				obj.transform.copy3x3(Matrix3D.IDENTITY);
			}
			
			for each( var child:DisplayObject3D in obj.children )
				setPoseMode(child);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function dispatchFileComplete( event:TimerEvent ):void
		{
			dispatchEvent( new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, "bvh") );
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadCompleteHandler( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			parse( String(loader.data) );
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent( event );
		}
		
		/** */
		private var stickModel:Lines3D;
		
		/** */
		private var _poses:Dictionary;

		/** */
		private var _delayTimer:Timer;
		
		/** */
		private var _mode:uint = 0;
	}	
}
