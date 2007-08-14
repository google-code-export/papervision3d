package
{
	import flash.display.StageQuality;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.ascollada.core.DaeAccessor;

	import org.ascollada.utils.Logger;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DAE;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	
	[SWF(width='800',height='600',backgroundColor='0x000000',frameRate='120')]
	
	/**
	 * 
	 */
	public class Main extends Sprite
	{
		/** sprite to render to */
		public var container:Sprite;
		
		/** pv3d scene */
		public var scene:Scene3D;
		
		/** pv3d camera */
		public var camera:Camera3D;
		
		/** focus example */
		public var focus:DisplayObject3D;
	
		/** show some info */
		public var status:TextField;
		
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
			this.stage.quality = StageQuality.LOW;
			
			this.status = new TextField();
			
			var tf:TextFormat = new TextFormat( "Arial", 9, 0xffff00 );
			this.status.defaultTextFormat = tf;
			
			addChild( this.status );
			this.status.x = this.status.y = 5;
			this.status.width = 200;
			
			// papervision container
			this.container = new Sprite();
			addChild( this.container );
			this.container.x = 400;
			this.container.y = 300;
			
			// papervision scene
			this.scene = new Scene3D( this.container );
			
			// papervision camera
			this.camera = new Camera3D();
			this.camera.zoom = 200;
			
			this.status.text = "loading collada";
			
			// set collada scaling to 100
			DAE.DEFAULT_SCALING = 1;
			
			this.focus = this.scene.addChild( new DAE("../../../meshes/focus.dae") );
			//this.focus.rotationX = 30;
			//this.focus.yaw(90);
		
			var dae:DAE = this.focus as DAE;
			dae.addEventListener( Event.COMPLETE, loop3D );
			dae.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
			//this.scene.renderCamera( this.camera );
			this.container.addEventListener( Event.ENTER_FRAME, loop3D );
		}

		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loop3D( event:Event ):void
		{
			this.scene.renderCamera( this.camera );
			
			this.focus.rotationY++;
			
			this.status.text = "";
		}	
		
		private function animationProgressHandler( event:ProgressEvent ):void
		{
			this.status.text = "loading animation #" + event.bytesLoaded + " of " + event.bytesTotal;
		}
	}
}
