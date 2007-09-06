package org.papervision3d.core.render.command
{
	import org.papervision3d.core.render.data.RenderSessionData;

	public class AbstractRenderCommand implements IRenderCommand
	{
		public var screenDepth:Number;
		
		public function execute(renderSessionData:RenderSessionData):void
		{
		}
		
	}
}