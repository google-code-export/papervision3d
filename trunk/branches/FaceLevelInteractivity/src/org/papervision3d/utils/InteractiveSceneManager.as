/**
* ...
* @author John Grden
* @version 0.1
*/

package org.papervision3d.utils 
{
	import com.blitzagency.xray.logger.XrayLog;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.geom.Face3DInstance;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.events.InteractiveSprite;
	import flash.events.Event;

	public class InteractiveSceneManager extends EventDispatcher
	{
		public static var DEFAULT_SPRITE_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_COLOR						:Number = 0xFFFFFF;
		
		public var buttonMode										:Boolean;
		
		public var mouseDown										:Function;
		public var mouseClick										:Function;
		public var release											:Function;
		public var releaseOutside									:Function;
		public var mouseOver										:Function;
		public var mouseOut											:Function;
		public var mouseMove										:Function;
		
		public var faceDictionary									:Dictionary = new Dictionary();
		public var containerDictionary								:Dictionary = new Dictionary();
		public var container										:Sprite = new InteractiveSprite();
		public var scene											:SceneObject3D;
		
		public var debug											:Boolean = false;
		
		protected var log											:XrayLog = new XrayLog();
		
		public function InteractiveSceneManager(p_scene:SceneObject3D):void
		{
			scene = p_scene;
			scene.container.parent.addChild(container);
			container.x = scene.container.x;
			container.y = scene.container.y;
			container.stage.addEventListener(Event.RESIZE, handleResize);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, handleReleaseOutside);
		}
		
		public function addDisplayObject(container3d:*):void
		{
			if(faceDictionary[container3d] == null) 
			{
				var icd:InteractiveContainerData;
				if(container3d is Face3DInstance && container3d.instance.faceLevelMode){
					
					icd = faceDictionary[container3d.face] = new InteractiveContainerData(container3d.face);
					icd.container = container3d.face.container;
					
					//container.addChild(icd.container);
					if(debug) log.debug("addDisplayObject id", container3d.face.id, container3d.face.id, DEFAULT_SPRITE_ALPHA);
				}
				else if(container3d is DisplayObject3D && !container3d.faceLevelMode){
					icd = faceDictionary[container3d] = new InteractiveContainerData(container3d);
					
					// for reverse lookup when you have the sprite container
					containerDictionary[icd.container] = container3d;
					
					if(debug) log.debug("addDisplayObject id", container3d.id, container3d.name, DEFAULT_SPRITE_ALPHA);
				} else {
					icd = faceDictionary[container3d] = new InteractiveContainerData(container3d);
					containerDictionary[icd.container] = container3d;
				}
				
			}
			if(icd && container3d is Face3DInstance && icd.displayObject3D.face3DInstance.instance.faceLevelMode || icd && icd.displayObject3D is DisplayObject3D && !icd.displayObject3D.faceLevelMode){
				
				// add mouse events to be captured and passed along
				if(buttonMode) icd.container.buttonMode = true;
				icd.container.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
				icd.container.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
				icd.container.addEventListener(MouseEvent.CLICK, handleMouseClick);
				icd.container.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
				icd.container.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
				icd.container.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
					
				icd.container.mouseDown = mouseDown;
				icd.container.mouseOver = mouseOver;
				icd.container.mouseOut = mouseOut;
				icd.container.release = release;
				icd.container.mouseClick = mouseClick;
				icd.container.mouseMove = mouseMove;
			}
		}
		
		public function drawFace(container3d:DisplayObject3D, face3D:Face3D, x0:Number, x1:Number, x2:Number, y0:Number, y1:Number, y2:Number ):void
		{
			if(faceDictionary[container3d] == null) addDisplayObject(container3d);
			if(!container3d.faceLevelMode){
				var drawingContainer:InteractiveContainerData = faceDictionary[container3d];
				
				drawingContainer.container.graphics.beginFill(drawingContainer.color, drawingContainer.fillAlpha);
				drawingContainer.container.graphics.moveTo( x0, y0 );
				drawingContainer.container.graphics.lineTo( x1, y1 );
				drawingContainer.container.graphics.lineTo( x2, y2 );
				drawingContainer.container.graphics.endFill();
				drawingContainer.isDrawn = true;
			}
		}
		
		public function getSprite(container3d:DisplayObject3D):InteractiveSprite
		{
			return InteractiveContainerData(faceDictionary[container3d]).container;
		}
		
		public function getDisplayObject3D(sprite:InteractiveSprite):DisplayObject3D
		{
			return DisplayObject3D(containerDictionary[sprite]);
		}
		
		public function resizeStage():void
		{
			container.x = scene.container.x;
			container.y = scene.container.y;
		}
		
		public function resetFaces():void
		{			
			// clear all triangles/faces that have been drawn
			for each( var item:InteractiveContainerData in faceDictionary)
			{
				
				item.container.graphics.clear();
				item.sort = item.isDrawn;
				item.isDrawn = false;
			}
			
			// make sure the sprite is aligned with the scene's canvas
			resizeStage();
		}
		
		public function sortObjects():void
		{
			// called from the scene after the render loop is completed
			var sort:Array = [];
			
			for each( var item:InteractiveContainerData in faceDictionary)
			{
				if(!item.sort) continue;
				var distance:Number = item.displayObject3D.screenZ;
				sort.push({container:item.container, distance:distance});
			}
			
			sort.sortOn("distance", Array.DESCENDING | Array.NUMERIC);
			
			for(var i:Number=0;i<sort.length;i++) container.addChild(sort[i].container);
		}
		
		protected function handleMousePress(e:MouseEvent):void
		{
			if(debug) log.debug("press", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
			
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_PRESS, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_PRESS, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			InteractiveSprite.mouseIsDown = true;
			if(mouseDown is Function)
				e.target.mouseDown();
		}
		
		protected function handleMouseRelease(e:MouseEvent):void
		{
			if(debug) log.debug("release", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
			
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			InteractiveSprite.mouseIsDown = false;
			if(release is Function)
				e.target.release();
		}
		
		protected function handleMouseClick(e:MouseEvent):void
		{
			if(debug) log.debug("click", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
			
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_CLICK, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_CLICK, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			if(mouseClick is Function)
				e.target.mouseClick();
		}
		
		protected function handleMouseOver(e:MouseEvent):void
		{
			if(debug) log.debug("Over", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
			
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OVER, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OVER, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			if(mouseOver is Function)
				e.target.mouseOver();
		}
		
		protected function handleMouseOut(e:MouseEvent):void
		{
			if(debug) log.debug("Out", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
			
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OUT, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OUT, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			if(mouseOut is Function)
				e.target.mouseOut();
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{	
			if(debug) log.debug("Move", DisplayObject3D(containerDictionary[e.target]).name);
			
			var do3d:*;
			if(e.target.obj is DisplayObject3D) do3d = DisplayObject3D(e.target.obj);
			else do3d = DisplayObject3D(e.target.obj.instance);
				
			do3d.dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_MOVE, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_MOVE, containerDictionary[e.currentTarget], InteractiveSprite(e.currentTarget)));
			if(mouseMove is Function)
				e.target.mouseMove();
		}
		
		protected function handleReleaseOutside(e:MouseEvent):void
		{	
			if(debug) log.debug("releaseOutside");
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE_OUTSIDE));
			InteractiveSprite.mouseIsDown = false;
			if(releaseOutside is Function)
				releaseOutside();
		}
		
		protected function handleResize(e:Event):void
		{
			resizeStage();
		}
	}
}
