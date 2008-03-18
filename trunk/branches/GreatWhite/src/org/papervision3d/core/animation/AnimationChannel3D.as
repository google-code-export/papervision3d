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
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip
	 */ 
	public class AnimationChannel3D
	{		
		public static const TYPE_SINGLE_PROPERTY:String = "single_prop";
		public static const TYPE_MATRIX:String = "matrix";
		public static const TYPE_TRANSLATE:String = "translate";
		public static const TYPE_ROTATE:String = "rotate";
		public static const TYPE_SCALE:String = "scale";
		public static const TYPE_MORPH:String = "morph";
		
		/** The target for this animation */
		public var target:DisplayObject3D;
		
		/** */
		public var minTime:Number;
		
		/** */
		public var maxTime:Number;
		
		/** */
		public var transformID:String;
		
		/** */
		public function get current():int { return _current; }
		
		/** */
		public function get next():int { return (_current+1) % _keyframes.length; }
		
		/** */
		public function get keyframes():Array { return _keyframes; }
		
		/** */
		public function get type():String { return _type; }
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function AnimationChannel3D(target:DisplayObject3D, property:*, type:String = TYPE_SINGLE_PROPERTY, transformID:String = null)
		{
			this.target = target;
			this.minTime = this.maxTime = 0;
			this.transformID = transformID;
			
			_keyframes = new Array();
			_current = 0;
			
			setTargetProperty(property, type);
		}
		
		public function tick(time:Number):void
		{
			time = time % this.maxTime;
			
			var cur:int = _current;
			for(var i:int = cur; i < _keyframes.length; i++, _current++)
			{
				if(_keyframes[i].time >= time)
					break;
			}
			_current = _current < _keyframes.length - 2 ? _current : 0;
			
			_currentKeyFrame = _keyframes[_current];
			_nextKeyFrame = _keyframes[(_current+1)%_keyframes.length];			
		}
		
		public function getOutputForTime(time:Number):Array
		{
			var cur:int = _current;
			for(var i:int = cur; i < _keyframes.length; i++, _current++)
			{
				if(_keyframes[i].time >= time)
					break;
			}
			_current = _current < _keyframes.length - 2 ? _current : 0;
			
			_currentKeyFrame = _keyframes[_current];
			_nextKeyFrame = _keyframes[(_current+1)%_keyframes.length];
			
			switch(_type)
			{
				case TYPE_MATRIX:
					return _currentKeyFrame.output;
				default:
					break;
			}
			
			return null;
		}
		
		/**
		 * Adds a new keyframe.
		 * 
		 * @param	keyframe
		 * 
		 * @return	The added keyframe.
		 */ 
		public function addKeyFrame(keyframe:AnimationKeyFrame3D):AnimationKeyFrame3D
		{
			switch(_type)
			{
				case TYPE_MATRIX:
					if(keyframe.output.length < 12)
						throw new Error("Expected at least 12 values! " + keyframe.output);
					break;
					
				case TYPE_MORPH:
					break;
				
				case TYPE_ROTATE:
					if(keyframe.output.length != 4)
						throw new Error("Expected exactly 4 values! " + keyframe.output);
					break;
					
				case TYPE_SCALE:
					if(keyframe.output.length != 3)
						throw new Error("Expected exactly 3 values! " + keyframe.output);
					break;
					
				case TYPE_TRANSLATE:
					if(keyframe.output.length != 3)
						throw new Error("Expected exactly 3 values! " + keyframe.output);
					break;
							
				case TYPE_SINGLE_PROPERTY:
				default:
					if(keyframe.output.length != 1)
						throw new Error("Expected a single value!");
					break;
			}
			
			if(_keyframes.length)
			{
				this.minTime = Math.min(this.minTime, keyframe.time);
				this.maxTime = Math.max(this.maxTime, keyframe.time);
			}
			else
			{
				this.minTime = this.maxTime = keyframe.time;
			}
			
			_keyframes.push(keyframe);
			_keyframes.sortOn("time", Array.NUMERIC);
			
			_current = 0;
			_currentKeyFrame = _keyframes[_current];
			_nextKeyFrame = _keyframes.length > 1 ? _keyframes[1] : _keyframes[_current];
			
			return keyframe;
		}
		
		/**
		 * Sets this channel's target property.
		 * 
		 * @param	property
		 * @param	type
		 */ 
		public function setTargetProperty(property:*, type:String = TYPE_SINGLE_PROPERTY):void
		{
			var prop:*;
			
			_type = type;
			
			switch(_type)
			{
				case TYPE_MATRIX:
				case TYPE_ROTATE:
				case TYPE_SCALE:
				case TYPE_TRANSLATE:
					if(!(property is Matrix3D))
						throw new Error("passed in property should be of type Matrix3D!");
					_matrixProperty = property as Matrix3D;
					break;

				case TYPE_MORPH:
					break;
							
				case TYPE_SINGLE_PROPERTY:
				default:
					if(!(property is String))
						throw new Error("passed in property should be of type String!");
					_type = TYPE_SINGLE_PROPERTY;
					_stringProperty = property as String;
					break;
			}		
		}
		
		/** */
		private var _type:String;
		
		/** */
		private var _keyframes:Array;
		
		/** */
		private var _stringProperty:String;
		
		/** */
		private var _arrayProperty:Array;
		
		/** */
		private var _matrixProperty:Matrix3D;
		
		/** */
		private var _currentKeyFrame:AnimationKeyFrame3D;
		
		/** */
		private var _nextKeyFrame:AnimationKeyFrame3D;
		
		/** */
		private var _current:uint;
	}
}