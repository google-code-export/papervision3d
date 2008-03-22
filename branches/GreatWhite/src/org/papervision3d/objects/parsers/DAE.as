/*
 * PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 * AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 * PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 * ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 * RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 * ______________________________________________________________________
 * papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 *
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
 
package org.papervision3d.objects.parsers
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.ascollada.io.DaeReader;
	import org.ascollada.namespaces.*;
	import org.ascollada.types.*;
	import org.papervision3d.core.animation.*;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip
	 */ 
	public class DAE extends DisplayObject3D implements IAnimationDataProvider
	{
		use namespace collada;
		
		/** */
		public var COLLADA:XML;
	
		/** */
		public var filename:String;
		
		/** */
		public var document:DaeDocument;
		
		/**
		 * Constructor.
		 */ 
		public function DAE()
		{
			super();
		}
		
		public function getAnimationChannelByName(name:String):AnimationChannel3D
		{
			return null;	
		}
		
		public function getAnimationChannelsByTarget(target:DisplayObject3D=null):Array
		{
			return null;
		}
		
		public function getAnimationChannelsByClip(name:String):Array
		{
			return null;	
		}
		
		/**
		 * Gets a child by its name.
		 * 
		 * @param	name	The name of the object to find.
		 */ 
		override public function getChildByName(name:String):DisplayObject3D
		{
			return findChildByName(name, this);
		}
		
		/**
		 * Removes a child.
		 * 
		 * @param	child	The child to remove
		 * 
		 * @return	The removed child
		 */ 
		override public function removeChild(child:DisplayObject3D):DisplayObject3D
		{
			var object:DisplayObject3D = getChildByName(child.name);
			
			if(object)
			{
				var parent:DisplayObject3D = DisplayObject3D(object.parent);
				if(parent)
				{
					var removed:DisplayObject3D = parent.removeChild(object);
					if(removed)
						return removed;
				}
			}
			return null;	
		}
		
		/**
		 * Loads the COLLADA.
		 * 
		 * @param	asset The url, an XML object or a ByteArray specifying the COLLADA file.
		 * @param	materials	An optional materialsList.
		 */ 
		public function load(asset:*, materials:MaterialsList = null):void
		{
			this.materials = materials || new MaterialsList();
			this.filename = "nofile";
			
			var reader:DaeReader = new DaeReader();
			reader.addEventListener(Event.COMPLETE, onParseComplete);
			
			if(asset is XML)
			{
				this.COLLADA = asset as XML;
				reader.loadDocument(asset);
			}
			else if(asset is ByteArray)
			{
				this.COLLADA = new XML(ByteArray(asset));
				reader.loadDocument(asset);
			}
			else if(asset is String)
			{
				this.filename = String(asset);
				reader.read(this.filename);
			}
			else
			{
				throw new Error("load : unknown asset type!");
			}
		}
		
		/**
		 * 
		 */ 
		private function buildAnimationChannels():void
		{
			for each(var animation:DaeAnimation in this.document.animations)
			{
				trace("=>"+animation.id);
			}
		}
		
		/**
		 * Build a color from RGB values.
		 * 
		 * @param	rgb
		 *  
		 * @return
		 */
		private function buildColor( rgb:Array ):uint
		{
			var r:uint = rgb[0] * 0xff;
			var g:uint = rgb[1] * 0xff;
			var b:uint = rgb[2] * 0xff;
			return (r<<16|g<<8|b);
		}
		
		/**
		 * Creates the faces for a COLLADA primitive. @see org.ascollada.core.DaePrimitive
		 * 
		 * @param 	primitive
		 * @param	geometry
		 * @param	voffset
		 * 
		 * @return 	The created faces.
		 */ 
		private function buildFaces(primitive:DaePrimitive, geometry:GeometryObject3D, voffset:uint):void
		{
			var faces:Array = new Array();
			var material:MaterialObject3D = MaterialObject3D.DEFAULT;
			
			// retreive correct texcoord-set for the material.
			var obj:DaeBindVertexInput = _textureSets[primitive.material] is DaeBindVertexInput ? _textureSets[primitive.material] : null;
			var setID:int = (obj is DaeBindVertexInput) ? obj.input_set : 0;
			var texCoordSet:Array = primitive.getTexCoords(setID); 
			var texcoords:Array = new Array();
			var i:int, j:int = 0;
			
			// texture coords
			for( i = 0; i < texCoordSet.length; i++ ) 
				texcoords.push(new NumberUV(texCoordSet[i][0], texCoordSet[i][1]));
			
			var hasUV:Boolean = (texcoords.length == primitive.vertices.length);

			var idx:Array = new Array();
			var v:Array = new Array();
			var uv:Array = new Array();
			
			switch( primitive.type ) 
			{
				// simple triangles
				case "triangles":
					for(i = 0, j = 0; i < primitive.vertices.length; i += 3, j++) 
					{
						idx[0] = voffset + primitive.vertices[i];
						idx[1] = voffset + primitive.vertices[i+1];
						idx[2] = voffset + primitive.vertices[i+2];
						
						v[0] = geometry.vertices[ idx[0] ];
						v[1] = geometry.vertices[ idx[1] ];
						v[2] = geometry.vertices[ idx[2] ];
						
						uv[0] = hasUV ? texcoords[ i+0 ] : new NumberUV();
						uv[1] = hasUV ? texcoords[ i+1 ] : new NumberUV();
						uv[2] = hasUV ? texcoords[ i+2 ] : new NumberUV();
						
						geometry.faces.push(new Triangle3D(null, [v[0], v[1], v[2]], material, [uv[0], uv[1], uv[2]]) );
					}
					break;
					
				default:
					throw new Error("Don't know how to create face for a DaePrimitive with type = " + primitive.type);
			}
		}
		
		/**
		 * Builds all COLLADA geometries.
		 */ 
		private function buildGeometries():void
		{
			_geometries = new Object();
			
			for each(var geometry:DaeGeometry in this.document.geometries)
			{
				if(geometry.mesh)
				{
					var g:GeometryObject3D = new GeometryObject3D();
					
					g.vertices = buildVertices(geometry.mesh);
					g.faces = new Array();
					
					for(var i:int = 0; i < geometry.mesh.primitives.length; i++)
					{
						buildFaces(geometry.mesh.primitives[i], g, 0);
					}
					
					_geometries[geometry.id] = g;
				}
			}	
		}
		
		/**
		 * Builds the materials.
		 */ 
		private function buildMaterials():void
		{
			_queuedMaterials = new Array();
			
			for( var materialId:String in this.document.materials )
			{
				var material:DaeMaterial = this.document.materials[ materialId ];

				var symbol:String = this.document.materialTargetToSymbol[ material.id ];
							
				// material already exists in our materialsList, no need to process
				if(this.materials.getMaterialByName(symbol))
					continue;
					
				var effect:DaeEffect = document.effects[ material.effect ];
				
				var lambert:DaeLambert = effect.color as DaeLambert;
				
				// save the texture-set if necessary
				if(lambert && lambert.diffuse.texture)
					_textureSets[material.id] = lambert.diffuse.texture.texcoord;
					
				// if the material has a texture, qeueu the bitmap
				if(effect && effect.texture_url)
				{				
					var image:DaeImage = document.images[effect.texture_url];
					if(image)
					{
						_queuedMaterials.push({symbol:symbol, url:image.init_from});
						continue;
					}
				}
				
				if(lambert && lambert.diffuse.color)
					this.materials.addMaterial(new ColorMaterial(buildColor(lambert.diffuse.color)), symbol);
				else
					this.materials.addMaterial(MaterialObject3D.DEFAULT, symbol);
			}
		}
		
		/**
		 * Builds a Matrix3D from a node's transform array. @see org.ascollada.core.DaeNode#transforms
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		private function buildMatrix(node:DaeNode):Matrix3D 
		{
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for( var i:int = 0; i < node.transforms.length; i++ ) 
				matrix = Matrix3D.multiply(matrix, new Matrix3D(node.transforms[i].matrix));	
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
		 * Builds a DisplayObject3D from a node. @see org.ascollada.core.DaeNode
		 * 
		 * @param	node	
		 * 
		 * @return	The created DisplayObject3D. @see org.papervision3d.objects.DisplayObject3D
		 */ 
		private function buildNode(node:DaeNode, parent:DisplayObject3D):void
		{
			var instance:DisplayObject3D;
			var i:int;
			
			if(node.controllers.length)
			{
				// controllers, can be of type 'skin' or 'morph'
				for(i = 0; i < node.controllers.length; i++)
				{
					
				}
			}
			else if(node.geometries.length)
			{
				// got geometry, so create a TriangleMesh3D
				instance = parent.addChild(new TriangleMesh3D(null, [], [], node.name));
				
				// add all COLLADA geometries to the TriangleMesh3D
				for each(var geom:DaeInstanceGeometry in node.geometries)
				{
					var geometry:GeometryObject3D = _geometries[ geom.url ];		
					if(!geometry)
						continue;
					mergeGeometries(instance.geometry, geometry.clone(instance));
				}
			}
			else
			{
				// no geometry, simply create a DisplayObject3D
				instance = parent.addChild(new DisplayObject3D(node.name));
			}
			
			// recurse node instances
			for(i = 0; i < node.instance_nodes.length; i++)
			{
				var dae_node:DaeNode = document.getDaeNodeById(node.instance_nodes[i].url);
				buildNode(dae_node, instance);
			}
			
			// recurse node children
			for(i = 0; i < node.nodes.length; i++)
				buildNode(node.nodes[i], instance);
					
			// setup the initial transform
			instance.copyTransform(buildMatrix(node));	
			
			// save COLLADA id, sid
			_colladaID[instance] = node.id;
			_colladaSID[instance] = node.sid;
		}
		
		/**
		 * Builds the scene.
		 */ 
		private function buildScene():void
		{
			buildGeometries();
			
			var scene:DisplayObject3D = this.addChild(new DisplayObject3D("COLLADA_Scene"));
			
			for(var i:int = 0; i < this.document.vscene.nodes.length; i++)
			{
				buildNode(this.document.vscene.nodes[i], scene);
			}
			
			this.addChild(scene);
			
			buildAnimationChannels();
			
			trace("COMPLETE, author: " + DaeContributor(document.asset.contributors[0]).author);
		}
		
		/**
		 * Builds vertices from a COLLADA mesh.
		 * 
		 * @param	mesh	The COLLADA mesh. @see org.ascollada.core.DaeMesh
		 * 
		 * @return	Array of Vertex3D
		 */
		private function buildVertices(mesh:DaeMesh):Array
		{
			var vertices:Array = new Array();
			for( var i:int = 0; i < mesh.vertices.length; i++ )
				vertices.push(new Vertex3D(mesh.vertices[i][0], mesh.vertices[i][1], mesh.vertices[i][2]));
			return vertices;
		}
		
		/**
		 * Recursively finds a child by its COLLADA is.
		 * 
		 * @param	id
		 * @param	parent
		 * 
		 * @return 	The found child.
		 */ 
		private function findChildByID(id:String, parent:DisplayObject3D = null):DisplayObject3D
		{
			parent = parent || this;
			if(_colladaID[parent] == id)
				return parent;
			for each(var child:DisplayObject3D in parent.children)	
			{
				var obj:DisplayObject3D = findChildByID(id, child);
				if(obj) 
					return obj;
			}
			return null
		}
		
		/**
		 * Recursively finds a child by its name.
		 * 
		 * @param	name
		 * @param	parent
		 * 
		 * @return 	The found child.
		 */ 
		private function findChildByName(name:String, parent:DisplayObject3D = null):DisplayObject3D
		{
			parent = parent || this;
			if(parent.name == name)
				return parent;
			for each(var child:DisplayObject3D in parent.children)	
			{
				var obj:DisplayObject3D = findChildByName(name, child);
				if(obj) 
					return obj;
			}
			return null
		}
		
		/**
		 * Recursively finds a child by its name.
		 * 
		 * @param	name
		 * @param	parent
		 * 
		 * @return 	The found child.
		 */ 
		private function findChildBySID(sid:String, parent:DisplayObject3D = null):DisplayObject3D
		{
			parent = parent || this;
			if(_colladaSID[parent] == sid)
				return parent;
			for each(var child:DisplayObject3D in parent.children)	
			{
				var obj:DisplayObject3D = findChildBySID(sid, child);
				if(obj) 
					return obj;
			}
			return null
		}
		
		/**
		 * Loads the next material.
		 * 
		 * @param	event
		 */ 
		private function loadNextMaterial(event:FileLoadEvent=null):void
		{
			if(_queuedMaterials.length)
			{
				var data:Object = _queuedMaterials.shift();
				var url:String = data.url;
				var symbol:String = data.symbol;
				
				var material:BitmapFileMaterial = new BitmapFileMaterial();
				material.addEventListener(FileLoadEvent.LOAD_COMPLETE, loadNextMaterial);
				material.addEventListener(FileLoadEvent.LOAD_ERROR, onMaterialError);
				material.texture = url;
				
				this.materials.addMaterial(material, symbol);
			}
			else
			{
				dispatchEvent(new FileLoadEvent(FileLoadEvent.COLLADA_MATERIALS_DONE, this.filename));
				trace("materials complete!");
				
				buildScene();
			}
		}
		
		private function mergeGeometries(target:GeometryObject3D, source:GeometryObject3D):void
		{
			target.vertices = target.vertices.concat(source.vertices);
			target.faces = target.faces.concat(source.faces);
		}
		
		/**
		 * Called when a BitmapMaterial failed to load.
		 * 
		 * @param	event
		 */ 
		private function onMaterialError(event:Event):void
		{
			loadNextMaterial();	
		}
		
		/**
		 * Called when the DaeReader completed parsing.
		 */ 
		private function onParseComplete(event:Event):void
		{
			var reader:DaeReader = event.target as DaeReader;
			
			this.document = reader.document;
			
			_textureSets = new Object();
			_colladaID = new Dictionary(true);
			_colladaSID = new Dictionary(true);
			
			buildMaterials();
			loadNextMaterial();
		}

		/** */
		private var _colladaID:Dictionary;
		
		/** */
		private var _colladaSID:Dictionary;
		
		/** */
		private var _geometries:Object;
		
		/** */
		private var _queuedMaterials:Array;
		
		/** */
		private var _textureSets:Object;
	}
}
