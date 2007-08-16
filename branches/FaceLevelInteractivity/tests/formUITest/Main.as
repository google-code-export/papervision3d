package {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.display.Stage;
	import flash.events.*;
//	import fl.motion.MatrixTransformer;
	import flash.geom.ColorTransform;
	//import flash.utils.Dictionary;
	
	// Import Papervision3D
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	import org.papervision3d.utils.virtualmouse.IVirtualMouseEvent;
	
	/**
	 *	Sorry about the changes I had to make to this class to make it work with CS3 as a class.  I hate the way they implemented stage instances...
	 *  Jim Kremens 
	*/
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		var container :Sprite;
		var scene     :InteractiveScene3D;
		var camera    :Camera3D;
		var ism		  :InteractiveSceneManager;
		var plane	  :Plane;
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
			
			InteractiveSceneManager.SHOW_DRAWN_FACES = false;
			//InteractiveSceneManager.DEFAULT_LINE_COLOR = 0xFFFFFF;
			InteractiveSceneManager.DEFAULT_SPRITE_ALPHA = 0;
			InteractiveSceneManager.DEFAULT_FILL_ALPHA = 1;
			
			BitmapMaterial.AUTO_MIP_MAPPING = false;
			DisplayObject3D.faceLevelMode = false;
			
			ism.buttonMode = true;
			ism.faceLevelMode = true;											
			ism.mouseInteractionMode = false;
			
			createPlane(-20, 350);
			createPlane(20, -350);

			// Create camera
			camera = new Camera3D();
			camera.zoom = 5;
			
		}
		// ___________________________________________________________________ Create album
		//var mouseIsDown:Boolean;
		
		public function createPlane(yaw=20, left:Number=250):void
		{
			//var material:MovieMaterial = new InteractiveMovieMaterial( new canvas() );
			var material:MovieMaterial = new InteractiveMovieMaterial( this.formUI );
		
			//material.doubleSided = true;
			//material.lineColor = 0xFFFFFF;
			material.animated = true;
			material.smooth = true;
			
			material.movie["btn"].drawNow();
			material.movie["txt"].drawNow();
			material.movie["label"].drawNow();
			material.movie["combobox"].drawNow();
			material.movie["numericstepper"].drawNow();
			material.movie["radio"].drawNow();
			material.movie["slider"].drawNow();
			
			material.movie["btn"].addEventListener(MouseEvent.CLICK, handleBTNClick);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OVER, handleBTNOver);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OUT, handleBTNOut);
			
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OVER, handleB1Over);
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OUT, handleB1Out)
			
			material.updateBitmap();
			
			var plane = new Plane( material, 500, 500, 8, 8 );
			plane.yaw(yaw);
			plane.moveLeft(left);

			scene.addChild(plane);
		}
		
		function handleBTNClick(e:MouseEvent):void
		{
			trace("vMouse click from btn");
			if (e is IVirtualMouseEvent) trace("IVirtualMouseEvent click from btn");
		
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleBTNOver(e:MouseEvent):void
		{
			trace("over");
			//e.currentTarget.invalidate();
			e.currentTarget.setMouseState("over");
			e.currentTarget.drawNow();
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleBTNOut(e:MouseEvent):void
		{
			trace("out");
			//e.currentTarget.invalidate();
			e.currentTarget.setMouseState("up");
			e.currentTarget.drawNow();
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleB1Over(e:MouseEvent):void
		{
			trace("over");
			e.currentTarget.blendMode = BlendMode.ADD;
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleB1Out(e:MouseEvent):void
		{
			trace("out");
			e.currentTarget.blendMode = BlendMode.NORMAL;
		}
		
		// ___________________________________________________________________ Loop
		
		function loop(event:Event):void 
		{
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