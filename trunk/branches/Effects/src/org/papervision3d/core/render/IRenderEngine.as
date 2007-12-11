package org.papervision3d.core.render
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.geom.Point;
	
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.view.Viewport3D;
	
	public interface IRenderEngine
	{
		
		function hitTestPoint2D(point:Point, viewPort:Viewport3D):RenderHitData;
		function addToRenderList(renderCommand:IRenderListItem):int;
		function removeFromRenderList(renderCommand:IRenderListItem):int;
	}

}