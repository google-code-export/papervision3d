package {
	import com.unitzeroone.pv3d.examples.MeshCuttingExample;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;

	public class Main extends Sprite
	{
		protected var example:MeshCuttingExample;
		
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			example = new MeshCuttingExample();
			addChild(example);
		}
	}
}
