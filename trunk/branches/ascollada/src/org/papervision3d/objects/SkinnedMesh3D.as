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
	import org.papervision3d.objects.AnimatedMesh3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Bone3D;
	
	/**
	 * 
	 */
	public class SkinnedMesh3D extends AnimatedMesh3D
	{		
		public var bindShapeMatrix:Matrix3D;
		
		/**
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 * @return
		 */
		public function SkinnedMesh3D( material:MaterialObject3D, vertices:Array, faces:Array, name:String = null, initObject:Object = null ):void
		{
			super( material, vertices, faces, name, initObject );
			
			_cached = new Array();
			_curFrame = 0;
			_startTime = getTimer();
			
			this.bindShapeMatrix = Matrix3D.IDENTITY;
		}
		
		public function get channel():DaeChannel { return this._channel; }
		public function set channel( ch:DaeChannel ):void
		{
			this._channel = ch; 
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		public function set skeleton( node:Bone3D ):void
		{
			_skeleton = node;
		}
		
		public function get skeleton():Bone3D
		{
			return _skeleton;
		}
		
		/**
		 * 
		 */
		public function initBindShape():void
		{
			var vertices:Array = this.geometry.vertices;
			
			_cached = new Array( vertices.length );
			
			Logger.trace( "bindShapeMatrix: " + this.bindShapeMatrix.toString() );
			
			for( var i:int = 0; i < vertices.length; i++ )
			{				
				var v:Vertex3D = vertices[i];
				
				_cached[i] = new Number3D(v.x, v.y, v.z);
				
				// move verts to bind pose
				Matrix3D.multiplyVector( this.bindShapeMatrix, _cached[i] );
			}	
		}
		
		/**
		 * calculate animation for a bone.
		 */
		public function calcAnimation( bone:Bone3D, dt:Number ):void
		{
			var matrix:Matrix3D;
			
			if( bone.channel )
				matrix = new Matrix3D( bone.channel.update(dt) );
			else
				matrix = Matrix3D.clone( bone.initMatrix );
				 
			bone.transformMatrix = matrix;
			for ( var i:int = 0; i < bone.children.length; i++ )
				calcAnimation( bone.children[i], dt );
		}
		
		/**
		 * computes world matrix for a bone.
		 * 
		 * @param	bone
		 * @param	parentMatrix
		 */
		public function computeWorldMatrix( bone:Bone3D, parentMatrix:Matrix3D ):void
		{				
			if( parentMatrix )
				bone.worldMatrix = Matrix3D.multiply( parentMatrix, bone.transformMatrix );
			else
				bone.worldMatrix = bone.transformMatrix;
			
			bone.transformMatrix = Matrix3D.multiply( bone.worldMatrix, bone.bindMatrix );
			
			for ( var i:int = 0; i < bone.children.length; i++ )
				computeWorldMatrix( bone.children[i], bone.worldMatrix );
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
			var st:Number = getTimer();
			
			if( _cached.length == this.geometry.vertices.length )
			{				
				var verts:Array = this.geometry.vertices;
				var i:int = verts.length;
				var v:Vertex3D;
				
				// reset verts to 0
				while( v = verts[ --i ] )
					v.x = v.y = v.z = 0;
				
				var dt:Number = (getTimer() - _startTime) / 1000;
								
				//dt *= 0.02;
					
				if( dt > 15 )
					_startTime = getTimer();

				calcAnimation( this.skeleton, dt );
				
				// compute skeleton
				computeWorldMatrix( this.skeleton, Matrix3D.IDENTITY );
				
				// skin mesh!
				skinMesh( this.skeleton, this._cached, this.geometry.vertices );
			}
			
			var num:Number = super.project( parent, camera, sorted );
			
			var et:Number = (getTimer()-st)/1000;
				
			//Logger.trace( "verts: " + this.geometry.vertices );
			//Logger.debug("num: " + num + " et: " + et + " " + verts.length + " cached:" + _cached.length);
				
			return num;
		}
		
		override public function render( scene :SceneObject3D ):void
		{
			var st:Number = getTimer();
			
			super.render(scene);
			
			var et:Number = (getTimer()-st)/1000;
			
			Logger.debug( "render: " + et );
		}
		
		/**
		 * skins an array of vertices.
		 * 
		 * <p>The skinning calculation for each vertex v in a bind shape is:
		 *  outv = ((v * BSM)* IBMi * JMi)* JW
		 *	where:
		 *		- n is the number of joints that influence vertex v
		 *		- BSM is bind shape matrix
		 *		- IBMi is inverse bind matrix of joint i
		 *		- JMi is joint matrix of joint i
		 *		- JW is joint weight/influence of joint i on vertex v
		 * 
		 *		Common optimizations include:
		 *		- (v * BSM) is calculated and stored at load time.</p>
		 * 
		 * @param	bone
		 * @param	meshVerts
		 * @param	skinnedVerts
		 */
		public function skinMesh( bone:Bone3D, meshVerts:Array, skinnedVerts:Array ):void
		{
			var i:int;
			var pos:Number3D = new Number3D();

			//Logger.trace( "skinMesh: bone + " + bone.id + "\n" + bone.blendVerts.length );
			
			for( i = 0; i < bone.blendVerts.length; i++ )
			{
				var bw:DaeBlendWeight = bone.blendVerts[i] as DaeBlendWeight;
				
				if( bw.weight <= 0.0001 || bw.weight >= 1.0001) continue;
				
				var v:* = meshVerts[ bw.vertexIndex ];	
				
				pos.x = v.x;
				pos.y = v.y;
				pos.z = v.z;
				
				//bone.transform
				Matrix3D.multiplyVector( bone.transformMatrix, pos );	
		
				//update the vertex
				skinnedVerts[ bw.vertexIndex ].x += (pos.x * bw.weight) ;
				skinnedVerts[ bw.vertexIndex ].z += (pos.y * bw.weight) ;
				skinnedVerts[ bw.vertexIndex ].y += (pos.z * bw.weight) ;
			}
			
			for ( i = 0; i < bone.children.length; i++ )
				skinMesh( bone.children[i], meshVerts, skinnedVerts );
		}
				
		private var _skeleton:Bone3D;
		
		private var _cached:Array;
		
		private var _channel:DaeChannel;
		
		private var _curFrame:Number; 
		
		private var _startTime:Number;
	}	
}
