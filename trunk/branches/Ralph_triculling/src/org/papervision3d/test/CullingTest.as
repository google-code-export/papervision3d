package org.papervision3d.test
{
	import flash.display.Sprite;
	
	import org.papervision3d.containers.PapervisionView;
	import org.papervision3d.objects.Sphere;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import flash.display.BitmapData;
	import org.papervision3d.objects.Cube;
	import flash.display.DisplayObject;
	import org.papervision3d.core.geom.Mesh3D;
	import flash.events.Event;

	public class CullingTest extends PapervisionView
	{
		
		private var material:BitmapMaterial;
		private var bitmapData:BitmapData;
		private var obj:Mesh3D;
		
		/**
		 * Quick test for the culling routines.
		 */
		public function CullingTest()
		{
			super();
		}
		
		override protected function setupScene():void
		{
			clipSprite.graphics.beginFill(0,.3);
			clipSprite.graphics.drawRect(-160,-120,320,240);
			clipSprite.graphics.endFill();
			
			bitmapData = new BitmapData(255,255,false,0xFFFFFF);
			bitmapData.perlinNoise(64,64,4,123456,false,true,7);
			material = new BitmapMaterial(bitmapData);
			material.doubleSided = false;
			obj = new Cube(material,1000,1000,1000,8,8,8);
			
			scene3D.addChild(obj);
			
			camera3D.target = obj;
			camera3D.x = 100;
		}
		
		override protected function onEnterFrame(event:Event):void
		{
			obj.yaw(1);
			obj.pitch(1);
			super.onEnterFrame(event);	
		}
		
	}
}