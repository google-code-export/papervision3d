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
 
package org.papervision3d.objects 
{
	import org.ascollada.core.DaeChannel;
	import org.ascollada.core.DaeNode;
	import org.ascollada.core.DaeSampler;
	import org.ascollada.utils.Logger;
	import org.papervision3d.core.Matrix3D;
	
	/**
	 * 
	 */
	public class Bone3D
	{
		public var id:String;
		
		public var name:String;
		
		public var blendVerts:Array;
		
		public var bindMatrix:Matrix3D;
		
		public var initMatrix:Matrix3D;
		
		public var transformMatrix:Matrix3D;
		
		public var worldMatrix:Matrix3D;
		
		public var children:Array;
				
		public var input:Array;
		
		public var output:Array;
		
		public var interpolations:Array;
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		public function Bone3D( node:DaeNode ):void
		{
			this.id = node.id;
			
			this.name = node.id;
			
			this.children = new Array();
			this.blendVerts = new Array();
			this.bindMatrix = Matrix3D.IDENTITY;
			this.initMatrix = Matrix3D.IDENTITY;
			this.transformMatrix = Matrix3D.IDENTITY;
			this.worldMatrix = Matrix3D.IDENTITY;
			
			this.input = new Array();
			this.output = new Array();
			this.interpolations = new Array();
		}
		
		public function get channel():DaeChannel { return this._channel; }
		public function set channel( ch:DaeChannel ):void
		{
			this._channel = ch; 
		}
		
		/**
		 * 
		 * @param	bone
		 * @param	indent
		 */
		public function printBone( bone:Bone3D, indent:String = "" ):void
		{
			Logger.trace( indent + bone.id + " #" + bone.blendVerts.length + " " + bone.blendVerts );
			for( var i:int = 0; i < bone.children.length; i++ )
				printBone( bone.children[i], indent + " -*-> " );
		}
		
		private var _channel:DaeChannel;
	}	
}
