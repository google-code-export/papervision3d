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
 
package org.papervision3d.objects {

	import flash.display.DisplayObject;
	import flash.utils.getTimer;

	// import papervision
	import org.papervision3d.animation.core.AnimationController;
	import org.papervision3d.core.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Node3D extends DisplayObject3D 
	{	
		public var sid:String;

		public var blendVerts:Array;
		
		public var bindMatrix:Matrix3D;
		
		public var controllers:Array;
		
		public var animate:Boolean;

		public static var dt:Number = 0;
		
		/**
		 * 
		 * @param	id
		 * @param	sid
		 * @return
		 */
		public function Node3D( id:String, sid:String = null ):void 
		{
			super(id);
			this.sid = sid || id;
			this.transform = Matrix3D.IDENTITY;
			this.world = Matrix3D.IDENTITY;
			this.bindMatrix = Matrix3D.IDENTITY;
			this.blendVerts = new Array();
			this.controllers = new Array();
			this.animate = true;
		}
		
		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		public override function project( parent:DisplayObject3D, camera:CameraObject3D, sorted :Array=null ):Number
		{
			if( animate )
			{
				for each( var controller:AnimationController in controllers )
					controller.update(dt);
			}

			return super.project(parent, camera, sorted);
		}
	}
}
