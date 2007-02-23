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
//                                                          Papervision3D
package org.papervision3d
{
/**
* Papervision3D
* The Papervision3D class lets you create, manipulate and display 3D objects.
*
*/
public class Papervision3D
{
	// __________________________________________________________________________
	//                                                                     STATIC

	static public var NAME     :String = 'Papervision3D';
	static public var VERSION  :String = 'Beta RC1';
	static public var DATE     :String = '01.02.07';
	static public var AUTHOR   :String = '(c) 2006-2007 Copyright by Carlos Ulloa | papervision3d.org | C4RL054321@gmail.com';

	static public var VERBOSE  :Boolean = true;

	/**
	* Indicates if the angles are expressed in degrees (true) or radians (false). The default value is true, degrees.
	*/
	public static var useDEGREES  :Boolean = true;

	/**
	* Indicates if the scales are expressed in percent (true) or from zero to one (false). The default value is false, i.e. units.
	*/
	public static var usePERCENT  :Boolean = false;

	/**
	* Indicates if the world Y positive axis is up or down.
	*/
	public static var useY_UP     :Boolean = true;

	/**
	* Indicates if the world Z positive axis is out or in.
	*/
	public static var useZ_OUT    :Boolean = true;

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
	*/
	public function Papervision3D():void
	{
		log( "Papervision3D scene class has been replaced by org.papervision3d.scenes" );
	}


	static public function log( message:String ):void
	{
		if( Papervision3D.VERBOSE )
			trace( message );
	}
}
}