/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

// _______________________________________________________________________ HelloWorld

// This example creates a basic scene with
// a plane primitive and a loaded sphere.

package
{
import flash.display.*;
import flash.events.*;

// Import Papervision3D
import org.papervision3d.Papervision3D;
import org.papervision3d.scenes.LayerScene3D;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.objects.Ase;
import org.papervision3d.objects.Plane;
import org.papervision3d.objects.PaperPlane;
import org.papervision3d.materials.BitmapAssetMaterial;
import org.papervision3d.materials.ColorMaterial;

public class main extends Sprite
{
	// ___________________________________________________________________ vars3D

	var container :Sprite;
	var scene     :LayerScene3D;
	var camera    :Camera3D;
	var sphere    :Ase;


	// ___________________________________________________________________ main

	function main()
	{
		init3D();

		// onEnterFrame
		this.addEventListener( Event.ENTER_FRAME, loop3D );
	}


	// ___________________________________________________________________ init3D

	function init3D():void
	{
		// No traces
		//Papervision3D.VERBOSE = false;

		// Create container sprite and center it in the stage
		container = new Sprite();
		addChild( container );
		container.x = 320;
		container.y = 240;

		// Create scene
		scene = new LayerScene3D( container );

		// Create camera
		camera = new Camera3D();

		// Add Earth sphere
		addEarth();

		// Add space plane
		addSpaces();
	}


	// ___________________________________________________________________ Earth

	function addEarth():void
	{
		// Create texture with a bitmap from the library
		var materialEarth :BitmapAssetMaterial = new BitmapAssetMaterial( "Earth" );

		// Load sphere...
		// and scale it down to half the size
		sphere = new Ase( materialEarth, "world.ase", 0.5 );

		// Position sphere
		sphere.rotationX = 45;
		sphere.yaw( -30 );

		// LAYERSCENE
		// Add to a specific layer using addChildAt
		// Layer 1 in this case will put the sphere in front
		scene.addChildAt( sphere, 1 );
	}


	// ___________________________________________________________________ Space

	function addSpaces():void
	{
		// LAYERSCENE
		// Select layer and use addChild
		// Layer 0 in this case will put the planes behind
		scene.selectLayer( 0 );

		// Create texture with a bitmap from the library
		var materialSpace :ColorMaterial = new ColorMaterial( 0xFFFFFF, 0.5 );
		materialSpace.doubleSided = true;

		var total:int = 99;
		var rad :Number = 700;

		for( var i:int = 0; i < total; i++ )
		{
			var plane:Plane = new Plane( materialSpace, 64*1.5, 48*1.5, 1, 1 );

			//Sphere surface distribution
			var ax  :Number = Math.random() * Math.PI;
			var ay  :Number = Math.random() * Math.PI * 2;

			plane.x = rad * Math.sin( ax ) * Math.cos( ay );
			plane.y = rad * Math.sin( ax ) * Math.sin( ay );
			plane.z = rad * Math.cos( ax );

			plane.lookAt( sphere );

			// LAYERSCENE
			// Select layer and use addChild, it will be added to the selectedLayer. Default is 0.
			scene.addChild( plane );
		}
	}


	// ___________________________________________________________________ loop

	function loop3D(event:Event):void
	{
		// Move camera with the mouse
		camera.x = -container.mouseX/4;
		camera.y = container.mouseY/3;

		// Rotate sphere around its own vertical axis
		sphere.yaw( 0.2 );

		// Render the scene
		scene.renderCamera( camera );
	}
}
}