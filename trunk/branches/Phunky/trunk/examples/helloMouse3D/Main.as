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
		public var scene     :Scene3D;
		public var camera    :Camera3D;
		public var ism		 :InteractiveSceneManager;
		public var ball	 	 :Sphere;
		public var mouse3D	 :Mouse3D;
		public var gismo	 :Cube;
		
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
			container = new Sprite();
			addChild( container );
			container.name = "mainCont";
			container.x = 320;
			container.y = 240;
		
			// Create scene
			scene = new Scene3D( container, true );
			
			
			var material:MovieMaterial = new MovieMaterial( new canvas() );
			material.smooth = true;
			material.interactive = true;
			
			//Create gismo
			gismo = new Cube( new MaterialsList({all:new ColorMaterial(0x888888)}), 10, 10, 10 );
			scene.addChild(gismo);
			
			var bx:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0xFF0000)}), 10, 10, 10 );
			var by:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0x00FF00)}), 10, 10, 10 );
			var bz:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0x0000FF)}), 10, 10, 10 );
			
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
			
			ball.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, handleMouseMove);
			ball.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, handleMouseDown);
			
			// Create camera
			camera = new Camera3D();
			camera.zoom = 5;
			scene.renderCamera( camera );
			ism = scene.renderer["interactiveSceneManager"];
			mouse3D = ism.mouse3D;
			Mouse3D.enabled = true;
			
			
		}
		
		//_______________________________________________________________Mouse Events
		
		public function handleMouseDown(e:InteractiveScene3DEvent)
		{
			var canvas:DisplayObject3D  = e.displayObject3D as DisplayObject3D;
				
				//Start Drawing
				canvas.material["movie"]["surface"].graphics.beginFill(0x000000,1);
				canvas.material["movie"]["surface"].graphics.drawCircle(ism.virtualMouse.x, ism.virtualMouse.y, 3)
				canvas.material["movie"]["surface"].graphics.endFill();
				canvas.material.updateBitmap();
				
			
		}
		
		
		public function handleMouseMove(e:InteractiveScene3DEvent)
		{
			var canvas:DisplayObject3D = e.displayObject3D as DisplayObject3D;
			
			if(InteractiveSceneManager.MOUSE_IS_DOWN){
					
				//Continue drawing when the mouse is down
				canvas.material["movie"]["surface"].graphics.beginFill(0x000000,1);
				canvas.material["movie"]["surface"].graphics.drawCircle(ism.virtualMouse.x, ism.virtualMouse.y, 3)
				canvas.material["movie"]["surface"].graphics.endFill();
				canvas.material.updateBitmap();
			}
				
			if(gismo!=null)
			
			// The Gismo is controled by mouse3D
			gismo.copyTransform(mouse3D);
			
		}
		
		
		// ___________________________________________________________________ Loop
		
		public function loop(event:Event):void 
		{
			ball.yaw(.5);
			scene.renderCamera( this.camera );
		}
		

	}
}