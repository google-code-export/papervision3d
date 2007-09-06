package org.papervision3d.core.render
{
	import flash.display.Sprite;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.render.command.IRenderListItem;
	import org.papervision3d.core.stat.RenderStatistics;
	
	public interface IRenderEngine
	{
		function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics;
		function addToRenderList(renderCommand:IRenderListItem):int;
		function removeFromRenderList(renderCommand:IRenderListItem):int;
	}

}