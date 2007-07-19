package
{
	import flash.display.Sprite;
	import org.papervision3d.test.CullingTest;
	import flash.display.StageAlign;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.culling.RectangleTriangleCuller;
	import org.papervision3d.core.culling.DefaultTriangleCuller;

	[SWF( width="640", height="480")]
	public class TriangleCullingTestApplication extends Sprite
	{
		
		private var cullingTest:CullingTest;
		
		public function TriangleCullingTestApplication()
		{
			super();
			stage.align = StageAlign.TOP_LEFT;
			init();
		}
		
		private function init():void
		{
			cullingTest = new CullingTest();
			//cullingTest.scene3D.triangleCuller = new RectangleTriangleCuller();
			addChild(cullingTest);
			cullingTest.startRendering();	
		}
		
	}
}