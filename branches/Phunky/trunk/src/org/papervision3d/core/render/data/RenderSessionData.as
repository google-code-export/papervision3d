package org.papervision3d.core.render.data
{
	import flash.display.Sprite;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.IRenderEngine;
	
	public class RenderSessionData
	{
		public var container:Sprite;
		public var scene:SceneObject3D;
		public var camera:CameraObject3D;
		public var renderer:IRenderEngine;
		
		public function RenderSessionData():void
		{
			
		}
		
	}
}