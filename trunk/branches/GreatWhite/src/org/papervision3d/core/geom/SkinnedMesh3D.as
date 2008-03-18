package org.papervision3d.core.geom
{
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;

	public class SkinnedMesh3D extends Joint3D
	{
		/** */
		public var joints:Array;
		
		/** */
		public var skeletons:Array;
		
		/** */
		public var bindShapeMatrix:Matrix3D;
		
		/**
		 * Constructor.
		 * 
		 * @param	material
		 * @param	vertices
		 * @param	faces
		 * @param	name
		 * @param	initObject
		 */ 
		public function SkinnedMesh3D(material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null)
		{
			super(material, vertices, faces, name, initObject);
			
			this.joints = new Array();
			this.skeletons = new Array();
			this.bindShapeMatrix = null;
			
			_root = DisplayObject3D.ZERO;
		}
		
		/**
		 * Project.
		 *
		 * @param	parent
		 * @param	renderSessionData
		 *
		 * @return
		 */
		override public function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			if(!this.bindShapeMatrix)
				return 0;
				
			if(!_cached)
				cacheVertices();
			
			if(joints.length)
			{
				var i:int;	
				var vertices:Array = this.geometry.vertices;
				var skeletons:Array = this.skeletons;
				var joints:Array = this.joints;
				
				// reset mesh's vertices to 0
				for(i = 0; i < vertices.length; i++)
					vertices[i].x = vertices[i].y = vertices[i].z = 0;
				
				// project the skeletons
				for(i = 0; i < skeletons.length; i++)
					skeletons[i].project(_root, renderSessionData);
				
				// skin the mesh!
				for(i = 0; i < joints.length; i++)
					skin(joints[i], _cached, vertices);
			}
			
			return super.project(parent, renderSessionData);
		}
		
		/**
		 * Cache original vertices.
		 */
		private function cacheVertices():void
		{
			var vertices:Array = this.geometry.vertices;
			var i:int;
			
			_cached = new Array(vertices.length);
			
			for( i = 0; i < vertices.length; i++ )
			{
				_cached[i] = new Number3D(vertices[i].x, vertices[i].y, vertices[i].z);
				Matrix3D.multiplyVector(this.bindShapeMatrix, _cached[i]);
			}
		}
		
		/**
		 * skins the mesh.
		 * 
		 * @param	joint
		 * @param	meshVerts
		 * @param	skinnedVerts
		 */
		private function skin(joint:Joint3D, meshVerts:Array, skinnedVerts:Array):void
		{
			var i:int;
			var pos:Number3D = new Number3D();
			var original:Number3D;
			var skinned:Vertex3D;
			var vertexWeights:Array = joint.vertexWeights;
			
			var matrix:Matrix3D = Matrix3D.multiply(joint.world, joint.inverseBindMatrix);
		
			for( i = 0; i < vertexWeights.length; i++ )
			{
				var weight:Number = vertexWeights[i].weight;
				var vertexIndex:int = vertexWeights[i].vertexId;

				if( weight <= 0.0001 || weight >= 1.0001) continue;
								
				original = meshVerts[ vertexIndex ];	
				skinned = skinnedVerts[ vertexIndex ];
				
				pos.x = original.x;
				pos.y = original.y;
				pos.z = original.z;
							
				// joint transform
				Matrix3D.multiplyVector(matrix, pos);	

				//update the vertex
				skinned.x += (pos.x * weight) ;
				skinned.y += (pos.y * weight) ;
				skinned.z += (pos.z * weight) ;
			}
		}
		
		/** Copy of the mesh's original vertices. */
		private var _cached:Array;
		
		/** */
		private var _root:DisplayObject3D;
	}
}