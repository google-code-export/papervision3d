package org.papervision3d.core.render.hit
{
	import org.papervision3d.core.geom.renderables.IRenderable;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class RenderHitData
	{
		public var displayObject3D:DisplayObject3D;
		public var renderable:IRenderable;
		
		
		public function toString():String
		{
			return displayObject3D +" "+renderable;
		}
	}
}