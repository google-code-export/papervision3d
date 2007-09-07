package org.papervision3d.core.render
{
	import com.blitzagency.xray.logger.XrayLog;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import org.papervision3d.objects.DisplayObject3D;
	import com.blitzagency.xray.logger.util.ObjectTools;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.filter.IRenderFilter;
	import org.papervision3d.core.render.hit.RenderHitData;
	import org.papervision3d.core.render.sort.BasicRenderSorter;
	import org.papervision3d.core.render.sort.IRenderSorter;
	import org.papervision3d.core.stat.RenderStatistics;
	import org.papervision3d.events.RendererEvent;
	
	public class BasicRenderEngine extends EventDispatcher implements IRenderEngine
	{
		public var sorter:IRenderSorter;
		public var filter:IRenderFilter;
		
		private var renderStatistics:RenderStatistics;
		private var lastRenderList:Array;
		private var renderList:Array;
		private var renderSessionData:RenderSessionData;
		
		private var log:XrayLog = new XrayLog();
		
		public function BasicRenderEngine():void
		{
			init();			 
		}
		
		protected function init():void
		{
			renderStatistics = new RenderStatistics();
			sorter = new BasicRenderSorter();
			renderList = new Array();
			lastRenderList = new Array();
			renderSessionData = new RenderSessionData();
		}
		
		public function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics
		{
			//Sort entire list.
			sorter.sort(renderList);
			
			lastRenderList = new Array();
			
			renderSessionData.container = container;
			renderSessionData.camera = camera;
			renderSessionData.scene = scene;
			renderSessionData.renderer = this;
			
			var rc:IRenderListItem;
			while(rc = renderList.pop())
			{
				rc.render(renderSessionData);
				lastRenderList.push(rc);
			}
			
			dispatchEvent(new RendererEvent(RendererEvent.RENDER_DONE, renderSessionData));
			return renderStatistics;
		}
		
		public function hitTestPoint2D(point:Point):RenderHitData
		{
			var rli:RenderableListItem;
			var rhd:RenderHitData;
			var rc:IRenderListItem;
			
			while(rc = lastRenderList.pop())
			{	
				if(rc is RenderableListItem)
				{
					rli = rc as RenderableListItem;
					if((rhd = rli.hitTestPoint2D(point)))
					{							
						return rhd;
					}
				}
			}
			return null;
		}
		
		public function addToRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.push(renderCommand);
		}
		
		public function removeFromRenderList(renderCommand:IRenderListItem):int
		{
			return renderList.splice(renderList.indexOf(renderCommand),1);
		}

	}
}