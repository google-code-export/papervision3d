package org.papervision3d.containers
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.core.Number3D;

	public class PapervisionView extends Sprite
	{
		
		private var isRendering:Boolean;
		
		public var scene3D:Scene3D;
		protected var papervisionSprite:Sprite;
		protected var camera3D:Camera3D;
		protected var clipSprite:Sprite;
		
		public function PapervisionView()
		{
			super();
			init();
		}
		
		private function init():void
		{
			papervisionSprite = new Sprite();
			clipSprite = new Sprite();
			scene3D = new Scene3D(papervisionSprite);
			camera3D = new Camera3D(null, 2, 200);
			
			x = 320;
			y = 240;
			
			
			addChild(papervisionSprite);
			addChild(clipSprite);
			setupScene();
			
			
			//addEventListener(Event.ADDED_TO_STAGE, onAdded);
			//addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		private function onAdded(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, onResize);	
		}
		
		private function onRemoved(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE, onResize);
		}
		
		private function onResize(event:Event):void
		{
			trace("onResize");
			//papervisionSprite.x = stage.stageWidth/2;
			//papervisionSprite.y = stage.stageHeight/2;
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