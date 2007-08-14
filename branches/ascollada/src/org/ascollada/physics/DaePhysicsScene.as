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
 
package org.ascollada.physics 
{
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeEntity;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaePhysicsScene extends DaeEntity
	{
		/**  
		 * A vector representation of the scene’s gravity force field. It is given as
		 * a denormalized direction vector of three floating-point values that
		 * indicate both the magnitude and direction of acceleration caused by
		 * the field.
		 */
		public var gravity:Array;
		
		/** 
		 * The integration time step, measured in seconds, of the physics scene.
		 * This value is engine-specific. If omitted, the physics engine's default is
		 * used. A floating-point number.
		 */
		public var time_step:Number;
		
		/**
		 * 
		 * @param	node
		 */
		public function DaePhysicsScene( node:XML = null )
		{
			super(node);
		}
		
		/**
		 * 
		 * @param	node
		 */
		override public function read( node:XML ):void
		{
			if( node.localName() != ASCollada.DAE_PHYSICS_SCENE_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_PHYSICS_SCENE_ELEMENT + "' element" );
				
			super.read( node );
			
			Logger.trace( "reading physics scene: " + this.id );
			
			var technique_common:XML = getNode(node, ASCollada.DAE_TECHNIQUE_COMMON_ELEMENT);
			
			var gravityNode:XML = getNode(technique_common, ASCollada.DAE_GRAVITY_ATTRIBUTE);
			var timeNode:XML = getNode(technique_common, ASCollada.DAE_TIME_STEP_ATTRIBUTE);
			
			this.gravity = gravityNode ? getFloats(gravityNode) : [0, 0.098, 0];
			this.time_step = timeNode ? parseFloat(getNodeContent(timeNode)) : 0.0;
		
			Logger.trace( " => gravity: " + this.gravity );
			Logger.trace( " => time_step: " + this.time_step );
		}
	}	
}
