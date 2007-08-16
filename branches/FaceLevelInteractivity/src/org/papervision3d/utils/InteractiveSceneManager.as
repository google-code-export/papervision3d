/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org ï¿½ blog.papervision3d.org ï¿½ osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

/**
* ...
* @author John Grden
* @version 0.1
*/

package org.papervision3d.utils 
{
	import com.blitzagency.xray.logger.XrayLog;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	import org.papervision3d.components.as3.utils.CoordinateTools;
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.utils.virtualmouse.VirtualMouse;
	
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
	import org.papervision3d.materials.InteractiveMovieMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import flash.events.Event;

	public class InteractiveSceneManager extends EventDispatcher
	{
		/**
		* The ISM, by default, uses a BlendMode.ERASE to hide the hit area of the drawn face.
		* Setting this to true will show the drawn faces and give you the ability to add whatever type effects/filters you want
		* over your scene and 3D objects.
		* 
		* When set to true, you should set DEFAULT_SPRITE_ALPHA, DEFAULT_FILL_ALPHA and DEFAULT_FILL_COLOR as these will dictate how the faces are drawn over the scene
		*/
		public static var SHOW_DRAWN_FACES							:Boolean = false;
		public static var DEFAULT_SPRITE_ALPHA						:Number = 1;
		public static var DEFAULT_FILL_ALPHA						:Number = 1;
		public static var DEFAULT_FILL_COLOR						:Number = 0xFFFFFF;
		public static var DEFAULT_LINE_COLOR						:Number = -1;
		public static var DEFAULT_LINE_SIZE 						:Number = 1;
		public static var DEFAULT_LINE_ALPHA						:Number = 1;
		
		/**
		* MOUSE_IS_DOWN is a quick static property to check and is maintained by the ISM
		*/
		public static var MOUSE_IS_DOWN								:Boolean = false;
		
		/**
		* When set to true, the hand cursor is shown over objects that have mouse events assigned to it.
		*/
		public var buttonMode										:Boolean = false;
		
		/**
		* This allows objects faces to have their own containers.  When set to true
		* and the DisplayObject3D.faceLevelMode = false, the faces will be drawn in ISM's layer of containers
		*/
		public var faceLevelMode  									:Boolean = false;
		
		/**
		* If the user sets this to true, then we monitor the allowDraw flag via mouse interaction.
		* If set to true, then leave SHOW_DRAWN_FACES set to false to avoid odd drawings over the 3D scene
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
		public var mouse3D											:Mouse3D = new Mouse3D();
		public var virtualMouse										:VirtualMouse = new VirtualMouse();
		
		public function set enableMouse(value:Boolean):void
		{
			Mouse3D.enabled = value;
		}
		public function get enableMouse():Boolean { return Mouse3D.enabled; }
		
		public var debug											:Boolean = false;
		
		/**
		* Boolean flag used internally to turn off ISM drawing when it's not needed in the render loop.  This only applies if mouseInteractionMode is set to true.
		*/
		protected var allowDraw										:Boolean = true;
		
		protected var evaluateClick									:Boolean = false;
		
		protected var log											:XrayLog = new XrayLog();
		
		public function InteractiveSceneManager(p_scene:SceneObject3D):void
		{
			container.addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			scene = p_scene;
			scene.container.parent.addChild(container);
			container.x = scene.container.x;
			container.y = scene.container.y;			
		
			enableMouse = false;
		}
		
		public function setInteractivityDefaults():void 
		{
		   SHOW_DRAWN_FACES = false;
		   DEFAULT_SPRITE_ALPHA = 1;
		   DEFAULT_FILL_ALPHA = 1;

		   BitmapMaterial.AUTO_MIP_MAPPING = false;
		   DisplayObject3D.faceLevelMode = false;

		   buttonMode = true;
		   faceLevelMode = true;
		   mouseInteractionMode = false;
		}

		
		public function addInteractiveObject(container3d:Object):void
		{
			if(faceDictionary[container3d] == null) 
			{
				var icd:InteractiveContainerData = faceDictionary[container3d] = new InteractiveContainerData(container3d);
				
				// for reverse lookup when you have the sprite container
				containerDictionary[icd.container] = container3d;
				
				// add mouse events to be captured and passed along
				var icdContainer:InteractiveSprite = icd.container;
				icdContainer.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
				icdContainer.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
				icdContainer.addEventListener(MouseEvent.CLICK, handleMouseClick);
				icdContainer.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
				icdContainer.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
				icdContainer.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				
				icdContainer.buttonMode = buttonMode;
				if( !SHOW_DRAWN_FACES && !DisplayObject3D.faceLevelMode ) icdContainer.blendMode = BlendMode.ERASE;
				
				// need to let virtualMouse know what to ignore
				virtualMouse.ignore(icdContainer);
				
				// let others know we've added a container
				dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_ADDED, null, icdContainer));
				
				if(debug) log.debug("addDisplayObject id", container3d.id, container3d.name, DEFAULT_SPRITE_ALPHA);
			}
		}
		
		public function drawFace(container3d:DisplayObject3D, face3d:Face3D, x0:Number, x1:Number, x2:Number, y0:Number, y1:Number, y2:Number ):void
		{
			// if we're face level on this DO3D, then we switch to the face3D object
			var container:Object = container3d;
			if(faceLevelMode || DisplayObject3D.faceLevelMode) container = face3d;
			
			// add to the dictionary if not added already
			if(faceDictionary[container] == null) addInteractiveObject(container);

			if( allowDraw && !DisplayObject3D.faceLevelMode )
			{
				var drawingContainer:InteractiveContainerData = faceDictionary[container];
				var iContainer:InteractiveSprite = drawingContainer.container;
				var graphics:Graphics = iContainer.graphics;
				
				iContainer.x0 = x0;
				iContainer.x1 = x1;
				iContainer.x2 = x2;
				iContainer.y0 = y0;
				iContainer.y1 = y1;
				iContainer.y2 = y2;
				
				graphics.beginFill(drawingContainer.color, drawingContainer.fillAlpha);
				if( drawingContainer.lineColor != -1 && SHOW_DRAWN_FACES ) graphics.lineStyle(drawingContainer.lineSize, drawingContainer.lineColor, drawingContainer.lineAlpha);
				graphics.moveTo( x0, y0 );
				graphics.lineTo( x1, y1 );
				graphics.lineTo( x2, y2 );
				graphics.endFill();
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
				var distance:Number = item.face3d == null ? item.screenZ : item.face3d.face3DInstance.screenZ;
				sort.push({container:item.container, distance:distance});
			}
			
			sort.sortOn("distance", Array.DESCENDING | Array.NUMERIC);
			
			for(var i:uint=0;i<sort.length;i++) container.addChild(sort[i].container);
			
			// after the render loop is complete, and we've sorted, we reset the allowDraw flag
			if( mouseInteractionMode ) allowDraw = false;
		}
		
		protected function handleAddedToStage(e:Event):void
		{
			container.stage.addEventListener (Event.RESIZE, handleResize);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, handleReleaseOutside);
			
			virtualMouse.stage = container.stage;
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
			if(virtualMouse) virtualMouse.click();
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_CLICK, Sprite(e.currentTarget));
		}
		
		protected function handleMouseOver(e:MouseEvent):void
		{
			var eventType:String
			eventType = !evaluateClick || !mouseInteractionMode ? InteractiveScene3DEvent.OBJECT_OVER : InteractiveScene3DEvent.OBJECT_CLICK;
			evaluateClick = false;
			
			if( virtualMouse && eventType == InteractiveScene3DEvent.OBJECT_CLICK ) virtualMouse.click()
			dispatchObjectEvent(eventType, Sprite(e.currentTarget));
		}
		
		protected function handleMouseOut(e:MouseEvent):void
		{
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_OUT, Sprite(e.currentTarget));
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{	
			var point:Object;
			if( VirtualMouse && ( faceLevelMode || DisplayObject3D.faceLevelMode ))
			{
				// need the face3d for the coordinate conversion
				var face3d:Face3D = containerDictionary[e.currentTarget];
				
				// get 2D coordinates
				point = InteractiveUtils.getMapCoordAtPoint(face3d, container.mouseX, container.mouseY);
				
				// locate the material's movie
				var mat:InteractiveMovieMaterial = InteractiveMovieMaterial(face3d.face3DInstance.instance.material);
				
				// set the location where the calcs should be performed
				virtualMouse.container = mat.movie;
				
				// update virtual mouse so it can test
				virtualMouse.setLocation(point.x, point.y);
			}
			
			dispatchObjectEvent(InteractiveScene3DEvent.OBJECT_MOVE, Sprite(e.currentTarget));
			
			if( Mouse3D.enabled && ( faceLevelMode || DisplayObject3D.faceLevelMode ) ) 
			{
				mouse3D.updatePosition(Face3D(containerDictionary[e.currentTarget]), e.currentTarget as Sprite);
			}
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
