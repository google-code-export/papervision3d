package org.papervision3d.core.render.command
{
	import org.papervision3d.core.render.data.RenderSessionData;

	public class AbstractRenderListItem implements IRenderListItem
	{
		public var renderable:Class;
		public var screenDepth:Number;
	
		public function render(renderSessionData:RenderSessionData):void
		{
			
		}
		
	}
}