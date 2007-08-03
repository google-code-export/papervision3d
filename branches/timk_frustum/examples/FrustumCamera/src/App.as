package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.papervision3d.cameras.FrustumCamera3D;
	import org.papervision3d.core.culling.RectangleTriangleCuller;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.scenes.Scene3D;
	
	/**
	 * 
	 */
	public class App extends Sprite
	{
		/** the sprite to render to */
		public var container:Sprite;
	
		/** the scene */
		public var scene:Scene3D;
		
		/** the camera */
		public var camera:FrustumCamera3D;
	
		/** show some info */
		public var status:TextField;
		
		/**
		 * 
		 */
		public function App()
		{
			init();
		}
		
		/**
		 * 
		 */
		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			// used for camera movement
			lastMouse = new Point();
			
			status = new TextField();
			addChild(status);
			status.x = status.y = 5;
			status.width = 300;
			status.height = 200;
			status.selectable = false;
			status.multiline = true;
			status.defaultTextFormat = new TextFormat("Arial", 9, 0xff0000);
			
			// sprite to render to
			container = new Sprite();
			addChild(container);
			container.x = 375;
			container.y = 200;
			
			// the scene
			scene = new Scene3D(container);
			
			// viewport for camera
			var vp:Rectangle = new Rectangle(0, 0, 320, 240);
			
			// create camera
			camera = new FrustumCamera3D(60, 10, 1000, vp);
			
			// set scene culler to a RectangleTriangleCuller 
			var rc:Rectangle = new Rectangle(-vp.width/2, -vp.height/2, vp.width, vp.height);
			scene.triangleCuller = new RectangleTriangleCuller(rc);
			
			// mask the viewport :)
			maskViewport();
			
			// create some objects
			init3D();
			
			// some event listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			// render!
			loop3D();
		}
		
		/**
		 * add some spheres...
		 */
		private function init3D():void
		{
			var material:WireframeMaterial = new WireframeMaterial();
			var step:Number = 400;
			var radius:Number = 100;
			var size:Number = 1200;
			
			for( var x:int = -size; x < size; x += step )
			{
				for( var z:int = -size; z < size; z += step )
				{
					var sphere:Sphere = new Sphere(material, radius);
					scene.addChild(sphere);
					sphere.x = x;
					sphere.z = z;
				}
			}
			
			// move camera to 0,0,0
			camera.x = camera.y = camera.z = 0;
		}
		
		/**
		 * render!
		 */
		private function loop3D( event:Event = null ):void
		{			
			scene.renderCamera(camera);
			
			drawViewport(camera);
			
			updateStatus();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function keyDownHandler( event:KeyboardEvent ):void
		{
			switch( event.keyCode )
			{
				case "A".charCodeAt():
					camera.moveLeft(speed);
					break;
				
				case "W".charCodeAt():
					camera.moveForward(speed);
					break;
					
				case "S".charCodeAt():
					camera.moveBackward(speed);
					break;
					
				case "D".charCodeAt():
					camera.moveRight(speed);
					break;
				
				case "F".charCodeAt():
					if(event.shiftKey)
						camera.far -= speed;
					else
						camera.far += speed;
					break;
					
				case "M".charCodeAt():
					if( container.mask )
						unMaskViewport();
					else
						maskViewport();
					break;
				
				case "N".charCodeAt():
					if(event.shiftKey)
						camera.near -= speed;
					else
						camera.near += speed;
					break;
				
				case "V".charCodeAt():
					if(event.shiftKey)
						camera.fov--;
					else
						camera.fov++;
					break;
					
				default:
					break;
			}
			
			loop3D();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function mouseDownHandler( event:MouseEvent ):void
		{
			lastMouse.x = event.stageX;
			lastMouse.y = event.stageY;
			orbiting = true;
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var dx:Number = lastMouse.x - event.stageX;
			var dy:Number = lastMouse.y - event.stageY;
			
			if(orbiting)
			{	
				camera.yaw(-dx);
				
				loop3D();
				
				lastMouse.x = event.stageX;
				lastMouse.y = event.stageY;
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function mouseUpHandler( event:MouseEvent ):void
		{
			orbiting = false;
		}
		
		/**
		 * draws outline of the cameras viewport
		 * 
		 * @param	rc
		 */
		private function drawViewport( camera:FrustumCamera3D ):void
		{
			var rc:Rectangle = camera.viewport;
			var g:Graphics = container.graphics;
			g.lineStyle(3, 0xff0000);
			g.drawRect(-rc.width/2, -rc.height/2, rc.width, rc.height);
		}
		
		/**
		 * 
		 */
		private function maskViewport():void
		{
			unMaskViewport();
			
			viewportMask = new Sprite();
			
			container.addChild(viewportMask);
			
			var vp:Rectangle = camera.viewport;
			var rc:Rectangle = new Rectangle(-vp.width/2, -vp.height/2, vp.width, vp.height);
			
			var g:Graphics = viewportMask.graphics;
			g.beginFill(0xffff00);
			g.lineStyle();
			g.drawRect(rc.x, rc.y, rc.width, rc.height);
			g.endFill();
			
			container.mask = viewportMask;
		}
		
		/**
		 * 
		 */
		private function unMaskViewport():void
		{
			if( viewportMask ) container.removeChild(viewportMask);
			container.mask = viewportMask = null;
		}
		
		/**
		 * 
		 */
		private function updateStatus():void
		{
			var msg:String  = "click/drag to rotate view.\nKEYS:\n";
			
			msg += "W: move forward\n";
			msg += "S: move backward\n";
			msg += "A: sidestep left\n";
			msg += "D: sidestep right\n";
			msg += "N: adjust near plane (*) [near: " + camera.near + "]\n";
			msg += "F: adjust far plane (*) [far: " + camera.far + "]\n";
			msg += "V: adjust field of view (*) [fov: " + camera.fov + "]\n";
			msg += "M: toggle viewport masking [mask: " + (container.mask?"ON":"OFF") + "]\n";
			msg += "(*) = use shift to decrease";
			
			status.text = msg;
		}
		
		private var lastMouse:Point;
		private var orbiting:Boolean;
		private var viewportMask:Sprite;
		private var speed:Number = 10;
	}
}
