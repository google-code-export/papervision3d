/*
 * Copyright 2007 (c) Tim Knip, asdocument.org.
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
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.*;

	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.Papervision3D;
	
	import org.ascollada.core.DaeAnimation;
	import org.ascollada.core.DaeChannel;
	import org.ascollada.core.DaeSampler;
	import org.papervision3d.events.FileLoadEvent;
	
	import org.ascollada.core.DaeController;
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeGeometry;
	import org.ascollada.core.DaeImage;
	import org.ascollada.core.DaeInstanceController;
	import org.ascollada.core.DaeInstanceGeometry;
	import org.ascollada.core.DaeMesh;
	import org.ascollada.core.DaeNode;
	import org.ascollada.core.DaeSkin;
	import org.ascollada.fx.DaeEffect;
	import org.ascollada.fx.DaeInstanceMaterial;
	import org.ascollada.fx.DaeLambert;
	import org.ascollada.fx.DaeMaterial;
	import org.ascollada.io.DaeReader;
	import org.ascollada.types.DaeColorOrTexture;
	import org.ascollada.utils.Logger;
	
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.geom.Vertex3D;
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.core.NumberUV;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.core.proto.GeometryObject3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.materials.MaterialsList;
	import org.papervision3d.objects.Bone3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.SkinnedMesh3D;
	
	/**
	 * 
	 */
	public class DAE extends DisplayObject3D
	{
		/** Default scaling value for constructor. */
		static public var DEFAULT_SCALING  :Number = 10;
	
		/** the collada document */
		public var document:DaeDocument;
		
		/** the collada file */
		public var filename:String;
		
		/** name of file */
		public var fileTitle:String;
		
		/** base folder */
		public var baseUrl:String;
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		public function DAE( filename:String, materials:MaterialsList = null ):void
		{
			this.filename = filename;
			
			// make sure we've got forward slashes!
			this.filename = this.filename.split("\\").join("/");
			
			this.materials = materials || new MaterialsList();
			
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
			
			_scaling = DEFAULT_SCALING;
			
			_reader = new DaeReader();
			_reader.addEventListener( Event.COMPLETE, buildDAE );
			_reader.read( this.filename );
		}
				
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function buildDAE( event:Event ):void 
		{
			if( _reader.hasEventListener(Event.COMPLETE) )
				_reader.removeEventListener( Event.COMPLETE, buildDAE );
			
			this.document = _reader.document;
			
			MaterialObject3D.DEFAULT_COLOR = 0xff0000;
			
			for( var i:int = 0; i < this.document.vscene.nodes.length; i++ )
				buildScene( this.document.vscene.nodes[i], this );
			
			if( this.document.yUp == DaeDocument.Z_UP )
			{
				//this.rotationX = 90;
				//this.rotationZ = 90;
			}

			// let listeners know we got something to show
			dispatchEvent( new Event(Event.COMPLETE) );
			
			// but... there may be animations left to parse...
			_reader.addEventListener( Event.COMPLETE, animationCompleteHandler );
			_reader.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
			
			// check it out!
			_reader.readAnimations();
		}
		
		/**
		 * event handler triggered when a (bitmap-file) material is loaded.
		 * 
		 * @param	event
		 * 
		 * @return
		 */
		private function materialCompleteHandler( event:FileLoadEvent ):void
		{				
			// notify listeners that a material was loaded.
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		/**
		 * event handler triggered when all animations are parsed.
		 * 
		 * @param	event
		 * 
		 * @return
		 */
		private function animationCompleteHandler( event:Event ):void
		{						
			buildAnimations();
			
			dispatchEvent( event.clone() );
		}
		
		/**
		 * 
		 * @param	obj
		 * @param	id
		 * @return
		 */
		private function findAnimationTarget( obj:Object, id:String ):Object
		{
			if( obj.name == id )
				return obj;
				
			if( obj is SkinnedMesh3D )
			{
				obj = obj.skeleton;
				if( obj.name == id )
					return obj;
			}
			
			for( var o:String in obj.children )
			{
				var child:Object = findAnimationTarget( obj.children[o], id );
				if( child )
					return child;
			}
			return null;
		}
		
		/**
		 * event handler triggered when a animation is parsed.
		 * 
		 * @param	event
		 * 
		 * @return
		 */
		private function animationProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent( event.clone() as ProgressEvent );
		}
		
		/**
		 * 
		 * @param	node
		 */
		private function buildAnimations():void
		{			
			for each( var animation:DaeAnimation in this.document.animations )
			{
				for each( var channel:DaeChannel in animation.channels )
				{
					var nodeID:String = channel.target.split("/")[0];
					
					var target:Object = findAnimationTarget( this, nodeID );
					
					if( !target )
					{
						Logger.error( "animation target: " + nodeID + " not found." );
						throw new Error( "animation target: " + nodeID + " not found." );
					}	
					target.channel = channel;
				}
			}
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
			var i:int;
			
			// create vertices
			for( i = 0; i < v.length; i++ )
			{
				if( yUP )
					geom.vertices.push( new Vertex3D(v[i][0] * scaling, v[i][1] * scaling, v[i][2] * scaling) );
				else
					geom.vertices.push( new Vertex3D(v[i][0] * scaling, v[i][1] * scaling, v[i][2] * scaling) );
			}
			
			// create faces 
			for( i = 0; i < f.length; i++ )
			{
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
				
				// reversed winding due to positive flash-y pointing down (?)
				if( this.document.yUp == DaeDocument.Y_UP )
					geom.faces.push( new Face3D( [p2, p1, p0], "wire", [t2, t1, t0] ) ); 
				else
					geom.faces.push( new Face3D( [p0, p1, p2], "wire", [t0, t1, t2] ) );
			}	
			
			Logger.trace( "geom v:" + geom.vertices.length + " f:" + geom.faces.length );
			
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
		 * builds a papervision material from a collada <instance_material> element.
		 * 
		 * @param	instance_material
		 * 
		 * @return
		 */
		private function buildMaterial( instance_material:DaeInstanceMaterial ):MaterialObject3D
		{
			var material:MaterialObject3D = this.materials.getMaterialByName(instance_material.symbol);
			
			if( material ) 
			{
				Logger.trace( "instancing material: " + instance_material.symbol + " from passed in materialsList.");
				return material;
			}
			
			// get material from library
			var dae_material:DaeMaterial = this.document.materials[ instance_material.target ];
			
			if( dae_material )
			{
				//Logger.trace( "buildMaterial : " + instance_material.symbol );
					
				var effect:DaeEffect = this.document.effects[ dae_material.effect ];
				if( effect && effect.texture_url )
				{
					var img:DaeImage = this.document.images[effect.texture_url];
					if( img )
					{
						material = new BitmapFileMaterial( buildImagePath(this.baseUrl, img.init_from) );
						material.addEventListener( FileLoadEvent.LOAD_COMPLETE, materialCompleteHandler );
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
					
					material = new ColorMaterial( col );
					//material.doubleSided = true;
					
					Logger.trace( " setting material:  0x"+ col.toString(16) );
				}
			}	
		
			return material;
		}
		
		/**
		 * builds a papervision Matrix3D from a node's matrices array. @see DaeNode#matrices
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMatrix( node:DaeNode ):Matrix3D
		{
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for( var i:int = 0; i < node.matrices.length; i++ )
			{
				matrix = Matrix3D.multiply( matrix, new Matrix3D(node.matrices[i]) );
			}
			return matrix;
		}
		
		/**
		 * builds a papervision Mesh3D from a DaeMesh. @see DaeMesh
		 * 
		 * @param	geometry
		 * @param	material
		 * 
		 * @return
		 */
		private function buildMesh( geometry:DaeMesh, material:MaterialObject3D = null, name:String = null ):Mesh3D
		{			
			name = name ? name : geometry.id;
			material = material ? material : MaterialObject3D.DEBUG;
			
			var mesh:Mesh3D = new Mesh3D( material, [], [], name );
			
			mesh.materials = new MaterialsList();
			mesh.materials.addMaterial( material, "wire" );
				
			var geo:GeometryObject3D = null;
			
			try
			{
				geo = buildGeometry(geometry, _scaling);
			}
			catch( e:Error )
			{
				Papervision3D.log( "ERROR: " + e.toString() + "\n" + e.getStackTrace() + "\n"+ geometry.id + " " + geometry.name);
			}
			
			if( geo )
			{
				mesh.addGeometry( geo );
				mesh.geometry.ready = true;
			}
			
			return mesh;
		}
		
		/**
		 * builds a papervision Mesh3D from a DaeMesh. @see DaeMesh
		 * 
		 * @param	geometry
		 * @param	material
		 * 
		 * @return
		 */
		private function buildSkinnedMesh( geometry:DaeMesh, material:MaterialObject3D = null, name:String = null ):SkinnedMesh3D
		{			
			name = name ? name : geometry.id;
			material = material ? material : MaterialObject3D.DEBUG;
			
			var mesh:SkinnedMesh3D = new SkinnedMesh3D( material, [], [], name );
			
			mesh.materials = new MaterialsList();
			mesh.materials.addMaterial( material, "wire" );
			
			mesh.addGeometry( buildGeometry(geometry, _scaling) );

			mesh.geometry.ready = true;
			
			return mesh;
		}
		
		/**
		 * 
		 * @param	node
		 * @param	parent
		 * 
		 * @return
		 */
		private function buildScene( node:DaeNode, parent:DisplayObjectContainer3D ):void
		{
			var newNode:DisplayObject3D;
						
			// build node's matrix
			var matrix:Matrix3D = buildMatrix(node);
			
			// node's material
			var material:MaterialObject3D;
			
			if( node.type == DaeNode.TYPE_NODE && node.controllers.length )
			{
				// just handle a single controller
				// TODO: handle more
				var instance_controller:DaeInstanceController = node.controllers[0];
				
				var controller:DaeController = this.document.controllers[ instance_controller.url ];

				// can be of type <skin> or <morph>
				if( controller.skin )
				{
					var geom:DaeGeometry = this.document.geometries[ controller.skin.source ];
					
					// simply try first instance_material of controller, when available
					material = buildMaterial( instance_controller.materials[0] );	
					
					// create a skinned mesh
					var skinnedMesh:SkinnedMesh3D = buildSkinnedMesh( geom.mesh, material, node.id );
					
					// setup the skin's bindmatrix
					skinnedMesh.bindShapeMatrix = new Matrix3D(controller.skin.bind_shape_matrix);
					
					// set skeleton for the mesh
					var skeletonNode:DaeNode = this.document.getDaeNodeById(instance_controller.skeleton);
					
					skinnedMesh.skeleton = buildSkeleton( skeletonNode, controller.skin );
					
					newNode = skinnedMesh;
				}
				else if( controller.morph )
				{
					// TODO: handle <morph>
					throw new Error( "cannot handle morph-controllers!" );
				}
				else
					throw new Error( "invalid controller: require <skin> or <morph>!" ); 
			}
			else if( node.type == DaeNode.TYPE_NODE && node.geometries.length )
			{
				Logger.error( "ok" );
				
				// handle just one geometry per node for now...
				var instance_geometry:DaeInstanceGeometry = node.geometries[0];
				
				// simply use first instance_material
				if( instance_geometry.materials.length )
					material = buildMaterial( instance_geometry.materials[0] );					
				
				// build mesh
				var geometry:DaeGeometry = this.document.geometries[ instance_geometry.url ];
				
				// can be of type <mesh>, <convex_mesh> or <spline>
				if( geometry.mesh )
				{
					newNode = buildMesh( geometry.mesh, material, node.id );
				}
				else if( geometry.convex_mesh )
				{
					throw new Error( "don't know how to handle <convex_mesh>" );
				}
				else if( geometry.spline )
				{
					throw new Error( "don't know how to handle <spline>" );
				}
			}
			else if( node.type == DaeNode.TYPE_NODE )
				newNode = new DisplayObject3D( node.name, new GeometryObject3D() )
	
			if( newNode )
			{
				var instance:DisplayObject3D = parent.addChild(newNode, node.id);
							
				for( var i:int = 0; i < node.nodes.length; i++ )
					buildScene( node.nodes[i], instance );
				
				matrix.n14 *= _scaling;
				matrix.n24 *= _scaling;
				matrix.n34 *= _scaling;
			
				instance.copyTransform( matrix );
				
				if( newNode is SkinnedMesh3D )
					SkinnedMesh3D(newNode).initBindShape();
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function buildSkeleton( node:DaeNode, skin:DaeSkin ):Bone3D
		{
			var bone:Bone3D = new Bone3D(node);
			
			var bindMatrix:Array = skin.findJointBindMatrix(node.id);	
			if( !bindMatrix )
				throw new Error( "could not find the bindmatrix for node: " + node.id );
				
			// bind-matrix for the bone
			bone.bindMatrix = new Matrix3D( bindMatrix );
			
			// init-matrix
			bone.initMatrix = buildMatrix( node );
			
			bone.transformMatrix = Matrix3D.clone(bone.initMatrix);
			
			// vertex-weigths for the bone
			bone.blendVerts = skin.findJointVertexWeights( node.id );
				
			// recurse children
			for( var i:int = 0; i < node.nodes.length; i++ )
				bone.children.push( buildSkeleton(node.nodes[i], skin) );
			
			return bone;
		}
		
		/** */
		private var _reader:DaeReader; 
		
		private var _scaling:Number; 
	}	
}
