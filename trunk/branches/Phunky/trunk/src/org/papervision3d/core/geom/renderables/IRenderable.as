package org.papervision3d.core.geom.renderables
{
	import org.papervision3d.core.render.command.IRenderCommand;
	
	public interface IRenderable
	{
		function getRenderCommand():IRenderCommand;
	}
}