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
 
package org.ascollada.core {
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeEntity;
	import org.ascollada.core.DaeInstanceController;
	import org.ascollada.core.DaeInstanceGeometry;
	import org.ascollada.types.DaeTransform;	

	/**
	 * 
	 */
	public class DaeNode extends DaeEntity
	{
		public static const TYPE_NODE:uint = 0;
		public static const TYPE_JOINT:uint = 1;
		
		/** node type, can be TYPE_NODE or TYPE_JOINT */
		public var type:uint;
		
		/** array of childnodes */
		public var nodes:Array;
		
		/** array of matrices for this node, we need to post-multiply later */
		public var matrices:Array;
		
		/** array of transform sid's */
		public var matrix_sids:Array;
		
		/** */
		public var matrix_types:Array;
		
		public var transforms:Array;
		
		/** array of controller instances */
		public var controllers:Array;
		
		/** array of geometry instances */
		public var geometries:Array;
		
		/** array of instance_node instances */
		public var instance_nodes:Array;
		
		/** array of instance_cameras */
		public var instance_cameras:Array;
		
		private var _yUp:uint;
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		public function DaeNode( node:XML = null, yUp:uint = 1 ):void
		{
			_yUp = yUp;
			
			super( node );
		}

		/**
		 * 
		 * @param	id
		 * @return
		 */
		public function findController( id:String ):DaeInstanceController
		{
			for each( var ctrl:DaeInstanceController in this.controllers )
			{
				if( id == ctrl.id )
					return ctrl;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	sid
		 * @return
		 */
		public function findMatrixBySID( sid:String ):Array
		{
			for( var i:uint = 0; i < this.matrix_sids.length; i++ )
			{
				if( sid == this.matrix_sids[i] )
					return this.matrices[i];
			}
			return null;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{	
			this.nodes = new Array();
			this.matrices = new Array();
			this.matrix_sids = new Array();
			this.matrix_types = new Array();
			this.controllers = new Array();
			this.geometries = new Array();
			this.instance_nodes = new Array();
			this.instance_cameras = new Array();
			this.transforms = new Array();
			
			if( node.localName() != ASCollada.DAE_NODE_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_NODE_ELEMENT + "' element" );
				
			super.read( node );
								
			this.type = getAttribute(node, ASCollada.DAE_TYPE_ATTRIBUTE) == "JOINT" ? TYPE_JOINT : TYPE_NODE;
			
			//Logger.trace( "reading node: " + this.id + " name: " + this.name + " sid:" + this.sid + " type:" + this.type );
			
			var children:XMLList = node.children();
			var num:int = children.length();
			
			for( var i:int = 0; i < num; i++ )
			{
				var child:XML = children[i];
				var floats:Array;
				var csid:String = getAttribute(child, ASCollada.DAE_SID_ATTRIBUTE);
				
				switch( child.localName() )
				{	
					case ASCollada.DAE_ASSET_ELEMENT:
						break;
						
					case ASCollada.DAE_ROTATE_ELEMENT:			
						floats = getFloats(child);
						this.matrices.push(rotationMatrix(floats[0], floats[1], floats[2], floats[3]));
						this.matrix_sids.push( csid );
						this.matrix_types.push( "rotate" );
						this.transforms.push( new DaeTransform(ASCollada.DAE_ROTATE_ELEMENT, csid, floats) );
						break;
						
					case ASCollada.DAE_TRANSLATE_ELEMENT:
						floats = getFloats(child);
						this.matrices.push(translationMatrix(floats[0], floats[1], floats[2]));
						this.matrix_sids.push( csid );
						this.matrix_types.push( "translate" );
						this.transforms.push( new DaeTransform(ASCollada.DAE_TRANSLATE_ELEMENT, csid, floats) );
						break;
						
					case ASCollada.DAE_SCALE_ELEMENT:
						floats = getFloats(child);
						this.matrices.push(scaleMatrix(floats[0], floats[1], floats[2]));
						this.matrix_sids.push( csid );
						this.matrix_types.push( "scale" );
						this.transforms.push( new DaeTransform(ASCollada.DAE_SCALE_ELEMENT, csid, floats) );
						break;
						
					case ASCollada.DAE_SKEW_ELEMENT:
						floats = getFloats(child);
						break;
						
					case ASCollada.DAE_LOOKAT_ELEMENT:
						floats = getFloats(child);
						break;
						
					case ASCollada.DAE_MATRIX_ELEMENT:
						floats = getFloats(child);
						this.matrices.push( floats );
						this.matrix_sids.push( csid );
						this.transforms.push( new DaeTransform(ASCollada.DAE_MATRIX_ELEMENT, csid, floats) );
						break;
						
					case ASCollada.DAE_NODE_ELEMENT:
						this.nodes.push( new DaeNode(child, _yUp) );
						break;
					
					case ASCollada.DAE_INSTANCE_CAMERA_ELEMENT:
						this.instance_cameras.push(getAttribute(child, ASCollada.DAE_URL_ATTRIBUTE));
						break;
						
					case ASCollada.DAE_INSTANCE_CONTROLLER_ELEMENT:
						this.controllers.push( new DaeInstanceController( child ) );
						break;
					
					case ASCollada.DAE_INSTANCE_GEOMETRY_ELEMENT:
						this.geometries.push( new DaeInstanceGeometry( child ) );
						break;
					
					case ASCollada.DAE_INSTANCE_LIGHT_ELEMENT:
						break;
						
					case ASCollada.DAE_INSTANCE_NODE_ELEMENT:
						this.instance_nodes.push( new DaeInstanceNode(child) );
						break;
						
					case ASCollada.DAE_EXTRA_ELEMENT:
						break;
						
					default:
						break;
				}
			}
		}
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	rad
		 * @return
		 */
		private function rotationMatrix( x:Number, y:Number, z:Number, deg:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];

			var rad:Number = deg * (Math.PI/180);
			var nCos:Number	= Math.cos( rad );
			var nSin:Number	= Math.sin( rad );
			var scos:Number	= 1 - nCos;

			var sxy	:Number = x * y * scos;
			var syz	:Number = y * z * scos;
			var sxz	:Number = x * z * scos;
			var sz	:Number = nSin * z;
			var sy	:Number = nSin * y;
			var sx	:Number = nSin * x;

			m[0] =  nCos + x * x * scos;
			m[1] = -sz   + sxy;
			m[2] =  sy   + sxz;

			m[4] =  sz   + sxy;
			m[5] =  nCos + y * y * scos;
			m[6] = -sx   + syz;

			m[8] = -sy   + sxz;
			m[9] =  sx   + syz;
			m[10] =  nCos + z * z * scos;

			return m;			
		}

		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		public function scaleMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			m[0] = x;
			m[5] = y;
			m[10] = z;
			
			return m;
		}
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		public function translationMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			m[3] = x;
			m[7] = y;
			m[11] = z;
			
			return m;
		}
	}	
}
