/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

// _______________________________________________________________________ HelloMouse3D

package {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.display.Stage;
	import flash.events.*;
	
	import caurina.transitions.Tweener;
	
	// Import Papervision3D
	import org.papervision3d.events.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.core.geom.*;
	
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		public var container :Sprite;
		public var scene     :InteractiveScene3D;
		public var camera    :Camera3D;
		public var ism		 :InteractiveSceneManager;
		public var ball	 	 :Sphere;
		public var mouse3D	 :Mouse3D;
		public var gismo	 :OldCube;
		public var medium    :DisplayObject3D;
		
		public function Main() {
			init();
		}
		
		public function init():void {
			
			stage.scaleMode = "noScale"
			
			init3D();
			
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
			mouse3D = ism.mouse3D;
			ism.enableMouse = true;
			
			InteractiveSceneManager.SHOW_DRAWN_FACES = false;
			InteractiveSceneManager.DEFAULT_LINE_COLOR = 0xFFFFFF;
			InteractiveSceneManager.DEFAULT_SPRITE_ALPHA = .75;
			InteractiveSceneManager.DEFAULT_FILL_ALPHA = .75;
			
			ism.buttonMode = true;
			ism.faceLevelMode = true;											
			ism.mouseInteractionMode = false;
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, handleMouseOver);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, handleMouseOut);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, handleMouseMove);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, handleMouseDown);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, handleMouseClick);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, handleMouseUp);
			ism.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE_OUTSIDE, handleMouseUp);
			//ism.addEventListener(InteractiveScene3DEvent.OBJECT_ADDED, handleAddedSprite);
			
			var material:MovieMaterial = new InteractiveMovieMaterial( new canvas() );
			material.smooth = true;
			material.allowAutoResize = false;
			
			//Create gismo
			gismo = new OldCube( new ColorMaterial(0x888888), 10, 10, 10 );
			scene.addChild(gismo);
			
			var bx:OldCube = new OldCube( new ColorMaterial(0xFF0000), 10, 10, 10 );
			var by:OldCube = new OldCube( new ColorMaterial(0x00FF00), 10, 10, 10 );
			var bz:OldCube = new OldCube( new ColorMaterial(0x0000FF), 10, 10, 10 );
			
			bx.x = 100;
			by.y = 100;
			bz.z = -100;
			
			bx.scaleX = 15;
			by.scaleY = 15;
			bz.scaleZ = 15;
			
			gismo.addChild(bx);
			gismo.addChild(by);
			gismo.addChild(bz);
			
			//Create ball to draw on
			ball = new Sphere( material, 500, 10, 10 );
			ball.z = 400;
			ball.rotationY = -90;
			scene.addChild(ball);
			
			//create crystal
			medium = new DisplayObject3D();
			var c:OldCube = new OldCube( new ColorMaterial(0x000000),  300, 50, 50 );
			c.z = -150;
			
			medium.addChild( c, "c" );
			scene.addChild( medium );
			medium.container.alpha = 0;
			
			// Create camera
			camera = new Camera3D();
			camera.zoom = 5;
			
		}
		
		//_______________________________________________________________Mouse Events
		
		public function handleMouseDown(e:InteractiveScene3DEvent)
		{
			var canvas:DisplayObject3D;
			if(e.displayObject3D != null)
			{
				canvas = e.displayObject3D;
			}
			else 
			{
				canvas = e.face3d.face3DInstance.instance;
				
				//Start Drawing
				canvas.material["movie"]["surface"].graphics.beginFill(0x000000,1);
				canvas.material["movie"]["surface"].graphics.drawCircle(e.target.virtualMouse.x, e.target.virtualMouse.y, 3)
				canvas.material["movie"]["surface"].graphics.endFill();
				canvas.material.updateBitmap();
				
				//Show medium
				Tweener.addTween(medium.getChildByName("c"),{z:-150, time:.1, transition:"easeOutExpo"});
				Tweener.addTween(medium.container,{alpha:1, time:.3, transition:"easeOutExpo"});
			}
			
		}
		
		public function handleMouseUp(e:InteractiveScene3DEvent)
		{
			//Hide medium
			Tweener.addTween(medium.getChildByName("c"),{z:-400, time:.3, transition:"easeOutExpo"});
			Tweener.addTween(medium.container,{alpha:0, time:.3, transition:"easeOutExpo"});
		}
		
		public function handleMouseMove(e:InteractiveScene3DEvent)
		{
			var canvas:DisplayObject3D;
			if(e.displayObject3D != null)
			{
				canvas = e.displayObject3D;
			}
			else 
			{
				canvas = e.face3d.face3DInstance.instance;
				if(InteractiveSceneManager.MOUSE_IS_DOWN){
					
					//Continue drawing when the mouse is down
					canvas.material["movie"]["surface"].graphics.beginFill(0x000000,1);
					canvas.material["movie"]["surface"].graphics.drawCircle(e.target.virtualMouse.x, e.target.virtualMouse.y, 3)
					canvas.material["movie"]["surface"].graphics.endFill();
					canvas.material.updateBitmap();
				}
				
			}
			if(gismo!=null)
			
			// The Gismo is controled by mouse3D
			gismo.copyTransform(mouse3D);
			medium.copyTransform(mouse3D);
			
		}
		
		
		// ___________________________________________________________________ Loop
		
		public function loop(event:Event):void 
		{
			ball.yaw(.5);
//			camera.x = -(container.mouseX * 3)/2;
//			camera.y = (container.mouseY * 3);
			scene.renderCamera( this.camera );
		}
		

	}
}