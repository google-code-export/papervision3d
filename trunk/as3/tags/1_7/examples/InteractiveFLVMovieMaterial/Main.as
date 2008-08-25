package {
	
	import flash.display.BitmapData;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.InteractiveScene3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Sphere;

	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Matrix;

	[SWF(backgroundColor="0xFFFFFF", frameRate="31")]
	public class Main extends Sprite 
	{		
		protected var container 				:Sprite;
		protected var scene     				:InteractiveScene3D;
		protected var camera   					:Camera3D;
		protected var ism						:InteractiveSceneManager;
		protected var plane	 	 				:Plane;
		
		public function Main() 
		{
			init();
		}
		public function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			init3D();
			createPlane();
			addEventListener(Event.ENTER_FRAME, loop);
		}
	
		protected function init3D():void {
			container = new InteractiveSprite();
			addChild(container);
			container.name = "mainCont";
			container.x = stage.stageWidth*.5;
			container.y = stage.stageHeight*.5;
	
			scene = new InteractiveScene3D(container);
			ism = scene.interactiveSceneManager;
			ism.faceLevelMode = false;
			
			camera = new Camera3D();
			camera.zoom = 2;
			camera.focus = 500;
		}
		
		protected function createPlane():void 
		{
			var material:InteractiveMovieAssetMaterial = new InteractiveMovieAssetMaterial("flv", false, true);
			
			plane = new Plane( material, 500, 500, 4, 4 );
			getMovie().gotoAndStop(1);
			plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, handlePlaneClick);
			scene.addChild(plane);
		}
		protected function handlePlaneClick(e:InteractiveScene3DEvent):void
		{
			trace("click");
			getMovie().gotoAndPlay(1);
		}
		protected function getMovie():MovieClip
		{
			return InteractiveMovieAssetMaterial(plane.material).movie as MovieClip;
		}
		protected function loop(event:Event):void {
			camera.x = -(container.mouseX * 3)/2;
			camera.y = (container.mouseY * 3);
			scene.renderCamera(camera);
		}
	}
}



