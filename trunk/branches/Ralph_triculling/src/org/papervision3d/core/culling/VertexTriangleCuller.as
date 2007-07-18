package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;

	public class VertexTriangleCuller implements ITriangleCuller
	{
		/**
		 * @Author Ralph Hauwert
		 *
		 * VertexTriangleCuller
		 * 
		 * This Triangle Culler culls faces based upon the visibility of it vertices.
		 */
		public function VertexTriangleCuller()
		{
			
		}
		
		public function testFace(faceInstance:Object, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			return vertex0.visible && vertex1.visible && vertex2.visible;	
		}
		
	}
}