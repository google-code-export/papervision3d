/**
* ...
* @author John Grden
* @version 0.1
*/

package org.papervision3d.utils 
{
	import com.blitzagency.xray.logger.XrayLog;
	import flash.geom.Point;
	import org.papervision3d.components.as3.utils.CoordinateTools;
	
	import flash.display.Sprite;
	import flash.display.BlendMode;
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
	import org.papervision3d.utils.InteractiveSprite;
	import flash.events.Event;

	public class InteractiveSceneManager extends EventDispatcher
	{
		public static var DEFAULT_SPRITE_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_COLOR						:Number = 0xFFFFFF;
		public static var MOUSE_IS_DOWN								:Boolean = false;
		
		public var buttonMode										:Boolean = false;
		/**
		* This allows objects faces to have their own containers.  When set to true
		* and the DisplayObject3D.faceLevelMode = false, the faces will be drawn in ISM's layer of containers
		*/
		public var faceLevelMode  									:Boolean = false;
		
		/**
		* If the user sets this to true, then we monitor the allowDraw flag via mouse interaction.
		* If set to true, then leave DEFAULT_SPRITE_ALPHA and DEFAULT_FILL_ALPHA at their default values to avoid odd drawings over the 3D scene
		*/
		private var _mouseInteractionMode							:Boolean = false;
		public function set mouseInteractionMode(value:Boolean):void
		{
			_mouseInteractionMode = value;
			allowDraw = !value;
			if( value ) container.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleStageMouseMove);
			if( !value ) container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleStageMouseMove);
		}
		public function get mouseInteractionMode():Boolean { return _mouseInteractionMode; }
		public var faceDictionary									:Dictionary = new Dictionary();
		public var containerDictionary								:Dictionary = new Dictionary();
		public var container										:Sprite = new InteractiveSprite();
		public var scene											:SceneObject3D;
		
		public var debug											:Boolean = false;
		
		/**
		* Boolean flag used internally to turn off ISM drawing when it's not needed in the render loop.  This only applies if mouseInteractionMode is set to true.
		*/
		protected var allowDraw										:Boolean = true;
		
		protected var evaluateClick									:Boolean = false;
		
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
		
		public function addInteractiveObject(container3d:Object):void
		{
			if(faceDictionary[container3d] == null) 
			{
				var icd:InteractiveContainerData = faceDictionary[container3d] = new InteractiveContainerData(container3d);
				
				// for reverse lookup when you have the sprite container
				containerDictionary[icd.container] = container3d;
				
				// add mouse events to be captured and passed along
				icd.container.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
				icd.container.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
				icd.container.addEventListener(MouseEvent.CLICK, handleMouseClick);
				icd.container.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
				icd.container.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
				icd.container.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				
				icd.container.buttonMode = buttonMode;
				icd.container.blendMode = BlendMode.ERASE;
				
				if(debug) log.debug("addDisplayObject id", container3d.id, container3d.name, DEFAULT_SPRITE_ALPHA);
			}
		}
		
		public function drawFace(container3d:DisplayObject3D, face3d:Face3D, x0:Number, x1:Number, x2:Number, y0:Number, y1:Number, y2:Number ):void
		{
			// if we're face level on this DO3D, then we switch to the face3D object
			var container:Object = container3d;
			if(faceLevelMode || container3d.faceLevelMode) container = face3d;
			
			// add to the dictionary if not added already
			if(faceDictionary[container] == null) addInteractiveObject(container);
			
			// if ISM.faceLevelMode = false, and DO3D.faceLevelMode = true, then ISM isn't dealing with drawing the tri's just return and don't draw.
			// otherwise, we're in object level mode, and we draw
			//log.debug("drawFace", faceLevelMode, allowDraw);
			//if( faceLevelMode && allowDraw )
			if( allowDraw )
			{
				var drawingContainer:InteractiveContainerData = faceDictionary[container];
				//drawingContainer.container.drawHitArea(x0, x1, x2, y0, y1, y2);
				
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
				var distance:Number = item.screenZ;
				sort.push({container:item.container, distance:distance});
			}
			
			sort.sortOn("distance", Array.DESCENDING | Array.NUMERIC);
			
			for(var i:Number=0;i<sort.length;i++) container.addChild(sort[i].container);
			
			// after the render loop is complete, and we've sorted, we reset the allowDraw flag
			if( mouseInteractionMode ) allowDraw = false;
		}
		
		public function UVatPoint( face3d:Face3D, x : Number, y : Number ) : Object 
		{	
			
			var v0:Number = face3d.v0;
			var v1:Number = face3d.v1;
			var v2:Number = face3d.v2;
			
			var v0_x : Number = v2.vertex2DInstance.x - v0.vertex2DInstance.x;
			var v0_y : Number = v2.vertex2DInstance.y - v0.vertex2DInstance.y;
			var v1_x : Number = v1.vertex2DInstance.x - v0.vertex2DInstance.x;
			var v1_y : Number = v1.vertex2DInstance.y - v0.vertex2DInstance.y;
			var v2_x : Number = x - v0.vertex2DInstance.x;
			var v2_y : Number = y - v0.vertex2DInstance.y;
				
			var dot00 : Number = v0_x * v0_x + v0_y * v0_y;
			var dot01 : Number = v0_x * v1_x + v0_y * v1_y;
			var dot02 : Number = v0_x * v2_x + v0_y * v2_y;
			var dot11 : Number = v1_x * v1_x + v1_y * v1_y;
			var dot12 : Number = v1_x * v2_x + v1_y * v2_y;
				
			var invDenom : Number = 1 / (dot00 * dot11 - dot01 * dot01);
			var u : Number = (dot11 * dot02 - dot01 * dot12) * invDenom;
			var v : Number = (dot00 * dot12 - dot01 * dot02) * invDenom;
		   
			return { u : u, v : v };
		}
		
		public function getCoordAtPoint( face3d:Face3D, x : Number, y : Number ) : Vertex3D 
		{	
			var rUV : Object = UVatPoint(face3d, x, y);
			
			var u : Number = rUV.u;
			var v : Number = rUV.v;
				
			var rX : Number = v0.x + ( v1.x - v0.x ) * v + ( v2.x - v0.x ) * u;
			var rY : Number = v0.y + ( v1.y - v0.y ) * v + ( v2.y - v0.y ) * u;
			var rZ : Number = v0.z + ( v1.z - v0.z ) * v + ( v2.z - v0.z ) * u;
				
			return { x:rX, y:rY, z:rZ };
		}
		
		public function getMapCoordAtPoint( face3d:Face3D, x : Number, y : Number ) : Object 
		{
			var rUV : Object = UVatPoint(face3d, x, y);
			var u : Number = rUV.u;
			var v : Number = rUV.v;
				
			var v_x : Number = ( uv[1].u - uv[0].u ) * v +  (uv[2].u - uv[0].u) * u + uv[0].u;
			var v_y : Number = ( uv[1].v - uv[0].v ) * v +  (uv[2].v - uv[0].v) * u + uv[0].v;
			
			var face3DInstance:Face3DInstance = face3d.face3DInstance;
				
			return { x: v_x * face3DInstance.instance.material.bitmap.width, y: face3DInstance.instance.material.bitmap.height - v_y * face3DInstance.instance.material.bitmap.height };
		}
		
		protected function handleMousePress(e:MouseEvent):void
		{
			MOUSE_IS_DOWN = true;
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_PRESS, Sprite(e.currentTarget));
		}
		
		protected function handleMouseRelease(e:MouseEvent):void
		{
			MOUSE_IS_DOWN = false;
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_RELEASE, Sprite(e.currentTarget));
		}
		
		protected function handleMouseClick(e:MouseEvent):void
		{
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_CLICK, Sprite(e.currentTarget));
		}
		
		protected function handleMouseOver(e:MouseEvent):void
		{
			var eventType:String
			eventType = !evaluateClick || !mouseInteractionMode ? InteractiveScene3DEvent.OBJECT_OVER : InteractiveScene3DEvent.OBJECT_CLICK;
			evaluateClick = false;
			dispatchObjectEvent(eventType, Sprite(e.currentTarget));
		}
		
		protected function handleMouseOut(e:MouseEvent):void
		{
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_OUT, Sprite(e.currentTarget));
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{	
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_MOVE, Sprite(e.currentTarget));
		}
		
		protected function handleReleaseOutside(e:MouseEvent):void
		{	
			if(debug) log.debug("releaseOutside");
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE_OUTSIDE));
			MOUSE_IS_DOWN = false;
			evaluateClick = true
			allowDraw = true;
		}
		
		protected function handleStageMouseMove(e:MouseEvent):void
		{
			allowDraw = true;
		}
		
		protected function dispatchObjectEvent(event:String, currentTarget:Sprite):void
		{
			if(debug) log.debug(event, DisplayObject3D(containerDictionary[currentTarget]).name);
			
			if(containerDictionary[currentTarget] is DisplayObject3D)
			{
				containerDictionary[currentTarget].dispatchEvent(new InteractiveScene3DEvent(event, containerDictionary[currentTarget], InteractiveSprite(currentTarget)));
				dispatchEvent(new InteractiveScene3DEvent(event, containerDictionary[currentTarget], InteractiveSprite(currentTarget), null, null));
			}else if(containerDictionary[currentTarget] is Face3D)
			{
				var face3d:Face3D = containerDictionary[currentTarget];
				var face3dContainer:InteractiveContainerData = faceDictionary[face3d];
				dispatchEvent(new InteractiveScene3DEvent(event, null, InteractiveSprite(currentTarget), face3d, face3dContainer));
			}
		}
		
		protected function handleResize(e:Event):void
		{
			resizeStage();
		}
	}
}
