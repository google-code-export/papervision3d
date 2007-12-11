/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {

	import flash.filters.BitmapFilter;
	import org.papervision3d.core.layers.EffectLayer;
	import org.papervision3d.core.layers.RenderLayer;
	
	public class AbstractEffect implements IEffect{

		function AbstractEffect(){}
		
		public function attachEffect(layer:EffectLayer):void{}
		public function preRender():void{}
		public function postRender():void{}
		public function getEffect():BitmapFilter{
			return null;
		}
		
	}
	
}
