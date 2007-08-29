package {
	
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	import org.papervision3d.utils.virtualmouse.IVirtualMouseEvent;
	import org.papervision3d.utils.InteractiveSceneManager;

	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.display.Sprite;
	import flash.media.Video;
	import fl.controls.Button;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	[SWF(backgroundColor="0xFFFFFF", frameRate="31")]
	public class Main extends Sprite {
		
		protected var container 				:Sprite;
		protected var scene     				:InteractiveScene3D;
		protected var camera   					:Camera3D;
		protected var plane	 	 				:Plane;
		protected var vMouse	  				:VirtualMouse;
		protected var mc						:MovieClip;
		
		// create basic netConnection object
		var nc:NetConnection = new NetConnection();
		var ns:NetStream;
		public var videoContainer				:Video;
		public var playButton					:Button;
		public var logo							:MovieClip;
		
		private var videoWidth					:Number = 300;
		private var videoHeight					:Number = 300;
		
		public function Main() 
		{
			init();
		}
		
		public function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// connect to the local Red5 server
			nc.client = this;
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.connect("rtmp://localhost/oflaDemo");
		}
		
		protected function createStream():void
		{
			// create the netStream object and pass the netConnection object in the constructor
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.client = this;

			// listen for the button click
			playButton.addEventListener(MouseEvent.CLICK, handleClick);		
			
			//createContent();
			init3D();
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    createStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Stream not found");
                    break;
            }
        }

		public function onMetaData(info:Object):void
		{
			trace("width/height", info.width, info.height);
			videoWidth = info.width;
			videoHeight = info.height;
			
			// we create the plane after we have the metadata so we can make it the same size as the video
			createPlane();
		}
		
		public function onPlayStatus(info:Object):void
		{
			
		}
		
		public function onBWDone(...rest):void
		{
			
		}
		
		protected function handleClick(e:MouseEvent):void
		{
			videoContainer.attachNetStream ( null );
			// called via the "Play" button
			// simply call play on the netStream object, and pass the name of the FLV.
			// This FLV is sitting in webapps/oflaDemo/streams/ directory
			ns.play("Spiderman3_trailer_300.flv");
		}
		
		protected function init3D():void 
		{
			container = new InteractiveSprite();
			addChild(container);
			container.name = "mainCont";
			container.x = stage.stageWidth*.5;
			container.y = stage.stageHeight*.5;
	
			scene = new InteractiveScene3D(container);
						
			camera = new Camera3D();
			camera.zoom = 11;
		}
		
		protected function createPlane():void 
		{
			if( scene.getChildByName("plane") ) scene.removeChild(plane);
			var material:VideoStreamMaterial= new VideoStreamMaterial(videoContainer, ns);
			material.animated = true;
			material.smooth = true;
			
			plane = new Plane( material, videoWidth, videoHeight, 8, 8 );
			scene.addChild(plane, "plane");
		}
		
		protected function loop(event:Event):void 
		{
			camera.x = -(container.mouseX * 3)/2;
			camera.y = (container.mouseY * 3);
			scene.renderCamera(camera);
		}
	}
}



