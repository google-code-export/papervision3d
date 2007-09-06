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
	import org.papervision3d.animation.TweenerCurve;
	import org.papervision3d.core.Matrix3D;
	
	/**
	 * 
	 */
	public class AnimationChannel
	{	
		public static const TYPE_TRANSFORM:String = "transform";
		public static const TYPE_ROTATE_X:String = "rotateX";
		public static const TYPE_ROTATE_Y:String = "rotateY";
		public static const TYPE_ROTATE_Z:String = "rotateZ";
		
		public static var curveClass:Class = AnimationCurve;
		
		public var curves:Array;
		
		/**
		 * 
		 * @return
		 */
		public function AnimationChannel():void
		{
			this.curves = new Array();
		}
		
		/**
		 * adds curves for a matrix.
		 * 
		 * @param	matrix
		 * @param	keys
		 * @param	values
		 * @param	interpolations
		 * @return
		 */
		public function addMatrixCurves( matrix:Matrix3D, keys:Array, values:Array, interpolations:Array ):void
		{
			var props:Array = [
				"n11", "n12", "n13", "n14",
				"n21", "n22", "n23", "n24",
				"n31", "n32", "n33", "n34"
				];
			
			var i:int, j:int;
			
			var tmpCurves:Array = new Array();
			for( i = 0; i < props.length; i++ )
				tmpCurves.push( new curveClass(matrix, props[i]) );
				
			for( i = 0; i < values.length; i++ )
			{
				for( j = 0; j < tmpCurves.length; j++ )
				{
					tmpCurves[j].keys[i] = keys[i];
					tmpCurves[j].keyValues[i] = values[i][j];
				}
			}
			
			this.curves = this.curves.concat(tmpCurves);
		}
		
		/**
		 * adds a single curve.
		 * 
		 * @param	curve
		 * @return
		 */
		public function addCurve( curve:AnimationCurve ):AnimationCurve
		{
			this.curves.push( curve );
			return curve;
		}
		
		/**
		 * 
		 * @param	curve
		 * @return
		 */
		public function removeCurve( curve:AnimationCurve ):AnimationCurve
		{
			var tmp:Array = new Array();
			var removed:AnimationCurve = null;
			for( var i:int = 0; i < this.curves.length; i++ )
			{
				if( this.curves[i] === curve )
					removed = this.curves[i];
				else
					tmp.push(this.curves[i]);
			}
			this.curves = tmp;
			return removed;
		}
		
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		public function update( dt:Number ):void
		{
			for( var i:int = 0; i < this.curves.length; i++ )
				this.curves[i].update(dt);
		}
	}
}
