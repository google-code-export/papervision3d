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
//                                                                Collada

package org.papervision3d.core.utils
{
import flash.display.*;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.*;

import org.papervision3d.*;
import org.papervision3d.core.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.core.geom.*;
import org.papervision3d.events.FileLoadEvent;
import org.papervision3d.scenes.*;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.materials.*;

/**
* The Collada class lets you load and parse Collada scenes.
* <p/>
* Recommended DCC Settings:
* <ul><li><b>Maya</b>:
* <ul><li>General Export Options
* <ul><li>Relative Paths, Triangulate.</li></ul>
* <li>Filter Export
* <ul><li>Polygon meshes, Normals, Texture Coordinates.</li></ul>
* </li></ul>
* <li><b>3DS Max</b>:
* <ul><li>Standard Options
* <ul><li>Relative Paths.</li></ul>
* <li>Geometry
* <ul><li>Normals, Triangulate.</li></ul>
* </li></ul>
*/
public class Collada extends EventDispatcher
{
	/**
	* Default scaling value for constructor.
	*/
	static public var DEFAULT_SCALING  :Number = 1;

	/**
	* Internal scaling value.
	*/
	static private var INTERNAL_SCALING :Number = 100;

	// ___________________________________________________________________________________________________
	//                                                                                               N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* Creates a new Collada object.
	* <p/>
	* The Collada class lets you load and parse a Collada mesh.
	* <p/>
	* COLLADA is a COLLAborative Design Activity for establishing an interchange file format for interactive 3D applications.
	* <p/>
	* COLLADA defines an open standard XML schema for exchanging digital assets among various container software applications that might otherwise store their assets in incompatible formats.
	* <p/>
	* COLLADA documents that describe digital assets are XML files, usually identified with a .dae (digital asset exchange) filename extension.
	* <p/>
	* Only the geometry and mapping of one mesh is currently parsed. As usual, the texture is specified in the material object.
	* <p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	* <p/>
	* @param	filename	Filename of the .ASE object to parse.
	* <p/>
	* @param	scale		Scaling factor. Max = 100. Maya =
	* <p/>
	* @param	callback	Function callback that's called when the file is loaded and parsed.
	* <p/>
	*/

	public function Collada( container:DisplayObjectContainer3D, filename:String, materials :MaterialsList=null, scale:Number=1, callback:Function=null, initObject:Object=null )
	{
		this._container = container;
		this._filename  = filename;
		this._materials = materials;

		this._scaling  = scale || DEFAULT_SCALING;
		this._scaling *= INTERNAL_SCALING;

		this._callback = callback;

		this._geometries = new Object();

		loadCollada();
	}

	// _______________________________________________________________________ PRIVATE

	private function loadCollada():void
	{
		this._loader = new URLLoader();
		this._loader.addEventListener( Event.COMPLETE, onComplete );
		this._loader.load( new URLRequest( this._filename ) );
	}


	private function onComplete(evt:Event):void
	{
		COLLADA = new XML( this._loader.data );

		buildCollada();
	}

	// _______________________________________________________________________


	private function buildCollada():void
	{
		default xml namespace = COLLADA.namespace();

		// Get up axis
		this._yUp = (COLLADA.asset.up_axis == "Y_UP");

		// Parse first scene
		var sceneId:String = getId( COLLADA.scene.instance_visual_scene.@url );

		var scene:XML = COLLADA.library_visual_scenes.visual_scene.(@id == sceneId)[0];

		parseScene( scene );

		var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_COMPLETE, _filename );
		this.dispatchEvent( fileEvent );
	}


	// _______________________________________________________________________ parseScene

	private function parseScene( scene:XML ):void
	{
		for each( var node:XML in scene.node )
			parseNode( node, this._container );
	}

	// _______________________________________________________________________ parseNode

	private function parseNode( node:XML, parent:DisplayObjectContainer3D ):void
	{
		var matrix :Matrix3D = Matrix3D.IDENTITY;

		//if( ! this._yUp && parent == this._container )
		//{
			//matrix = Matrix3D.rotationX( Math.PI/2 );
			//matrix = Matrix3D.multiply( matrix, Matrix3D.rotationZ( Math.PI ) );
		//}

		var newNode:DisplayObject3D;

		if( String( node.instance_geometry ) == "" )
			newNode = new DisplayObject3D( node.@name );
		else
			newNode = new Mesh3D( null, null, null, node.@name );


		var instance :DisplayObject3D = parent.addChild( newNode, node.@name );

		var children      :XMLList  = node.children();
		var totalChildren :int      = children.length();

		for( var i:int = 0; i < totalChildren; i++ )
		{
			var child:XML = children[i];

			switch( child.name().localName )
			{
				case "translate":
					matrix = Matrix3D.multiply( matrix, translateMatrix( getArray( child ) ) );
					break;

				case "rotate":
					matrix = Matrix3D.multiply( matrix, rotateMatrix( getArray( child ) ) );
					break;

				case "scale":
					matrix = Matrix3D.multiply( matrix, scaleMatrix( getArray( child ) ) );
					break;

				// Baked transform matrix
				case "matrix":
					matrix = Matrix3D.multiply( matrix, new Matrix3D( getArray( child ) ) );
					break;

				case "node":
					parseNode( child, instance );
					break;

				case "instance_geometry":
					for each( var geometry:XML in child )
					{
						var geoId:String = getId( geometry.@url );
						var geo:XML = COLLADA.library_geometries.geometry.(@id == geoId)[0];
						parseGeometry( geo, instance, Matrix3D.clone( matrix ) );
					}
					break;
			}
		}

		instance.copyTransform( matrix );
	}

	// _______________________________________________________________________ parseGeometry

	private function parseGeometry( geometry:XML, instance:DisplayObject3D, matrix2:Matrix3D=null ):void
	{
		var matrix:Matrix3D = Matrix3D.clone( matrix2 ) || Matrix3D.IDENTITY; // TODO: Cleanup

		// DEBUG
		//trace( "parseGeometry: " + geometry.@id ); // DEBUG

		// Semantics
		var semantics :Object = new Object();
		semantics.name = geometry.@id;

		var faces:Array = semantics.triangles = new Array();

		// Multi material
		var multiMaterial:Boolean = (geometry.mesh.triangles.length() > 1);

		// Triangles
		for each( var triangles:XML in geometry.mesh.triangles )
		{
			// Input
			var field:Array = new Array();

			for each( var input:XML in triangles.input )
			{
				semantics[ input.@semantic ] = deserialize( input, geometry );
				field.push( input.@semantic );
			}

			var data     :Array  = triangles.p.split(' ');
			var len      :Number = triangles.@count;
			var material :String = triangles.@material;

			// DEBUG
			//trace( "triangles: " + len );
			addMaterial( instance, material );

			for( var j:Number = 0; j < len; j++ )
			{
				var t:Object = new Object();

				for( var v:Number = 0; v < 3; v++ )
				{
					var fld:String;
					for( var k:Number = 0; fld = field[k]; k++ )
					{
						if( ! t[ fld ] ) t[ fld ] = new Array();

						t[ fld ].push( Number( data.shift() ) );
					}

					t["material"] = material; //multiMaterial? material : null;
				}
				faces.push( t );
			}
		}

		buildObject( semantics, instance, matrix );
	}


	// _______________________________________________________________________ buildObject


	private function buildObject( semantics:Object, instance:DisplayObject3D, matrix:Matrix3D=null ):void
	{
		matrix = matrix || Matrix3D.IDENTITY;

//		var mesh :Mesh3D = new Mesh3D( null, new Array(), new Array() )
		instance.addGeometry( new GeometryObject3D() );

		// Vertices
		var vertices :Array    = instance.geometry.vertices = new Array();
		var scaling  :Number   = this._scaling;
		var accVerts :Number   = vertices.length;

		var semVertices :Array = semantics.VERTEX;
		var len:Number = semVertices.length;

		// DEBUG
		//trace( "Vertices: " + len );

		var i:int;
		for( i=0; i < len; i++ )
		{
			// Swap z & y for Max (to make Y up and Z depth)
			var vert:Object = semVertices[ i ];
			var x :Number = Number( vert.X ) * scaling;
			var y :Number = Number( vert.Y ) * scaling;
			var z :Number = Number( vert.Z ) * scaling;

			if( this._yUp )
				vertices.push( new Vertex3D( -x, y, z ) );
			else
				vertices.push( new Vertex3D(  x, z, y ) );
		}

		// Faces
		var faces    :Array = instance.geometry.faces = new Array();
		var semFaces :Array = semantics.triangles;
		len = semFaces.length;

		// DEBUG
		//trace( "Faces: " + len );

		for( i=0; i < len; i++ )
		{
			// Triangle
			var tri :Array = semFaces[i].VERTEX;
			var a   :Vertex3D = vertices[ accVerts + tri[ 0 ] ];
			var b   :Vertex3D = vertices[ accVerts + tri[ 1 ] ];
			var c   :Vertex3D = vertices[ accVerts + tri[ 2 ] ];

			var faceList :Array = [ a, b, c ];

			var tex :Array = semantics.TEXCOORD;
			var uv  :Array = semFaces[i].TEXCOORD;

			var uvList :Array, uvA :NumberUV, uvB :NumberUV, uvC :NumberUV;

			if( uv && tex )
			{
				uvA = new NumberUV( tex[ uv[0] ].S, tex[ uv[0] ].T );
				uvB = new NumberUV( tex[ uv[1] ].S, tex[ uv[1] ].T );
				uvC = new NumberUV( tex[ uv[2] ].S, tex[ uv[2] ].T );

				uvList = [ uvA, uvB, uvC ];
			}
			else uvList = null;

			var materialName:String = semFaces[i].material || null;

			var face:Face3D = new Face3D( faceList, materialName, uvList );
			faces.push( face );
		}

		// Activate object
//		instance.materials = instance.materials.clone();
		instance.geometry.ready = true;

		matrix.n14 *= scaling;
		matrix.n24 *= scaling;
		matrix.n34 *= scaling;

		instance.material = new ColorMaterial( 0xFF0000, 0.25 );

		instance.visible  = true;
	}


	private function getArray( spaced:String ):Array
	{
		var strings :Array = spaced.split(" ");
		var numbers :Array = new Array();

		var totalStrings:Number = strings.length;

		for( var i:Number=0; i < totalStrings; i++ )
			numbers[i] = Number( strings[i] );

		return numbers;
	}


	private function addMaterial( instance:DisplayObject3D, name:String ):void
	{
		//trace( "Collada: addMaterial: " + instance.name + " > " + name ); // DEBUG
		var material:MaterialObject3D = this._materials.getMaterialByName( name );

		// Use default material if no material provided.
		if( ! material )
		{
			material = new WireframeMaterial( Math.random() * 0xFFFFFF );
			material.name = name;
			material.fillAlpha = 1;
			material.fillColor = 0;
			material.oneSide = true;

			Papervision3D.log( "Collada material " + name + " not found." ); // TODO: WARNING
		}

		if( ! instance.materials ) instance.materials = new MaterialsList();

		instance.materials.addMaterial( material, name );
	}


	// _______________________________________________________________________
	//                                                                Matrices

	private function rotateMatrix( vector:Array ):Matrix3D
	{
		if( this._yUp )
			return Matrix3D.rotationMatrix( vector[0], vector[1], vector[2], -vector[3] *toRADIANS );
		else
			return Matrix3D.rotationMatrix( vector[0], vector[2], vector[1], -vector[3] *toRADIANS );
	}


	private function translateMatrix( vector:Array ):Matrix3D
	{
		if( this._yUp )
			return Matrix3D.translationMatrix( -vector[0] *this._scaling, vector[1] *this._scaling, vector[2] *this._scaling );
		else
			return Matrix3D.translationMatrix(  vector[0] *this._scaling, vector[2] *this._scaling, vector[1] *this._scaling );
	}


	private function scaleMatrix( vector:Array ):Matrix3D
	{
		if( this._yUp )
			return Matrix3D.scaleMatrix( vector[0], vector[1], vector[2] );
		else
			return Matrix3D.scaleMatrix( vector[0], vector[2], vector[1] );
	}


	// _______________________________________________________________________
	//                                                                     XML

	private function deserialize( input:XML, geo:XML ):Array
	{
		var output :Array = new Array();
		var id     :String = input.@source.split("#")[1];

		// Source?
		var acc:XMLList = geo..source.(@id == id).technique_common.accessor;

		if( acc != new XMLList() )
		{
			// Build source floats array
			var floId  :String  = acc.@source.split("#")[1];
			var floXML :XMLList = COLLADA..float_array.(@id == floId);
			var floStr :String  = floXML.toString();
			var floats :Array   = floStr.split(" ");

			// Build params array
			var params :Array = new Array();

			for each( var par:XML in acc.param )
				params.push( par.@name );

			// Build output array
			var count  :int = acc.@count;
			var stride :int = acc.@stride;

			for( var i:int=0; i < count; i++ )
			{
				var element :Object = new Object();

				for( var j:int=0; j < stride; j++ )
					element[ params[j] ] = floats.shift();

				//for( j=0; j < stride; j++ ) trace( params[j] + " " + element[ params[j] ] ); // DEBUG

				output.push( element );
			}
		}
		else
		{
			// Store indexes if no source
			var recursive :XMLList = geo..vertices.(@id == id)[INPUTTAG];

			output = deserialize( recursive[0], geo );
		}

		return output;
	}


	private function getId( url:String ):String
	{
		return url.split("#")[1];
	}

	// _______________________________________________________________________
	//                                                       COLLADA tag names

	private static var COLLADASECTION  :String = "COLLADA";
	private static var LIBRARYSECTION  :String = "library";
	private static var ASSETSECTION    :String = "asset";
	private static var SCENESECTION    :String = "scene";

	private static var LIGHTPREFAB     :String = "light";
	private static var CAMERAPREFAB    :String = "camera";
	private static var MATERIALSECTION :String = "material";
	private static var GEOMETRYSECTION :String = "geometry";

	private static var MESHSECTION     :String = "mesh";
	private static var SOURCESECTION   :String = "source";
	private static var ARRAYSECTION    :String = "array";
	private static var ACCESSORSECTION :String = "accessor";
	private static var VERTICESSECTION :String = "vertices";
	private static var INPUTTAG        :String = "input";
	private static var POLYGONSSECTION :String = "polygons";
	private static var POLYGON         :String = "p";
	private static var NODESECTION     :String = "node";
	private static var LOOKATNODE      :String = "lookat";
	private static var MATRIXNODE      :String = "matrix";
	private static var PERSPECTIVENODE :String = "perspective";
	private static var ROTATENODE      :String = "rotate";
	private static var SCALENODE       :String = "scale";
	private static var TRANSLATENODE   :String = "translate";
	private static var SKEWNODE        :String = "skew";
	private static var INSTANCENODE    :String = "instance";
	private static var INSTACESCENE    :String = "instance_visual_scene";

	private static var PARAMTAG        :String = "param";

	private static var POSITIONINPUT   :String = "POSITION";
	private static var VERTEXINPUT     :String = "VERTEX";
	private static var NORMALINPUT     :String = "NORMAL";
	private static var TEXCOORDINPUT   :String = "TEXCOORD";
	private static var UVINPUT         :String = "UV";
	private static var TANGENTINPUT    :String = "TANGENT";

	// _______________________________________________________________________

	private var COLLADA     :XML;
	private var _container  :DisplayObjectContainer3D;
	private var _geometries :Object;

	private var _loader     :URLLoader;

	private var _filename   :String;
	private var _materials  :MaterialsList;
	private var _scaling    :Number;
	private var _callback   :Function;

	private var _yUp        :Boolean;

	static private var toDEGREES :Number = 180/Math.PI;
	static private var toRADIANS :Number = Math.PI/180;
}
}