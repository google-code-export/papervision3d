package org.papervision3d.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.display.SpreadMethod;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import org.papervision3d.utils.InteractiveSprite;
	
	public class InteractiveContainerData extends EventDispatcher
	{
		public var displayObject3D							:DisplayObject3D = null;
		public var container								:InteractiveSprite;
		public var face3d									:Face3D;
		
		public var isDrawn									:Boolean = false;
		public var sort										:Boolean = false;
		
		public var color									:Number = InteractiveSceneManager.DEFAULT_FILL_COLOR;
		public var fillAlpha								:Number = InteractiveSceneManager.DEFAULT_FILL_ALPHA;
		public var lineColor								:Number = InteractiveSceneManager.DEFAULT_LINE_COLOR;
		public var lineSize									:Number = InteractiveSceneManager.DEFAULT_LINE_SIZE;
		public var lineAlpha								:Number = InteractiveSceneManager.DEFAULT_LINE_ALPHA;
		
		
		public function get screenZ():Number
		{
			return displayObject3D != null ? displayObject3D.screenZ : face3d.screenZ;
		}
		
		public function InteractiveContainerData(container3d:*, p_color:Number=0x000000, target:IEventDispatcher=null)
		{
			super(target);

			displayObject3D = container3d is DisplayObject3D == true ? container3d : null;
			face3d = container3d is Face3D == true ? container3d : null;
			
			if( displayObject3D != null ) this.container = new InteractiveSprite(container3d);
			if( face3d != null )
			{
				if( face3d.face3DInstance.container != null )
				{
					this.container = InteractiveSprite(face3d.face3DInstance.container);
				}
				else
				{
					this.container = new InteractiveSprite();
				}
			}
			color = p_color;
			
			container.alpha = InteractiveSceneManager.DEFAULT_SPRITE_ALPHA;
			container.interactiveContainerData = this;
		}		
	}
}