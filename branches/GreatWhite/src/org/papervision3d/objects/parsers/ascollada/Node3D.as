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
 
package org.papervision3d.objects.parsers.ascollada
{
	// import papervision
	
	import org.papervision3d.core.geom.AnimatedMesh3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;	

	public class Node3D extends AnimatedMesh3D 
	{	
		public var daeID:String;
		
		public var daeSID:String;
		
		public var blendVerts:Array;
		
		public var bindMatrix:Matrix3D;
		
		public var matrixStack:Array;
		
		public var transforms:Array;
		
		/**
		 * 
		 * @param	daeName
		 * @param	daeID
		 * @param	daeSID
		 * @param	c
		 * @return
		 */
		public function Node3D( daeName:String, daeID:String, daeSID:String = null, c:uint = 0xffff00 ):void 
		{
			super(new WireframeMaterial(), new Array(), new Array(), daeName);
			
			this.daeID = daeID;
			this.daeSID = daeSID || daeID;
			this.transform = Matrix3D.IDENTITY;
			this.world = Matrix3D.IDENTITY;
			this.bindMatrix = Matrix3D.IDENTITY;
			this.blendVerts = new Array();
			
			this.matrixStack = new Array();
			this.transforms = new Array();
		}
	}
}
