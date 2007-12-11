package org.papervision3d.view
{
	import flash.display.BitmapData;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class BitmapViewport3D extends Viewport3D implements IViewport3D
	{
		
		public var bitmapData:BitmapData;
		
		public function BitmapViewport3D(viewportWidth:Number=640, viewportHeight:Number=480, interactive:Boolean=false, autoCulling:Boolean=true)
		{
			super(viewportWidth, viewportHeight, false, interactive, true, autoCulling);
			bitmapData = new BitmapData(Math.round(viewportWidth), Math.round(viewportHeight), false, 0);
			removeChild(_containerSprite);
		}
		
		override public function updateAfterRender():void
		{
			if(bitmapData.width != Math.round(viewportWidth) || bitmapData.height != Math.round(viewportHeight)){
				bitmapData = new BitmapData(viewportWidth, viewportHeight, false, 0);
			}else{
				bitmapData.fillRect(bitmapData.rect, 0);
			}
			bitmapData.draw(_containerSprite, null, null, null, bitmapData.rect, false);
		}
	}
}