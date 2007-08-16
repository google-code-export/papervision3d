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
			mouse = ism.mouse;
			ism.enableMouse = true;
			
//			InteractiveSceneManager.SHOW_DRAWN_FACES = true;
//			InteractiveSceneManager.DEFAULT_LINE_COLOR = 0xFFFFFF;
//			InteractiveSceneManager.DEFAULT_SPRITE_ALPHA = .75;
//			InteractiveSceneManager.DEFAULT_FILL_ALPHA = .75;
			
			BitmapMaterial.AUTO_MIP_MAPPING = true;
			DisplayObject3D.faceLevelMode = true;
			
			ism.buttonMode = true;
			ism.faceLevelMode = false;											
			ism.mouseInteractionMode = false;
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, handleMouseOver);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, handleMouseOut);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, handleMouseMove);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, handleMouseDown);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, handleMouseUp);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, handleMouseUp);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_ADDED, handleAddedSprite);
			
			//var material:MovieMaterial = new InteractiveMovieMaterial( new canvas() );
			var material:MovieMaterial = new InteractiveMovieMaterial( this.formUI );
		
			material.doubleSided = true;
			material.lineColor = 0xFFFFFF;
			material.animated = true;
			material.smooth = true;
			
			material.movie.alpha = .3;
			material.movie["btn"].drawNow();
			material.movie["txt"].drawNow();
			
			material.movie["btn"].addEventListener(MouseEvent.CLICK, handleBTNClick);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OVER, handleBTNOver);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OUT, handleBTNOut);
			
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OVER, handleB1Over);
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OUT, handleB1Out)
			
			material.updateBitmap();
		
			plane = new Plane( material, 500, 500, 8, 8 );
			plane.yaw(-20);
//			plane.x = 200;
			scene.addChild(plane);
			
			vMouse = new VirtualMouse(stage, material.movie);

			// Create camera
			camera = new Camera3D();
			camera.zoom = 5;
			
		}
		// ___________________________________________________________________ Create album
		//var mouseIsDown:Boolean;
		
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
		
		// everytime a sprite contrainer is made for a face3d in the ISM, we add it as an ignored item for the VirtualMouse
		function handleAddedSprite(e:InteractiveScene3DEvent):void
		{
			vMouse.ignore(e.sprite);
		}
		
		function handleMouseDown(e:InteractiveScene3DEvent)
		{
		
		}
		
		function handleMouseUp(e:InteractiveScene3DEvent)
		{
			// we tell the vMouse there was a click to execute.
			vMouse.click();
		}
		
		function handleMouseOver(e:InteractiveScene3DEvent)
		{
			trace("over", e.sprite.name);
		}
		
		var dragObject:*;
		
		function handleMouseMove(e:InteractiveScene3DEvent)
		{
			//ball.copyTransform(mouse);
			var plane:DisplayObject3D;
			if(e.displayObject3D != null)
			{
				plane = e.displayObject3D;
			}
			else 
			{
				plane = e.face3d.face3DInstance.instance;
				var point:Object = InteractiveUtils.getMapCoordAtPoint(e.face3d, e.sprite.mouseX, e.sprite.mouseY);
				//trace(point.x, point.y);
				var mat:InteractiveMovieMaterial = InteractiveMovieMaterial(plane.material);
				
				var g:Graphics = mat.movie.graphics;
				g.beginFill(0x000000,1);
				g.drawCircle(point.x, point.y, 5);
				g.endFill();
			}
			
			vMouse.setLocation(point.x, point.y);
			return ;
			
			if(InteractiveSceneManager.MOUSE_IS_DOWN)
			{
				if(dragObject){
					dragObject.x = point.x;
					dragObject.y = point.y;
					plane.material.updateBitmap();
				} 
				//plane.material.updateBitmap();
			} else {
		
				
				var color:ColorTransform = new ColorTransform();
				var color1:ColorTransform = new ColorTransform();
				
				if(plane.material.movie.b1.hitTestPoint(point.x, point.y)){
					color.color = 0xff0000;
					plane.material.movie.b1.transform.colorTransform = color;
					plane.material.updateBitmap();
				} else if(plane.material.movie.b2.hitTestPoint(point.x, point.y)){
					color.color = 0xff0000;
					plane.material.movie.b2.transform.colorTransform = color;
					plane.material.updateBitmap();
				}else if(plane.material.movie.btn.hitTestPoint(point.x, point.y)){
					plane.material.movie.btn.setMouseState("over");
					plane.material.movie.btn.drawNow();
					plane.material.updateBitmap();
				} else if(!plane.material.movie.b1.hitTestPoint(point.x, point.y) || !plane.material.movie.b2.hitTestPoint(point.x, point.y) || !plane.material.movie.btn.hitTestPoint(point.x, point.y)){
					plane.material.movie.b1.transform.colorTransform = color1;
					plane.material.movie.b2.transform.colorTransform = color1;
					plane.material.movie.btn.setMouseState("up");
					plane.material.movie.btn.drawNow();
					plane.material.updateBitmap();
				} 
			}
			
		}
		
		
		// ___________________________________________________________________ Loop
		
		function loop(event:Event):void 
		{
			//plane.yaw(.05);
//			camera.x = -(container.mouseX * 3)/2;
//			camera.y = (container.mouseY * 3);
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