package
{
	import com.blitzagency.xray.logger.XrayLog;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import org.papervision3d.core.culling.RectangleTriangleCuller;
	import org.papervision3d.core.Plane3D;
	import org.papervision3d.materials.WireframeMaterial;

	
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import org.papervision3d.Papervision3D;
	import org.papervision3d.cameras.*;
	import org.papervision3d.events.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.scenes.*;

	import mx.utils.StringUtil;
	
	/**
	 * 
	 */
	public class Main extends flash.display.Sprite
	{
		public var container:Sprite;
		
		public var scene:Scene3D;
		
		public var camera:FrustumCamera3D;
		
		public var status:TextField;
		
		[Embed (source="ballerina.bvh", mimeType="application/octet-stream")]
		public var ballerinaClass:Class;
		
		[Embed (source="breakdance.bvh", mimeType="application/octet-stream")]
		public var breakdanceClass:Class;
		
		[Embed (source="shothead.bvh", mimeType="application/octet-stream")]
		public var shotheadClass:Class;
		
		[Embed (source="destroy.bvh", mimeType="application/octet-stream")]
		public var destroyClass:Class;
		
		[Embed (source="sexy.bvh", mimeType="application/octet-stream")]
		public var sexyClass:Class;
		
		[Embed (source="dribble.bvh", mimeType="application/octet-stream")]
		public var dribbleClass:Class;
		
		[Embed (source="coolwalk.bvh", mimeType="application/octet-stream")]
		public var coolwalkClass:Class;
		
		[Embed (source="cowboy.bvh", mimeType="application/octet-stream")]
		public var cowboyClass:Class;
		
		[Embed (source="animazoo/martial_arts/doublepunch1.bvh", mimeType="application/octet-stream")]
		public var doublepunch1Class:Class;
		
		[Embed (source="animazoo/martial_arts/doublepunch3.bvh", mimeType="application/octet-stream")]
		public var doublepunch3Class:Class;
		
		[Embed (source="animazoo/martial_arts/elbowing_back_right.bvh", mimeType="application/octet-stream")]
		public var elbowing_back_rightClass:Class;
		
		[Embed (source="animazoo/martial_arts/headbutt.bvh", mimeType="application/octet-stream")]
		public var headbuttClass:Class;
		
		[Embed (source="animazoo/martial_arts/kick_r.bvh", mimeType="application/octet-stream")]
		public var kick_rClass:Class;
		
		[Embed (source="animazoo/martial_arts/right_uppercut.bvh", mimeType="application/octet-stream")]
		public var right_uppercutClass:Class;
		
		[Embed (source="animazoo/martial_arts/slapping.bvh", mimeType="application/octet-stream")]
		public var slappingClass:Class;
		
		[Embed (source="animazoo/martial_arts/slapping2.bvh", mimeType="application/octet-stream")]
		public var slapping2Class:Class;
		
		[Embed (source="animazoo/talking/annoyed_conversation.bvh", mimeType="application/octet-stream")]
		public var annoyed_conversationClass:Class;
		
		[Embed (source="animazoo/talking/on_telephone.bvh", mimeType="application/octet-stream")]
		public var on_telephoneClass:Class;
		
		[Embed (source="freebones/horseruncycle.bvh", mimeType="application/octet-stream")]
		public var horseruncycleClass:Class;
		
		[Embed (source="freebones/floordancers21.bvh", mimeType="application/octet-stream")]
		public var floordancers21Class:Class;
		
		[Embed (source="freebones/fallstunt1.bvh", mimeType="application/octet-stream")]
		public var fallstunt1Class:Class;
		
		[Embed (source="freebones/boxerwarming1.bvh", mimeType="application/octet-stream")]
		public var boxerwarming1Class:Class;
		
		[Embed (source="freebones/dance.bvh", mimeType="application/octet-stream")]
		public var danceClass:Class;
		/*
		[Embed (source="freebones/matrix1.bvh", mimeType="application/octet-stream")]
		public var matrix1Class:Class;
		
		[Embed (source="freebones/mike8.bvh", mimeType="application/octet-stream")]
		public var mike8Class:Class;
		*/
		
		public var bvh:BVH;
		
		public var log:XrayLog;
		
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
			
			log = new XrayLog();
			
			status = new TextField();
			addChild(status);
			status.x = status.y = 5;
			status.width = 300;
			status.height = 50;
			status.multiline = true;
			status.selectable = false;
			status.defaultTextFormat = new TextFormat("Arial", 10, 0xff0000);
			
			_files = [
				new boxerwarming1Class(),
				new fallstunt1Class(),
				new floordancers21Class(),
				new horseruncycleClass(),
				new annoyed_conversationClass(),
				new on_telephoneClass(),
				new doublepunch1Class(),
				new doublepunch3Class(),
				new elbowing_back_rightClass(),
				new headbuttClass(),
				new kick_rClass(),
				new right_uppercutClass(),
				new slappingClass(),
				new slapping2Class(),
				new danceClass(),
				new ballerinaClass(),
				new breakdanceClass(),
				new shotheadClass(),
				new destroyClass(),
				new sexyClass(),
				new dribbleClass(),
				new coolwalkClass(),
				new cowboyClass()
			];
			
			container = new Sprite();
			addChild(container);
			container.x = 400;
			container.y = 300;
			
			// viewport for camera
			var vp:Rectangle = new Rectangle(0, 0, 600, 400);
			
			scene = new Scene3D(container);
			
			scene.triangleCuller = new RectangleTriangleCuller(new Rectangle(-vp.width/2, -vp.height/2, vp.width, vp.height));
			
			var plane:Plane = new Plane( new WireframeMaterial(0x0caa0c, 0.2), 400, 400, 16, 16 );
			scene.addChild(plane);
			plane.rotationX = -90;
			plane.z -= 120;
			
			var border:Sprite = new Sprite();
			addChild(border);
			border.graphics.lineStyle(3, 0xff0000);
			border.graphics.drawRect(400-vp.width/2-2, 300-vp.height/2-2, vp.width+4, vp.height+4);
			
			var mask:Sprite = new Sprite();
			container.addChild(mask);
			mask.graphics.beginFill(0xffff00);
			mask.graphics.drawRect(-vp.width/2, -vp.height/2, vp.width, vp.height);
			container.mask = mask;
			
			camera = new FrustumCamera3D(60, 0, 1000, vp);
			camera.x = -40;
			camera.y = 20;
			camera.z = -120;
			camera.lookAt(DisplayObject3D.ZERO);
			camera.pitch(-5);
			
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
			
			addEventListener( Event.ENTER_FRAME, loop3D );
			
			nextFile();
		}
		
		/**
		* 
		* @param	event
		* @return
		*/
		private function loop3D( event:Event ):void
		{
			if( bvh.rootNode )
				camera.z = bvh.rootNode.world.n34 - 120;
			
			scene.renderCamera(camera);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function nextFile( event:TimerEvent = null ):void
		{
			if( bvh )
				scene.removeChild(bvh);
	
			_curFileName = getQualifiedClassName(_files[_curFile]).substr(5);
			_curFileName = _curFileName.substr(0, _curFileName.length - 5) + ".bvh";
			
			bvh = new BVH(_files[_curFile++]);
			
			bvh.addEventListener( FileLoadEvent.LOAD_COMPLETE, playBVH );
			bvh.addEventListener( ProgressEvent.PROGRESS, bvhProgressHandler );
			
			// animation complete handler.
			bvh.controller.addEventListener( TimerEvent.TIMER_COMPLETE, nextFile );
			
			// each frame handler.
			bvh.controller.addEventListener( ProgressEvent.PROGRESS, bvhFrameHandler );
			
			scene.addChild(bvh);
	
			bvh.rotationY += 90;
			
			_curFile = _curFile < _files.length ? _curFile : 0;
		}
		
		/**
		 * 
	 	 * @param	event
		 * @return
		 */
		private function playBVH( event:FileLoadEvent = null ):void
		{
			Papervision3D.log(bvh.toHierarchyString());
			
			bvh.play(1);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function bvhFrameHandler( event:ProgressEvent ):void
		{
			status.text = _curFileName + "\nframe #" + event.bytesLoaded + " of " + event.bytesTotal;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function bvhProgressHandler( event:ProgressEvent ):void
		{
			status.text = _curFileName + "\nframe #" + event.bytesLoaded + " of " + event.bytesTotal;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function keyUpHandler( event:KeyboardEvent ):void
		{
			if( !bvh )
				return;
				
			if( bvh.mode == BVH.MODE_OBJECT )
				bvh.mode = BVH.MODE_POSE;
			else
				bvh.mode = BVH.MODE_OBJECT;
		}
		
		private var _curFile:uint = 0;
		private var _curFileName:String;
		private var _files:Array;
	}
}
