package {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.display.Stage;
	import flash.display.BlendMode;
	import flash.events.*;
	
	// Import Papervision3D
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.InteractiveScene3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	import org.papervision3d.utils.virtualmouse.IVirtualMouseEvent;
	
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		var container :Sprite;
		var scene     :InteractiveScene3D;
		var camera    :Camera3D;
		var ism		  :InteractiveSceneManager;
		var sphere	  :Sphere;
		var mouse     :Mouse3D;
		var vMouse	  :VirtualMouse;
		
		public var formUI:MovieClip;
		
//		var formUI	  :MovieClip;
		var FS 		  :SimpleButton;
		
		public function Main() {
			init();
		}
		
		public function init():void {
				
			FS = new SimpleButton();
			FS.visible = stage.hasOwnProperty("displayState");
			FS.addEventListener( MouseEvent.CLICK, goFull );
			FS.x = 622;
			FS.y = 464;
			
			stage.scaleMode = "noScale"
			
			init3D();
			
			addChild( FS );
			
			addEventListener( Event.ENTER_FRAME, loop );
			
		}
		
		// ___________________________________________________________________ Init3D
		public function init3D():void {
			
			// Create container sprite and center it in the stage
			container = new InteractiveSprite();
			addChild( container );
			container.name = "mainCont";
			container.x = 320;
			container.y = 240;
		
			// Create scene
			scene = new InteractiveScene3D( container );
			ism = scene.interactiveSceneManager;
			
			// set SHOW_DRAWN_FACES = false if you don't want to see the overlay of sprites - this will also increase speed
			InteractiveSceneManager.SHOW_DRAWN_FACES = false;
			InteractiveSceneManager.DEFAULT_LINE_COLOR = 0x000000;
			InteractiveSceneManager.DEFAULT_FILL_COLOR = 0x003399;
			InteractiveSceneManager.DEFAULT_SPRITE_ALPHA = .3;
			InteractiveSceneManager.DEFAULT_FILL_ALPHA = 1;
			
			ism.buttonMode = true;
			ism.faceLevelMode = true;
			
			// add event to listen for mouse moves from the ISM
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, handleMouseMove);
			
			// create our simple sphere with an interactive material
			createSphere();

			// Create camera
			camera = new Camera3D();
			camera.zoom = 5;
			
		}
		// ___________________________________________________________________ Create album
		//var mouseIsDown:Boolean;

		public function createSphere():void
		{
			// canvas is in the library and set to export in first frame
			var material:MovieMaterial = new InteractiveMovieMaterial( new canvas() );
			material.lineColor = 0xffffff;
			material.lineThickness = .25;
			material.animated = true;
			material.smooth = true;
			material.allowAutoResize = false;
			
			sphere = new Sphere(material, 350, 12, 12);

			scene.addChild(sphere);
		}
		
		public function handleMouseMove(e:InteractiveScene3DEvent):void
		{
			// MOUSE_IS_DOWN is a publis static property of ISM
			if( !InteractiveSceneManager.MOUSE_IS_DOWN ) return;
			
			// grab the 2D coordinates
			var point:Object = InteractiveUtils.getMapCoordAtPoint(e.face3d, e.sprite.mouseX, e.sprite.mouseY);
			var mat:InteractiveMovieMaterial = InteractiveMovieMaterial(e.face3d.face3DInstance.instance.material);
			
			// get to the movieclip's level
			var movie:MovieClip = MovieClip(mat.movie);
			
			// draw
			movie.surface.graphics.beginFill(Math.random()*0xFFFFFF,2);
			movie.surface.graphics.drawCircle(point.x, point.y, 3)
			movie.surface.graphics.endFill();
		}
		
		// ___________________________________________________________________ Loop
		
		function loop(event:Event):void 
		{
			sphere.yaw(.3);
			scene.renderCamera( this.camera );
		
			FS.x = 640 + (stage.stageWidth - 640)/2;
			FS.y = 480 + (stage.stageHeight - 480)/2;
		}
		
		// ___________________________________________________________________ FullScreen
		
		function goFull(event:MouseEvent):void {
			if ( stage.hasOwnProperty("displayState") ) {
				if ( stage.displayState != "fullScreen" ) {
					stage.displayState = "fullScreen";
				} else {
					stage.displayState = "normal";
				}
			}
		}

	}
}