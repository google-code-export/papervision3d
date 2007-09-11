/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
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

// ______________________________________________________________________
//                                               GeometryObject3D: Mesh3D
package org.papervision3d.core.geom
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.*;
	import org.papervision3d.core.culling.ITriangleCuller;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Triangle3DInstance;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.core.proto.*;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	import org.papervision3d.objects.DisplayObject3D;
	
	
	/**
	* The Mesh3D class lets you create and display solid 3D objects made of vertices and triangular polygons.
	*/
	public class TriangleMesh3D extends Vertices3D
	{
		// ___________________________________________________________________________________________________
		//                                                                                               N E W
		// NN  NN EEEEEE WW    WW
		// NNN NN EE     WW WW WW
		// NNNNNN EEEE   WWWWWWWW
		// NN NNN EE     WWW  WWW
		// NN  NN EEEEEE WW    WW
	
		/**
		* Creates a new Mesh object.
		*
		* The Mesh DisplayObject3D class lets you create and display solid 3D objects made of vertices and triangular polygons.
		* <p/>
		* @param	material	A MaterialObject3D object that contains the material properties of the object.
		* <p/>
		* @param	vertices	An array of Vertex3D objects for the vertices of the mesh.
		* <p/>
		* @param	faces		An array of Face3D objects for the faces of the mesh.
		* <p/>
		* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created DisplayObject3D.
		* <p/>
		* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
		* <p/>
		* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
		* <ul>
		* <li><b>sortFaces</b>: Z-depth sorting when rendering. Some objects might not need it. Default is false (faster).</li>
		* <li><b>showFaces</b>: Use only if each face is on a separate MovieClip container. Default is false.</li>
		* </ul>
		*
		*/
		public function TriangleMesh3D( material:MaterialObject3D, vertices:Array, faces:Array, name:String=null, initObject:Object=null )
		{
			super( vertices, name, initObject );
	
			this.geometry.faces = faces || new Array();
			this.material       = material || MaterialObject3D.DEFAULT;
		}
	
		// ___________________________________________________________________________________________________
		//                                                                                       P R O J E C T
		// PPPPP  RRRRR   OOOO      JJ EEEEEE  CCCC  TTTTTT
		// PP  PP RR  RR OO  OO     JJ EE     CC  CC   TT
		// PPPPP  RRRRR  OO  OO     JJ EEEE   CC       TT
		// PP     RR  RR OO  OO JJ  JJ EE     CC  CC   TT
		// PP     RR  RR  OOOO   JJJJ  EEEEEE  CCCC    TT
	
		/**
		* Projects three dimensional coordinates onto a two dimensional plane to simulate the relationship of the camera to subject.
		*
		* This is the first step in the process of representing three dimensional shapes two dimensionally.
		*
		* @param	camera	Camera3D object to render from.
		*/
		public override function project( parent :DisplayObject3D, camera :CameraObject3D, sorted :Array=null ):Number
		{
			// Vertices
			super.project( parent, camera, sorted );
			if( ! sorted ) sorted = this._sorted;
			
			// Faces
			var faces:Array  = this.geometry.faces, 
								screenZs:Number = 0, 
								visibleFaces :Number = 0, 
								triCuller:ITriangleCuller = scene.triangleCuller, 
								vertex0:Vertex3DInstance, 
								vertex1:Vertex3DInstance, 
								vertex2:Vertex3DInstance, 
								iFace:Triangle3DInstance, 
								face:Triangle3D,
								mat:MaterialObject3D;
								
			for each(face in faces){
				mat = face.material ? face.material : material;
				iFace = face.face3DInstance;
				vertex0 = face.v0.vertex3DInstance;
				vertex1 = face.v1.vertex3DInstance;
				vertex2 = face.v2.vertex3DInstance;
				if( (iFace.visible = triCuller.testFace(face, vertex0, vertex1, vertex2)))
				{
					if(mat.needsFaceNormals){
						face.faceNormal.copyTo(iFace.faceNormal);
						Matrix3D.multiplyVector3x3( this.view, iFace.faceNormal );
					}
					if(mat.needsVertexNormals){
						face.v0.normal.copyTo(face.v0.vertex3DInstance.normal);
						Matrix3D.multiplyVector3x3(this.world, vertex0.normal);
						
						face.v1.normal.copyTo(face.v1.vertex3DInstance.normal);
						Matrix3D.multiplyVector3x3(this.world, vertex1.normal);
						
						face.v2.normal.copyTo(face.v2.vertex3DInstance.normal);
						Matrix3D.multiplyVector3x3(this.world, vertex2.normal);
					}
					//Note to self ;-) Get the switch out of here.
					switch(meshSort)
					{
						case DisplayObject3D.MESH_SORT_CENTER:
							screenZs += iFace.screenZ = ( vertex0.z + vertex1.z + vertex2.z ) *.333;
							break;
						
						case DisplayObject3D.MESH_SORT_FAR:
							screenZs += iFace.screenZ = Math.max(vertex0.z,vertex1.z,vertex2.z);
							break;
							
						case DisplayObject3D.MESH_SORT_CLOSE:
							screenZs += iFace.screenZ = Math.min(vertex0.z,vertex1.z,vertex2.z);
							break;
					}
					visibleFaces++;
					face.renderCommand.renderer = mat as ITriangleDrawer;
					face.renderCommand.screenDepth = iFace.screenZ;
					scene.renderer.addToRenderList(face.renderCommand);
				}else{
					scene.stats.culledTriangles++;
				}
			}
			return this.screenZ = screenZs / visibleFaces;
		}
	
	
		/**
		* Planar projection from the specified plane.
		*
		* @param	u	The texture horizontal axis. Can be "x", "y" or "z". The default value is "x".
		* @param	v	The texture vertical axis. Can be "x", "y" or "z". The default value is "y".
		*/
		public function projectTexture( u:String="x", v:String="y" ):void
		{
			var faces	:Array  = this.geometry.faces, 
				bBox	:Object = this.boundingBox(), 
				minX	:Number = bBox.min[u], 
				sizeX 	:Number = bBox.size[u],
				minY  	:Number = bBox.min[v],
				sizeY 	:Number = bBox.size[v];
	
			var objectMaterial :MaterialObject3D = this.material;
	
			for( var i:String in faces )
			{
				var myFace     :Triangle3D = faces[Number(i)],
					myVertices :Array  = myFace.vertices,
					a :Vertex3D = myVertices[0],
					b :Vertex3D = myVertices[1],
					c :Vertex3D = myVertices[2],
					uvA :NumberUV = new NumberUV( (a[u] - minX) / sizeX, (a[v] - minY) / sizeY ),
					uvB :NumberUV = new NumberUV( (b[u] - minX) / sizeX, (b[v] - minY) / sizeY ),
					uvC :NumberUV = new NumberUV( (c[u] - minX) / sizeX, (c[v] - minY) / sizeY );
	
				myFace.uv = [ uvA, uvB, uvC ];
			}
		}
	
		/**
		* Merges duplicated vertices.
		*/
		public function mergeVertices():void
		{
			var uniqueDic  :Dictionary = new Dictionary(),
				uniqueList :Array = new Array();
	
			// Find unique vertices
			for each( var v:Vertex3D in this.geometry.vertices )
			{
				for each( var vu:Vertex3D in uniqueDic )
				{
					if( v.x == vu.x && v.y == vu.y && v.z == vu.z )
					{
						uniqueDic[ v ] = vu;
						break;
					}
				}
				
				if( ! uniqueDic[ v ] )
				{
					uniqueDic[ v ] = v;
					uniqueList.push( v );
				}
			}
	
			// Use unique vertices list
			this.geometry.vertices = uniqueList;
	
			// Update faces
			for each( var f:Triangle3D in this.geometry.faces )
			{
				f.v0 = uniqueDic[ f.v0 ];
				f.v1 = uniqueDic[ f.v1 ];
				f.v2 = uniqueDic[ f.v2 ];
			}
		}
	}
}