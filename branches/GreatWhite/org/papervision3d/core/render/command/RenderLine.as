package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	
	
	import org.papervision3d.core.geom.renderables.Line3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.LineMaterial;

	public class RenderLine extends RenderableListItem implements IRenderListItem
	{
		
		public var line:Line3D;
		public var renderer:LineMaterial;
		
		public function RenderLine(line:Line3D)
		{
			super();
			this.renderable = Line3D;
			this.renderableInstance = line;
			this.line = line;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			renderer.drawLine(line, renderSessionData.container.graphics, renderSessionData);
		}
		
	}
}