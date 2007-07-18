package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Vertex2D;
	
	public interface ITriangleCuller
	{
		function testFace(faceInstance:Object, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean;
	}
}