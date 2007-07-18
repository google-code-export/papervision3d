package org.papervision3d.test
{
	import flash.display.Sprite;
	
	import org.papervision3d.containers.PapervisionView;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import flash.display.BitmapData;

	public class CullingTest extends PapervisionView
	{
		
		private var material:BitmapMaterial;
		private var bitmapData:BitmapData;
		private var sphere:Sphere;
		
		/**
		 * Quick test for the culling routines.
		 */
		public function CullingTest()
		{
			super();
			
		}
		
		override protected function setupScene():void
		{
			trace("called");
			bitmapData = new BitmapData(255,255,false,0);
			bitmapData.perlinNoise(64,64,4,12345,false,false,7,false);
			
			material = new BitmapMaterial(bitmapData);
			sphere = new Sphere(material, 100, 8,8);
			
			scene3D.addChild(sphere, "testSphere");
			camera3D.target = sphere;
			camera3D.x = 100;
		}
		
	}
}