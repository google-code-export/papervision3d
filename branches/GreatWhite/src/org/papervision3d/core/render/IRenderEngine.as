package org.papervision3d.core.render
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public interface IRenderEngine
	{
		function addToRenderList(renderCommand:IRenderListItem):int;
		function removeFromRenderList(renderCommand:IRenderListItem):int;
	}

}