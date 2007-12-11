package org.papervision3d.core.render.data
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	public class RenderStatistics
	{
		public var projectionTime:int = 0;
		public var renderTime:int = 0;
		public var rendered:int = 0;
		public var triangles:int = 0;
		public var culledTriangles:int = 0;
		public var particles:Number = 0;
		public var lines:Number = 0;
		public var shadedTriangles:Number = 0;
		
		public function RenderStatistics()
		{
			
		}
		
		public function clear():void
		{
			projectionTime = 0;
			renderTime = 0;
			rendered = 0;
			particles = 0;
			triangles = 0;
			culledTriangles = 0;
			lines = 0;
			shadedTriangles = 0;
		}
		
		public function toString():String
		{
			return new String("ProjectionTime:"+projectionTime+" RenderTime:"+renderTime+" Particles:"+particles+" Triangles:"+triangles+" CulledTriangles:"+culledTriangles);
		}
		
	}
}