package org.papervision3d.core.geom.controller
{
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class AbstractController
	{
		public var target:DisplayObject3D;
		
		public function AbstractController(target:DisplayObject3D)
		{
			this.target = target;
		}
		
		public function apply(parent:DisplayObject3D, renderSessionData:RenderSessionData):void
		{
			
		}
	}
}