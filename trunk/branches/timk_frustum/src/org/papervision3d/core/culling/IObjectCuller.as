package org.papervision3d.core.culling
{
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface IObjectCuller
	{
		function testObject( obj:DisplayObject3D ):int;
	}
}