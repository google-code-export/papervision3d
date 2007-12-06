package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.renderables.Particle;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;

	public class RectangleParticleCuller implements IParticleCuller
	{
		private static var vInstance:Vertex3DInstance;
		private static var testPoint:Point;
		
		public var cullingRectangle:Rectangle;
		
		public function RectangleParticleCuller(cullingRectangle:Rectangle = null)
		{
			this.cullingRectangle = cullingRectangle;
			testPoint = new Point();
		}
		
		public function testParticle(particle:Particle):Boolean
		{
			vInstance = particle.vertex3D.vertex3DInstance;
			if(vInstance.visible){
				testPoint.x = vInstance.x;
				testPoint.y = vInstance.y;
				if(cullingRectangle.containsPoint(testPoint)){
					return true;
				}
			}
			return false;
		}
		
	}
}