package {
	
	/**
	 * @Author Ralph Hauwert
	 */
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.materials.ColorMaterial;
	
	import org.papervision3d.objects.Cube;
	import org.papervision3d.objects.ParticleField;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.objects.VertexParticles;
	import org.papervision3d.objects.particles.StarParticle;
	import org.papervision3d.scenes.Scene3D;
	
	[SWF( width="640", height="480", backgroundColor="0")]
	public class VertexParticleTest extends Sprite
	{
		
		private var pv3dContainer:Sprite;
		private var starSprite:Sprite;
		
		private var scene:Scene3D;
		private var camera:FreeCamera3D;
		private var vParticles:VertexParticles;
		private var particleField:ParticleField;
		
		private var doForward:Boolean = false;
		private var doBackward:Boolean = false;
		private var doLeft:Boolean = false;
		private var doRight:Boolean = false;
		/**
		 * VertexParticleTest
		 * 
		 * An example application showing the usage of the Particles in PV3D
		 */
		public function VertexParticleTest()
		{
			initScene();
			run();
		}
		
		/**
		 * Creates the pv3d Scene.
		 */
		private function initScene():void
		{
			//Create a sprite to act as a canvas for PV3D
			pv3dContainer = new Sprite();
			starSprite = new Sprite();
			
			//Create a new Scene
			scene = new Scene3D(pv3dContainer);
			
			//Create a new FreeCamera3D, and center it in the scene
			camera = new FreeCamera3D(.25,1500);
			camera.x = 400;
			camera.y = 0;
			camera.z = 0;
			
			/**
			//Create a new VertexParticles object 
			vParticles = new VertexParticles();
			//Add some random red particle
			vParticles.addParticle(new StarParticle(0xFF0000,10,0,0,0));
			//Add it to the scene
			scene.addChild(vParticles);
			*/
			
			//Create a new particlefield.
			particleField = new ParticleField(2000,0xcccccc, starSprite, 20000, 20000, 20000);
			scene.addChild(particleField);
			
			//Set the container to the center of the stage.
			pv3dContainer.x = 320;
			pv3dContainer.y = 240;
			
			//The starSprite container, if used needs to be set the same way.
			starSprite.x = 320;
			starSprite.y = 240;
			
			//Just for reference and fun, add a sphere.
			var s:Sphere = new Sphere(new ColorMaterial(0x888888,1));
			scene.addChild(s);
			
			//Add the containers to the displaylist
			addChild(starSprite);
			addChild(pv3dContainer);
		}
		
		/**
		 * run();
		 * 
		 * initiates the rendering of this application 
		 */
		private function run():void
		{
			//Set the framerate, start listening for the onEnterFrame Event
			stage.frameRate = 31;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			//Listen to the keyboard events
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}	
		
		
		/**
		 * onEnterFrame();
		 * 
		 * handles the onEnterFrame, moves the camera, and renders the scene.
		 */
		private function onEnterFrame(event:Event = null):void
		{
			//Move the camera, render the scene.
			if(doForward){
				camera.moveForward(10);
			}
			if(doBackward){
				camera.moveBackward(10);
			}
			if(doLeft){
				camera.yaw(-1);
			}
			if(doRight){
				camera.yaw(1);
			}
			scene.renderCamera(camera);
		}
		
		/**
		 * onKeyDown
		 * 
		 * Handles the key events from the stage
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode){
				case Keyboard.UP:
					doForward = true;	
				break;
				case Keyboard.DOWN:
					doBackward = true;
				break;
				case Keyboard.LEFT:
					doLeft = true;
				break;
				case Keyboard.RIGHT:
					doRight = true;
				break;
			}
		}
		
		/**
		 * onKeyUp
		 * 
		 * Handles the key events from the stage
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch(event.keyCode){
				case Keyboard.UP:
					doForward = false;	
				break;
				case Keyboard.DOWN:
					doBackward = false;
				break;
				case Keyboard.LEFT:
					doLeft = false;
				break;
				case Keyboard.RIGHT:
					doRight = false;
				break;
			}
		}
		
	}
}
