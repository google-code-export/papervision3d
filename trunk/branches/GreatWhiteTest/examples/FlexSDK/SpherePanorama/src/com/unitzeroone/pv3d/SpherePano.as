package com.unitzeroone.pv3d
{
	import flash.events.Event;
	
	import mx.core.MovieClipAsset;
	
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	public class SpherePano extends BasicView
	{
		[Embed(source="/assets/pano.swf")]
		private var panoAsset:Class;

		protected var panoSphere:Sphere;
		protected var sphereMat:MovieMaterial;
		
		/**
		 * @Author Ralph Hauwert
		 */
		public function SpherePano()
		{
			//Setup the basic view to do autoscaling, no interactivity, and use a free camera.
			super(0, 0, true, false, FreeCamera3D.TYPE);
			init();
			startRendering();
		}
		
		private function init():void
		{
			//Set the background to black
			opaqueBackground = 0;
			
			//Create the pano material
			var movieAsset:MovieClipAsset = new panoAsset();
			sphereMat = new MovieMaterial(movieAsset, false);
			sphereMat.opposite = true;
			sphereMat.animated = true;
			
			//Smooth is heavy, but it makes stuff look nicer...you could make it switch dynamically.
			sphereMat.smooth = true;
			
			//Create the panosphere.
			panoSphere = new Sphere(sphereMat, 25000, 30,30);
			scene.addChild(panoSphere);
			
			//position the camera in the center of the sphere, and set it's properties for focus and zoom.
			camera.x = camera.y = camera.z = 0;
			camera.focus = 300;
			camera.zoom = 2;
		}
		
		override protected function onRenderTick(event:Event=null):void
		{
			//Rotate the camera left and right.
			camera.rotationY += (mouseX-(stage.width/2))/50;
			//Rotate the camera up and down
			camera.rotationX -= (mouseY-(stage.height/2))/50;
			//Lock the camera up down rotation so you can't do "loopings".
			if(camera.rotationX <= -90){
				camera.rotationX = -90;
			}else if(camera.rotationX >= 90){
				camera.rotationX = 90;	
			}
			//Render as usual
			super.onRenderTick(event);
		}
		
	}
}