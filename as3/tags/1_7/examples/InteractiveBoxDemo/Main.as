package {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.setTimeout;
	import org.papervision3d.materials.MaterialsList;
	
	// Import Papervision3D
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.InteractiveScene3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.Collada;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.Plane;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	import org.papervision3d.utils.virtualmouse.IVirtualMouseEvent;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.components.as3.utils.ObjectController;
	
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		var container :Sprite;
		var scene     :InteractiveScene3D;
		var camera    :Camera3D;
		var ism		  :InteractiveSceneManager;
		var box       :DisplayObject3D;
		var mouse     :Mouse3D;
		var vMouse	  :VirtualMouse;
		var collada	  :Collada;
		var material  :InteractiveMovieMaterial;
		
		public var formUIContainer:MovieClip;
		
//		var formUI	  :MovieClip;
		var FS 		  :SimpleButton;
		
		public function Main() {
			init();
		}
		
		public function init():void {
				
			FS = new SimpleButton();
			FS.visible = stage.hasOwnProperty("displayState");
			FS.addEventListener( MouseEvent.CLICK, goFull );
			FS.x = 622;
			FS.y = 464;
			
			stage.scaleMode = "noScale"
			
			init3D();
			
			addChild( FS );
		}
		
		// ___________________________________________________________________ Init3D
		public function init3D():void {
			
			// Create container sprite and center it in the stage
			container = new InteractiveSprite();
			addChild( container );
			container.name = "mainCont";
			container.x = stage.stageWidth *.5;
			container.y = stage.stageHeight *.5;
		
			// Create scene
			scene = new InteractiveScene3D( container );
			ism = scene.interactiveSceneManager;
			
			InteractiveSceneManager.SHOW_DRAWN_FACES = false;
			//InteractiveSceneManager.DEFAULT_LINE_COLOR = 0xFFFFFF;
			InteractiveSceneManager.DEFAULT_SPRITE_ALPHA = 1;
			InteractiveSceneManager.DEFAULT_FILL_ALPHA = 1;
			
			BitmapMaterial.AUTO_MIP_MAPPING = true;
			DisplayObject3D.faceLevelMode = false;
			
			ism.buttonMode = true;
			ism.faceLevelMode = true;											
			ism.mouseInteractionMode = false;
			
			createMaterial();
			var matsList:MaterialsList = new MaterialsList();
			matsList.addMaterial(material, "boxMaterial");
			
			var file:String = this.loaderInfo.url.indexOf("http:") > -1 ? "http://www.rockonflash.com/demos/pv3d/InteractiveSceneManager_faceLevelMode/boxDemo/box.DAE" : "box.DAE";
			
			collada = new Collada(file, matsList, .3);
			collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, handleLoadComplete);
			
			this.formUIContainer.blendMode = BlendMode.ERASE;
			this.formUIContainer.enabled = false;

			// Create camera
			camera = new Camera3D();
			camera.zoom = .25;
			camera.focus = 1650;
			camera.z = -2000;
		}
		// ___________________________________________________________________ Create album
		//var mouseIsDown:Boolean;

		public function createMaterial():void
		{
			material = new InteractiveMovieMaterial( this.formUIContainer["formUI"] );

			material.animated = true;
			material.smooth = true;
			
			material.movie["btn"].addEventListener(MouseEvent.CLICK, handleBTNClick);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OVER, handleBTNOver);
			material.movie["btn"].addEventListener(MouseEvent.MOUSE_OUT, handleBTNOut);
			
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OVER, handleB1Over);
			material.movie["b1"].addEventListener(MouseEvent.MOUSE_OUT, handleB1Out);
		}
		
		private function handleLoadComplete(e:FileLoadEvent):void
		{
			initScene();
		}
		
		private function initScene():void
		{
			/**
			* In this box example, I created a box in 3DS, then, I changed the pivot location.  
			* 
			* The funny thing is, it creates a sub object called nameOfObject_PIVOT.  Pivot, as it turns out, receives the material.
			* 
			* So, I have to reassign the material to pivot because for some reason, going through collada, the material is converted back to MaterialObject3D.
			* 
			* I would say this is a bug we need to fix in Collada object ;)
			*/
			box = collada.getChildByName("Box01").getChildByName("Box01_PIVOT");
			box.material = material;

			scene.addChild(collada);
			
			ObjectController.getInstance().registerStage(stage);
			ObjectController.getInstance().registerControlObject(collada);
			
			addEventListener( Event.ENTER_FRAME, loop );
		}
		
		function handleBTNClick(e:MouseEvent):void
		{
			trace("vMouse click from btn");
			if (e is IVirtualMouseEvent) trace("IVirtualMouseEvent click from btn");
		
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleBTNOver(e:MouseEvent):void
		{
			trace("over");
			//e.currentTarget.invalidate();
			e.currentTarget.setMouseState("over");
			e.currentTarget.drawNow();
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleBTNOut(e:MouseEvent):void
		{
			trace("out");
			//e.currentTarget.invalidate();
			e.currentTarget.setMouseState("up");
			e.currentTarget.drawNow();
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleB1Over(e:MouseEvent):void
		{
			trace("over");
			e.currentTarget.blendMode = BlendMode.ADD;
		}
		
		// these are received from the btn in the canvas itself via the VirtualMouse
		function handleB1Out(e:MouseEvent):void
		{
			trace("out");
			e.currentTarget.blendMode = BlendMode.NORMAL;
		}
		
		// ___________________________________________________________________ Loop
		
		function loop(event:Event):void 
		{
			material.movie.cacheAsBitmap = true;
			scene.renderCamera( this.camera );
			material.movie.cacheAsBitmap = false;
			FS.x = 640 + (stage.stageWidth - 640)/2;
			FS.y = 480 + (stage.stageHeight - 480)/2;
		}
		
		// ___________________________________________________________________ FullScreen
		
		function goFull(event:MouseEvent):void {
			if ( stage.hasOwnProperty("displayState") ) {
				if ( stage.displayState != "fullScreen" ) {
					stage.displayState = "fullScreen";
				} else {
					stage.displayState = "normal";
				}
			}
		}

	}
}