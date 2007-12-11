/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.layers {
	
	import flash.display.Sprite;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.effects.*;
	import org.papervision3d.core.layers.*;
	

	public class EffectLayer extends RenderLayer{
		
		public var effects:Array;
		
		public function EffectLayer(){
			super();
			effects = new Array();
			drawLayer = this;
		}
		
		public function renderEffects():void{
			for each(var e:AbstractEffect in effects){
				e.postRender();
			}
		}
		
		public function addEffect(fx:AbstractEffect):void{
			
			fx.attachEffect(this);
			effects.push(fx);
			
		}
		
		public function removeEffect(fx:AbstractEffect):void{
			
			
			this.filters = [];
	
			effects.splice(effects.indexOf(fx), 1);
			
			for each(var e:AbstractEffect in effects){
				e.attachEffect(this);
			}

		}
		
		public function updateBeforeRender():void
		{
			faceCount = 0;
			screenDepth = 0;
			for each(var e:AbstractEffect in effects){
				e.preRender();
			}
			this.graphics.clear();
		}
		
	}
	
}
