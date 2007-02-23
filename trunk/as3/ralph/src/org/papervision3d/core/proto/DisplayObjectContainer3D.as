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
//                                               DisplayObjectContainer3D

package org.papervision3d.core.proto
{
import org.papervision3d.Papervision3D;
import org.papervision3d.scenes.*;
import org.papervision3d.materials.MaterialsList;
import org.papervision3d.core.utils.Collada;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class DisplayObjectContainer3D extends EventDispatcher
{
	/**
	* The MovieClip that you draw into when rendering. Use only when the object is rendered in its own unique MovieClip.
	*/
	public function get numChildren():int
	{
		return this._childrenTotal;
	}

	// ___________________________________________________________________________________________________
	//                                                                                               N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	public function DisplayObjectContainer3D():void
	{
		this._children       = new Dictionary(true);
		this._childrenByName = new Dictionary(true);
		this._childrenTotal  = 0;
	}


	public function addChild( child :*, name:String=null ):DisplayObject3D
	{
		// Create instance if needed
		if( child is GeometryObject3D )
			child = new DisplayObject3D( name, child );

		// Choose name
		name = name || child.name || child.id;

		if( child is DisplayObject3D )
		{
			this._children[ child ] = name;
			this._childrenByName[ name ] = child;
			this._childrenTotal++;
		}
		else Papervision3D.log( "DisplayObjectContainer3D.addChild(): Object not recognized. Must be GeometryObject3D or DisplayObject3D descendants." );

		return child;
	}

	public function removeChild( child:DisplayObject3D ):DisplayObject3D
	{
		delete this._childrenByName[ this._children[ child ] ];
		delete this._children[ child ];

		return child;
	}


	public function getChildByName( name:String ):DisplayObject3D
	{
		return this._childrenByName[ name ];
	}


	public function removeChildByName( name:String ):DisplayObject3D
	{
		return removeChild( getChildByName( name ) );
	}

	// ___________________________________________________________________________________________________

	/**
	* Returns a string value representing the three-dimensional values in the specified Number3D object.
	*
	* @return	A string.
	*/
	public override function toString():String
	{
		var list:String = "";

		for( var name:String in this._children )
			list += name + "\n";

		return list;
	}

	public function childrenList():String
	{
		var list:String = "";

		for( var name:String in this._children )
			list += name + "\n";

		return list;
	}

	public function addCollada( filename :String, materials :MaterialsList=null, scale :Number=1 ):DisplayObjectContainer3D
	{
		var collada:Collada = new Collada( this, filename, materials, scale );

//		collada.addEventListener( FileLoadEvent.LOAD_COMPLETE, onLoadCompleteHandler );

		return this;
	}

	// ___________________________________________________________________________________________________
	//                                                                                       P R I V A T E

	protected var _children       :Dictionary; // TODO: protected?

	protected var _childrenByName :Dictionary;
	private   var _childrenTotal  :int;
}
}