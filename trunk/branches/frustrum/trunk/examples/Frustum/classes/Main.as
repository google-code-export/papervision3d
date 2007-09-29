package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.papervision3d.core.culling.IFrustumCuller;
	import org.papervision3d.core.culling.RectangleTriangleCuller;
	import org.papervision3d.Papervision3D;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.cameras.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.scenes.*;
	
	public class Main extends flash.display.Sprite
	{
		public var container:Sprite;
		
		public var scene:Scene3D;
		
		public var camera:CameraObject3D;
		
		/**
		 * 
		 * @return
		 */
		public function Main():void
		{
			init();
		}
		
		/**
		 * 
		 * @return
		 */
		private function init():void
		{
			stage.quality = StageQuality.LOW;
			
			// used for camera movement
			lastMouse = new Point();
			orbiting = false;
			
			container = new Sprite();
			addChild(container);
			container.x = 400;
			container.y = 300;
						
			scene = new Scene3D(container);
			
		//	scene.triangleCuller = new RectangleTriangleCuller(new Rectangle(-160, -120, 320, 240));
			
			// viewport for camera
			var vp:Rectangle = new Rectangle(0, 0, 320, 240);
			
			//camera = new FreeCamera3D(2, 2000);

			camera = new FrustumCamera3D(60, 10, 1000, vp);

			buildScene();
			
			//maskViewport();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			loop3D();
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loop3D( event:Event = null ):void
		{
			scene.renderCamera(camera);
			
			drawViewport(camera);
		}
		
		/**
		 * 
		 * @return
		 */
		private function buildScene():void
		{
			var radius:Number = 100;
			var material:WireframeMaterial = new WireframeMaterial();
			
			var numx:int = 20;
			var numy:int = 20;
			var step:int = radius * 4;
			var sx:int = -(numx/2) * step;
			var ex:int =  (numx/2) * step;
			var sy:int = -(numy/2) * step;
			var ey:int =  (numy/2) * step;
			
			for( var x:int = sx; x < ex; x += step )
			{
				for( var y:int = sy; y < ey; y += step )
				{
					var sphere:Sphere = new Sphere(material, radius);
					scene.addChild(sphere);
					sphere.x = x;
					sphere.z = y;
				}
			}
			
			// move camera to 0,0,0
			camera.x = camera.y = camera.z = 0;
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
				
				case "C".charCodeAt():
					if( camera is FrustumCamera3D )
					{
						FrustumCamera3D(camera).enableFrustum = !FrustumCamera3D(camera).enableFrustum;
					}
					break;
					
				case "F".charCodeAt():
					if( camera is FrustumCamera3D )
					{
						if(event.shiftKey)
							FrustumCamera3D(camera).far -= speed;
						else
							FrustumCamera3D(camera).far += speed;
					}
					break;
				
				case "L".charCodeAt():
					camera.lookAt(DisplayObject3D.ZERO);
					break;
					
				case "M".charCodeAt():
					if( container.mask )
						unMaskViewport();
					else
						maskViewport();
					break;
				
				case "N".charCodeAt():
					if( camera is FrustumCamera3D )
					{
						if(event.shiftKey)
							FrustumCamera3D(camera).near -= speed;
						else
							FrustumCamera3D(camera).near += speed;
					}
					break;
				
				case "V".charCodeAt():
					if( camera is FrustumCamera3D )
					{
						if(event.shiftKey)
							FrustumCamera3D(camera).fov--;
						else
							FrustumCamera3D(camera).fov++;
					}
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
		private function drawViewport( camera:CameraObject3D ):void
		{
			if( camera.viewport ) return;
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
		
		private var lastMouse:Point;
		private var orbiting:Boolean;
		private var speed:Number = 10;
		private var viewportMask:Sprite;
	}
}
