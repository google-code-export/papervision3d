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
import flash.display.DisplayObject;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import org.ascollada.core.DaeBlendWeight;
import org.ascollada.utils.Logger;
import org.papervision3d.core.*;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.objects.Node3D;

public class Skin3D extends Mesh3D
{
	public var bindPose:Matrix3D;
	
	public var joints:Array;
	
	/** 
	 *
	 * @param	material
	 * @param	vertices
	 * @param	faces
	 * @param	name
	 * @return
	 */
	public function Skin3D(material:MaterialObject3D, vertices:Array, faces:Array, name:String = null):void
	{
		super(material, vertices, faces, name);
		
		this.bindPose = Matrix3D.IDENTITY;
		this.joints = new Array();
	}
	
	/**
	 * 
	 * @return
	 */
	public function addController():void
	{
		
	}
	
	/**
	 * 
	 * @param	parent
	 * @param	camera
	 * @param	sorted
	 * @return
	 */
	override public function project( parent:DisplayObject3D, camera:CameraObject3D, sorted:Array = null ):Number
	{
		if( !_cached )
			cacheVertices();
		
		var verts:Array = this.geometry.vertices;
		var i:int = verts.length;
		var v:Vertex3D;
				
		// reset verts to 0
		while( v = verts[ --i ] )
			v.x = v.y = v.z = 0;
		
		for each( var joint:Node3D in this.joints )
			skinMesh(joint, _cached, this.geometry.vertices);

		return super.project(parent, camera, sorted);
	}
	
	/**
	 * 
	 * @return
	 */
	private function cacheVertices():void
	{
		var vertices:Array = this.geometry.vertices;
		_cached = new Array(vertices.length);
		for( var i:int = 0; i < vertices.length; i++ )
		{
			var v:Vertex3D = vertices[i];	
			_cached[i] = new Number3D(v.x, v.y, v.z);
		}
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
	 * @param	joint
	 * @param	meshVerts
	 * @param	skinnedVerts
	 */
	private function skinMesh( joint:Node3D, meshVerts:Array, skinnedVerts:Array ):void
	{
		var i:int;
		var pos:Number3D = new Number3D();
		var original:Number3D;
		var skinned:Vertex3D;
		var blendVerts:Array = joint.blendVerts;
		
		var matrix:Matrix3D = Matrix3D.multiply(joint.world, joint.bindMatrix);
		
		for( i = 0; i < blendVerts.length; i++ )
		{
			var bw:DaeBlendWeight = blendVerts[i] as DaeBlendWeight;
			
			if( bw.weight <= 0.0001 || bw.weight >= 1.0001) continue;
			
			original = meshVerts[ bw.vertexIndex ];	
			skinned = skinnedVerts[ bw.vertexIndex ];
			
			pos.x = original.x;
			pos.y = original.y;
			pos.z = original.z;
			
			// joint transform
			Matrix3D.multiplyVector( matrix, pos );	
			
			//update the vertex
			skinned.x += (pos.x * bw.weight) ;
			skinned.y += (pos.y * bw.weight) ;
			skinned.z += (pos.z * bw.weight) ;
		}
	}
	
	private var _cached:Array;
	
	private var _processed:Dictionary;
}
}