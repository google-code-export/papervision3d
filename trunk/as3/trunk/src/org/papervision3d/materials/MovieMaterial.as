/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org � blog.papervision3d.org � osflash.org/papervision3d
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

// __________________________________________________________________________ MOVIE MATERIAL

package org.papervision3d.materials
{
import flash.geom.Matrix;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.utils.Dictionary;

/**
* The MovieMaterial class creates a texture from an existing MovieClip instance.
* <p/>
* The texture can be animated and/or transparent. Current scale and color values of the MovieClip instance will be used. Rotation will be discarded.
* <p/>
* The MovieClip's content needs to be top left aligned with the registration point.
* <p/>
* Materials collects data about how objects appear when rendered.
*/
public class MovieMaterial extends BitmapMaterial
{
	// ______________________________________________________________________ PUBLIC

	/**
	* The MovieClip that is used as a texture.
	*/
	public var movie :Sprite;

	/**
	* A Boolean value that determines whether the MovieClip is transparent. The default value is false, which is much faster.
	*/
	public var movieTransparent :Boolean;
	
	/**
	* When updateBitmap() is called on an animated material, it looks to handle a change in size on the texture.
	* 
	* This is true by default, but in certain situations, like drawing on an object, you wouldn't want the size to change
	*/
	public var allowAutoResize:Boolean = true;


	// ______________________________________________________________________ ANIMATED

	/**
	* A Boolean value that determines whether the texture is animated.
	*
	* If set, the material must be included into the scene so the BitmapData texture can be updated when rendering. For performance reasons, the default value is false.
	*/
	public function get animated():Boolean
	{
		return animatedMaterials[ this ];
	}

	public function set animated( status:Boolean ):void
	{
		animatedMaterials[ this ] = status;
	}

	// ______________________________________________________________________ NEW

	/**
	* The MovieMaterial class creates a texture from an existing MovieClip instance.
	*
	* @param	asset			A String that contains an existing MovieClip library id.
	* @param	transparent		[optional] - If it's not transparent, the empty areas of the MovieClip will be of fill32 color. Default value is false.
	* @param	initObject		[optional] - An object that contains additional properties with which to populate the newly created material.
	*/
	public function MovieMaterial( asset:*, transparent:Boolean=false, initObject:Object=null )
	{
		super( initBitmap( asset, transparent ), initObject );
		
		animatedMaterials[ this ] = initObject.animated || false;
	}


	// ______________________________________________________________________ UPDATE

	/**
	* Updates animated MovieClip bitmap.
	*
	* Draws the current MovieClip image onto bitmap.
	*/
	public override function updateBitmap():void
	{
		// using int is much faster than using Math.floor. And casting the variable saves in speed from having the avm decide what to cast it as
		var mWidth:int = int(movie.width);
		var mHeight:int = int(movie.height);
		
		if( allowAutoResize && ( mWidth != bitmap.width || mHeight != bitmap.height ) )
		{
			// Init new bitmap size
			initBitmap( movie, movieTransparent );

			// Init texture
			texture = movie;
		}

		bitmap.fillRect( bitmap.rect, this.fillColor );

		var mtx:Matrix = new Matrix();
		mtx.scale( movie.scaleX, movie.scaleY );

		bitmap.draw( movie, mtx, movie.transform.colorTransform );
	}


	// ______________________________________________________________________ CREATE BITMAP

	protected override function createBitmap( asset:* ):BitmapData
	{
		// Draw bitmap
		this.movie = asset;
		updateBitmap();

		// Call super.createBitmap to centralize the bitmap specific code.
		// Here only MovieClip specific code, all bitmap code (maxUVs, AUTO_MIP_MAP, correctBitmap) in BitmapMaterial.
		super.createBitmap( bitmap );

		return this.bitmap;
	}

	// ______________________________________________________________________ CREATE BITMAP

	/**
	* Updates bitmap on all animated MovieMaterial instances.
	*/
	static public function updateAnimatedBitmaps():void
	{
		for( var material:Object in animatedMaterials )
		{
			if( animatedMaterials[ material ] )
			{
				material.updateBitmap();
			}
		}
	}

	// ______________________________________________________________________ PRIVATE

	private function initBitmap( asset:*, transparent:Boolean ):*
	{
		this.movieTransparent = transparent || false;

		// Cleanup previous bitmap if needed
		if( bitmap )
			bitmap.dispose();

		// Create new bitmap
		bitmap = new BitmapData( asset.width, asset.height, this.movieTransparent );

		return asset;
	}
	
	static private var animatedMaterials :Dictionary = new Dictionary( false );
}
}