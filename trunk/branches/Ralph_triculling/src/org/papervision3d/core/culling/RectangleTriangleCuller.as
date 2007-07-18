package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;
	import flash.geom.Rectangle;

	public class RectangleTriangleCuller implements ITriangleCuller
	{
		private const DEFAULT_RECT_X:Number;
		private const DEFAULT_RECT_Y:Number;
		private const DEFAULT_RECT_W:Number;
		private const DEFAULT_RECT_H:Number;
		
		private static var hitRect:Rectangle = new Rectangle();
		public static var cullingRectangle:Rectangle = new Rectangle(DEFAULT_RECT_X, DEFAULT_RECT_Y, DEFAULT_RECT_W, DEFAULT_RECT_W);
		
		static public function testFace(faceInstance:Face3D, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			hitRect.x = Math.min(vertex2.x, Math.min(vertex1.x, vertex0.x));
			hitRect.width = Math.max(vertex2.x, Math.max(vertex1.x, vertex0.x)) + Math.abs(minX);
			hitRect.y = Math.min(vertex2.y, Math.min(vertex1.y, vertex0.y));
			hitRect.height = Math.max(vertex2.y, Math.max(vertex1.y, vertex0.y)) + Math.abs(minY);
			
			return cullingRectangle.intersects(hitRect);
		}
		
	}
}