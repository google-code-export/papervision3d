/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.layers {
	
	import flash.display.Sprite;

	public class RenderLayer extends Sprite{
		
		public var drawLayer:Sprite;
		public var screenDepth:Number = 0;
		public var faceCount:Number = 0;
		public var layerIndex:Number = 1;
		
		public function RenderLayer(){
			drawLayer = this;
		}
		
	}
	
}
