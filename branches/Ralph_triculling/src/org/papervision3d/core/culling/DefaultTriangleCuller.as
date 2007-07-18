package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.geom.Face3DInstance;
	import org.papervision3d.objects.DisplayObject3D;

	public class DefaultTriangleCuller implements ITriangleCuller
	{
		
		public function DefaultTriangleCuller()
		{
			
		}
		
		
		public function testFace(displayObject3D:DisplayObject3D, faceInstance:Face3DInstance, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			//Material checks & backface culling
			if(vertex0.visible && vertex1.visible && vertex2.visible){
				var material:MaterialObject3D = ( faceInstance.face.materialName && displayObject3D.materials )? displayObject3D.materials.materialsByName[ faceInstance.face.materialName ] : displayObject3D.material;
				
				if(material.invisible){
					return false
				};
				
				var x0:Number = vertex0.x;
				var y0:Number = vertex0.y;
				var x1:Number = vertex1.x;
				var y1:Number = vertex1.y;
				var x2:Number = vertex2.x;
				var y2:Number = vertex2.y;
				
				
				if( material.oneSide ){
					if( material.opposite ){
						if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) > 0 )
						{
							return false;
						}
					}else{
						if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) < 0 )
						{
							return false;
						}
					}
				}
				return true;
			}
			return false;
		}
		
	}
}