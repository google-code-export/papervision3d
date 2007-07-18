package 
{
	import com.blitzagency.xray.logger.XrayLog;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import mx.events.ResizeEvent;
	
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.MaterialsList;
	import org.papervision3d.materials.MovieAssetMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.Collada;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.InteractiveScene3D;
	import org.papervision3d.scenes.MovieScene3D;
	import flash.filters.BlurFilter;
	import flash.utils.setTimeout;

	public class Main extends Sprite
	{
		private var log						:XrayLog = new XrayLog();
		private var canvas					:Sprite = new Sprite();
		
		private var camera					:FreeCamera3D;
		private var scene3d					:InteractiveScene3D;
		private var collada					:Collada;
		private var mainCanvas				:DisplayObject3D = new DisplayObject3D("mainCanvas");
		private var colladaButton			:Sprite = null;
		private var group					:DisplayObject3D = null;
		private var button					:DisplayObject3D = null;
		private var bg						:DisplayObject3D = null;
		
		public function Main()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resetStage);
			stage.quality = "medium";
			setTimeout(init, 250);
		}
		
		public function init():void
		{	
			log.debug("init called");
			/*
			Create canvas and center it
			*/
			addChild(canvas);
			canvas.name = "canvas";
			resetStage();

			// create scene and camera
			scene3d = new InteractiveScene3D(canvas);
			scene3d.interactiveSceneManager.debug = true;
			camera = new FreeCamera3D();
			
			var matsList:MaterialsList = new MaterialsList();

			var bam:BitmapFileMaterial = new BitmapFileMaterial("http://www.rockonflash.com/demos/pv3d/InteractiveScene3D/images/sphereMaterial.png");
			matsList.addMaterial(bam, "sphereMaterial");

			collada = new Collada("http://www.rockonflash.com/demos/pv3d/InteractiveScene3D/spheres.DAE", matsList, .043);
			collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, handleLoadComplete);
			collada.addEventListener(FileLoadEvent.LOAD_ERROR, handleLoadError);
			collada.addEventListener(FileLoadEvent.SECURITY_LOAD_ERROR, handleSecurityLoadError);
			collada.name="myCollada";

			camera.focus=300;
			camera.zoom=1;
			camera.z = -1000;
		}
		
		public function resetStage(...rest):void
		{
			log.debug("resetStage called");
			canvas.x = stage.stageWidth*.5;
			canvas.y = stage.stageHeight*.5;
			graphics.beginFill(0x000000,1);
			graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight)
			graphics.endFill();
		}
		
		private function handleLoadComplete(e:FileLoadEvent):void
		{
			log.debug("handleLoadComplete called");
			scene3d.addChild(collada);
			
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, handleMousePress);
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, handleMouseRelease);
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, handleMouseClick);
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, handleMouseOver);
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, handleMouseOut);
			scene3d.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, handleMouseMove);
			
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleLoadError(e:FileLoadEvent):void
		{
			log.error("collada file failed to load", e.file);
		}
		
		private function handleSecurityLoadError(e:FileLoadEvent):void
		{
			log.error("collada file security error", e.file);
		}
		
		private function handleMousePress(e:InteractiveScene3DEvent):void
		{
			log.debug("press", e.displayObject3D.name);
			e.sprite.filters = [new GlowFilter(0xFFFFFF, 1, 20,20,3,1)];
			e.displayObject3D.moveUp(30);
		}
		
		private function handleMouseRelease(e:InteractiveScene3DEvent):void
		{
			log.debug("release", e.displayObject3D.name);
			e.sprite.filters = [];
			e.displayObject3D.moveDown(30);
		}
		
		private function handleMouseClick(e:InteractiveScene3DEvent):void
		{
			log.debug("click", e.displayObject3D.name);
			e.sprite.filters = [];
		}
		
		private function handleMouseOver(e:InteractiveScene3DEvent):void
		{
			log.debug("over", e.displayObject3D.name);
			e.sprite.filters = [new GlowFilter(0x20ADCD, .75, 20,20,2,1)];
		}
		
		private function handleMouseOut(e:InteractiveScene3DEvent):void
		{
			log.debug("out", e.displayObject3D.name);
			e.sprite.filters = [];
		}
		
		private function handleMouseMove(e:InteractiveScene3DEvent):void
		{
			log.debug("move", e.displayObject3D.name);
		}

		private function handleEnterFrame(e:Event):void
		{
			collada.yaw(.7);
			scene3d.renderCamera(camera);
		}
	}
}
