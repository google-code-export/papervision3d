package
{
	import flash.display.StageQuality;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import org.ascollada.core.DaeAccessor;

	import org.ascollada.utils.Logger;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DAE;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.core.stat.RenderStatistics;
	
	[SWF(width='800',height='600',backgroundColor='0x000000',frameRate='20')]
	
	/**
	 * 
	 */
	public class App extends Sprite
	{
		/** sprite to render to */
		public var container:Sprite;
		
		/** pv3d scene */
		public var scene:Scene3D;
		
		/** pv3d camera */
		public var camera:Camera3D;
		
		/** focus example */
		public var focus:DisplayObject3D;
	
		public var status:TextField;
		
		/**
		 * 
		 * @return
		 */
		public function App():void
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
			this.camera.zoom = 1700;
			
			this.status.text = "loading collada";
			
			DAE.DEFAULT_SCALING = 1;
			
			this.focus = this.scene.addChild( new DAE("../../../../meshes/hound.dae") );
			this.focus.rotationX = 90;
			this.focus.rotationZ = -90;
			
			//this.focus.pitch(50);
			this.focus.roll(-40);
			this.focus.pitch( 50 );
			
			//this.scene.renderCamera( this.camera );
			
			//addEventListener( Event.ENTER_FRAME, loop3D );
			
			var dae:DAE = this.focus as DAE;
			dae.addEventListener( Event.COMPLETE, loop3D );
			dae.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			this.container.addEventListener( Event.ENTER_FRAME, loop3D );
		}
				
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			loop3D();
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loop3D( event:Event = null ):void
		{			
			this.scene.renderCamera( this.camera );
		}	
		
		/**
		 * 
		 * @param	event
		 */
		private function animationProgressHandler( event:ProgressEvent ):void
		{
			this.status.text = "loading animation #" + event.bytesLoaded + " of " + event.bytesTotal;
			
			if( event.bytesLoaded == event.bytesTotal )
			{
				//loop3D(null);
				
				this.status.text = "";
			}
		}
	}
}
