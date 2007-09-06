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
 
package org.papervision3d.objects 
{
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.ascollada.io.DaeReader;
	import org.ascollada.types.DaeColorOrTexture;
	import org.ascollada.utils.Logger;
	import org.papervision3d.animation.core.AnimationChannel;
	import org.papervision3d.animation.core.AnimationController;
	import org.papervision3d.animation.core.AnimationCurve;
	import org.papervision3d.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 */
	public class DAE extends DisplayObject3D
	{
		/** the filename */
		public var filename:String;
		
		/** */
		public var fileTitle:String;
		
		/** */
		public var baseUrl:String;
		
		/**
		 * 
		 * @param	filename
		 * @param	materials
		 * @return
		 */
		public function DAE(asset:*, materials:MaterialsList = null):void
		{
			_reader = new DaeReader();
			
			this.materials = materials || new MaterialsList();
			
			this.filename = asset is String ? String(asset) : "../../../meshes/rawdata_dae";
			
			// make sure we've got forward slashes!
			this.filename = this.filename.split("\\").join("/");
				
			if( this.filename.indexOf("/") != -1 )
			{
				// dae is located in a sub-directory of the swf.
				var parts:Array = this.filename.split("/");
				this.fileTitle = String( parts.pop() );
				this.baseUrl = parts.join("/");
			}
			else
			{
				// dae is located in root directory of swf.
				this.fileTitle = this.filename;
				this.baseUrl = "";
			}
				
			super( fileTitle, new GeometryObject3D() );
				
			_scaling = 1;
			
			if( asset is ByteArray )
			{
				_reader.addEventListener( Event.COMPLETE, buildDAE );
				_reader.addEventListener( ProgressEvent.PROGRESS, loadProgressHandler );
				
				_asset = asset;
				
				var timer:Timer = new Timer(500);
				timer.addEventListener(TimerEvent.TIMER, delayedLoadHandler);
				timer.start();
			}
			else if( asset is XML )
			{
				
			}
			else if( asset is String )
			{		
				_reader.addEventListener( Event.COMPLETE, buildDAE );
				_reader.addEventListener( ProgressEvent.PROGRESS, loadProgressHandler );
				_reader.read( this.filename );
			}
		}
		
		/**
		 * 
		 * @param	name
		 * @return
		 */
		override public function getChildByName(name:String):DisplayObject3D
		{
			return this.findChildByName(this, name);
		}
		
		/**
		 * 
		 * @param	parent
		 * @param	camera
		 * @param	sorted
		 * @return
		 */
		override public function project( parent:DisplayObject3D, camera:CameraObject3D, sorted :Array=null ):Number
		{
			Node3D.dt = (getTimer() - _dt) * 0.001;
			
			return super.project(parent, camera, sorted);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function buildDAE( event:Event ):void
		{
			if(_reader.hasEventListener(Event.COMPLETE))
				_reader.removeEventListener( Event.COMPLETE, buildDAE );
				
			_document = _reader.document;
			_queuedBitmaps = new Object();
			_skins = new Dictionary();
			
			var i:int;
			
			var root:DisplayObject3D = addChild(new DisplayObject3D());
			
			for( i = 0; i < _document.vscene.nodes.length; i++ )
			{
				var node:DaeNode = _document.vscene.nodes[i];
				//if( node.type == DaeNode.TYPE_NODE )
					var obj:DisplayObject3D = buildScene( node, root );
			}
			
			_dt = getTimer();
			
			linkSkeletons(this);
			
			// should have something to show now...
			dispatchEvent(new Event(Event.COMPLETE));
					
			// but... there may be animations left to parse...
			_reader.addEventListener( Event.COMPLETE, animationCompleteHandler );
			_reader.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
			
			_reader.readAnimations();
			
			
		}
				
		/**
		 * 
		 * @param	node
		 * @param	instance
		 * @return
		 */
		private function buildControllers( node:DaeNode, instance:DisplayObject3D ):void
		{
		}
		
		/**
		 * builds the papervision geometry for a collada <mesh>.
		 * 
		 * @param	geometry
		 * @param	scaling
		 * @param	yUP
		 * 
		 * @return
		 */
		private function buildGeometry( geometry:DaeMesh, scaling:Number = 1.0, yUP:Boolean = true ):GeometryObject3D
		{
			var geom:GeometryObject3D = new GeometryObject3D();
			
			geom.vertices = new Array();
			geom.faces = new Array();
			
			var v:Array = geometry.vertices;
			var f:Array = geometry.faces;
			var t:Array = geometry.texcoords;
			var n:Array = geometry.normals;
			var m:Array = geometry.materials;
			var i:int;
			
			// create vertices
			for( i = 0; i < v.length; i++ )
				geom.vertices.push( new Vertex3D(v[i][0] * scaling, v[i][1] * scaling, v[i][2] * scaling) );
			
			// create faces 
			for( i = 0; i < f.length; i++ ) {
				
				var material:MaterialObject3D = this.materials.getMaterialByName(m[i]);
				
				// get triangle's vertex indices
				var tri:Array = f[i];
				
				// get vertex refs
				var p0:Vertex3D = geom.vertices[ tri[0] ];
				var p1:Vertex3D = geom.vertices[ tri[1] ];
				var p2:Vertex3D = geom.vertices[ tri[2] ];
								
				// create uvs
				var t0:NumberUV = new NumberUV( t[i][0][0], t[i][0][1] );
				var t1:NumberUV = new NumberUV( t[i][1][0], t[i][1][1] );
				var t2:NumberUV = new NumberUV( t[i][2][0], t[i][2][1] );
				
				geom.faces.push( new Face3D( [p2, p1, p0], material, [t2, t1, t0] ) ); 
			}	

			return geom;
		}
		
		/**
		 *
		 * @return
		 */
		private function buildImagePath( meshFolderPath:String, imgPath:String ):String
		{
			var baseParts:Array = meshFolderPath.split("/");
			var imgParts:Array = imgPath.split("/");
			
			while( baseParts[0] == "." )
				baseParts.shift();
				
			while( imgParts[0] == "." )
				imgParts.shift();
				
			while( imgParts[0] == ".." )
			{
				imgParts.shift();
				baseParts.pop();
			}
						
			var imgUrl:String = baseParts.length > 1 ? baseParts.join("/") : (baseParts.length?baseParts[0]:"");
						
			imgUrl = imgUrl != "" ? imgUrl + "/" + imgParts.join("/") : imgParts.join("/");
			
			return imgUrl;
		}
		
		/**
		 * 
		 * @param	obj
		 * @return
		 */
		private function buildJoints( obj:DisplayObject3D ):void
		{
		}
		
		private function buildMaterial( instance_material:DaeInstanceMaterial ):MaterialObject3D
		{
			var material:MaterialObject3D = this.materials.getMaterialByName(instance_material.symbol);
			
			// already in library
			if( material )
				return material;
			
			// get material from library
			var dae_material:DaeMaterial = _document.materials[ instance_material.target ];
			
			if( dae_material )
			{	
				var effect:DaeEffect = _document.effects[ dae_material.effect ];
				if( effect && effect.texture_url )
				{
					var img:DaeImage = _document.images[effect.texture_url];
					if( img )
					{
						var path:String = buildImagePath(this.baseUrl, img.init_from);
						
						material = new BitmapFileMaterial( path );
						material.addEventListener( FileLoadEvent.LOAD_COMPLETE, materialCompleteHandler );
						material.addEventListener( FileLoadEvent.LOAD_ERROR, materialErrorHandler );
						
						_queuedBitmaps[path] = instance_material.symbol;
					}
				}
				else if( effect.color is DaeLambert )
				{
					var lambert:DaeLambert = effect.color as DaeLambert;
					var c:DaeColorOrTexture = lambert.diffuse;
					
					var r:uint = Math.round(c.color[0] * 255);
					var g:uint = Math.round(c.color[1] * 255);
					var b:uint = Math.round(c.color[2] * 255);
					
					var col:uint = (r<<16 | g<<8 | b);
					
					material = new ShadedColorMaterial( col );
				}
			}
			
			materials.addMaterial( material, instance_material.symbol ); // C4

			return material;
		}
		
		/**
		 * builds a papervision Matrix3D from a node's matrices array. @see DaeNode#matrices
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMatrix( node:DaeNode ):Matrix3D {
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for( var i:int = 0; i < node.matrices.length; i++ ) {
				matrix = Matrix3D.multiply( matrix, new Matrix3D(node.matrices[i]) );
			}
			return matrix;
		}
		
		/**
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMesh( node:DaeNode ):DisplayObject3D
		{
			var newNode:DisplayObject3D = new Node3D(node.id, node.sid);
			
			for( var i:int = 0; i < node.geometries.length; i++ )
			{
				var geom_instance:DaeInstanceGeometry = node.geometries[i];
				
				var geom:DaeGeometry = _document.geometries[geom_instance.url];
				
				for each( var m:DaeInstanceMaterial in geom_instance.materials )
					buildMaterial( m );
				
				var mesh:Mesh3D = new Mesh3D(new WireframeMaterial(), new Array(), new Array());
				mesh.materials = this.materials;
				mesh.geometry = buildGeometry(geom.mesh);
				mesh.geometry.ready = true;
				
				newNode.addChild(mesh);
			}
			
			return newNode;
		}
		
		/**
		 * 
		 * @param	node
		 * @param	parent
		 * 
		 * @return
		 */
		private function buildScene( node:DaeNode, parent:DisplayObjectContainer3D ):DisplayObject3D
		{	
			var newNode:DisplayObject3D;
			var skinController:DaeInstanceController = findSkinController(node);
			
			if( skinController )
			{
				newNode = buildSkin(node, skinController);
			}
			else if( node.geometries.length )
			{
				newNode = buildMesh(node);
			}
			else
			{
				newNode = new Node3D(node.id, node.sid);
			}
			
			// node instances!
			for( var j:int = 0; j < node.instance_nodes.length; j++ )
			{
				var instance_node:DaeInstanceNode = node.instance_nodes[j];
				var iNode:DaeNode = _document.getDaeNodeById(instance_node.url);
				
				var iObj:DisplayObject3D = getChildByName(iNode.id);
				
				if( iObj )
					newNode.addChild(iObj);
				else if(iNode)
					buildScene(iNode, newNode);
			}
			
			var instance:DisplayObject3D = parent.addChild(newNode);
			
			for( var i:int = 0; i < node.nodes.length; i++ )
				buildScene(node.nodes[i], instance);
				
			instance.copyTransform( buildMatrix(node) );

			return instance;
		}
				
		/**
		 * 
		 * @param	node
		 * @param	controller
		 * @return
		 */
		private function buildSkin( node:DaeNode, controller:DaeInstanceController ):DisplayObject3D
		{
			var skinCtrl:DaeController = _document.controllers[controller.url];
			
			if( !skinCtrl || !skinCtrl.skin )
				return new DisplayObject3D(node.id);
				
			var skin:DaeSkin = skinCtrl.skin;
			var skinnedMesh:Skin3D = new Skin3D(new WireframeMaterial(), new Array(), new Array(), node.id);
			
			var geom:DaeGeometry = _document.geometries[ skin.source ];
				
			if( !geom )
			{
				if( _document.controllers[skin.source] )
				{
					var morhpCtrl:DaeController = _document.controllers[skin.source];
					if( morhpCtrl.morph )
						geom = _document.geometries[ morhpCtrl.morph.source ];
				}				
				if( !geom )
					throw new Error("Can't find geometry: " + skin.source );
			}
			
			for each( var m:DaeInstanceMaterial in controller.materials )
				buildMaterial( m );
						
			skinnedMesh.materials = this.materials;

			skinnedMesh.geometry = buildGeometry(geom.mesh);
			skinnedMesh.geometry.ready = true;
			
			skinnedMesh.bindPose = new Matrix3D(skin.bind_shape_matrix);
			
			_skins[ skinnedMesh ] = skin;
			
			skinnedMesh.transformVertices(skinnedMesh.bindPose);
			
			return skinnedMesh;
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		private function findAnimationChannelsByID( id:String ):Array
		{
			var channels:Array = new Array();
		
			for each( var animation:DaeAnimation in _document.animations )
			{
				for each( var channel:DaeChannel in animation.channels )
				{
					var target:String = channel.target.split("/").shift() as String;
					if( target == id )
						channels.push(channel);
				}
			}
			return channels;
		}
		
		/**
		 * 
		 * @param	node
		 * @param	name
		 * @return
		 */
		private function findChildByName(node:DisplayObject3D, name:String):DisplayObject3D
		{
			if( node.name == name )
				return node;
				
			for each(var child:DisplayObject3D in node.children ) 
			{
				var n:DisplayObject3D = findChildByName(child, name);
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	node
		 * @param	name
		 * @return
		 */
		private function findChildBySID(node:DisplayObject3D, sid:String):DisplayObject3D
		{
			if( node is Node3D && Node3D(node).sid == sid )
				return node;
				
			for each(var child:DisplayObject3D in node.children ) 
			{
				var n:DisplayObject3D = findChildBySID(child, sid);
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function findSkinController( node:DaeNode ):DaeInstanceController
		{
			for each( var controller:DaeInstanceController in node.controllers )
			{
				var control:DaeController = _document.controllers[controller.url];
				if( control.skin )
					return controller;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function linkAnimations( node:DisplayObject3D ):void
		{
			if( node is Node3D )
			{
				var joint:Node3D = node as Node3D;

				var channels:Array = findAnimationChannelsByID(node.name);
				
				if( channels && channels.length )
				{
					var controller:AnimationController = new AnimationController();
					
					for each( var channel:DaeChannel in channels )
					{
						var keys:Array = channel.input;
						var values:Array = channel.output;
						var interpolations:Array = channel.interpolations;
						
						var targetObject:String = channel.target.split("/")[1];
						
						Logger.trace( node.name + " => " + targetObject );
						
						if( keys.length && keys.length == values.length )
						{
							var c:AnimationChannel = new AnimationChannel();
							
							switch( targetObject )
							{
								case "transform":
									c.addMatrixCurves( node.transform, keys, values, interpolations );
									controller.addChannel( c );
									break;
								default:
									break;
							}
						}
					}
					
					joint.controllers.push( controller );
				}
			}
			for each( var child:DisplayObject3D in node.children )
				linkAnimations( child );
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function linkSkeletons( node:DisplayObject3D ):void
		{
			if( node is Skin3D )
			{
				var skinned:Skin3D = node as Skin3D;
				
				skinned.joints = new Array();
				
				var skin:DaeSkin = _skins[ skinned ];
				
				if( skin )
				{
					for( var i:int = 0; i < skin.joints.length; i++ )
					{
						var jid:String = skin.joints[i];
						var joint:DisplayObject3D = findChildByName(this, jid);
						if( !joint )
							joint = findChildBySID(this, jid);
							
						var bind:Array = skin.findJointBindMatrix2(jid);
						
						Node3D(joint).bindMatrix = new Matrix3D(bind);
						Node3D(joint).blendVerts = skin.findJointVertexWeightsByIDOrSID(jid);

						skinned.joints.push(joint);
					}
				}
			}
			
			for each( var child:DisplayObject3D in node.children )
				linkSkeletons( child );
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function animationCompleteHandler( event:Event ):void
		{
			linkAnimations(this);
			_dt = getTimer();
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function animationProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function delayedLoadHandler( event:TimerEvent ):void
		{
			loadProgressHandler(new ProgressEvent(ProgressEvent.PROGRESS,false,false,1,1));
			
			var timer:Timer = Timer(event.target);
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, delayedLoadHandler);
			
			_reader.loadDocument(_asset);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function materialCompleteHandler( event:Event ):void
		{
			
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function materialErrorHandler( event:FileLoadEvent ):void
		{
			var materialName:String = _queuedBitmaps[ event.file ];
			
			resetMaterial( this, materialName );
			
			Logger.trace( "[ERROR] material failed to load! " + materialName + " " + event.file );
		}
		
		/**
		 * 
		 * @param	node
		 * @param	materialName
		 * @param	newMaterial
		 * @return
		 */
		private function resetMaterial( node:DisplayObject3D, materialName:String, newMaterial:MaterialObject3D = null ):void
		{
			newMaterial = newMaterial || new ShadedColorMaterial(0xff0000);
			
			node.materials = node.materials || new MaterialsList();
			
			var mat:MaterialObject3D = node.materials.getMaterialByName(materialName);
			if( mat )
				node.materials.removeMaterialByName(materialName);
			
			node.materials.addMaterial(newMaterial, materialName);
			
			if( node.geometry )
			{
				for each( var face:Face3D in node.geometry.faces )
					face.material = newMaterial;
			}
			
			for each(var child:DisplayObject3D in node.children )
				resetMaterial( child, materialName, newMaterial );
		}
		
		/**
		 * 
		 * @param	node
		 * @param	indent
		 * @return
		 */
		private function dumpHierarchy(node:DisplayObject3D = null, indent:String = ""):String
		{
			node = node || this;
			var s:String = indent + node.name + "\n";
			for each(var child:DisplayObject3D in node.children )
				s += dumpHierarchy(child, indent + " -> ");			
			return s;
		}
		
		/**
		 * 
		 * @return
		 */
		public override function toString():String
		{
			return dumpHierarchy();
		}
				
		private var _document:DaeDocument;
		
		private var _reader:DaeReader;
		
		private var _scaling:Number = 1;
		
		private var _queuedBitmaps:Object;
				
		private var _asset:*;
		
		// keep track of skins
		private var _skins:Dictionary;
		
		private var _dt:Number = getTimer();
	}
}
