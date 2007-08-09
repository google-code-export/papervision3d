package org.papervision3d.utils
{
	import flash.display.Sprite;
	import org.papervision3d.objects.DisplayObject3D;

	public class InteractiveSprite extends Sprite
	{
		public var obj:DisplayObject3D = null;
		public var interactiveContainerData:InteractiveContainerData = null;
		
		public var x0:Number;
		public var x1:Number;
		public var x2:Number;
		public var y0:Number;
		public var y1:Number;
		public var y2:Number;		
		
		public function InteractiveSprite(obj:DisplayObject3D=null):void
		{
			this.obj = obj;
		}
	}
}