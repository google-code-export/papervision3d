package org.papervision3d.containers
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.scenes.Scene3D;

	public class PapervisionView extends Sprite
	{
		
		private var isRendering:Boolean;
		
		protected var scene3D:Scene3D;
		protected var papervisionSprite:Sprite;
		protected var camera3D:Camera3D;
		
		public function PapervisionView()
		{
			super();
			init();
		}
		
		private function init():void
		{
			papervisionSprite = new Sprite();
			scene3D = new Scene3D(papervisionSprite);
			camera3D = new Camera3D(null, 2, 100);
			
			addChild(papervisionSprite);
		
			setupScene();
		}
		
		protected function setupScene():void
		{
			
		}
		
		public function renderScene():void
		{
			scene3D.renderCamera(camera3D);
		}
		
		public function startRendering():void
		{
			if(!isRendering){
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				isRendering = true;
			}
		}
		
		public function stopRendering():void
		{
			if(isRendering){
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				isRendering = false;	
			}
		}
		
		protected function onEnterFrame(event:Event):void
		{
			renderScene();	
		}
		
	}
}