package org.papervision3d.utils
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.papervision3d.objects.DisplayObject3D;

	public class InteractiveSprite extends Sprite
	{
		public var obj:DisplayObject3D = null;
		
		// not sure why this is static - I would think we'd want this per instance
		static public var mouseIsDown:Boolean;
		
		/*
		public var mouseDown:Function;
		public var mouseClick:Function;
		public var release:Function;
		public var mouseOver:Function;
		public var mouseOut:Function;
		public var mouseMove:Function;
		*/
		
		public function InteractiveSprite(obj:DisplayObject3D=null):void
		{
			this.obj = obj;
		}	
		
	}
}