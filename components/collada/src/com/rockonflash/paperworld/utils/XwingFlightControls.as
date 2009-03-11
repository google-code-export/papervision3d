package com.rockonflash.paperworld.utils
{
	import com.blitzagency.xray.logger.XrayLog;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;

	public class XwingFlightControls extends EventDispatcher
	{
		/*
		private static var _instance:XwingFlightControls = null;
		public static function getInstance():XwingFlightControls
		{
			if(_instance == null) _instance = new XwingFlightControls();
			return _instance;
		}
		*/
		public var paused			:Boolean = false;
		public var invertMouse		:Boolean = true;
		public var useKeyboard		:Boolean = false;
		public var sensitivity		:Number = 75;
		
		private var log				:XrayLog = new XrayLog();
		
		private var _speed			:Number = 0;
		private var maxSpeed		:Number = 500;
		private var minSpeed		:Number = -500;
		private var movementInc		:Number = 1;
		
		private var arrowLeft		:Boolean;
		private var arrowUp			:Boolean;
		private var arrowRight		:Boolean;
		private var arrowDown		:Boolean;
		
		private var lastKeyCode		:Number;
		
		private var wDown			:Boolean;
		private var aDown			:Boolean;
		private var sDown			:Boolean;
		private var dDown			:Boolean;
		
		private var arrowPitch		:Number = 1;
		private var arrowYaw		:Number = 1;
		
		private var pitchRate		:Number = 0;
		private var yawRate			:Number = 0;
		
		private var _cockpitView	:Boolean = false;
		private var rearView		:Boolean = false;
		private var gameRunning		:Boolean = false;
		
		
		private var _target			:DisplayObject3D;
		private var _camera			:CameraObject3D;
		private var _canvas			:Sprite;
		
		public function XwingFlightControls(p_target:DisplayObject3D, 
											p_camera:CameraObject3D, 
											p_canvas:Sprite):void
		{
			target = p_target;
			camera = p_camera;
			canvas = p_canvas;
			
			canvas.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpEventHandler );
			canvas.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEventHandler);
		}
		
		public function set target(p_target:DisplayObject3D):void
		{
			_target = p_target;
		}
		
		public function get target():DisplayObject3D
		{
			return _target;
		}
		
		public function set camera(p_camera:CameraObject3D):void
		{
			_camera = p_camera;
		}
		
		public function get camera():CameraObject3D
		{
			return _camera;
		}
		
		public function set canvas(p_canvas:Sprite):void
		{
			_canvas = p_canvas;
		}
		
		public function get canvas():Sprite
		{
			return _canvas;
		}
		
		public function set cockpitView(p_cockpitView:Boolean):void
		{
			_cockpitView = p_cockpitView;
		}
		
		public function get cockpitView():Boolean
		{
			return _cockpitView;
		}
		
		public function set speed(p_speed:Number):void
		{
			_speed = p_speed;
		}
		
		public function get speed():Number
		{
			return _speed;
		}
		
		public function updateControl(p_gameRunning:Boolean):void
		{
			try
			{
				gameRunning = p_gameRunning;
				if(target == null || paused) return;
				target.visible = !cockpitView;
				
				var deadArea:Number = 20;
				
				if(!useKeyboard) calcMousePitchYaw();
				if(useKeyboard) calcKeyPitchYaw();
				
				target.pitch(pitchRate) ;
				target.yaw(yawRate);
				// give it some roll as you turn (yaw)
				target.roll(-yawRate);
				
				// check keys for roll or speed changes
				handleKeyStroke();
				
				// move the ship forward
				if(Math.abs(speed) < 5) speed = 0;
				
				if(gameRunning) target.moveForward(speed);
				
				// after we're done changing the coordinates of the ship, update the camera's coordinates and rotations to the ship
				camera.transform.copy(target.transform);
				if(!cockpitView) 
				{
					// if we're in chase mode, set the camer back a bit, and up, the move left/right and roll according to the mouse values
					camera.zoom=5;
					camera.focus=100;
					var backAmt:Number = (rearView == true) ? -1000 : 500;
					camera.moveBackward( backAmt );
					camera.moveUp( -(pitchRate*10)+150 );
					camera.moveLeft( - (yawRate*10) );
					camera.roll((yawRate*3));
				}else
				{
					camera.zoom=5.5;
					camera.focus=130;
				}
				
				if(rearView) camera.yaw(180);
				if(!rearView) camera.yaw(0);
				
			}catch(e:Error)
			{
				log.debug("updateScene", 5 + ", " + e.message);
			}
		}
		
		private function keyDownEventHandler( event:KeyboardEvent ):void 
		{
			try
			{
				movementInc += movementInc*.1;
				//log.debug("keyDown", event.keyCode);
				switch(event.keyCode)
				{
					case 37:
						arrowLeft = true;
					break;
					
					case 38:
						arrowUp = true;
					break;
					
					case 39:
						arrowRight = true;
					break;
					
					case 40:
						arrowDown = true;
					break;
					
					//=============================
					
					case 65:
						aDown = true;
					break;
					
					case 87:
						wDown = true;
					break;
					
					case 68:
						dDown = true;
					break;
					
					case 83:
						sDown = true;
					break;
					
					case 191:  // backslash
						rearView = true;
					break;
				}
				
			}catch(e:Error)
			{
				log.debug("keyDown error");
			}
		}
		
		private function keyUpEventHandler( event:KeyboardEvent ):void 
		{
			try
			{
				movementInc = 1;
				lastKeyCode = event.keyCode;
				switch(event.keyCode)
				{
					case 37:
						arrowLeft = false;
						resetYaw();
					break;
					
					case 38:
						arrowUp = false;
						resetPitch();
					break;
					
					case 39:
						arrowRight = false;
						resetYaw();
					break;
					
					case 40:
						arrowDown = false;
						resetPitch();
					break;
					
					//==========================
					
					case 65:
						aDown = false;
					break;
					
					case 87:
						wDown = false;
					break;
					
					case 68:
						dDown = false;
					break;
					
					case 83:
						sDown = false;
					break;
					
					case 186:
						// semi colon - cockpit or chase toggle
						cockpitView = !cockpitView;
					break;
					
					case 191:  // backslash
						rearView = false;
					break;
					
					// pause
					case 80:
						if(!gameRunning) return;
						paused = !paused;
					break;
				}
			}catch(e:Error)
			{
				//no targetect
			}
		}
		
		private function calcMousePitchYaw():void
		{
			pitchRate = (canvas.mouseY / sensitivity)//*1.5;
			if(invertMouse) pitchRate *= -1;
			yawRate = canvas.mouseX / sensitivity;
		}
		
		private function calcKeyPitchYaw():void
		{
			if(useKeyboard && (arrowUp || arrowDown))
			{
				if(arrowPitch < 5) arrowPitch += arrowPitch *.03;
				pitchRate = arrowPitch;
				
				if(arrowUp && !invertMouse) pitchRate *= -1;

				if(arrowDown && invertMouse) pitchRate *= -1;
			}else if(!arrowUp && !arrowDown)
			{
				//resetPitch();
			}
			
			if(useKeyboard && (arrowLeft || arrowRight))
			{
				if(arrowYaw < 5) arrowYaw += arrowYaw *.03;
				yawRate = arrowYaw;
				
				if(arrowLeft) yawRate *= -1;
			}else if(!arrowLeft && !arrowRight)
			{
				//resetYaw();
			}
		}
		
		private function resetPitch():void
		{
			arrowPitch = 1;
			if(pitchRate > 0 && pitchRate - 1 > 0) 
			{
				pitchRate--
				//if(lastKeyCode == 
			}else if(pitchRate - 1 < 0) 
			{
				pitchRate = 0;
			}
		}
		
		private function resetYaw():void
		{
			arrowYaw = 1;
			yawRate = 0;
		}
		
		private function handleKeyStroke():void
		{
			var inc				:Number = 5 + movementInc;
			
			
			// wasd
			if(aDown) target.roll(5);
			if(wDown && gameRunning) 
			{
				speed = speed + inc > maxSpeed ? maxSpeed : speed + inc;
			}
			if(dDown) target.roll(-5);;
			if(sDown && gameRunning) 
			{
				speed = speed - inc < minSpeed ? minSpeed : speed - inc;
			}
		}
	}
}