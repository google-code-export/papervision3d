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
 
package org.papervision3d.objects.parsers
{
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import org.papervision3d.Papervision3D;
	
	import org.ascollada.ASCollada;
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.ascollada.io.DaeReader;
	import org.ascollada.types.*;
	import org.ascollada.utils.Logger;
	import org.papervision3d.core.*;
	import org.papervision3d.core.animation.controllers.*;
	import org.papervision3d.core.animation.core.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.shadematerials.*;
	import org.papervision3d.materials.special.*;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;


	import org.papervision3d.objects.parsers.ascollada.Node3D;
	import org.papervision3d.objects.parsers.ascollada.Skin3D;
	import org.papervision3d.materials.special.LineMaterial;

	import org.papervision3d.objects.parsers.ascollada.*;
	import org.papervision3d.lights.PointLight3D;


	/**
	 * @author Tim Knip
	 */
	public class DAE extends DisplayObject3D
	{		
		/** */
		public var filename:String;
		
		/** */
		public var fileTitle:String;
		
		/** */
		public var baseUrl:String;
		
		/** */
		public var rootNode:DisplayObject3D;
		
		/** */
		public var document:DaeDocument;
		
		/** */
		public var hasAnimations:Boolean = false;
		
		/**
		 * 
		 * @param	asset
		 * @param	async
		 * @return
		 */
		public function DAE( async:Boolean = false ):void
		{
			_reader = new DaeReader(async);
		}
		
		public function load(asset:*, materials:MaterialsList = null ):void
		{
			this.materials = materials || new MaterialsList();
			this.buildFileInfo(asset);
			_asset = asset;
			
			if( _asset is ByteArray || _asset is XML )
			{
				if( !this._reader.hasEventListener(Event.COMPLETE) )
					this._reader.addEventListener(Event.COMPLETE, buildScene);
					
				this._reader.loadDocument(_asset);
			}
			else
			{
				doLoad( String(_asset) );
			}
		}
		
		/**
		 * 
		 * @param	url
		 * @return
		 */
		protected function doLoad( url:String ):void
		{
			this.filename = url;
			
			_reader.addEventListener( Event.COMPLETE, buildScene );
			_reader.addEventListener( ProgressEvent.PROGRESS, loadProgressHandler );
			_reader.addEventListener( IOErrorEvent.IO_ERROR, handleIOError,false, 0, true );
			_reader.read(filename);
		}
		
		/**
		 * Gets a child by name recursively.
		 * 
		 * @param	name
		 * @return
		 */
		override public function getChildByName( name:String ):DisplayObject3D
		{
			return findChildByName(this, name);
		}
		
		/**
		 * Bakes all transforms of a joint into single matrices.
		 * 
		 * @param	joint
		 * @param	channels
		 * @return
		 */
		private function bakeJointMatrices( joint:Node3D, keys:Array, channels:Array ):Array
		{
			var matrices:Array = new Array();
						
			for( var i:int = 0; i < keys.length; i++ )
			{
				var matrix:Matrix3D = Matrix3D.IDENTITY;
				
				for( var j:int = 0; j < joint.transforms.length; j++ )
				{
					var transform:DaeTransform = joint.transforms[j];
					
					// check for a key at this time
					var m:Matrix3D = findChannelMatrix(channels, transform.sid, keys[i]);
					
					if( m )
						matrix = Matrix3D.multiply(matrix, m);
					else
						matrix = Matrix3D.multiply(matrix, new Matrix3D(transform.matrix));
				}
							
				matrices.push(matrix);
			}

			return matrices;
		}
		
		/**
		 * 
		 * @param	joint
		 * @return
		 */
		private function buildAnimations( node:DisplayObject3D ):void
		{				
			var joint:Node3D = node as Node3D;
			
			var channels:Array = null;
			if( joint )
			{
				channels = findAnimationChannelsByID(joint.daeSID);
				if( !channels.length )
					channels = findAnimationChannelsByID(joint.daeID);
			}

			if( channels && channels.length )
			{
				var keys:Array = buildAnimationKeys(channels);
				var baked:Boolean = false;
				
				for( var i:int = 0; i < channels.length; i++ )
				{
					var channel:DaeChannel = channels[i];
					
					// fetch the transform this channel is targeting
					var transform:DaeTransform = findTransformBySID(joint, channel.syntax.targetSID);
				
					if( !transform )
						throw new Error( "no transform targeted by channel : " + channel.syntax.targetSID );
					
					// build animation matrices (Array) from channel outputs
					var matrices:Array = transform.buildAnimatedMatrices(channel);
						
					// #keys and #matrices *should* be equal
					if( matrices.length != channel.input.length )
						continue;
						//throw new Error( "matrices.length != channel.input.length" );

					channel.output = matrices;		
					
					if( channels.length == 1 && transform.type == ASCollada.DAE_MATRIX_ELEMENT )
					{
						// dealing with a matrix node, no need to bake!
						try
						{
							buildAnimationController(joint, keys, matrices);
						}
						catch( e:Error )
						{
							Logger.error( "[ERROR] " + joint.name + "\n" + channel.syntax  );
						}
						baked = true;
						break;
					}
				}
				
				if( !baked )
				{
					// need to bake matrices
					var ms:Array = bakeJointMatrices(joint, keys, channels);
					
					joint.copyTransform(ms[0]);
					
					buildAnimationController(joint, keys, ms);
				}
			}
			
			for each( var child:DisplayObject3D in node.children )
				buildAnimations( child );
		}
		
		/**
		 * 
		 * @param	joint
		 * @param	keys
		 * @param	matrices
		 * @return
		 */
		private function buildAnimationController( joint:Node3D, keys:Array, matrices:Array ):void
		{
			var mats:Array = new Array(matrices.length);
			
			var ctl:SimpleController = new SimpleController(joint, SimpleController.TRANSFORM);
			
			for(var i:int = 0; i < matrices.length; i++)
			{
				var j:int = (i+1) % matrices.length;
				
				mats[i] = matrices[i] is Matrix3D ? matrices[i] : new Matrix3D(matrices[i]);
				
				var keyframe0:int = AnimationEngine.secondsToFrame(keys[i]);
				var keyframe1:int = AnimationEngine.secondsToFrame(keys[j]);
				var duration:uint = j > 0 ? keyframe1 - keyframe0 : 10;
				
				var frame:AnimationFrame = new AnimationFrame(keyframe0, duration, [mats[i]]);
				
				ctl.addFrame(frame);
			}
			
			joint.addController(ctl);
		}
		
		/**
		 * 
		 * @param	channels
		 * @return
		 */
		private function buildAnimationKeys( channels:Array ):Array
		{
			var keys:Array = new Array();
			var tmp:Array = new Array();
			var obj:Object = new Object();
			var i:int, j:int;
			
			for( i = 0; i < channels.length; i++ )
			{
				var channel:DaeChannel = channels[i];
				for( j = 0; j < channel.input.length; j++ )
				{
					if( !(obj[ channel.input[j] ]) )
					{
						obj[ channel.input[j] ] = true;
						tmp.push( {time:channel.input[j]} );
					}
				}
			}
			
			tmp.sortOn("time", Array.NUMERIC);
			
			for( i = 0; i < tmp.length; i++ )
				keys.push( tmp[i].time );
				
			return keys;
		}
		
		/**
		 * 
		 * @return
		 */
		private function buildColor( daeColor:Array ):uint
		{
			var r:uint = daeColor[0] * 0xff;
			var g:uint = daeColor[1] * 0xff;
			var b:uint = daeColor[2] * 0xff;
			return (r<<16|g<<8|b);
		}
		
		/**
		 * 
		 * @param	primitive
		 * @param	geometry
		 * @param	instance
		 * @param	material
		 * 
		 * @return
		 */
		private function buildFaces( primitive:DaePrimitive, geometry:GeometryObject3D, instance:DisplayObject3D, material:MaterialObject3D = null ):void
		{
			var i:int, j:int, k:int;
			
			material = material || _materialInstances[primitive.material];
			
			material = material || MaterialObject3D.DEFAULT;
			
			instance.material = material;
			
			var texcoords:Array = new Array();
			
			// retreive correct texcoord-set for the material.
			var obj:DaeBindVertexInput = _materialTextureSets[primitive.material] is DaeBindVertexInput ? _materialTextureSets[primitive.material] : null;
			var setID:int = (obj is DaeBindVertexInput) ? obj.input_set : 0;
			var texCoordSet:Array = primitive.getTexCoords(setID);
			
			// texture coords
			for( i = 0; i < texCoordSet.length; i++ ) 
			{
				var t:Array = texCoordSet[i];
				texcoords.push( new NumberUV( t[0], t[1] ) );
			}
			
			var hasUV:Boolean = (texcoords.length == primitive.vertices.length);

			var idx:Array = new Array();
			var v:Array = new Array();
			var uv:Array = new Array();
			
			switch( primitive.type ) 
			{
				// Each line described by the mesh has two vertices. The first line is formed 
				// from first and second vertices. The second line is formed from the third and fourth 
				// vertices and so on.
				case ASCollada.DAE_LINES_ELEMENT:
					for( i = 0; i < primitive.vertices.length; i += 2 ) 
					{
						v[0] = geometry.vertices[ primitive.vertices[i] ];
						v[1] = geometry.vertices[ primitive.vertices[i+1] ];
						uv[0] = hasUV ? texcoords[  i  ] : new NumberUV();
						uv[1] = hasUV ? texcoords[ i+1 ] : new NumberUV();
						//geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[1]], material, [uv[0], uv[1], uv[1]]) );
					}
					break;
					
				// Each line-strip described by the mesh has an arbitrary number of vertices. Each line 
				// segment within the line-strip is formed from the current vertex and the preceding 
				// vertex.
				case ASCollada.DAE_LINESTRIPS_ELEMENT:
					for( i = 1; i < primitive.vertices.length; i++ ) 
					{
						v[0] = geometry.vertices[ primitive.vertices[i-1] ];
						v[1] = geometry.vertices[ primitive.vertices[i] ];
						uv[0] = hasUV ? texcoords[i-1] : new NumberUV();
						uv[1] = hasUV ? texcoords[i] : new NumberUV();
						//geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[1]], material, [uv[0], uv[1], uv[1]]) );
					}
					break;
					
				// simple triangles
				case ASCollada.DAE_TRIANGLES_ELEMENT:
					for( i = 0, j = 0; i < primitive.vertices.length; i += 3, j++ ) 
					{
						idx[0] = primitive.vertices[i];
						idx[1] = primitive.vertices[i+1];
						idx[2] = primitive.vertices[i+2];
						
						v[0] = geometry.vertices[ idx[0] ];
						v[1] = geometry.vertices[ idx[1] ];
						v[2] = geometry.vertices[ idx[2] ];
						
						uv[0] = hasUV ? texcoords[ i+0 ] : new NumberUV();
						uv[1] = hasUV ? texcoords[ i+1 ] : new NumberUV();
						uv[2] = hasUV ? texcoords[ i+2 ] : new NumberUV();
						
						geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					}
					break;
				
				// Each triangle described by the mesh has three vertices. 
				// The first triangle is formed from the first, second, and third vertices. 
				// Each subsequent triangle is formed from the current vertex, reusing the 
				// first and the previous vertices.
				case ASCollada.DAE_TRIFANS_ELEMENT:
					v[0] = geometry.vertices[ primitive.vertices[0] ];
					v[1] = geometry.vertices[ primitive.vertices[1] ];
					v[2] = geometry.vertices[ primitive.vertices[2] ];
					uv[0] = hasUV ? texcoords[0] : new NumberUV();
					uv[1] = hasUV ? texcoords[1] : new NumberUV();
					uv[2] = hasUV ? texcoords[2] : new NumberUV();
					
					geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					
					for( i = 3; i < primitive.vertices.length; i++ ) 
					{
						v[1] = geometry.vertices[ primitive.vertices[i-1] ];
						v[2] = geometry.vertices[ primitive.vertices[i] ];
						uv[1] = hasUV ? texcoords[i-1] : new NumberUV();
						uv[2] = hasUV ? texcoords[i] : new NumberUV();
						
						geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					}
					break;
				
				// Each triangle described by the mesh has three vertices. The first triangle 
				// is formed from the first, second, and third vertices. Each subsequent triangle 
				// is formed from the current vertex, reusing the previous two vertices.
				case ASCollada.DAE_TRISTRIPS_ELEMENT:
					v[0] = geometry.vertices[ primitive.vertices[0] ];
					v[1] = geometry.vertices[ primitive.vertices[1] ];
					v[2] = geometry.vertices[ primitive.vertices[2] ];
					uv[0] = hasUV ? texcoords[0] : new NumberUV();
					uv[1] = hasUV ? texcoords[1] : new NumberUV();
					uv[2] = hasUV ? texcoords[2] : new NumberUV();
					
					geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					
					for( i = 3; i < primitive.vertices.length; i++ ) 
					{
						v[0] = geometry.vertices[ primitive.vertices[i-2] ];
						v[1] = geometry.vertices[ primitive.vertices[i-1] ];
						v[2] = geometry.vertices[ primitive.vertices[i] ];
						uv[0] = hasUV ? texcoords[i-2] : new NumberUV();
						uv[1] = hasUV ? texcoords[i-1] : new NumberUV();
						uv[2] = hasUV ? texcoords[i] : new NumberUV();
						
						geometry.faces.push( new Triangle3D(instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					}
					break;
					
				// polygon with *no* holes
				case ASCollada.DAE_POLYLIST_ELEMENT:
					for( i = 0, k = 0; i < primitive.vcount.length; i++ ) 
					{
						var poly:Array = new Array();
						var uvs:Array = new Array();
						for( j = 0; j < primitive.vcount[i]; j++ ) 
						{
							uvs.push( (hasUV ? texcoords[ k ] : new NumberUV()) );
							poly.push( geometry.vertices[primitive.vertices[k++]] );
						}
						
						if( !geometry || !geometry.faces || !geometry.vertices )
							throw new Error( "no geomotry" );
						if( !instance )
							throw new Error( "no instance" );
							
						v[0] = poly[0];
						uv[0] = uvs[0];
						
						for( j = 1; j < poly.length - 1; j++ )
						{
							v[1] = poly[j];
							v[2] = poly[j+1];
							uv[1] = uvs[j];
							uv[2] = uvs[j+1];
							geometry.faces.push( new Triangle3D( instance, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
						}
					}
					break;
				
				// polygon with holes...
				case ASCollada.DAE_POLYGONS_ELEMENT:
					break;
					
				default:
					break;
			}
		}
		
		/**
		 * 
		 * @param	asset
		 * @return
		 */
		private function buildFileInfo( asset:* ):void
		{
			this.filename = asset is String ? String(asset) : "./meshes/rawdata_dae";
			
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
		}
		
		/**
		 * 
		 * @param	daeId
		 * @param	instance
		 * @return
		 */
		private function buildGeometry( daeId:String, instance:DisplayObject3D, material:MaterialObject3D = null ):Boolean
		{
			var geom:DaeGeometry = document.geometries[ daeId ];
			
			if( !geom )
				return false;
				
			if( geom.mesh )
			{
				instance.geometry = instance.geometry ? instance.geometry : new GeometryObject3D();
				
				var geometry:GeometryObject3D = instance.geometry;
					
				geometry.vertices = buildVertices(geom.mesh);
				geometry.faces = new Array();
				
				for( var i:int = 0; i < geom.mesh.primitives.length; i++ )
					buildFaces(geom.mesh.primitives[i], geometry, instance, material);
					
				geometry.ready = true;
				
				Logger.trace( "created geometry v:" + geometry.vertices.length + " f:" + geometry.faces.length );
				
				return true;
			}
			
			return false;
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
		 * @return
		 */
		private function buildMaterials():void
		{
			var symbol2target:Object = document.materialSymbolToTarget;
				
			for( var materialId:String in document.materials )
			{
				var mat:DaeMaterial = document.materials[ materialId ];
				var exists:Boolean = false;
				
				for ( var name:String in this.materials.materialsByName )
				{
					if( symbol2target[name] == mat.id )
					{
						exists = true;
						break;
					}
				}
				
				if( exists )
					continue;
				
				var effect:DaeEffect = document.effects[ mat.effect ];
				
				var lambert:DaeLambert = effect.color as DaeLambert;
				
				if(lambert && lambert.diffuse.texture)
				{
					_materialTextureSets[mat.id] = lambert.diffuse.texture.texcoord;
				}
				
				var material:MaterialObject3D;
				
				if( effect && effect.texture_url )
				{				
					var img:DaeImage = document.images[effect.texture_url];
					if( img )
					{
						var path:String = buildImagePath(this.baseUrl, img.init_from);
						material = new BitmapFileMaterial( path );
						material.tiled = true;
						material.addEventListener( FileLoadEvent.LOAD_COMPLETE, materialCompleteHandler );
						material.addEventListener( FileLoadEvent.LOAD_ERROR, materialErrorHandler );
						this.materials.addMaterial(material, mat.id );
						continue;
					}
				}					
				
				if( lambert && lambert.diffuse.color )
				{
					material = new ColorMaterial( buildColor(lambert.diffuse.color)/*, lambert.transparency*/ );
				}
				else
				{
					material = MaterialObject3D.DEFAULT;
				}
				
				this.materials.addMaterial(material, mat.id );
			}
		}
		
		/**
		 * builds material instances from loaded materials.
		 * 
		 * @param 	instances	Array of DaeInstanceMaterial. @see org.ascollada.fx.DaeInstanceMaterial
		 * @return
		 */
		private function buildMaterialInstances(instances:Array):MaterialObject3D
		{
			var firstMaterial:MaterialObject3D;
			
			for each( var instance_material:DaeInstanceMaterial in instances )
			{
				var material:MaterialObject3D = this.materials.getMaterialByName(instance_material.symbol);
					
				if( !material )
					material = this.materials.getMaterialByName(instance_material.target);
				
				if( !material )
					continue;
					
				_materialInstances[instance_material.symbol] = material;
				
				if( !firstMaterial )
					firstMaterial = material;
					
				// setup texcoord-set for the material.
				if(	_materialTextureSets[instance_material.target] )
				{
					var semantic:String = _materialTextureSets[instance_material.target];			
					var obj:DaeBindVertexInput = instance_material.findBindVertexInput(semantic);	
					if( obj )
						_materialTextureSets[instance_material.symbol] = obj;
				}
			}
			
			return firstMaterial;
		}
		
		/**
		 * builds a papervision Matrix3D from a node's matrices array. @see org.ascollada.core.DaeNode#transforms
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMatrix( node:DaeNode ):Matrix3D 
		{
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for( var i:int = 0; i < node.transforms.length; i++ ) 
			{
				var transform:DaeTransform = node.transforms[i];
				matrix = Matrix3D.multiply( matrix, new Matrix3D(transform.matrix) );
			}			
			return matrix;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function buildMatrixStack( node:DaeNode ):Array
		{
			var stack:Array = new Array();
			for( var i:int = 0; i < node.transforms.length; i++ ) 
			{
				var transform:DaeTransform = node.transforms[i];				
				var matrix:Matrix3D = new Matrix3D(transform.matrix);
				stack.push(matrix);
			}
			return stack;
		}
		
		/**
		 * 
		 * @param	instance_controller
		 * @param	instance
		 * @return
		 */
		private function buildMorph( instance_controller:DaeInstanceController, instance:AnimatedMesh3D ):void
		{
			var controller:DaeController = document.controllers[instance_controller.url];
			var morph:DaeMorph = controller.morph;
		
			var success:Boolean = buildGeometry(morph.source, instance);
			
			if( !success )
			{
				Logger.error("[ERROR] could not find geometry for morph!");
				throw new Error("could not find geometry for morph!");
			}

			var ctl:MorphController = new MorphController(instance.geometry);
			
			var target0:DisplayObject3D = new DisplayObject3D();
			buildGeometry(morph.source, target0);
			
			var frame:uint = 0;
			var duration:uint = AnimationEngine.NUM_FRAMES / morph.targets.length;
			
			// use a copy of the original vertices!
			ctl.addFrame(new AnimationFrame(frame, duration, target0.geometry.vertices, "start"));
			
			frame += duration;
			
			for( var i:int = 0; i < morph.targets.length; i++ )
			{
				var obj:DisplayObject3D = new DisplayObject3D();
							
				var target:String = morph.targets[i];
				var weight:Number = morph.weights[i];
				
				buildGeometry(target, obj);
				
				ctl.addFrame(new AnimationFrame(frame, duration, obj.geometry.vertices, target));
				frame += duration;
			}
			
			instance.addController(ctl);
			
			_morphs[ instance ] = true;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function buildNode( node:DaeNode, parent:DisplayObject3D ):void
		{				
			var instance_controller :DaeInstanceController = findSkinController(node);
			var instance_ctl_morph :DaeInstanceController = findMorphController(node);
			
			var newNode:DisplayObject3D;
			var instance:DisplayObject3D;
			var material:MaterialObject3D;
						
			if( instance_controller )
			{
				buildMaterialInstances(instance_controller.materials);
				newNode = buildSkin(instance_controller, material);
				
				if( newNode )
				{
					instance = parent.addChild(newNode);
				}
			}
			else if( instance_ctl_morph ) 
			{
				buildMaterialInstances(instance_ctl_morph.materials);
				
				newNode = new AnimatedMesh3D(material, new Array(), new Array(), node.id);
					
				buildMorph(instance_ctl_morph, newNode as AnimatedMesh3D);
	
				instance = parent.addChild(newNode);
			}
			else if( node.geometries.length )
			{
				newNode = new Node3D(node.name, node.id, node.sid);

				for each( var geomInst:DaeInstanceGeometry in node.geometries )
				{
					material = buildMaterialInstances(geomInst.materials);
					
					var inst:TriangleMesh3D = new TriangleMesh3D(material, new Array(), new Array());
					
					buildGeometry(geomInst.url, inst, material);
					
					newNode.addChild(inst);
				}
				
				instance = parent.addChild(newNode);
				Node3D(instance).matrixStack = buildMatrixStack(node);
				Node3D(instance).transforms = node.transforms;
			}
			else
			{
				instance = parent.addChild(new Node3D(node.name, node.id, node.sid));
				Node3D(instance).matrixStack = buildMatrixStack(node);
				Node3D(instance).transforms = node.transforms;
			}
			
			for( var j:int = 0; j < node.instance_nodes.length; j++ )
			{
				var instance_node:DaeInstanceNode = node.instance_nodes[j];
				var dae_node:DaeNode = document.getDaeNodeById(instance_node.url);
				buildNode(dae_node, instance);
			}
			
			for( var i:int = 0; i < node.nodes.length; i++ )
				buildNode(node.nodes[i], instance);
				
			var matrix:Matrix3D = buildMatrix(node);
						
			instance.copyTransform( matrix );
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function buildScene( event:Event ):void
		{
			if( _reader.hasEventListener(Event.COMPLETE) )
				_reader.removeEventListener(Event.COMPLETE, buildScene);
				
			this.document = _reader.document;
			
			_yUp = (this.document.asset.yUp == ASCollada.DAE_Y_UP);
			_materialInstances = new Object();
			_materialTextureSets = new Object();
			_skins = new Dictionary();
			_morphs = new Dictionary();
			
			buildMaterials();
			
			buildVisualScene();
			
			linkSkins(this.rootNode);
						
			readySkins(this);
			readyMorphs(this);
			
			if( _yUp )
			{
				//this.rootNode.rotationY = 180;
			}
			else
			{
				//this.rootNode.rotationX = 90;
				//this.rootNode.rotationY = 180;
			}
			
			// there may be animations left to parse...
			if( document.numQueuedAnimations )
			{
				hasAnimations = true;
				_reader.addEventListener( Event.COMPLETE, animationCompleteHandler );
				_reader.addEventListener( ProgressEvent.PROGRESS, animationProgressHandler );
				
				_reader.readAnimations();
			}
			else
				hasAnimations = false;
				
			// done with geometry
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 
		 * @param	instance_controller
		 * @return
		 */
		private function buildSkin( instance_controller:DaeInstanceController, material:MaterialObject3D = null ):TriangleMesh3D
		{
			var controller:DaeController = document.controllers[ instance_controller.url ];
			
			if( !controller || !controller.skin )
			{
				Logger.trace( "[WARNING] no skin controller!" );
				return null;
			}
			
			var skin:DaeSkin = controller.skin;
			
			var obj:Skin3D = new Skin3D(material, new Array(), new Array(), skin.source, (document.yUp == DaeDocument.Y_UP));
			
			obj.bindPose = new Matrix3D(skin.bind_shape_matrix);	

			obj.joints = new Array();
			
			var success:Boolean = buildGeometry(skin.source, obj);
				
			// geometry could reside in a morph controller
			if( !success && document.controllers[skin.source] )
			{
				var morph_controller:DaeController = document.controllers[skin.source];
				if( morph_controller.morph )
				{
					success = buildGeometry(morph_controller.morph.source, obj);
					
					if( success )
					{
						var ctl:MorphController = new MorphController(obj.geometry);
						
						var method:String = morph_controller.morph.method;
						var duration:int = AnimationEngine.NUM_FRAMES / morph_controller.morph.targets.length;
						var frame:uint = 0;
						
						for( var i:int = 0; i < morph_controller.morph.targets.length; i++ )
						{
							var morph:DisplayObject3D = new DisplayObject3D();
							
							var target:String = morph_controller.morph.targets[i];
							var weight:Number = morph_controller.morph.weights[i];
							
							var morph_succes:Boolean = buildGeometry(target, morph);
							
							if( morph_succes )
							{
								ctl.addFrame(new AnimationFrame(frame, duration, morph.geometry.vertices, target));
								frame += duration;
								//obj.morph_targets.push( morph.geometry );
								//obj.morph_weights.push( weight );
							}
						}
						
						obj.addController(ctl);
					}
				}
			}
			
			if( !success )
			{
				Logger.error( "[ERROR] could not find geometry for skin!" );
				throw new Error( "could not find geometry for skin!" );
			}
			
			obj.geometry.ready = true;
			
			_skins[ obj ] = instance_controller;
			
			return obj;
		}
				
		/**
		 * 
		 * @param	spline
		 * @return
		 */
		private function buildSpline( spline:DaeSpline ):DisplayObject3D
		{
			var lines:Lines3D = new Lines3D(new LineMaterial(0xffff00, 0.5));
					
			for( var i:int = 0; i < spline.vertices.length; i++ )
			{
				var v0:Array = spline.vertices[i];
				var v1:Array = spline.vertices[(i+1) % spline.vertices.length];
				lines.addNewLine(0, v0[0], v0[1], v0[2], v1[0], v1[1], v1[2]);
			}
			
			return lines;
		}
		
		/**
		 * 
		 * @param	mesh
		 * @return
		 */
		private function buildVertices( mesh:DaeMesh ):Array
		{
			var vertices:Array = new Array();
			
			var yUp:Boolean = (document.yUp == DaeDocument.Y_UP);
			
			for( var i:int = 0; i < mesh.vertices.length; i++ )
			{
				var v:Array = mesh.vertices[i];
				
				if( _yUp )
					vertices.push(new Vertex3D(-v[0], v[1], v[2]));
				else
					vertices.push(new Vertex3D(v[0], v[2], v[1]));
			}
			
			return vertices;
		}

		/**
		 * 
		 * @return
		 */
		private function buildVisualScene():void
		{
			this.rootNode = addChild(new DisplayObject3D("COLLADA_root"));
			
			for( var i:int = 0; i < document.vscene.nodes.length; i++ )
				buildNode(document.vscene.nodes[i], this.rootNode);
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		private function findAnimationChannelsByID( id:String ):Array
		{
			var channels:Array = new Array();
		
			try
			{
				for each( var animation:DaeAnimation in document.animations )
				{
					for each( var channel:DaeChannel in animation.channels )
					{
						var target:String = channel.target.split("/").shift() as String;
						if( target == id )
							channels.push(channel);
					}
				}
			}
			catch( e:Error )
			{
				
			}
			return channels;
		}
		
		/**
		 * 
		 * @param	channels
		 * @param	sid
		 * @param	time
		 * @return
		 */
		private function findChannelMatrix( channels:Array, sid:String, time:Number = 0 ):Matrix3D
		{
			try
			{
				for( var i:int = 0; i < channels.length; i++ )
				{
					var channel:DaeChannel = channels[i];
					if( channel.syntax.targetSID == sid )
					{
						for( var j:int = 0; j < channel.input.length; j++ )
						{
							var t:Number = channel.input[j];
													
							if( t == time )
								return new Matrix3D(channel.output[j]);
								
							if( t > time )
								break;
						}
					}
				}
			}
			catch( e:Error )
			{
				Papervision3D.log( "[WARNING] Could not find channel matrix for SID=" + sid );
			}
			return null;
		}
		
		/**
		 * Finds a child by name.
		 * 
		 * @param	node
		 * @param	name
		 * @return
		 */
		private function findChildByID(node:DisplayObject3D, daeID:String, bySID:Boolean = false):DisplayObject3D
		{	
			if( node is Node3D )
			{
				if( bySID && Node3D(node).daeSID == daeID )
					return node;
				else if( !bySID && Node3D(node).daeID == daeID )
					return node;
			}
			for each(var child:DisplayObject3D in node.children ) 
			{
				var n:DisplayObject3D = findChildByID(child, daeID, bySID);
				if( n )
					return n;
			}
			
			return null;			
		}
		
		/**
		 * Finds a child by name.
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
		 * @param	sid
		 * @return
		 */
		private function findTransformBySID( node:Node3D, sid:String ):DaeTransform
		{
			for each( var transform:DaeTransform in node.transforms )
			{
				if( transform.sid == sid )
					return transform;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function findMorphController( node:DaeNode ):DaeInstanceController
		{
			for each( var controller:DaeInstanceController in node.controllers )
			{
				var control:DaeController = document.controllers[controller.url];
				if( control.morph )
					return controller;
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
				var control:DaeController = document.controllers[controller.url];
				if( control.skin )
					return controller;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	values
		 * @return
		 */
		private function getMatrixKeyValues( values:Array ):Array
		{
			var i:int, j:int;
			var keyValues:Array = new Array(values.length);
			
			for( i = 0; i < values[0].length; i++ )
				keyValues[i] = new Array();
				
			for( i = 0; i < values.length; i++ )
				for( j = 0; j < values[i].length; j++ )
					keyValues[j][i] = values[i][j];
			return keyValues;
		}
		
		/**
		 * 
		 * @param	values
		 * @return
		 */
		private function getTranslationKeyValues( values:Array ):Array
		{
			var i:int;
			var keyValues:Array = new Array(3);
			
			keyValues[0] = new Array();
			keyValues[1] = new Array();
			keyValues[2] = new Array();
			
			for( i = 0; i < values.length; i++ )
			{
				keyValues[0][i] = values[i][0];
				keyValues[1][i] = values[i][1];
				keyValues[2][i] = values[i][2];
			}
			
			return keyValues;
		}
		
		/**
		 * 
		 * @param	skin
		 * @param	instance_controller
		 * @return
		 */
		private function linkSkin(skin:Skin3D, instance_controller:DaeInstanceController):void
		{
			var controller:DaeController = document.controllers[ instance_controller.url ];
			
			var daeSkin:DaeSkin = controller.skin;

			var found:Object = new Object();
			
			skin.joints = new Array();
			skin.skeletons = new Array();
						
			for(var i:int = 0; i < instance_controller.skeletons.length; i++ )
			{				
				var skeletonId:String = instance_controller.skeletons[i];
				
				var skeletonNode:DisplayObject3D = findChildByID(this, skeletonId);
				
				if( !skeletonNode )
					throw new Error( "could not find skeleton: " + skeletonId);
						
				skin.skeletons.push(skeletonNode);

				for( var j:int = 0; j < daeSkin.joints.length; j++ )
				{
					var jointId:String = daeSkin.joints[j];
					
					if( found[jointId] )
						continue;
						
					var joint:Node3D = findChildByID(skeletonNode, jointId) as Node3D;
					if( !joint )
						joint = findChildByID(skeletonNode, jointId, true) as Node3D;
						
					if( !joint )
						throw new Error( "could not find joint: " + jointId + " " + skeletonId);

					var bindMatrix:Array = daeSkin.findJointBindMatrix2(jointId);
					
					if( !bindMatrix )
						throw new Error( "could not find bindmatrix for joint: " + jointId );
						
					joint.bindMatrix = new Matrix3D(bindMatrix);
					joint.blendVerts = daeSkin.findJointVertexWeightsByIDOrSID(jointId);

					if( !joint.blendVerts )
						throw new Error( "could not find influences for joint: " + jointId );
						
					skin.joints.push(joint);
					
					found[jointId] = joint;
				}
			}
			
			var ctl:SkinController = new SkinController(skin, _yUp);
			
			skin.addController(ctl);
		}
		
		/**
		 * 
		 * @param	do3d
		 * @return
		 */
		private function linkSkins( do3d:DisplayObject3D ):void
		{
			if( _skins[ do3d ] is DaeInstanceController && do3d is Skin3D )
				linkSkin(do3d as Skin3D, _skins[do3d]);
				
			for each( var child:DisplayObject3D in do3d.children )
				linkSkins(child);
		}
		
		
		
		/**
		 * 
		 * @param	do3d
		 * @return
		 */
		private function readyMorphs( do3d:DisplayObject3D ):void
		{
			//if( do3d is AnimatedMesh3D )
			//	AnimatedMesh3D(do3d).play();
			//for each( var child:DisplayObject3D in do3d.children )
			//	readyMorphs(child);
		}
		
		/**
		 * 
		 * @param	do3d
		 * @return
		 */
		private function readySkins( do3d:DisplayObject3D ):void
		{
		//	if( do3d is Skin3D )
		//		Skin3D(do3d).animate = true;
		//	for each( var child:DisplayObject3D in do3d.children )
		//		readySkins(child);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function animationCompleteHandler( event:Event ):void
		{
			buildAnimations(this);
			
			//this.controller.frameTime = 10;
			
			//this.controller.play();
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
		private function loadProgressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function materialCompleteHandler( event:FileLoadEvent ):void
		{
			dispatchEvent(event);
		}
		
		private function handleIOError( event:IOErrorEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function materialErrorHandler( event:FileLoadEvent ):void
		{
			Logger.error( "[ERROR] a texture failed to load: " + event.file );
			dispatchEvent( event );
		}
		
		
		
		private var _reader:DaeReader;
		
		private var _morphs:Dictionary;
		
		private var _skins:Dictionary;
		
		private var _materialInstances:Object;
		
		private var _materialTextureSets:Object;
		
		private var _yUp:Boolean;
		
		private var _delayTimer:Timer;
		
		private var _asset:*;
		
		private var _fixZ:Matrix3D;
	}
}
