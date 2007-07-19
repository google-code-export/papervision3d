package org.papervision3d.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.display.SpreadMethod;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.display.Sprite;

	public class InteractiveContainerData extends EventDispatcher
	{
		public var displayObject3D							:DisplayObject3D = null;
		public var container								:Sprite = new Sprite();
		public var color									:Number = 0x000000;
		public var isDrawn									:Boolean = false;
		public var sort										:Boolean = false;
		
		public function InteractiveContainerData(container3d:DisplayObject3D, p_color:Number=0x000000, target:IEventDispatcher=null)
		{
			super(target);
			displayObject3D = container3d;
			color = p_color;
		}		
	}
}