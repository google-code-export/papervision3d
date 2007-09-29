package org.papervision3d.core.render.data
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.display.Sprite;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.IRenderEngine;
	import org.papervision3d.core.stat.RenderStatistics;
	
	public class RenderSessionData
	{
		public var container:Sprite;
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var renderer:IRenderEngine;
		public var renderStatistics:RenderStatistics;
		
		public function RenderSessionData():void
		{
			
		}
		
	}
}