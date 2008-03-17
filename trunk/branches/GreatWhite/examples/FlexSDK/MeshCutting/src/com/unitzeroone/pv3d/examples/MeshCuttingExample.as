package com.unitzeroone.pv3d.examples
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.utils.MeshUtil;
	import org.papervision3d.materials.BitmapColorMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;

	public class MeshCuttingExample extends BasicView
	{
		protected var planeMaterial:BitmapColorMaterial;
		protected var sphereMaterial:BitmapMaterial;
		
		protected var sourceSphere:Sphere;
		protected var hemiSphereA:TriangleMesh3D;
		protected var hemiSphereB:TriangleMesh3D;
	
		
		public function MeshCuttingExample()
		{
			super(0, 0, true, false);
			opaqueBackground = 0;
			setupScene();
		}
		
		protected function setupScene():void
		{
			//Setup a bitmapdata material for the spheres to use.
			var bmp:BitmapData = new BitmapData(512,255,false,0);
			bmp.perlinNoise(64,64,4,123456,true,false);
			
			//Create a new sphere, which we will use as a source geometry, cutting it.
			sphereMaterial = new BitmapMaterial(bmp);
			sphereMaterial.doubleSided = true;
			sourceSphere = new Sphere(sphereMaterial, 400, 15,15);
			
			//Setup a plane3d along which we will cut the sphere.
			var normal:Number3D = new Number3D(.5,.5,0); //Some angle
			var point:Number3D = new Number3D(0,80,0); //at position...
			var cutPlane:Plane3D = Plane3D.fromNormalAndPoint(normal, point);
			
			//Cut the sphere along the plane3D, returns an array of maximum 2 meshes.
			var meshes:Array = MeshUtil.cutTriangleMesh(sourceSphere, cutPlane);
			
			//Add result meshA
			hemiSphereA = meshes[0];
			hemiSphereA.x = 400;
			scene.addChild(hemiSphereA);
			
			//Add result meshB
			hemiSphereB = meshes[1];
			hemiSphereB.x = -400;
			scene.addChild(hemiSphereB);
			
			//Start rendering
			startRendering();
		}
		
		override protected function onRenderTick(event:Event=null):void
		{
			//Rotate the spheres.
			hemiSphereA.yaw(1);
			hemiSphereB.yaw(-1);
			super.onRenderTick(event);
		}
		
	}
}