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
//                                                          SceneObject3D

package org.papervision3d.core.proto
{
import flash.display.Sprite;
import flash.utils.getTimer;
import flash.utils.Dictionary;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.proto.*;
import org.papervision3d.materials.MaterialsList;
import org.papervision3d.scenes.DisplayObject3D;

/**
* Scene3D
* The Scene3D class lets you create, manipulate and display 3D objects.
*
*/
public class SceneObject3D extends DisplayObjectContainer3D
{
	// __________________________________________________________________________
	//                                                                     STATIC

	/**
	* The MovieClip that you draw into when rendering.
	*/
	public var container :Sprite;

	private var geometries :Dictionary;

	/**
	* An object that contains total and current statistics.
	* <ul>
	* <li>points</li>
	* <li>polys</li>
	* <li>triangles</li>
	* <li>performance<li>
	* <li>rendered<li>
	* </ul>
	*/
	public var stats :Object;

	/**
	* It contains a list of DisplayObject3D objects in a scene.
	*/
	public var objects :Array;

	/**
	* It contains a list of Material3D materials in a scene.
	*/
	public var materials :MaterialsList;

	// ___________________________________________________________________________________________________
	//                                                                           P A P E R V I S I O N 3 D
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* The Papervision3D class lets you create, manipulate and display 3D objects.
	*
	* @param	container	The MovieClip that you draw into when rendering. If not defined, each object must have it's own private container.
	*
	*/
	public function SceneObject3D( container:Sprite )
	{
		if( container )
			this.container = container;
		else
			Papervision3D.log( "Scene3D: container argument required." );

		this.objects = new Array();
		this.materials = new MaterialsList();

		Papervision3D.log( Papervision3D.NAME + " " + Papervision3D.VERSION + " (" + Papervision3D.DATE + ")\n" );

		this.stats = new Object();
		this.stats.points = 0;
		this.stats.polys = 0;
		this.stats.triangles = 0;
		this.stats.performance = 0;
		this.stats.rendered = 0;
	}

	// ___________________________________________________________________________________________________
	//                                                                                             P U S H
	// PPPPP  UU  UU  SSSSS HH  HH
	// PP  PP UU  UU SS     HH  HH
	// PPPPP  UU  UU  SSSS  HHHHHH
	// PP     UU  UU     SS HH  HH
	// PP      UUUU  SSSSS  HH  HH

	/**
	* Includes an DisplayObject3D or a Material3D element in the scene.
	*
	* @param	sceneElement	Element to add.
	*/

	public override function addChild( child:*, name:String=null ):DisplayObject3D
	{
		var newChild:DisplayObject3D =	super.addChild( child, name );

		this.objects.push( newChild );

		return newChild;
	}


	public override function removeChild( child:DisplayObject3D ):DisplayObject3D
	{
		super.removeChild( child );

		for (var i:int = 0; i < this.objects.length; i++ )
		{
			if (this.objects[i] === child )
			{
				this.objects.splice(i, 1);
				return child;
			}
		}

		return child;
	}


	// ___________________________________________________________________________________________________
	//                                                                           R E N D E R   C A M E R A
	// RRRRR  EEEEEE NN  NN DDDDD  EEEEEE RRRRR
	// RR  RR EE     NNN NN DD  DD EE     RR  RR
	// RRRRR  EEEE   NNNNNN DD  DD EEEE   RRRRR
	// RR  RR EE     NN NNN DD  DD EE     RR  RR
	// RR  RR EEEEEE NN  NN DDDDD  EEEEEE RR  RR CAMERA

	/**
	* Generates an image from the camera's point of view and the active models of the scene.
	*
	* @param	camera		Camera3D object to render from.
	*/
	public function renderCamera( camera :CameraObject3D ):void
	{
		// Render performance stats
		var stats:Object  = this.stats;
		stats.performance = getTimer();

		// Materials
		for each( var m:MaterialObject3D in this.materials )
		{
			trace( "SceneObject3D:materials " + m );
			if( m.animated )
				m.updateBitmap();
		}

		// 3D projection
		if( camera )
		{
			// Transform camera
			camera.transformView();

			// Project objects
			var objects :Array = this.objects;
			var p       :DisplayObject3D;
			var i       :Number = objects.length;

			while( p = objects[--i] )
				if( p.visible )
					p.project( camera, camera );
		}

		// Z sort
		if( camera.sort )
			this.objects.sortOn( 'screenZ', Array.NUMERIC );

		// Render objects
		stats.rendered = 0;
		renderObjects( camera.sort );
	}


	protected function renderObjects( sort:Boolean ):void {}
}
}