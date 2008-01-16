package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.layers.RenderLayer;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.LineMaterial;

	public class RenderPixels extends RenderableListItem implements IRenderListItem
	{
		
		public var pixels:Pixels;
		public var renderer:LineMaterial;
		public var container:RenderLayer;
		
		public function RenderPixels(line:Line3D)
		{
			super();
			this.renderable = Line3D;
			this.renderableInstance = line;
			this.line = line;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			//container = line.instance.container;
			container =  line.instance.renderLayer || renderer.renderLayer || renderSessionData.defaultRenderLayer;
			container.faceCount++;
			container.screenDepth += this.screenDepth;			
			renderer.drawLine(line, container.drawLayer.graphics, renderSessionData);
		}
		
	}
}