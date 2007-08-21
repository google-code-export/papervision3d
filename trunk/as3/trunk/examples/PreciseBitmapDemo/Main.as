package {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.display.Stage;
	import flash.events.*;
	
	// Import Papervision3D
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.scenes.*;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.materials.*;
	import org.papervision3d.utils.*;
	import org.papervision3d.objects.*;
	import flash.text.TextField;
	import flash.utils.*;

	
	/**
	 *	Sorry about the changes I had to make to this class to make it work with CS3 as a class.  I hate the way they implemented stage instances...
	 *  Jim Kremens 
	*/
	public class Main extends MovieClip {

		// ___________________________________________________________________ 3D vars
		var container :Sprite;
		var scene     :MovieScene3D;
		var camera    :Camera3D;
		var ism		  :InteractiveSceneManager;
		var plane	  :Plane;
		var time:Number;

		public function Main() {
			init();
			time = getTimer();
		}
		
		public function init():void {
				

			stage.scaleMode = "noScale"
			
			init3D();
			

			addEventListener( Event.ENTER_FRAME, loop );
			
		}
		
		// ___________________________________________________________________ Init3D
		public function init3D():void {
			
			// Create container sprite and center it in the stage
			container = new Sprite();
			addChild( container );
			container.name = "mainCont";
			container.x = 300;
			container.y = 200;
			
			scene = new MovieScene3D(container);
		
			var bp:BitmapMaterial = new BitmapMaterial(new wall(1,1));
			
			var bpp:PreciseBitmapMaterial = new PreciseBitmapMaterial(new wall(1,1));
			var mp1 = new MaterialsList();
			mp1.addMaterial(bp, "all");
			
			var mp2 = new MaterialsList();
			mp2.addMaterial(bpp, "all");
			var p:Cube = new Cube(mp1, 500, 500, 500, 1, 1,1);
			var pp:Cube = new Cube(mp2, 500, 500,500, 1, 1,1);
			scene.addChild(p);
			scene.addChild(pp);
			p.rotationZ = -30;
			pp.rotationZ = -30;
			p.x = 310;
			pp.x = -310;


			// Create camera
			camera = new Camera3D();
			camera.zoom = 6;
			camera.sort = true;
			
		}
		// ___________________________________________________________________ Create album
		//var mouseIsDown:Boolean;


		// ___________________________________________________________________ Loop
		
		function loop(event:Event):void 
		{

			
			camera.hover(1, (container.x - mouseX)/40, (container.y-mouseY)/40);
			scene.renderCamera( this.camera );
			
			//m_time_txt.text = (getTimer()-time).toString()+" ms";
			//time = getTimer();

		}
		


	}
}