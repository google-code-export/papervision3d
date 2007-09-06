package org.papervision3d.core.draw
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface ITriangleDrawer
	{
		function drawFace3D(face3D:Triangle3D, graphics:Graphics, v0:Vertex3DInstance, v1:Vertex3DInstance, v2:Vertex3DInstance):int;
	}
}