package org.papervision3d.core.render.command
{

	import flash.display.Sprite;
	
	import org.papervision3d.core.geom.renderables.IRenderable;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public class RenderTriangle extends RenderableListItem implements IRenderListItem
	{
		//Avoiding vars in the main loop.
		private static var container:Sprite;
		private static var renderMat:MaterialObject3D;
		
		public var renderableInstance:IRenderable;
		public var triangle:Triangle3D;
		
		public function RenderTriangle(triangle:Triangle3D):void
		{
			this.triangle = triangle;
			renderableInstance = triangle;
			renderable = Triangle3D;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			container = triangle.instance.container ? triangle.instance.container : renderSessionData.container;
			renderMat = triangle.material ? triangle.material : triangle.instance.material;
			renderMat.drawFace3D(triangle, container.graphics, triangle.v0.vertex3DInstance, triangle.v1.vertex3DInstance, triangle.v2.vertex3DInstance);
		}
		
	}
}