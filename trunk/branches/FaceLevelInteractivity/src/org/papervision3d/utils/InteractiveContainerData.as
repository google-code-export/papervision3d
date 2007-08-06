package org.papervision3d.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.display.SpreadMethod;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.display.Sprite;
	import org.papervision3d.events.InteractiveSprite;
	
	public class InteractiveContainerData extends EventDispatcher
	{
		public var displayObject3D							:* = null;
		public var container								:InteractiveSprite;
		public var color									:Number = InteractiveSceneManager.DEFAULT_FILL_COLOR;
		public var isDrawn									:Boolean = false;
		public var sort										:Boolean = false;
		public var fillAlpha								:Number = InteractiveSceneManager.DEFAULT_FILL_ALPHA;
		
		public function InteractiveContainerData(container3d:*, p_color:Number=0x000000, target:IEventDispatcher=null)
		{
			super(target);
			displayObject3D = container3d;
			this.container = new InteractiveSprite(container3d);
			color = p_color;
			
			container.alpha = InteractiveSceneManager.DEFAULT_SPRITE_ALPHA;
		}		
	}
}