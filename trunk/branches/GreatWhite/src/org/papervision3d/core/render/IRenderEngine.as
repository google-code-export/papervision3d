package org.papervision3d.core.render
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	import org.papervision3d.core.render.command.IRenderListItem;	 

	public interface IRenderEngine
	{
		function addToRenderList(renderCommand:IRenderListItem):int;
		function removeFromRenderList(renderCommand:IRenderListItem):int;
	}

}