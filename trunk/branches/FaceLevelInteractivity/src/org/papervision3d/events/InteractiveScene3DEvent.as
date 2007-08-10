/**
* @author John Grden
*/

package org.papervision3d.events
{
	import flash.events.Event;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.display.Sprite;
	import org.papervision3d.utils.InteractiveContainerData;

	public class InteractiveScene3DEvent extends Event
	{
		public static var OBJECT_CLICK:String = "mouseClick";
		public static var OBJECT_OVER:String = "mouseOver";
		public static var OBJECT_OUT:String = "mouseOut";
		public static var OBJECT_MOVE:String = "mouseMove";
		public static var OBJECT_PRESS:String = "mousePress";
		public static var OBJECT_RELEASE:String = "mouseRelease";
		public static var OBJECT_RELEASE_OUTSIDE:String = "mouseReleaseOutside";
		
		public var displayObject3D				:DisplayObject3D = null;
		public var sprite						:Sprite = null;
		public var face3d						:Face3D = null;
		public var interactiveContainerData		:InteractiveContainerData = null;
		
		public function InteractiveScene3DEvent(type:String, container3d:DisplayObject3D=null, sprite:Sprite=null, face3d:Face3D=null, interactiveContainerData:InteractiveContainerData=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.displayObject3D = container3d;
			this.sprite = sprite;
			this.face3d = face3d;
			this.interactiveContainerData = interactiveContainerData;
		}		
	}
}