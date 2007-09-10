/**
* ...
* @author John Grden
* @version 0.2 
*/

package org.papervision3d.core.render 
{
	import flash.display.Sprite;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.core.stat.RenderStatistics;
	import org.papervision3d.utils.InteractiveSceneManager;

	public class InteractiveRendererEngine extends BasicRenderEngine
	{
		
		public var interactiveSceneManager:InteractiveSceneManager = null;
		
		public function InteractiveRendererEngine() 
		{
			super();
		}
		
		// not sure this is needed yet
		override protected function init():void
		{
			super.init();
			interactiveSceneManager = new InteractiveSceneManager(scene, container, camera);
		}
		
		override public function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics
		{
			return super.render(scene, container, camera);
		}
	}
	
}
