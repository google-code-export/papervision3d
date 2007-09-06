package {
	
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import org.ascollada.core.DaeAccessor;

	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DAE;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	
	[SWF(width='800',height='600',backgroundColor='0x000000',frameRate='120')]
	
	/**
	 * 
	 */
	public class Main extends Sprite {
		
		/** sprite to render to */
		public var container:Sprite;
		
		/** pv3d scene */
		public var scene:Scene3D;
		
		/** pv3d camera */
		public var camera:Camera3D;
			
		public var status:TextField;
		
		private var car  :DisplayObject3D;

		// ___________________________________________________________________ Car vars

		private var topSpeed  :Number = 0;
		private var topSteer  :Number = 0;
		private var speed     :Number = 0;
		private var steer     :Number = 0;

		// ___________________________________________________________________ Keyboard vars

		private var keyRight   :Boolean = false;
		private var keyLeft    :Boolean = false;
		private var keyForward :Boolean = false;
		private var keyReverse :Boolean = false;
		
		/**
		 * 
		 * @return
		 */
		public function Main():void {
			init();
		}
		
		/**
		 * 
		 * @return
		 */
		private function init():void {
			
			stage.quality = StageQuality.LOW;
			
			status = new TextField();
			
			var tf:TextFormat = new TextFormat( "Arial", 9, 0xffff00 );
			status.defaultTextFormat = tf;
			
			addChild( status );
			status.x = this.status.y = 5;
			status.width = 200;
			
			// papervision container
			container = new Sprite();
			addChild( this.container );
			container.x = 400;
			container.y = 300;
			
			// papervision scene
			scene = new Scene3D( this.container );
			
			// papervision camera
			camera = new Camera3D();
			camera.zoom = 200;

			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		
			status.text = "loading collada";
						
			car = scene.addChild( new DAE("../../meshes/focus.dae") );
			car.addEventListener( Event.COMPLETE, daeCompleteHandler );
			car.addEventListener( ProgressEvent.PROGRESS, daeProgressHandler );
		}

		// ___________________________________________________________________ Keyboard

		private function keyDownHandler( event :KeyboardEvent ):void
		{
			switch( event.keyCode )
			{
				case "W".charCodeAt():
				case Keyboard.UP:
					keyForward = true;
					keyReverse = false;
					break;

				case "S".charCodeAt():
				case Keyboard.DOWN:
					keyReverse = true;
					keyForward = false;
					break;

				case "A".charCodeAt():
				case Keyboard.LEFT:
					keyLeft = true;
					keyRight = false;
					break;

				case "D".charCodeAt():
				case Keyboard.RIGHT:
					keyRight = true;
					keyLeft = false;
					break;
			}
			//trace("keyDownHandler: " + event.keyCode);
		}

		private function keyUpHandler( event :KeyboardEvent ):void
		{
			switch( event.keyCode )
			{
				case "W".charCodeAt():
				case Keyboard.UP:
					keyForward = false;
					break;

				case "S".charCodeAt():
				case Keyboard.DOWN:
					keyReverse = false;
					break;

				case "A".charCodeAt():
				case Keyboard.LEFT:
					keyLeft = false;
					break;

				case "D".charCodeAt():
				case Keyboard.RIGHT:
					keyRight = false;
					break;
			}
			//trace("keyUpHandler: " + event.keyCode);
		}
	
		// ___________________________________________________________________ driveCar

		private function driveCar():void
		{
			// Speed
			if( keyForward )
			{
				topSpeed = 50;
			}
			else if( keyReverse )
			{
				topSpeed = -20;
			}
			else
			{
				topSpeed = 0;
			}

			speed -= ( speed - topSpeed ) / 10;

			// Steer
			if( keyRight )
			{
				if( topSteer < 45 )
				{
					topSteer += 5;
				}
			}
			else if( keyLeft )
			{
				if( topSteer > -45 )
				{
					topSteer -= 5;
				}
			}
			else
			{
				topSteer -= topSteer / 24;
			}

			steer -= ( steer - topSteer ) / 2;
		}


		// ___________________________________________________________________________________________ updateCar

		private function updateCar( car :DisplayObject3D ):void
		{			
			// Steer front wheels
			var steerFR :DisplayObject3D = car.getChildByName( "Steer_FR" );
			var steerFL :DisplayObject3D = car.getChildByName( "Steer_FL" );

			steerFR.rotationY = steer;
			steerFL.rotationY = steer;

			// Rotate wheels
			var wheelFR :DisplayObject3D = car.getChildByName( "Steer_FR_Wheel_FR" );
			var wheelFL :DisplayObject3D = car.getChildByName( "Steer_FL_Wheel_FL" );
			var wheelRR :DisplayObject3D = car.getChildByName( "Focus_Wheel_RR" );
			var wheelRL :DisplayObject3D = car.getChildByName( "Focus_Wheel_RL" );

			var roll :Number = speed/2
			wheelFR.roll( -roll );
			wheelRR.roll( -roll );
			wheelFL.roll( roll );
			wheelRL.roll( roll );
			
			// Steer car
			car.yaw( (speed/2) * steer / 500 );

			// Move car
			car.moveForward( speed/50 );
		}
	
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loop3D( event:Event ):void 
		{	
			// Check if car has been loaded
			if( car )
			{
				// Calculate current steer and speed
				driveCar();

				// Update car model
				updateCar( car );
			}
			scene.renderCamera( this.camera );
		}	
		
		private function animationProgressHandler( event:ProgressEvent ):void {
			status.text = "loading animation #" + event.bytesLoaded + " of " + event.bytesTotal + " done.";
		}
		
		private function daeProgressHandler( event:ProgressEvent ):void {
			status.text = "loading collada : " + event.bytesLoaded + " of " + event.bytesTotal + " done.";
		}
		
		private function daeCompleteHandler( event:Event ):void {
			status.text = "";
			
			// get rid of old progress event for the DAE
			if( car.hasEventListener(ProgressEvent.PROGRESS) )
				car.removeEventListener(ProgressEvent.PROGRESS, daeProgressHandler);
				
			// after initial load of the DAE, there might be animations left to parse...
			car.addEventListener(ProgressEvent.PROGRESS, animationProgressHandler);
			
			container.addEventListener( Event.ENTER_FRAME, loop3D );
		}
	}
}
