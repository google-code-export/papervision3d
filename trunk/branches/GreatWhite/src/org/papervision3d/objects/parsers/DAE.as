package org.papervision3d.objects.parsers
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.ascollada.ASCollada;
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.ascollada.io.DaeReader;
	import org.ascollada.namespaces.*;
	import org.ascollada.types.*;
	import org.papervision3d.core.animation.*;
	import org.papervision3d.core.animation.channel.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.controller.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.*;
	import org.papervision3d.materials.special.*;
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
		public var fileTitle:String;
		
		/** */
		public var baseUrl:String;
		
		/** Path where the textures should be loaded from. */
		public var texturePath:String;
		
		/** */
		public var parser:DaeReader;
		
		/** */
		public var document:DaeDocument;
		
		/**
		 * Constructor.
		 */ 
		public function DAE()
		{
			super();
		}
		
		/**
		 * Gets the default FPS.
		 */ 
		public function get fps():uint
		{
			return 20;
		}
		
		/**
		 * Gets a animation channel by its name.
		 * 
		 * @param	name
		 * 
		 * @return the found channel.
		 */ 
		public function getAnimationChannelByName(name:String):AbstractChannel3D
		{
			return null;	
		}
		
		/**
		 * Gets all animation channels for a target. NOTE: when target is null, 'this' object is used.
		 * 
		 * @param	target	The target to get the channels for.
		 * 
		 * @return	Array of AnimationChannel3D.
		 */ 
		public function getAnimationChannelsByTarget(target:DisplayObject3D=null):Array
		{
			var channels:Array = new Array();
			if(target == null)
			{
				for each(var array:Array in _channelsByTarget)
					channels = channels.concat(array);
			}
			else if(_channelsByTarget[target])
			{
				channels = channels.concat(_channelsByTarget[target]);
			}
			else
				return null;
					
			return channels;
		}
		
		/**
		 * Gets animation channels by clip name.
		 * 
		 * @param	name	The clip name
		 * 
		 * @return	Array of AnimationChannel3D.
		 */ 
		public function getAnimationChannelsByClip(name:String):Array
		{
			return null;	
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
			var object:DisplayObject3D = getChildByName(child.name, true);
			
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
			
			buildFileInfo(asset);
			
			this.parser = new DaeReader();
			this.parser.addEventListener(Event.COMPLETE, onParseComplete);
			this.parser.addEventListener(ProgressEvent.PROGRESS, onParseProgress);
			
			if(asset is XML)
			{
				this.COLLADA = asset as XML;
				this.parser.loadDocument(asset);
			}
			else if(asset is ByteArray)
			{
				this.COLLADA = new XML(ByteArray(asset));
				this.parser.loadDocument(asset);
			}
			else if(asset is String)
			{
				this.filename = String(asset);
				this.parser.read(this.filename);
			}
			else
			{
				throw new Error("load : unknown asset type!");
			}
		}
		
		/**
		 * Builds a animation channel for an object.
		 * 
		 * @param	matrixStackChannel	the target object's channel
		 * @param	target	The target object
		 * @param	channel	The DaeChannel
		 */ 
		private function buildAnimationChannel(matrixStackChannel:MatrixStackChannel3D, target:DisplayObject3D, channel:DaeChannel):void
		{
			//if(channel.syntax.isArrayAccess)
			//	return;
				
			var node:DaeNode = _objectToNode[target];
					
			if(!node)
				throw new Error("Couldn't find the targeted object!");
					
			var matrixChannel:MatrixChannel3D = new MatrixChannel3D(this, target, channel.syntax.targetSID);
			
			var transform:DaeTransform = node.findMatrixBySID(channel.syntax.targetSID);
					
			if(!transform)
				throw new Error("Couldn't find the targeted object's transform!");
			
			var matrix:Matrix3D;
			var matrixProp:String;
			var arrayMember:String;
			var data:Array;
			var i:int;
						
			if(channel.syntax.isArrayAccess)
			{
				arrayMember = channel.syntax.arrayMember.join("");
				
				switch(arrayMember)
				{
					case "(0)(0)":
						matrixProp = "n11";
						break;
					case "(1)(0)":
						matrixProp = "n12";
						break;
					case "(2)(0)":
						matrixProp = "n13";
						break;
					case "(3)(0)":
						matrixProp = "n14";
						break;
					case "(0)(1)":
						matrixProp = "n21";
						break;
					case "(1)(1)":
						matrixProp = "n22";
						break;
					case "(2)(1)":
						matrixProp = "n23";
						break;
					case "(3)(1)":
						matrixProp = "n24";
						break;
					case "(0)(2)":
						matrixProp = "n31";
						break;
					case "(1)(2)":
						matrixProp = "n32";
						break;
					case "(2)(2)":
						matrixProp = "n33";
						break;
					case "(3)(2)":
						matrixProp = "n34";
						break;
					default:
						throw new Error(arrayMember);
				}
			}
					
			switch(transform.type)
			{
				case "matrix":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							data = channel.output[i];
							matrix = new Matrix3D(data);
							matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
						}
					}
					else if(channel.syntax.isArrayAccess)
					{
						matrix = Matrix3D.clone(target.transform);
						
						for(i = 0; i < channel.input.length; i++)
						{
							matrix[matrixProp] = channel.output[i];
							matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}
					break;
				case "rotate":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							data = channel.output[i];
							matrix = Matrix3D.rotationMatrix(data[0], data[1], data[2], data[3] * (Math.PI/180));
							matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
						}
					}
					else if(channel.syntax.isDotAccess)
					{
						switch(channel.syntax.member)
						{
							case "ANGLE":
								for(i = 0; i < channel.input.length; i++)
								{
									var angle:Number = channel.output[i] * (Math.PI/180);
									matrix = Matrix3D.rotationMatrix(transform.values[0], transform.values[1], transform.values[2], angle);
									matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
								}
								break;
							default:
								throw new Error("Don't know how to handle this channel: " + channel.syntax);
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}	
					break;
				case "scale":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							data = channel.output[i];
							matrix = Matrix3D.scaleMatrix(data[0], data[1], data[2]);
							matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
						}
					}
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}
					break;
				case "translate":
					if(channel.syntax.isFullAccess)
					{
						for(i = 0; i < channel.input.length; i++)
						{
							data = channel.output[i];
							matrix = Matrix3D.translationMatrix(data[0], data[1], data[2]);
							matrixChannel.addKeyFrame(new AnimationKeyFrame3D("keyframe_" + i, channel.input[i], [matrix]));
						}
					}	
					else
					{
						throw new Error("Don't know how to handle this channel: " + channel.syntax);
					}		
					break;
				default:
					throw new Error("Unknown transform type!");	
			}
			
			matrixStackChannel.addMatrixChannel(matrixChannel);
		}
		
		/**
		 * Build all animation channels.
		 */ 
		private function buildAnimationChannels():void
		{
			var target:DisplayObject3D;
			var channel:DaeChannel;
			var channelsByObject:Dictionary = new Dictionary(true);
			var i:int;
			
			_channelsByTarget = new Dictionary(true);
			
			for each(var animation:DaeAnimation in this.document.animations)
			{
				for(i = 0; i < animation.channels.length; i++)
				{
					channel = animation.channels[i];
					
					target = _colladaIDToObject[channel.syntax.targetID];
					if(!target)
						throw new Error("damn");
						
					if(!channelsByObject[target])
						channelsByObject[target] = new Array();
					
					channelsByObject[target].push(channel);
				}
			}
			
			for(var object:* in channelsByObject)
			{
				target = object as DisplayObject3D;
							
				trace(target.name);
				
				var matrixStackChannel:MatrixStackChannel3D = new MatrixStackChannel3D(this, target, target.name);
							
				var channels:Array = channelsByObject[object];

				for(i = 0; i < channels.length; i++)
					buildAnimationChannel(matrixStackChannel, target, channels[i]);
					
				_channelsByTarget[target] = [matrixStackChannel];
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
			var material:MaterialObject3D = this.materials.getMaterialByName(primitive.material);
			
			trace( "MATERIAL: " + material + " " + primitive.material);
			
			if(!material)
			{
				material = new CompositeMaterial();
				CompositeMaterial(material).addMaterial(new ColorMaterial(0xff0000, 0.5));
				CompositeMaterial(material).addMaterial(new WireframeMaterial(0));
			}
			
			// retreive correct texcoord-set for the material.
			var obj:DaeBindVertexInput = _textureSets[primitive.material] is DaeBindVertexInput ? _textureSets[primitive.material] : null;
			var setID:int = (obj is DaeBindVertexInput) ? obj.input_set : 0;
			var texCoordSet:Array = primitive.getTexCoords(setID); 
			var texcoords:Array = new Array();
			var i:int, j:int = 0, k:int;
			
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
						
						geometry.faces.push(new Triangle3D(null, [v[2], v[1], v[0]], material, [uv[2], uv[1], uv[0]]) );
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
							
						v[0] = poly[0];
						uv[0] = uvs[0];
						
						for( j = 1; j < poly.length - 1; j++ )
						{
							v[1] = poly[j];
							v[2] = poly[j+1];
							uv[1] = uvs[j];
							uv[2] = uvs[j+1];
							geometry.faces.push( new Triangle3D(null, [v[2], v[1], v[0]], material, [uv[2], uv[1], uv[0]]) );
						}
					}
					break;
						
				default:
					throw new Error("Don't know how to create face for a DaePrimitive with type = " + primitive.type);
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
		 *
		 * @return
		 */
		private function buildImagePath( meshFolderPath:String, imgPath:String ):String
		{
			if (texturePath != null)
				imgPath = texturePath + imgPath.slice( imgPath.lastIndexOf("/") + 1 );
			
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
						var imageUrl:String = buildImagePath(this.baseUrl, image.init_from);
						
						_queuedMaterials.push({symbol:symbol, url:imageUrl});
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
			var stack:Array = buildMatrixStack(node);
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for( var i:int = 0; i < stack.length; i++ ) 
				matrix.calculateMultiply4x4(matrix, stack[i]);
			return matrix;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function buildMatrixStack(node:DaeNode):Array
		{
			var toRadians:Number = Math.PI/180;
			var stack:Array = new Array();
			
			for( var i:int = 0; i < node.transforms.length; i++ ) 
			{
				var transform:DaeTransform = node.transforms[i];
				var v:Array = transform.values;				
				var matrix:Matrix3D;
				
				switch(transform.type)
				{
					case ASCollada.DAE_ROTATE_ELEMENT:
						matrix = Matrix3D.rotationMatrix(v[0], v[1], v[2], v[3] * toRadians);
						break;
					case ASCollada.DAE_SCALE_ELEMENT:
						matrix = Matrix3D.scaleMatrix(v[0], v[1], v[2]);
						break;
					case ASCollada.DAE_TRANSLATE_ELEMENT:
						matrix = Matrix3D.translationMatrix(v[0], v[1], v[2]);
						break;
					case ASCollada.DAE_MATRIX_ELEMENT:
						matrix = new Matrix3D(v);
						break;
					default:
						throw new Error("Unknown transform type: " + transform.type);
				}
				
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
				instance = new ControllerMesh3D(null, [], [], node.name);
				
				var controllerMesh:ControllerMesh3D = instance as ControllerMesh3D;
				
				// controllers, can be of type 'skin' or 'morph'
				for(i = 0; i < node.controllers.length; i++)
				{
					var instanceController:DaeInstanceController = node.controllers[i];
					var colladaController:DaeController = document.controllers[instanceController.url];

					if(colladaController.skin)
					{
						buildSkin(controllerMesh, colladaController.skin, instanceController.skeletons);
					}
					else if(colladaController.morph)
					{
					}
					else
						throw new Error("A COLLADA controller should be of type <skin> or <morph>!");
					// dunnu yet how to handle multiple controllers.
					break;
				}
			}
			else if(node.geometries.length)
			{
				// got geometry, so create a TriangleMesh3D
				instance = new TriangleMesh3D(null, [], [], node.name);
				
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
				// no geometry, simply create a Joint3D
				instance = new Joint3D(node.name);
			}
			
			// recurse node instances
			for(i = 0; i < node.instance_nodes.length; i++)
			{
				var dae_node:DaeNode = document.getDaeNodeById(node.instance_nodes[i].url);
				buildNode(dae_node, instance);
			}

			// setup the initial transform
			instance.copyTransform(buildMatrix(node));	
						
			// recurse node children
			for(i = 0; i < node.nodes.length; i++)
				buildNode(node.nodes[i], instance);
					
			// save COLLADA id, sid
			_colladaID[instance] = node.id;
			_colladaSID[instance] = node.sid;
			_colladaIDToObject[node.id] = instance;
			_colladaSIDToObject[node.sid] = instance;
			_objectToNode[instance] = node;
			
			parent.addChild(instance);
		}
		
		/**
		 * Builds the scene.
		 */ 
		private function buildScene():void
		{
			if(this.parser.hasEventListener(Event.COMPLETE))
				this.parser.removeEventListener(Event.COMPLETE, onParseComplete);
			if(this.parser.hasEventListener(ProgressEvent.PROGRESS))
				this.parser.removeEventListener(ProgressEvent.PROGRESS, onParseProgress);
					
			buildGeometries();
			
			var scene:DisplayObject3D = this.addChild(new DisplayObject3D("COLLADA_Scene"));
			
			for(var i:int = 0; i < this.document.vscene.nodes.length; i++)
			{
				buildNode(this.document.vscene.nodes[i], scene);
			}
			
			// link the skins
			linkSkins();
			
			this.addChild(scene);
			
			// may have animations to be parsed.
			if(document.numQueuedAnimations)
			{
				this.parser.addEventListener(Event.COMPLETE, onParseAnimationsComplete);
				this.parser.addEventListener(ProgressEvent.PROGRESS, onParseAnimationsProgress);
				this.parser.readAnimations();
			}
			
			dispatchEvent(new FileLoadEvent(FileLoadEvent.LOAD_COMPLETE, this.filename));
		}
		
		/**
		 * Builds a skin.
		 * 
		 * @param	instance
		 * @param	colladaSkin
		 */ 
		private function buildSkin(instance:ControllerMesh3D, colladaSkin:DaeSkin, skeletons:Array):void
		{
			var skin:GeometryObject3D = _geometries[ colladaSkin.source ];
			if(!skin)
				throw new Error("no geometry?");
							
			mergeGeometries(instance.geometry, skin.clone(instance));
			
			var yUp:Boolean = (this.document.asset.yUp == ASCollada.DAE_Y_UP);
			
			var controller:SkinController = new SkinController(instance, yUp);
			
			controller.joints = new Array();
			controller.skeletons = new Array();
			
			for each(var skeletonId:String in skeletons)
				controller.skeletons.push(skeletonId)
			
			for(var i:int = 0; i < colladaSkin.joints.length; i++)
				controller.joints.push(colladaSkin.joints[i]);

			instance.addController(controller);
			
			_skins[ instance ] = colladaSkin;
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
		 * Recursively finds a child by its SID.
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
		 * Setup the skin controllers.
		 */ 
		private function linkSkin(instance:ControllerMesh3D, skin:DaeSkin):void
		{
			var skinController:SkinController;
			for each(var controller:AbstractController in instance.controllers)
			{
				if(controller is SkinController)
				{
					skinController = controller as SkinController;
					break;
				}
			}
			
			if(!skinController)
				return;	
			
			var i:int;
			var found:Object = new Object();
			
			for(i = 0; i < skinController.joints.length; i++)
			{
				var jointId:String = skinController.joints[i];
				
				if(found[jointId])
					continue;
					
				var joint:Joint3D = _colladaIDToObject[jointId];
				if(!joint)
					joint = _colladaSIDToObject[jointId];
				if(!joint)
					throw new Error("Couldn't find the joint id = " + jointId);
				
				joint = this.getChildByName(joint.name, true) as Joint3D;
				 
				var vertexWeights:Array = skin.findJointVertexWeightsByIDOrSID(jointId);
				if(!vertexWeights)
					throw new Error("Could not find vertex weights for joint with id = " + jointId);
					
				joint.vertexWeights = vertexWeights;
				
				var bindMatrix:Array = skin.findJointBindMatrix2(jointId);
				if(!bindMatrix || bindMatrix.length != 16)
					throw new Error("Could not find inverse bind matrix for joint with id = " + jointId);
				
				joint.inverseBindMatrix = new Matrix3D(bindMatrix);
				
				skinController.joints[i] = joint;
				
				found[jointId] = true;
			}
			
			for(i = 0; i < skinController.skeletons.length; i++)
			{
				var skeletonId:String = skinController.skeletons[i];
				
				var skeleton:Joint3D = _colladaIDToObject[skeletonId];
				if(!skeleton)
					skeleton = _colladaSIDToObject[skeletonId];	
				if(!skeleton)
					throw new Error("Couldn't find the skeleton with id = " + skeletonId);
					
				skeleton = this.getChildByName(skeleton.name, true) as Joint3D;
				
				if(!skeleton)
					throw new Error("Couldn't find the skeleton with id = " + skeletonId);
					
				skinController.skeletons[i] = skeleton;
				
				//this.removeChild(skeleton);
			}
			
			for each(var triangle:Triangle3D in instance.geometry.faces)
			{
				var tmp:Vertex3D = triangle.v0;
				triangle.v0 = triangle.v2;
				triangle.v2 = tmp;
				
				triangle.uv = [triangle.uv2, triangle.uv1, triangle.uv0];
			}
			
			skinController.bindShapeMatrix = new Matrix3D(skin.bind_shape_matrix);
		}
		
		/**
		 * Setup the skin controllers.
		 */ 
		private function linkSkins():void
		{
			for(var object:* in _skins)
			{
				var instance:ControllerMesh3D = object as ControllerMesh3D;
				if(!instance)
					throw new Error("Not a ControllerMesh3D?");
				linkSkin(instance, _skins[object]);
			}
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
		 * Called when the parser completed parsing animations.
		 * 
		 * @param	event
		 */ 
		private function onParseAnimationsComplete(event:Event):void
		{
			trace( "animations COMPLETE");
			
			buildAnimationChannels();
						
			dispatchEvent(new FileLoadEvent(FileLoadEvent.ANIMATIONS_COMPLETE, this.filename));
		}
		
		/**
		 * Called on parse animations progress.
		 * 
		 * @param	event
		 */ 
		private function onParseAnimationsProgress(event:ProgressEvent):void
		{
			trace( "animations #" + event.bytesLoaded + " of " + event.bytesTotal);
		}
		
		/**
		 * Called when the DaeReader completed parsing.
		 * 
		 * @param	event
		 */
		private function onParseComplete(event:Event):void
		{
			var reader:DaeReader = event.target as DaeReader;
			
			this.document = reader.document;
			
			_textureSets = new Object();
			_colladaID = new Dictionary(true);
			_colladaSID = new Dictionary(true);
			_colladaIDToObject = new Object();
			_colladaSIDToObject = new Object();
			_objectToNode = new Object();
			_skins = new Dictionary(true);
			
			buildMaterials();
			loadNextMaterial();
		}
		
		/**
		 * Called on parsing progress.
		 * 
		 * @param	event
		 */ 
		private function onParseProgress(event:ProgressEvent):void
		{
			
		}
		
		/** */
		private var _colladaID:Dictionary;
		
		/** */
		private var _colladaSID:Dictionary;
		
		/** */
		private var _colladaIDToObject:Object;
		
		/** */
		private var _colladaSIDToObject:Object;
		
		/** */
		private var _objectToNode:Object;
		
		/** */
		private var _channelsByTarget:Dictionary;
		
		/** */
		private var _geometries:Object;
		
		/** */
		private var _queuedMaterials:Array;
		
		/** */
		private var _textureSets:Object;
		
		/** */
		private var _channels:Array;
		
		/** */
		private var _skins:Dictionary;
	}
}

