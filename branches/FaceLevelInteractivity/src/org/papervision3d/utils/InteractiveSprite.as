package org.papervision3d.utils
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class InteractiveSprite extends Sprite
	{
		public var obj:*;
		
		static public var mouseIsDown:Boolean;
		
		public var mouseDown:Function;
		public var mouseClick:Function;
		public var release:Function;
		public var mouseOver:Function;
		public var mouseOut:Function;
		public var mouseMove:Function;
		
		public function InteractiveSprite(obj=null):void
		{
			this.obj = obj;
		}	
		
	}
}