package org.papervision3d.core.render
{
	import flash.display.Scene;
	import flash.display.Sprite;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.command.AbstractRenderCommand;
	import org.papervision3d.core.render.command.IRenderCommand;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.filter.IRenderFilter;
	import org.papervision3d.core.render.sort.BasicRenderSorter;
	import org.papervision3d.core.render.sort.IRenderSorter;
	import org.papervision3d.core.stat.RenderStatistics;
	
	public class BasicRenderEngine implements IRenderEngine
	{
		public var sorter:IRenderSorter;
		public var filter:IRenderFilter;
		
		private var lastRenderList:Array;
		private var renderList:Array;
		private var renderSessionData:RenderSessionData;
		
		public function BasicRenderEngine():void
		{
			init();			
		}
		
		private function init():void
		{
			sorter = new BasicRenderSorter();
			renderList = new Array();
			lastRenderList = new Array();
			renderSessionData = new RenderSessionData();
		}
		
		public function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics
		{
			sorter.sort(renderList);
			
			lastRenderList = new Array();
			var renderStatistics:RenderStatistics = new RenderStatistics();
			
			renderSessionData.container = container;
			renderSessionData.camera = camera;
			renderSessionData.scene = scene;
	
			var rc:AbstractRenderCommand;
			while(rc = renderList.pop())
			{
				rc.execute(renderSessionData);
				lastRenderList.push(rc);
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