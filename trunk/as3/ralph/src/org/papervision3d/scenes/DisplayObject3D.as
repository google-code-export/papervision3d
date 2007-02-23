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
//                                                        DisplayObject3D

package org.papervision3d.scenes
{
import com.blitzagency.xray.logger.XrayLog;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.*;
import org.papervision3d.core.geom.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.materials.MaterialsList;

import flash.display.Sprite;
import flash.utils.Dictionary;

/**
* The DisplayObject3D class is at the root of the Papervision3D object class hierarchy.
* <p/>
* The DisplayObject3D class is the base class for all objects, not only those that can be rendered, but also the camera and its target. The Papervision3D class manages all objects displayed.
* <p/>
* The DisplayObject3D class supports basic functionality like the x, y and z position of an object, as well as rotationX, rotationY, rotationZ. It also supports more advanced properties of the object such as visible, and scaleX, scaleY and scaleZ.
* <p/>
* DisplayObject3D is not an abstract base class; therefore, you can call DisplayObject3D directly. Invoking new DisplayObject() creates a new empty object in 3D space, like when you createEmptyMovieClip(). All 3D display objects inherit from the DisplayObject class. You can create a custom subclass of the DisplayObject class, or also extend a subclass of the DisplayObject class.
* <p/>
* Some properties previously used in the ActionScript 1.0 and 2.0 MovieClip classes (such as _x, _y, _xscale, _yscale and others) have equivalents in the DisplayObject3D class that are renamed as in ActionScript 3.0, so that they no longer begin with the underscore (_) character.
* <p/>
* It serves as the prototype for classes that extend the DisplayObject3D class. These classes are in org.papervision3D.objects package.
*
*/
public class DisplayObject3D extends DisplayObjectContainer3D
{
	// ___________________________________________________________________________________________________
	//                                                                                     P O S I T I O N

	/**
	* An Number that sets the X coordinate of a object relative to the scene coordinate system.
	*/
	public function get x():Number
	{
		return this.transform.n14;
	}

	public function set x( value:Number ):void
	{
		this.transform.n14 = value;
	}


	/**
	* An Number that sets the Y coordinate of a object relative to the scene coordinates.
	*/
	public function get y():Number
	{
		return this.transform.n24;
	}

	public function set y( value:Number ):void
	{
		this.transform.n24 = value;
	}


	/**
	* An Number that sets the Z coordinate of a object relative to the scene coordinates.
	*/
	public function get z():Number
	{
		return this.transform.n34;
	}

	public function set z( value:Number ):void
	{
		this.transform.n34 = value;
	}


	// ___________________________________________________________________________________________________
	//                                                                                     R O T A T I O N

	/**
	* Specifies the rotation around the X axis from its original orientation.
	*/
	public function get rotationX():Number
	{
		if( this._rotationDirty ) updateRotation();

		return Papervision3D.useDEGREES? -this._rotationX * toDEGREES : -this._rotationX;
	}

	public function set rotationX( rot:Number ):void
	{
		this._rotationX = Papervision3D.useDEGREES? -rot * toRADIANS : -rot;
		this._transformDirty = true;
	}


	/**
	* Specifies the rotation around the Y axis from its original orientation.
	*/
	public function get rotationY():Number
	{
		if( this._rotationDirty ) updateRotation();

		return Papervision3D.useDEGREES? -this._rotationY * toDEGREES : -this._rotationY;
	}

	public function set rotationY( rot:Number ):void
	{
		this._rotationY = Papervision3D.useDEGREES? -rot * toRADIANS : -rot;
		this._transformDirty = true;
	}


	/**
	* Specifies the rotation around the Z axis from its original orientation.
	*/
	public function get rotationZ():Number
	{
		if( this._rotationDirty ) updateRotation();

		return Papervision3D.useDEGREES? -this._rotationZ * toDEGREES : -this._rotationZ;
	}

	public function set rotationZ( rot:Number ):void
	{
		this._rotationZ = Papervision3D.useDEGREES? -rot * toRADIANS : -rot;
		this._transformDirty = true;
	}


	// Update rotation values
	private function updateRotation():void
	{
		var rot:Number3D = Matrix3D.matrix2euler( this.transform );
		this._rotationX = rot.x * toRADIANS;
		this._rotationY = rot.y * toRADIANS;
		this._rotationZ = rot.z * toRADIANS;

		this._rotationDirty = false;
	}

	// ___________________________________________________________________________________________________
	//                                                                                           S C A L E

	/**
	* Sets the 3D scale as applied from the registration point of the object.
	*/
	//public function get scale():Number
	//{
		//if( this._scaleX == this._scaleY && this._scaleX == this._scaleZ )
			//if( Papervision3D.usePERCENT ) return this._scaleX * 100;
			//else return this._scaleX;
		//else return NaN;
	//}

	public function set scale( scale:Number ):void
	{
		if( Papervision3D.usePERCENT ) scale /= 100;

		this._scaleX = this._scaleY = this._scaleZ = scale;

		this._transformDirty = true;
	}


	/**
	* Sets the scale along the local X axis as applied from the registration point of the object.
	*/
	//public function get scaleX():Number
	//{
		//if( Papervision3D.usePERCENT ) return this._scaleX * 100;
		//else return this._scaleX;
	//}

	public function set scaleX( scale:Number ):void
	{
		if( Papervision3D.usePERCENT ) this._scaleX = scale / 100;
		else this._scaleX = scale;

		this._transformDirty = true;
	}

	/**
	* Sets the scale along the local Y axis as applied from the registration point of the object.
	*/
	//public function get scaleY():Number
	//{
		//if( Papervision3D.usePERCENT ) return this._scaleY * 100;
		//else return this._scaleY;
	//}

	public function set scaleY( scale:Number ):void
	{
		if( Papervision3D.usePERCENT ) this._scaleY = scale / 100;
		else this._scaleY = scale;

		this._transformDirty = true;
	}

	/**
	* Sets the scale along the local Z axis as applied from the registration point of the object.
	*/
	//public function get scaleZ():Number
	//{
		//if( Papervision3D.usePERCENT ) return this._scaleZ * 100;
		//else return this._scaleZ;
	//}

	public function set scaleZ( scale:Number ):void
	{
		if( Papervision3D.usePERCENT ) this._scaleZ = scale / 100;
		else this._scaleZ = scale;

		this._transformDirty = true;
	}


	/**
	* Whether or not the display object is visible.
	* <p/>
	* A Boolean value that indicates whether the object is projected, transformed and rendered. A value of false will effectively ignore the object. The default value is true.
	*/
	public var visible :Boolean;


	/**
	* An optional object name.
	*/
	public var name :String;

	/**
	* [read-only] Unique id of this instance.
	*/
	public var id :int;


	/**
	* An object that contains user defined properties.
	* <p/>
	* All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	*/
	public var extra :Object // = {}; TBD

	/**
	* The MovieClip that you draw into when rendering. Use only when the object is rendered in its own unique MovieClip.
	*/

	public var container   :Sprite;

	public var material    :MaterialObject3D;

	public var materials   :MaterialsList;


	/**
	* The scene where the object belongs.
	*/
	public var scene :SceneObject3D;

	/**
	* A Boolean value that indicates whether random coloring is enabled. Typically used for debug purposes. Defaults to false.
	*/
	public var showFaces :Boolean;

	/**
	* A Boolean value that determines whether the object's triagles are z-depth sorted between themselves when rendering.
	*/
	public var sortFaces :Boolean;

	/**
	* Returns a DiplayObject3D object positioned in the center of the 3D coordinate system (0, 0 ,0).
	*/
	static public function get ZERO():DisplayObject3D
	{
		return new DisplayObject3D();
	}

	/**
	* Relative directions.
	*/
	static private var FORWARD  :Number3D = new Number3D(  0,  0,  1 );
	static private var BACKWARD :Number3D = new Number3D(  0,  0, -1 );
	static private var LEFT     :Number3D = new Number3D( -1,  0,  0 );
	static private var RIGHT    :Number3D = new Number3D(  1,  0,  0 );
	static private var UP       :Number3D = new Number3D(  0,  1,  0 );
	static private var DOWN     :Number3D = new Number3D(  0, -1,  0 );

	public var transform :Matrix3D;
	public var view      :Matrix3D;

	public var projected :Dictionary;
	public var faces     :Array = new Array();

	public var geometry :GeometryObject3D;

	/**
	* [internal-use] The depth (z coordinate) of the transformed object's center. Also known as the distance from the camera. Used internally for z-sorting.
	*/
	public var screenZ :Number;

	// ___________________________________________________________________________________________________
	//                                                                                               N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* The DisplayObject3D constructor lets you create generic 3D objects.
	*
	* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created DisplayObject3D.
	*
	* <ul>
	* <li><b>x</b></b>: An Number that sets the X coordinate of a object relative to the scene coordinate system.</li>
	* <p/>
	* <li><b>y</b>: An Number that sets the Y coordinate of a object relative to the scene coordinate system.</li>
	* <p/>
	* <li><b>z</b>: An Number that sets the Z coordinate of a object relative to the scene coordinate system.</li>
	* <p/>
	* <li><b>rotationX</b>: Specifies the rotation around the X axis from its original orientation.</li>
	* <p/>
	* <li><b>rotationY</b>: Specifies the rotation around the Y axis from its original orientation.</li>
	* <p/>
	* <li><b>rotationZ</b>: Specifies the rotation around the Z axis from its original orientation.</li>
	* <p/>
	* <li><b>scaleX</b>: Sets the scale along the local X axis as applied from the registration point of the object.</li>
	* <p/>
	* <li><b>scaleY</b>: Sets the scale along the local Y axis as applied from the registration point of the object.</li>
	* <p/>
	* <li><b>scaleZ</b>: Sets the scale along the local Z axis as applied from the registration point of the object.</li>
	* <p/>
	* <li><b>visible</b>: Whether or not the display object is visible.
	* <p/>
	* A Boolean value that indicates whether the object is projected, transformed and rendered. A value of false will effectively ignore the object. The default value is true.</li>
	* <p/>
	* <li><b>container</b>: The MovieClip that you draw into when rendering. Use only when the object is rendered in its own unique MovieClip.
	* <p/>
	* It's Boolean value determines whether the container MovieClip should be cleared before rendering.</li>
	* <p/>
	* <li><b>extra</b>: An object that contains user defined properties.
	* <p/>
	* All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.</li>
	* </ul>
	*/
	public function DisplayObject3D( name:String=null, geometry:GeometryObject3D=null, initObject:Object=null ):void
	{
		super();

		Papervision3D.log( "DisplayObject3D: " + name );

		this.transform = Matrix3D.IDENTITY;
		this.view      = Matrix3D.IDENTITY;

		// TODO if( initObject )...
		this.x = initObject? initObject.x || 0 : 0;
		this.y = initObject? initObject.y || 0 : 0;
		this.z = initObject? initObject.z || 0 : 0;

		rotationX = initObject? initObject.rotationX || 0 : 0;
		rotationY = initObject? initObject.rotationY || 0 : 0;
		rotationZ = initObject? initObject.rotationZ || 0 : 0;

		var scaleDefault:Number = Papervision3D.usePERCENT? 100 : 1;
		scaleX = initObject? initObject.scaleX || scaleDefault : scaleDefault;
		scaleY = initObject? initObject.scaleY || scaleDefault : scaleDefault;
		scaleZ = initObject? initObject.scaleZ || scaleDefault : scaleDefault;

		if( initObject && initObject.extra ) this.extra = initObject.extra;
		if( initObject && initObject.container ) this.container = initObject.container;

		this.visible = true;

		this.id = _totalDisplayObjects++;
		this.name = name || String( this.id );

		this.sortFaces = initObject? (initObject.sortFaces != false) : true;
		this.showFaces = initObject? initObject.showFaces || false : false;

		if( geometry ) addGeometry( geometry );
	}

	// ___________________________________________________________________________________________________
	//                                                                                           U T I L S

	public function addGeometry( geometry:GeometryObject3D ):void
	{
		this.geometry = geometry;

		if( geometry.material )
			this.material = geometry.material.clone();

		if( geometry.materials )
			this.materials = geometry.materials.clone();

		this.projected = new Dictionary();
	}

	// ___________________________________________________________________________________________________
	//                                                                                   C O L L I S I O N

	public function distanceTo( obj:DisplayObject3D ):Number
	{
		var x :Number = this.x - obj.x;
		var y :Number = this.y - obj.y;
		var z :Number = this.z - obj.z;

		return Math.sqrt( x*x + y*y + z*z );
	}


	public function hitTestPoint( x:Number, y:Number, z:Number ):Boolean
	{
		var dx :Number = this.x - x;
		var dy :Number = this.y - y;
		var dz :Number = this.z - z;

		var d2 :Number = x*x + y*y + z*z;

		var sA :Number = this.geometry? this.geometry.boundingSphere2 : 0;

		return sA > d2;
	}


	// TODO: Use group boundingSphere
	public function hitTestObject( obj:DisplayObject3D ):Boolean
	{
		var dx :Number = this.x - obj.x;
		var dy :Number = this.y - obj.y;
		var dz :Number = this.z - obj.z;

		var d2 :Number = dx*dx + dy*dy + dz*dz;

		var sA :Number = this.geometry? this.geometry.boundingSphere2 : 0;
		var sB :Number = obj.geometry?  obj.geometry.boundingSphere2  : 0;

		return sA + sB > d2;
	}

	// ___________________________________________________________________________________________________
	//                                                                                   M A T E R I A L S

	// TODO: Recursive
	public function getMaterialByName( name:String ):MaterialObject3D
	{
		var material:MaterialObject3D = this.materials.getMaterialByName( name );

		if( material )
			return material;
		else
			for each( var child :DisplayObject3D in this._childrenByName )
			{
				material = child.getMaterialByName( name );

				if( material ) return material;
			}

		return null;
	}

	// TODO: Recursive
	public function materialsList():String
	{
		var list:String = ">>";

		for( var name:String in this.materials )
			list += name + "\n";

		for each( var child :DisplayObject3D in this._childrenByName )
		{
			for( name in child.materials.materialsByName )
				list += "+ " + name + "\n";
		}

		return list;
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
	* <p/>
	* This is the first step in the process of representing three dimensional shapes two dimensionally.
	*
	* @param	camera	Camera3D object to render from.
	*/
	public function project( parent :DisplayObject3D, camera :CameraObject3D, sorted :Array=null ):Number
	{
		if( ! sorted ) this._sorted = sorted = new Array();

		if( this._transformDirty ) updateTransform();

		this.view = Matrix3D.multiply( parent.view, this.transform ); // TODO: OPTIMIZE (MED) Inline this

		var screenZs :Number = 0;
		var children :Number = 0;

		for each( var child:DisplayObject3D in this._childrenByName )
		{
			screenZs += child.project( this, camera, sorted );
			children++;
		}

		if( geometry )
		{
			screenZs += geometry.project( this, camera, sorted );
			children++;
		}

		return this.screenZ = screenZs / children;
	}


	// ___________________________________________________________________________________________________
	//                                                                                         R E N D E R
	// RRRRR  EEEEEE NN  NN DDDDD  EEEEEE RRRRR
	// RR  RR EE     NNN NN DD  DD EE     RR  RR
	// RRRRR  EEEE   NNNNNN DD  DD EEEE   RRRRR
	// RR  RR EE     NN NNN DD  DD EE     RR  RR
	// RR  RR EEEEEE NN  NN DDDDD  EEEEEE RR  RR

	/**
	* Render object.
	*
	* @param	scene	Stats object to update.
	*/
	public function render( scene :SceneObject3D ):void
	{
		var iFaces :Array = this._sorted;

		iFaces.sortOn( 'screenZ', Array.DESCENDING | Array.NUMERIC );

		// Render
		var container :Sprite = this.container || scene.container;
		var rendered  :Number = 0;
		var iFace     :Object;

		for( var i:int = 0; iFace = iFaces[i]; i++ )
		{
			if( iFace.visible )
				rendered += iFace.face.render( iFace.instance, container );
		}

		// Update stats
		scene.stats.rendered += rendered;
	}

	// ___________________________________________________________________________________________________
	//                                                                     L O C A L   T R A N S F O R M S
	// LL      OOOO   CCCC    AA   LL
	// LL     OO  OO CC  CC  AAAA  LL
	// LL     OO  OO CC     AA  AA LL
	// LL     OO  OO CC  CC AAAAAA LL
	// LLLLLL  OOOO   CCCC  AA  AA LLLLLL

	public function moveForward  ( distance:Number ):void { translate( distance, FORWARD  ); }
	public function moveBackward ( distance:Number ):void { translate( distance, BACKWARD ); }
	public function moveLeft     ( distance:Number ):void { translate( distance, LEFT     ); }
	public function moveRight    ( distance:Number ):void { translate( distance, RIGHT    ); }
	public function moveUp       ( distance:Number ):void { translate( distance, UP       ); }
	public function moveDown     ( distance:Number ):void { translate( distance, DOWN     ); }

	// ___________________________________________________________________________________________________
	//                                                                   L O C A L   T R A N S L A T I O N

	public function translate( distance:Number, axis:Number3D ):void
	{
		var vector:Number3D = axis.clone();

		if( this._transformDirty ) updateTransform();

		Matrix3D.rotateAxis( transform, vector )

		this.x += distance * vector.x;
		this.y += distance * vector.y;
		this.z += distance * vector.z;
	}

	// ___________________________________________________________________________________________________
	//                                                                         L O C A L   R O T A T I O N

	public function pitch( angle:Number ):void
	{
		angle = Papervision3D.useDEGREES? angle * toRADIANS : angle;

		var vector:Number3D = RIGHT.clone();

		if( this._transformDirty ) updateTransform();

		Matrix3D.rotateAxis( transform, vector );
		var m:Matrix3D = Matrix3D.rotationMatrix( vector.x, vector.y, vector.z, angle );

		this.transform.copy3x3( Matrix3D.multiply3x3( m ,transform ) );

		this._rotationDirty = true;
	}


	public function yaw( angle:Number ):void
	{
		angle = Papervision3D.useDEGREES? angle * toRADIANS : angle;

		var vector:Number3D = UP.clone();

		if( this._transformDirty ) updateTransform();

		Matrix3D.rotateAxis( transform, vector );
		var m:Matrix3D = Matrix3D.rotationMatrix( vector.x, vector.y, vector.z, angle );

		this.transform.copy3x3( Matrix3D.multiply3x3( m ,transform ) );

		this._rotationDirty = true;
	}


	public function roll( angle:Number ):void
	{
		angle = Papervision3D.useDEGREES? angle * toRADIANS : angle;

		var vector:Number3D = FORWARD.clone();

		if( this._transformDirty ) updateTransform();

		Matrix3D.rotateAxis( transform, vector );
		var m:Matrix3D = Matrix3D.rotationMatrix( vector.x, vector.y, vector.z, angle );

		this.transform.copy3x3( Matrix3D.multiply3x3( m ,transform ) );

		this._rotationDirty = true;
	}


	public function lookAt( targetObject:DisplayObject3D, upAxis:Number3D=null ):void
	{
		var position :Number3D = new Number3D( this.x, this.y, this.z );
		var target   :Number3D = new Number3D( targetObject.x, targetObject.y, targetObject.z );

		var zAxis    :Number3D = Number3D.sub( target, position );
		zAxis.normalize();

		if( zAxis.modulo > 0.1 )
		{
			var xAxis :Number3D = Number3D.cross( zAxis, upAxis || UP );
			xAxis.normalize();

			var yAxis :Number3D = Number3D.cross( zAxis, xAxis );
			yAxis.normalize();

			var look  :Matrix3D = this.transform;

			look.n11 = xAxis.x;
			look.n21 = xAxis.y;
			look.n31 = xAxis.z;

			look.n12 = -yAxis.x;
			look.n22 = -yAxis.y;
			look.n32 = -yAxis.z;

			look.n13 = zAxis.x;
			look.n23 = zAxis.y;
			look.n33 = zAxis.z;

			this._transformDirty = false;
			this._rotationDirty = true;
			// TODO: Implement scale
		}
		else
		{
			var log:XrayLog = new XrayLog();
			log.debug( "lookAt Error" );
		}
	}

	// ___________________________________________________________________________________________________
	//                                                                                   T R A N S F O R M
	// TTTTTT RRRRR    AA   NN  NN  SSSSS FFFFFF OOOO  RRRRR  MM   MM
	//   TT   RR  RR  AAAA  NNN NN SS     FF    OO  OO RR  RR MMM MMM
	//   TT   RRRRR  AA  AA NNNNNN  SSSS  FFFF  OO  OO RRRRR  MMMMMMM
	//   TT   RR  RR AAAAAA NN NNN     SS FF    OO  OO RR  RR MM M MM
	//   TT   RR  RR AA  AA NN  NN SSSSS  FF     OOOO  RR  RR MM   MM

	public function copyPosition( reference:DisplayObject3D ):void
	{
		this.transform.n14 = reference.transform.n14;
		this.transform.n24 = reference.transform.n24;
		this.transform.n34 = reference.transform.n34;
	}


	public function copyTransform( reference:* ):void
	{
		var trans  :Matrix3D = this.transform;
		var matrix :Matrix3D = (reference is DisplayObject3D)? reference.transform : reference;

		trans.n11 = matrix.n11;		trans.n12 = matrix.n12;
		trans.n13 = matrix.n13;		trans.n14 = matrix.n14;

		trans.n21 = matrix.n21;		trans.n22 = matrix.n22;
		trans.n23 = matrix.n23;		trans.n24 = matrix.n24;

		trans.n31 = matrix.n31;		trans.n32 = matrix.n32;
		trans.n33 = matrix.n33;		trans.n34 = matrix.n34;

		this._transformDirty = false;
		this._rotationDirty  = true;
	}


	// TODO OPTIMIZE (HIGH)
	public function updateTransform():void
	{
		var q:Object = Matrix3D.euler2quaternion( -this._rotationY, -this._rotationZ, this._rotationX ); // Swapped

		var m:Matrix3D = Matrix3D.quaternion2matrix( q.x, q.y, q.z, q.w );

		var transform:Matrix3D = this.transform;

		m.n14 = transform.n14;
		m.n24 = transform.n24;
		m.n34 = transform.n34;

		transform.copy( m );

		// Scale
		var scaleM:Matrix3D = Matrix3D.IDENTITY;
		scaleM.n11 = this._scaleX;
		scaleM.n22 = this._scaleY;
		scaleM.n33 = this._scaleZ;

		this.transform = Matrix3D.multiply( transform, scaleM );

		this._transformDirty = false;
	}


	// ___________________________________________________________________________________________________

	/**
	* Returns a string value representing the three-dimensional values in the specified Number3D object.
	*
	* @return	A string.
	*/
	public override function toString(): String
	{
		return this.name + ': x:' + Math.round(this.x) + ' y:' + Math.round(this.y) + ' z:' + Math.round(this.z);
	}

	// ___________________________________________________________________________________________________
	//                                                                                       P R I V A T E

	protected var _transformDirty :Boolean = false;
	protected var _rotationDirty  :Boolean = false;
	protected var _scaleDirty     :Boolean = false;

	protected var _rotationX   :Number;
	protected var _rotationY   :Number;
	protected var _rotationZ   :Number;

	protected var _scaleX      :Number;
	protected var _scaleY      :Number;
	protected var _scaleZ      :Number;

	protected var _sorted      :Array;

	static private var _totalDisplayObjects :int = 0;

	static private var toDEGREES :Number = 180/Math.PI;
	static private var toRADIANS :Number = Math.PI/180;
}
}