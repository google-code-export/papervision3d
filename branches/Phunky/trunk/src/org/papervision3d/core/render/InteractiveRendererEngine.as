/**
* ...
* @author John Grden
* @version 0.1
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
		}
		
		override public function render(scene:SceneObject3D, container:Sprite, camera:CameraObject3D):RenderStatistics
		{
			if( interactiveSceneManager == null ) interactiveSceneManager = new InteractiveSceneManager(scene, container, camera);
			return super.render(scene, container, camera);
		}
	}
	
}
