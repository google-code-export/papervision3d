/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
	import flash.filters.BitmapFilter;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.layers.EffectLayer;

	public interface IEffect {
		
		function attachEffect(layer:EffectLayer):void;
		function preRender():void;
		function postRender():void;
		function getEffect():BitmapFilter;
		
	}
	
}
