package
{
	import flash.display.Sprite;
	import org.papervision3d.test.CullingTest;
	import flash.display.StageAlign;
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.culling.RectangleTriangleCuller;

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
			Papervision3D.triangleCuller = new RectangleTriangleCuller();
			cullingTest = new CullingTest();
			addChild(cullingTest);
			cullingTest.startRendering();	
		}
		
	}
}