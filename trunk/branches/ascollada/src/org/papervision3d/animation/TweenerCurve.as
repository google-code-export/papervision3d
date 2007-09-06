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
 
package org.papervision3d.animation
{
	import caurina.transitions.Tweener;
	import org.papervision3d.animation.core.AnimationCurve;
	
	/**
	 * 
	 */
	public class TweenerCurve extends AnimationCurve
	{
		/**
		 * 
		 * @param	target
		 * @param	targetProperty
		 * @param	keys
		 * @param	keyValues
		 * @param	interpolations
		 * @return
		 */
		public function TweenerCurve( target:Object, targetProperty:String, keys:Array = null, keyValues:Array = null, interpolations:Array = null ):void
		{
			super(target, targetProperty, keys, keyValues, interpolations);
		}
		
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		override public function update( dt:Number ):void
		{
			var params:Object = new Object();
			
			params.time = 0.001;
			
			params[targetProperty] = evaluate(dt);
			
			Tweener.addTween(target, params);
		}
	}
}
