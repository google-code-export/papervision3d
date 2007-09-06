package org.papervision3d.core.render.command
{
	import flash.geom.Point;
	
	import org.papervision3d.core.geom.renderables.IRenderable;
	import org.papervision3d.core.render.hit.RenderHitData;
	
	public class RenderableListItem extends AbstractRenderListItem
	{
		
		public var renderable:Class;
		public var renderableInstance:IRenderable;
		
		public function RenderableListItem()
		{
			super();
		}
		
		public function hitTestPoint2D(point:Point):RenderHitData
		{
			return null;	
		}
		
	}
}