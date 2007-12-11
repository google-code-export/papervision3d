/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import org.papervision3d.core.layers.*;

	public class BitmapLayerEffect extends AbstractEffect{
		
		private var layer:BitmapEffectLayer;
		private var filter:BitmapFilter;
		
		public function BitmapLayerEffect(filter:BitmapFilter){
			this.filter = filter;
		}
		
		public function updateEffect(filter:BitmapFilter):void{
			this.filter = filter;
		}
		
		public override function attachEffect(layer:EffectLayer):void{
			
			this.layer = BitmapEffectLayer(layer);
			
		}
		public override function postRender():void{
			layer.graphics.clear();
			layer.canvas.applyFilter(layer.canvas, layer.clippingRect, layer.clippingPoint, filter);
			
		}
	}
	
}
