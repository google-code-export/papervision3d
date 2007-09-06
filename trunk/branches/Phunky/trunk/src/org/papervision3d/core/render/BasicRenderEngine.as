package org.papervision3d.core.render
{
	import flash.display.Sprite;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.command.AbstractRenderCommand;
	import org.papervision3d.core.render.command.IRenderCommand;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.stat.RenderStatistics;
	
	public class BasicRenderEngine implements IRenderEngine
	{
		private var renderList:Array;
		private var renderSessionData:RenderSessionData;
		
		public function BasicRenderEngine():void
		{
			init();			
		}
		
		private function init():void
		{
			renderList = new Array();
			renderSessionData = new RenderSessionData();
		}
		
		public function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics
		{
			var renderStatistics:RenderStatistics = new RenderStatistics();
			
			renderSessionData.container = container;
			renderSessionData.camera = camera;
			renderSessionData.scene = scene;
			renderList.sortOn("screenDepth", Array.NUMERIC);
			
			var rc:AbstractRenderCommand;
			while(rc = renderList.pop())
			{
				rc.execute(renderSessionData);
			}
			return renderStatistics;
		}
		
		public function addToRenderList(renderCommand:IRenderCommand):int
		{
			return renderList.push(renderCommand);
		}
		
		public function removeFromRenderList(renderCommand:IRenderCommand):int
		{
			return renderList.splice(renderList.indexOf(renderCommand),1);
		}

	}
}