package org.papervision3d.test
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.containers.PapervisionView;
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.CompositeMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.Cube;
	import org.papervision3d.objects.Sphere;

	public class CullingTest extends PapervisionView
	{
		
		private var material:CompositeMaterial;
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
			//var material:BitmapMaterial = new BitmapMaterial(bitmapData);
			
			//var material:ColorMaterial = new ColorMaterial(0xFF0000,1);
			var material:CompositeMaterial = new CompositeMaterial();
			
			material.addMaterial(new BitmapMaterial(bitmapData));
			material.addMaterial(new WireframeMaterial(0xFF0000,100));
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