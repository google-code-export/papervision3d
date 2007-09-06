/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
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
 
package  
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.*;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import org.papervision3d.materials.BitmapAssetMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MaterialsList;
	import org.papervision3d.materials.ShadedColorMaterial;
	import org.papervision3d.Papervision3D;
	
	import org.ascollada.utils.*;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.scenes.*;
	
	/**
	 * 
	 */
	public class Main extends Sprite
	{
		public static const FILE_PREFIX:String = "../../../";

		/** sprite to render to */
		public var container:Sprite;
		
		/** pv3d scene */
		public var scene:Scene3D;
		
		/** pv3d camera */
		public var camera:Camera3D;
		
		/** collada example */
		public var dae:DAE;
	
		public var obj:DisplayObject3D;
		
		/** some test-files */
		public var testFiles:Array = [
			FILE_PREFIX + "meshes/focus.dae",
			FILE_PREFIX + "meshes/hound-hi.dae",
			FILE_PREFIX + "meshes/dino5.dae",
			FILE_PREFIX + "meshes/box-rotation-y.dae",
			FILE_PREFIX + "meshes/soldado.dae",
			FILE_PREFIX + "meshes/Express_Laugh.dae",
			FILE_PREFIX + "meshes/rocket_dance.dae"
			];
		
		/**
		 * 
		 * @return
		 */
		public function Main():void
		{
			init();
		}
		
		/**
		 * 
		 * @return
		 */
		private function init():void
		{
			this.stage.quality = StageQuality.LOW;
			
			//Papervision3D.VERBOSE = false;
			
			MaterialObject3D.DEFAULT_COLOR = 0xcccccc;
	
			_fps = new FPS();
			addChild(_fps);
			
			this.container = new Sprite();
			addChild(this.container);
			this.container.x = 400;
			this.container.y = 300;
			
			_lastMouse = new Point();
			
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
			
			loadTestFile(1);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function init3D( event:Event = null ):void
		{
			_loading = false;
			
			if( this.dae.hasEventListener(ProgressEvent.PROGRESS) )
				this.dae.removeEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			this.dae.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
			
			_fps.anim = "";
			
			this.scene = new Scene3D(this.container);
			
			var zoom:Number = 100;
			
			switch( _curFile )
			{
				case 0:
					zoom = 400;
					break;
				case 1:
					zoom = 2000;
					this.dae.rotationY = -60; 
					this.dae.rotationX = -90; 
					break;
				case 2:
					zoom = 10;
					this.dae.rotationX = -90; 
					this.dae.rotationZ = 60; 
					break;
				case 3:
					zoom = 2000;
					this.dae.y -= 0.4;
					this.dae.rotationY = 290;
					break;
				case 4:
					zoom = 50;
					break;
				default:
					zoom = 15;
					break;
			}
			
			this.camera = new Camera3D(null, zoom);
			
			this.scene.addChild(this.dae);
			
			this.camera.lookAt(this.dae);
			
			//this.dae.rotationY = 170;
			
			addEventListener(Event.ENTER_FRAME, loop3D);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loop3D( event:Event = null ):void
		{
			//this.dae.rotationY++;
			this.scene.renderCamera(this.camera);
			
			if( !_loading )
			{
				var filetitle:String = testFiles[_curFile].split("/").pop() as String;
				
				_fps.anim = "\nplayer: " + Capabilities.version;
				_fps.anim += "\nrendered: " + this.scene.stats.rendered;
				_fps.anim += "\n\nKEYS:\n[1..6] for some other test-files.";
				_fps.anim += "\n'A' : toggle animation [" + (_animate?"ON/off":"on/OFF") + "]";
				_fps.anim += "\n\ncurrent file: " + filetitle.toUpperCase();
			}
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		private function loadTestFile( id:uint = 0 ):void
		{
			_loading = true;
			_curFile = id < testFiles.length ? id : 0;
						
			var asset:* = this.testFiles[_curFile];
			
			this.dae = new DAE(asset);
			this.dae.addEventListener( Event.COMPLETE, init3D );
			this.dae.addEventListener( ProgressEvent.PROGRESS, loadProgressHandler );
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function animationProgressHandler( event:ProgressEvent ):void 
		{
			if( event.bytesLoaded == event.bytesTotal )
			{
				_loading = false;
				_fps.anim = "";
			}
			else
			{
				_loading = true;
				_fps.anim = "\nloading animation #" + event.bytesLoaded + " of " + event.bytesTotal;
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function keyUpHandler( event:KeyboardEvent ):void 
		{
			switch( event.keyCode )
			{
				case "1".charCodeAt():
					loadTestFile(0);
					break;
				
				case "2".charCodeAt():
					loadTestFile(1);
					break;
					
				case "3".charCodeAt():
					loadTestFile(2);
					break;
					
				case "4".charCodeAt():
					loadTestFile(3);
					break;
					
				case "5".charCodeAt():
					loadTestFile(4);
					break;
				
				case "6".charCodeAt():
					loadTestFile(5);
					break;
					
				case "7".charCodeAt():
					loadTestFile(6);
					break;
				
				case "8".charCodeAt():
					loadTestFile(7);
					break;
					
				case "9".charCodeAt():
					loadTestFile(8);
					break;
					
				case "0".charCodeAt():
					loadTestFile(9);
					break;
					
				case "A".charCodeAt():
					_animate = !_animate;
					setAnimate( this.dae, _animate );
					break;
					
				default:
					break;
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function loadProgressHandler( event:ProgressEvent ):void 
		{
			var perc:Number = (event.bytesLoaded/event.bytesTotal) * 100;
			var megs:Number = event.bytesTotal / 1000 / 1000;
			
			_fps.anim = "\nloading: " + this.dae.fileTitle + " " + perc.toFixed(2) + "% done.";
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function mouseDownHandler( event:MouseEvent ):void
		{
			_lastMouse.x = event.stageX;
			_lastMouse.y = event.stageY;
			_orbiting = true;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function mouseUpHandler( event:MouseEvent ):void
		{
			_orbiting = false;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function mouseMoveHandler( event:MouseEvent ):void
		{
			var dx:Number = event.stageX - _lastMouse.x;
			var dy:Number = event.stageY - _lastMouse.y;
			
			if( _orbiting && dae )
			{
				dae.rotationY += dx;
				
				_lastMouse.x = event.stageX;
				_lastMouse.y = event.stageY;
			}
		}
		
		/**
		 * 
		 * @param	obj
		 * @param	bAnimate
		 * @return
		 */
		private function setAnimate( obj:DisplayObject3D, bAnimate:Boolean ):void
		{
			if( obj is Node3D )
				Node3D(obj).animate = bAnimate;
			for each(var child:DisplayObject3D in obj.children )
				setAnimate(child, bAnimate);
		}
		
		private var _curFile:uint = 0;
		
		private var _status:TextField;
		
		private var _fps:FPS;
		
		private var _loading:Boolean = false;
		
		private var _animate:Boolean = true;
		
		private var _orbiting:Boolean = false;
		
		private var _lastMouse:Point;
	}
}
