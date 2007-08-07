/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org • blog.papervision3d.org • osflash.org/papervision3d
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
//                                                                 Face3D

package org.papervision3d.core.geom
{
import flash.display.*;
import flash.geom.Matrix;
	import flash.geom.Point;
import flash.utils.Dictionary;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.utils.InteractiveSprite;

/**
* The Face3D class lets you render linear textured triangles. It also supports solid colour fill and hairline outlines.
*
*/
public class Face3D
{
	/**
	* An array of Vertex3D objects for the three vertices of the triangle.
	*/
	public var vertices :Array;


	/**
	* A material id TODO
	*/
	public var materialName :String;


	/**
	* A MaterialObject3D object that contains the material properties of the back of a single sided triangle.
	*/
//	public var materialBack :MaterialObject3D;


	/**
	* An array of {x,y} objects for the corresponding UV pixel coordinates of each triangle vertex.
	*/
	public var uv :Array;

	// ______________________________________________________________________

	/**
	* [read-only] The average depth (z coordinate) of the transformed triangle. Also known as the distance from the camera. Used internally for z-sorting.
	*/
	public var screenZ :Number;

	/**
	* [read-only] A Boolean value that indicates that the face is visible, i.e. it's vertices are in front of the camera.
	*/
	public var visible :Boolean;


	/**
	* The object where the face belongs.
	*/
//	public var object :Mesh3D;


	/**
	* [read-only] Unique id of this instance.
	*/
	public var id :Number;
	
	/**
	 * Used to store references to the vertices.
	 */
	public var v0:Vertex3D;
	public var v1:Vertex3D;
	public var v2:Vertex3D;
	
	/**
	 * The face normal
	 */
	public var faceNormal:Number3D;
	
	/**
	 * The transformed Face3DInstance
	 */
	public var face3DInstance:Face3DInstance;
	
	/**
	* The Face3D constructor lets you create linear textured or solid colour triangles.
	*
	* @param	vertices	An array of Vertex3D objects for the three vertices of the triangle.
	* @param	material	A MaterialObject3D object that contains the material properties of the triangle.
	* @param	uv			An array of {x,y} objects for the corresponding UV pixel coordinates of each triangle vertex.
	*/
	public function Face3D( vertices:Array, materialName:String=null, uv:Array=null )
	{
		// Vertices
		this.vertices = vertices;
		v0 = vertices[0];
		v1 = vertices[1];
		v2 = vertices[2];
		
		
		// Material
		this.materialName = materialName;
		this.uv = uv;
		this.id = _totalFaces++;
		face3DInstance = new Face3DInstance(this);
		createNormal();
	}
	
	// ______________________________________________________________________________
	//                                                                         RENDER
	// RRRRR  EEEEEE NN  NN DDDDD  EEEEEE RRRRR
	// RR  RR EE     NNN NN DD  DD EE     RR  RR
	// RRRRR  EEEE   NNNNNN DD  DD EEEE   RRRRR
	// RR  RR EE     NN NNN DD  DD EE     RR  RR
	// RR  RR EEEEEE NN  NN DDDDD  EEEEEE RR  RR

	/**
	* Draws the triangle into its MovieClip container.
	*
	* @param	container	The default MovieClip that you draw into when rendering.
	* @param	randomFill		A Boolean value that indicates whether random coloring is enabled. Typically used for debug purposes. Defaults to false.
	* @return					The number of triangles drawn. Either one if it is double sided or visible, or zero if it single sided and not visible.
	*
	*/
	public function render( instance:DisplayObject3D, container:Sprite ): Number
	{
		var material:MaterialObject3D = ( this.materialName && instance.materials )? instance.materials.materialsByName[ this.materialName ] : instance.material;
		return material.drawFace3D(instance, this, container.graphics, v0.vertex2DInstance, v1.vertex2DInstance, v2.vertex2DInstance);
	}
	
	public function UVatPoint( x : Number, y : Number ) : Object 
	{	
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
	
	public function getCoordAtPoint( x : Number, y : Number ) : Vertex3D 
	{	
		var rUV : Object = UVatPoint(x,y);
        
		var u : Number = rUV.u;
		var v : Number = rUV.v;
        	
		var rX : Number = v0.x + ( v1.x - v0.x ) * v + ( v2.x - v0.x ) * u;
		var rY : Number = v0.y + ( v1.y - v0.y ) * v + ( v2.y - v0.y ) * u;
		var rZ : Number = v0.z + ( v1.z - v0.z ) * v + ( v2.z - v0.z ) * u;
        	
		return new Vertex3D(rX, rY, rZ);
	}
	
	public function getMapCoordAtPoint( x : Number, y : Number ) : Point 
	{
		var rUV : Object = UVatPoint(x,y);
		var u : Number = rUV.u;
		var v : Number = rUV.v;
        	
		var v_x : Number = ( uv[1].u - uv[0].u ) * v +  (uv[2].u - uv[0].u) * u + uv[0].u;
		var v_y : Number = ( uv[1].v - uv[0].v ) * v +  (uv[2].v - uv[0].v) * u + uv[0].v;
        	
		return new Point(v_x * face3DInstance.instance.material.bitmap.width, face3DInstance.instance.material.bitmap.height - v_y * face3DInstance.instance.material.bitmap.height );
	}
	
	/*
	private function getMapCoordAtPoint(displayObject:DisplayObject3D, material:BitmapMaterial):Point        
	{            
		var x:Number = displayObject.scene.container.mouseX;
		var y:Number = displayObject.scene.container.mouseY;            
		var face:Face3D = displayObject.geometry.faces[0];                            
		var UV : Object = UVatPoint(x, y, face);            
		var v_x : Number = (face.uv[1].u - face.uv[0].u) * UV.v +  (face.uv[2].u - face.uv[0].u) * UV.u + face.uv[0].u;            
		var v_y : Number = (face.uv[1].v - face.uv[0].v ) * UV.v + (face.uv[2].v - face.uv[0].v) * UV.u + face.uv[0].v;                        
		return new Point( v_x * material.texture.width, material.texture.height - v_y * material.texture.height );        
	}                
		
	private function UVatPoint(x:Number, y:Number, face:Face3D):Object        
	{                
		var v0_x : Number = face.v2.vertex2DInstance.x - face.v0.vertex2DInstance.x;            
		var v0_y : Number = face.v2.vertex2DInstance.y - face.v0.vertex2DInstance.y;            
		var v1_x : Number = face.v1.vertex2DInstance.x - face.v0.vertex2DInstance.x;            
		var v1_y : Number = face.v1.vertex2DInstance.y - face.v0.vertex2DInstance.y;            
		var v2_x : Number = x - face.v0.vertex2DInstance.x;            
		var v2_y : Number = y - face.v0.vertex2DInstance.y;                        
		var dot00 : Number = v0_x * v0_x + v0_y * v0_y;            
		var dot01 : Number = v0_x * v1_x + v0_y * v1_y;            
		var dot02 : Number = v0_x * v2_x + v0_y * v2_y;            
		var dot11 : Number = v1_x * v1_x + v1_y * v1_y;            
		var dot12 : Number = v1_x * v2_x + v1_y * v2_y;                        
		var invDenom : Number = 1 / (dot00 * dot11 - dot01 * dot01);            
		var u : Number = (dot11 * dot02 - dot01 * dot12) * invDenom;            
		var v : Number = (dot00 * dot12 - dot01 * dot02) * invDenom;                        
		return {u:u, v:v};        
	}   
	*/
		
	protected function createNormal():void
	{
		var vn0:Number3D = v0.toNumber3D();
		var vn1:Number3D = v1.toNumber3D();
		var vn2:Number3D = v2.toNumber3D();
		var vt1:Number3D = Number3D.sub(vn1,vn0);
		var vt2:Number3D = Number3D.sub(vn2,vn0);
		
		faceNormal = Number3D.cross(vt2,vt1);
		faceNormal.normalize();
	}
	
	// ______________________________________________________________________________
	//                                                                        PRIVATE

	private static var _totalFaces:Number = 0;
	
}
}