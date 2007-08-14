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
	import flash.utils.getTimer;
	
	import org.ascollada.core.DaeBlendWeight;
	import org.ascollada.core.DaeChannel;
	import org.ascollada.core.DaeNode;
	import org.ascollada.core.DaeSampler;
	import org.ascollada.utils.Logger;
	
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Bone3D;
	
	/**
	 * 
	 */
	public class AnimatedMesh3D extends Mesh3D
	{		
		/**
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 * @return
		 */
		public function AnimatedMesh3D( material:MaterialObject3D, vertices:Array, faces:Array, name:String = null, initObject:Object = null ):void
		{
			super( material, vertices, faces, name, initObject );
			
			_curFrame = 0;
			_keys = new Array();
		}
		
		/**
		 * 
		 * @param	keys
		 * @param	values
		 * @param	interpolations
		 */
		public function addChannel( keys:Array, values:Array, interpolations:Array ):void
		{
			
		}
		
		/**
		 * 
		 */
		public function nextFrame():void
		{
			_curFrame = _curFrame < _keys.length - 1 ? _curFrame + 1 : 0;
		}
		
		private var _curFrame:uint;
		
		private var _keys:Array;
		
		private var _keyValues:Array;
	}
}
