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
 
package org.ascollada.core
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import org.ascollada.physics.DaePhysicsScene;
	
	import org.ascollada.ASCollada;
	import org.ascollada.fx.DaeEffect;
	import org.ascollada.fx.DaeMaterial;
	import org.ascollada.namespaces.*;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeDocument extends DaeEntity
	{
		public static const X_UP:uint = 0;
		public static const Y_UP:uint = 1;
		public static const Z_UP:uint = 2;
		
		public var COLLADA:XML;
	
		public var version:String;
		
		public var animation_clips:Object;
		public var animations:Object;
		public var controllers:Object;
		public var effects:Object;
		public var images:Object;
		public var materials:Object;
		public var geometries:Object;
		public var physics_scenes:Object;
		public var visual_scenes:Object;
		
		public var vscene:DaeVisualScene;
		public var pscene:DaePhysicsScene;
		
		public var yUp:uint;
		
		/**
		 * 
		 */
		public function DaeDocument( object:Object )
		{
			this.COLLADA = new XML( object );
			
			super( this.COLLADA );
		}
		
		public function get numQueuedAnimations():uint { return _waitingAnimations.length; }
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		private function findDaeNodeById( node:DaeNode, id:String ):DaeNode
		{
			if( node.id == id )
				return node;

			for( var i:int = 0; i < node.nodes.length; i++ )
			{
				var n:DaeNode = findDaeNodeById( node.nodes[i], id );
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		public function getDaeNodeById( id:String ):DaeNode
		{
			for( var i:int = 0; i < this.vscene.nodes.length; i++ )
			{
				var n:DaeNode = findDaeNodeById( this.vscene.nodes[i], id );
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 
		 * @return
		 */
		public function readNextAnimation():Boolean
		{
			if( _waitingAnimations.length )
			{
				var animation:DaeAnimation = _waitingAnimations.shift() as DaeAnimation;
				
				var animLib:XML = getNode(this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_ELEMENT);
				var animNode:XML = getNodeById( animLib, ASCollada.DAE_ANIMATION_ELEMENT, animation.id );
				
				animation.read( animNode );
				
				return true;
			}
			else
				return false;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{
			this.version = node.attribute(ASCollada.DAE_VERSION_ATTRIBUTE).toString();
			
			Logger.trace( "version: " + this.version );
			
			// required!
			this.asset = new DaeAsset( getNode(this.COLLADA, ASCollada.DAE_ASSET_ELEMENT) );
			
			Logger.trace( "author: " + this.asset.contributors[0].author );
			Logger.trace( "created: " + this.asset.created );
			Logger.trace( "modified: " + this.asset.modified );
			Logger.trace( "y-up: " + this.asset.yUp );
			
			// default to Y_UP
			this.yUp = Y_UP;
			
			if( this.asset.yUp == ASCollada.DAE_X_UP )
				this.yUp = X_UP;
			else if( this.asset.yUp == ASCollada.DAE_Y_UP )
				this.yUp = Y_UP;
			else if( this.asset.yUp == ASCollada.DAE_Z_UP )
				this.yUp = Z_UP;
				
			readLibAnimationClips();
			readLibControllers();
			readLibAnimations();
			readLibImages();
			readLibMaterials();
			readLibEffects();
			readLibGeometries();
			readLibPhysicsScenes();
			readLibVisualScenes();
			
			readScene();
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibAnimations():void
		{
			_waitingAnimations = new Array();
			this.animations = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_ANIMATION_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeAnimation = new DaeAnimation();
					ent.id = item.attribute(ASCollada.DAE_ID_ATTRIBUTE).toString();
					this.animations[ ent.id ] = ent;
//					Logger.trace( "reading animation: " + ent.id );
					_waitingAnimations.push( ent );
				}
			}
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibAnimationClips():void
		{
			this.animation_clips = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_CLIP_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_ANIMCLIP_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeAnimationClip = new DaeAnimationClip( item );
					this.animation_clips[ ent.id ] = ent;
				}
			}
		}
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibControllers():void
		{
			this.controllers = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_CONTROLLER_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_CONTROLLER_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeController = new DaeController( item );
					this.controllers[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibEffects():void
		{
			this.effects = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_EFFECT_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_EFFECT_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeEffect = new DaeEffect( item );
					this.effects[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibGeometries():void
		{
			this.geometries = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_GEOMETRY_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_GEOMETRY_ELEMENT );
				for each( var item:XML in list )
				{
					var geometry:DaeGeometry = new DaeGeometry( item );
					this.geometries[ geometry.id ] = geometry;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibImages():void
		{
			this.images = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_IMAGE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_IMAGE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeImage = new DaeImage( item );
					this.images[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibMaterials():void
		{
			this.materials = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_MATERIAL_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_MATERIAL_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeMaterial = new DaeMaterial( item );
					this.materials[ ent.id ] = ent;
				}
			}
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibPhysicsScenes():void
		{
			this.physics_scenes = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_PSCENE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_PHYSICS_SCENE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaePhysicsScene = new DaePhysicsScene( item );
					this.physics_scenes[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibVisualScenes():void
		{
			this.visual_scenes = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_VSCENE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_VSCENE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeVisualScene = new DaeVisualScene( item, yUp );
					this.visual_scenes[ ent.id ] = ent;
					this.vscene = ent;
				}
			}
		}
		
		/**
		 * 
		 * @return
		 */
		private function readScene():void
		{
			// try to find a valid scene...
			var sceneNode:XML = getNode( this.COLLADA, ASCollada.DAE_SCENE_ELEMENT );
			if( sceneNode )
			{
				var vsceneNode:XML = getNode( sceneNode, ASCollada.DAE_INSTANCE_VSCENE_ELEMENT );
				if( vsceneNode )
				{
					var vurl:String = getAttribute( vsceneNode, ASCollada.DAE_URL_ATTRIBUTE );
					if( this.visual_scenes[vurl] is DaeVisualScene )
					{
						Logger.trace( "found visual scene: " + vurl );
						
						this.vscene = this.visual_scenes[ vurl ];
						
						Logger.trace( " -> frameRate: " + this.vscene.frameRate );
						Logger.trace( " -> startTime: " + this.vscene.startTime );
						Logger.trace( " -> endTime: " + this.vscene.endTime );
					}
				}
				
				var psceneNode:XML = getNode( sceneNode, ASCollada.DAE_INSTANCE_PHYSICS_SCENE_ELEMENT );
				if( psceneNode )
				{
					var purl:String = getAttribute( psceneNode, ASCollada.DAE_URL_ATTRIBUTE );
					if( this.physics_scenes[purl] is DaePhysicsScene )
					{
						Logger.trace( "found physics scene: " + purl );
						this.pscene = this.physics_scenes[ purl ];
					}
				}
			}
		}
		
		private var _waitingAnimations:Array;
	}	
}
