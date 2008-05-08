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
	import org.papervision3d.cameras.*;
	import org.papervision3d.scenes.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.special.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.special.*;
	import org.papervision3d.materials.shaders.*;
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.lights.*;
	import org.papervision3d.render.*;
	import org.papervision3d.view.*;
	import org.papervision3d.events.*;
	import org.papervision3d.core.utils.*;
	import org.papervision3d.core.utils.virtualmouse.VirtualMouse;
	
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		public var viewport  :Viewport3D;
		public var scene     :Scene3D;
		public var camera    :Camera3D;
		public var ball	 	 :Sphere;
		public var gismo	 :Cube;
		public var renderer  :BasicRenderEngine;
		public var mouse3D   :Mouse3D;
		public var vMouse	 :VirtualMouse;
		public var surface	 :Sprite;
		
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
			// Create viewport
			viewport = new Viewport3D(0, 0, true, true);
			addChild( viewport );
			
			renderer = new BasicRenderEngine();
			
			// Create scene
			scene = new Scene3D();
			
			camera = new Camera3D();
			
			vMouse = viewport.interactiveSceneManager.virtualMouse;
			mouse3D = viewport.interactiveSceneManager.mouse3D;
			Mouse3D.enabled = true;
			
			var material:MovieMaterial = new MovieMaterial( new canvas() );
			material.smooth = true;
			material.interactive = true;
			material.animated = true;
			material.allowAutoResize = false;
			
			//make an instance of the movieclip in the material
			surface = material.movie["surface"];
			
			//Create gismo
			gismo = new Cube( new MaterialsList({all:new ColorMaterial(0x888888)}), 10, 10, 10 );
			scene.addChild(gismo);
			
			var bx:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0xFF0000)}), 10, 10, 10 );
			var by:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0x00FF00)}), 10, 10, 10 );
			var bz:Cube = new Cube( new MaterialsList({all:new ColorMaterial(0x0000FF)}), 10, 10, 10 );
			
			bx.x = 100;
			by.y = 100;
			bz.z = 100;
			
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
			renderer.renderScene(scene, camera, viewport);
			
			
		}
		
		//_______________________________________________________________Mouse Events
		
		public function handleMouseDown(e:InteractiveScene3DEvent)
		{
				//Start Drawing
				surface.graphics.beginFill(0x000000,1);
				surface.graphics.drawCircle(vMouse.x, vMouse.y, 3)
				surface.graphics.endFill();
		}
		
		
		public function handleMouseMove(e:InteractiveScene3DEvent)
		{
			if(InteractiveSceneManager.MOUSE_IS_DOWN){
				//Continue drawing when the mouse is down
				surface.graphics.beginFill(0x000000,1);
				surface.graphics.drawCircle(vMouse.x, vMouse.y, 3)
				surface.graphics.endFill();
			}
				
			if(gismo!=null)
			// The Gismo is controled by mouse3D
			gismo.copyTransform(mouse3D);
			
		}
		
		// ___________________________________________________________________ Loop
		
		public function loop(event:Event):void 
		{
			ball.yaw(.5);
			renderer.renderScene(scene, camera, viewport);
		}
		

	}
}