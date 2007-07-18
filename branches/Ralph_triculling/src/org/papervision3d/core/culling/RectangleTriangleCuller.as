package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;
	import flash.geom.Rectangle;

	public class RectangleTriangleCuller implements ITriangleCuller
	{
		private static const DEFAULT_RECT_X:Number = -160;
		private static const DEFAULT_RECT_Y:Number = -120;
		private static const DEFAULT_RECT_W:Number = 320;
		private static const DEFAULT_RECT_H:Number = 240;
		
		private static var hitRect:Rectangle = new Rectangle();
		
		public var cullingRectangle:Rectangle = new Rectangle(DEFAULT_RECT_X, DEFAULT_RECT_Y, DEFAULT_RECT_W, DEFAULT_RECT_W);
	
		/**
		 * @Author Ralph Hauwert
		 *
		 * RectangleTriangleCuller
		 * 
		 * This Triangle Culler culls faces based upon the visibility of it vertices and their visibility in a defined rectangle.
		 */
		public function RectangleTriangleCuller(cullingRectangle:Rectangle = null):void
		{
			if(cullingRectangle){
				this.cullingRectangle = cullingRectangle;	
			}
		}
		
		public function testFace(faceInstance:Object, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			if(vertex0.visible && vertex1.visible && vertex2.visible){
				hitRect.x = Math.min(vertex2.x, Math.min(vertex1.x, vertex0.x));
				hitRect.width = Math.max(vertex2.x, Math.max(vertex1.x, vertex0.x)) + Math.abs(hitRect.x);
				hitRect.y = Math.min(vertex2.y, Math.min(vertex1.y, vertex0.y));
				hitRect.height = Math.max(vertex2.y, Math.max(vertex1.y, vertex0.y)) + Math.abs(hitRect.y);
				return cullingRectangle.intersects(hitRect);	
			}
			
			return false;
		}
		
	}
}