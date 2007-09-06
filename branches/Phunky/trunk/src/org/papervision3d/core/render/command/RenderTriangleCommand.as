package org.papervision3d.core.render.command
{

	import flash.display.Sprite;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	public class RenderTriangleCommand extends AbstractRenderCommand implements IRenderCommand
	{
		//Avoiding vars in the main loop.
		private static var container:Sprite;
		private static var renderMat:MaterialObject3D;
		
		public var face:Triangle3D;
		
		public function RenderTriangleCommand(face:Triangle3D):void
		{
			this.face = face;
		}
		
		override public function execute(renderSessionData:RenderSessionData):void
		{
			container = face.instance.container ? face.instance.container : renderSessionData.container;
			renderMat = face.material ? face.material : face.instance.material;
			renderMat.drawFace3D(face, container.graphics, face.v0.vertex3DInstance, face.v1.vertex3DInstance, face.v2.vertex3DInstance);
		}
		
	}
}