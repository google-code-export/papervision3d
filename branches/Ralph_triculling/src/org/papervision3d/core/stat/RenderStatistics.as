package org.papervision3d.core.stat
{
	public class RenderStatistics
	{
		public var performance:int;
		public var points:int;
		public var polys:int;
		public var rendered:int;
		public var triangles:int;
		
		public function RenderStatistics()
		{
			
		}
		
		public function toString():String
		{
			return new String("Performance:"+performance+", Points:"+points+" Polys:"+polys+" Rendered:"+rendered+" Triangles:"+triangles);
		}
		
	}
}