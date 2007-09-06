package org.papervision3d.core.render.command
{
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public interface IRenderListItem
	{
		function render(renderSessionData:RenderSessionData):void;
	}
}