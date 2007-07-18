package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;

	public class CompositeTriangleCuller implements ITriangleCuller
	{
		
		private static var cullers:Array = new Array();
		
		static public function addCuller(culler:ITriangleCuller):void
		{
			cullers.push(culler);
		}
		
		static public function removeCuller(culler:ITriangleCuller):void
		{
				
		}
		
		public static function clearCullers():void
		{
			cullers = new Array();
		}
		
		static public function testFace(faceInstance:Face3D, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			for each(var culler:ITriangleCuller in cullers){
				
			}
			return false;
		}
		
	}
}