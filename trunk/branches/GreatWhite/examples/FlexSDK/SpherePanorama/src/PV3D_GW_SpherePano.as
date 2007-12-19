package {
	import com.unitzeroone.pv3d.SpherePano;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	public class PV3D_GW_SpherePano extends MovieClip
	{
		/**
		 * @Author Ralph Hauwert
		 */
		protected var spherePano:SpherePano;
		
		public function PV3D_GW_SpherePano()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 30;
			spherePano = new SpherePano();
			addChild(spherePano);
		}
	}
}
