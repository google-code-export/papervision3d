package org.papervision3d.core.geom.controller
{
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.special.Joint3D;
	import org.papervision3d.objects.special.Skin3D;

	public class SkinController extends AbstractController
	{
		/** */
		public var joints:Array;
		
		/** */
		public var skeletons:Array;
		
		/** */
		public var bindShapeMatrix:Matrix3D;
		
		/** */
		public var yUp:Boolean;
		
		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function SkinController(target:DisplayObject3D, yUp:Boolean = true)
		{
			super(target);
			
			this.yUp = yUp;
			this.joints = new Array();
			this.skeletons = new Array();
			this.bindShapeMatrix = null;
			
			_root = DisplayObject3D.ZERO;
		}
		
		/**
		 * Applies the controller to the target. @see #target
		 * 
		 */ 
		public override function apply():void
		{		
			if(!this.bindShapeMatrix || !this.joints || !this.joints.length || !this.skeletons.length)
				return;
				
			var i:int;	
			var vertices:Array = this.target.geometry.vertices;
			var skeletons:Array = this.skeletons;
			var joints:Array = this.joints;
			
			if(!(joints[0] is Joint3D) || !joints[this.joints.length-1].inverseBindMatrix)
				return;
		
			if(!_cached)
				cacheVertices();
							
			// reset mesh's vertices to 0
			for(i = 0; i < vertices.length; i++)
				vertices[i].x = vertices[i].y = vertices[i].z = 0;
			
			// project the skeletons
			for(i = 0; i < skeletons.length; i++)
			{
				//_root.transform = Matrix3D.IDENTITY;
				//skeletons[i].transform = Matrix3D.IDENTITY;
					
				//skeletons[i].project(_root, renderSessionData);
			}
			
			// skin the mesh!
			for(i = 0; i < joints.length; i++)
			{
				skin(joints[i], _cached, vertices);
			}
		}
		
		/**
		 * Cache original vertices.
		 */
		private function cacheVertices():void
		{
			var vertices:Array = this.target.geometry.vertices;
			var i:int;
			
			_cached = new Array(vertices.length);
						
			for( i = 0; i < vertices.length; i++ )
			{
				_cached[i] = new Number3D(vertices[i].x, vertices[i].y, vertices[i].z);
				
				Matrix3D.multiplyVector(this.bindShapeMatrix, _cached[i]);
			}
		}
		
		/**
		 * Skins a mesh.
		 * 
		 * @param	joint
		 * @param	meshVerts
		 * @param	skinnedVerts
		 */
		private function skin(joint:Joint3D, meshVerts:Array, skinnedVerts:Array):void
		{
			var sk:Skin3D;
			var i:int;
			var pos:Number3D = new Number3D();
			var original:Number3D;
			var skinned:Vertex3D;
			var vertexWeights:Array = joint.vertexWeights;
				
			var matrix:Matrix3D = Matrix3D.multiply(joint.world, joint.inverseBindMatrix);
			
			for( i = 0; i < vertexWeights.length; i++ )
			{
				var weight:Number = vertexWeights[i].weight;
				var vertexIndex:int = vertexWeights[i].vertexIndex;

				if( weight <= 0.0001 || weight >= 1.0001) continue;
								
				original = meshVerts[ vertexIndex ];	
				skinned = skinnedVerts[ vertexIndex ];
				
				pos.x = original.x;
				pos.y = original.y;
				pos.z = original.z;
							
				// joint transform
				Matrix3D.multiplyVector(matrix, pos);	

				//update the vertex
				if(yUp)
				{
					skinned.x += (pos.x * weight);
					skinned.y += (pos.y * weight);
					skinned.z += (pos.z * weight);
				}
				else
				{
					skinned.x += (pos.x * weight);
					skinned.y += (pos.z * weight);
					skinned.z += (pos.y * weight);
				}
			}
		}
		
		/** Copy of the mesh's original vertices. */
		private var _cached:Array;
		
		/** */
		private var _root:DisplayObject3D;
	}
}