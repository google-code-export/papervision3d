package {
	
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	import org.papervision3d.utils.virtualmouse.IVirtualMouseEvent;
	import org.papervision3d.utils.InteractiveSceneManager;

	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	[SWF(backgroundColor="0xFFFFFF", frameRate="31")]
	public class Main extends Sprite {
		
		protected var container 				:Sprite;
		protected var scene     				:InteractiveScene3D;
		protected var camera   					:Camera3D;
		protected var plane	 	 				:Plane;
		protected var vMouse	  				:VirtualMouse;
		
		private var mc							:MovieClip;
		
		public function Main() {
			init();
		}
		public function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			createContent();
			init3D();
			createPlane();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		protected function createContent():void {
	 		mc = new MovieClip();
	 		mc.name = "mc";
			mc.graphics.beginFill( 0xFF3300, 100 );
			mc.graphics.drawRect(0, 0, 200, 200);
			mc.graphics.endFill();
		}
		protected function init3D():void {
			container = new InteractiveSprite();
			addChild(container);
			container.name = "mainCont";
			container.x = stage.stageWidth*.5;
			container.y = stage.stageHeight*.5;
	
			scene = new InteractiveScene3D(container);
						
			camera = new Camera3D();
			camera.zoom = 3;
			camera.focus = 500;
		}
		protected function createPlane():void {
			var material:MovieMaterial = new MovieMaterial(mc);
			material.animated = true;
			material.smooth = true;
			
			plane = new Plane( material, mc.width, mc.height, 8, 8 );
			scene.addChild(plane);
		}
		protected function loop(event:Event):void {
			camera.x = -(container.mouseX * 3)/2;
			camera.y = (container.mouseY * 3);
			scene.renderCamera(camera);
		}
	}
}



