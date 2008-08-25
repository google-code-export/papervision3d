/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

// _______________________________________________________________________ Cube

package
{
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;

// Import Papervision3D
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.cameras.FreeCamera3D;
import org.papervision3d.objects.Cube;
import org.papervision3d.materials.MaterialsList;
import org.papervision3d.materials.MovieAssetMaterial;

public class main extends MovieClip
{
	// ___________________________________________________________________ Static

	static public var SCREEN_WIDTH  :int = 1024;
	static public var SCREEN_HEIGHT :int = 768;

	// ___________________________________________________________________ 3D vars

	private var container :Sprite;
	private var scene     :Scene3D;
	private var camera    :FreeCamera3D;
	private var cube      :Cube;

	// ___________________________________________________________________ main

	public function main()
	{
		stage.scaleMode = StageScaleMode.NO_SCALE;

		init3D();
		
		createCube();

		stage.quality = StageQuality.LOW;

		this.addEventListener( Event.ENTER_FRAME, loop );
	}


	// ___________________________________________________________________ Init3D

	private function init3D():void
	{
		// Create container sprite and center it in the stage
		container = new Sprite();
		addChild( container );
		container.x = SCREEN_WIDTH  /2;
		container.y = SCREEN_HEIGHT /2;

		// Create scene
		scene = new Scene3D( container );

		// Create camera
		camera = new FreeCamera3D();
		camera.zoom = 1;
		camera.focus = 1000;
		camera.z = 0;
	}


	// ___________________________________________________________________ Create Cube

	private function createCube()
	{
		// Attributes
		var size :Number = 5000;
		var quality :Number = 16;
	
		// Materials
		var materials:MaterialsList = new MaterialsList(
		{
			//all:
			front:  new MovieAssetMaterial( "Front", true ),
			back:   new MovieAssetMaterial( "Back", true ),
			right:  new MovieAssetMaterial( "Right", true ),
			left:   new MovieAssetMaterial( "Left", true ),
			top:    new MovieAssetMaterial( "Top", true ),
			bottom: new MovieAssetMaterial( "Bottom", true )
		} );

		// Cube face settings
		// You can add or sustract faces to your selection. For examples: Cube.FRONT+Cube.BACK or Cube.ALL-Cube.Top.

		// On single sided materials, all faces will be visible from the inside.
		var insideFaces  :int = Cube.ALL;

		// Front and back cube faces will not be created.
		var excludeFaces :int = Cube.NONE;

		// Create the cube.
		cube = new Cube( materials, size, size, size, quality, quality, quality, insideFaces, excludeFaces );

		scene.addChild( cube, "Cube" );
	}


	// ___________________________________________________________________ Loop

	private function loop(event:Event):void
	{
		update3D();
	}


	private function update3D():void
	{
		// Pan
		var pan:Number = camera.rotationY - 210 * container.mouseX/(stage.stageWidth/2);
		pan = Math.max( -100, Math.min( pan, 100 ) ); // Max speed
		camera.rotationY -= pan / 12;

		// Tilt
		var tilt:Number = 90 * container.mouseY/(stage.stageHeight/2);
		camera.rotationX -= (camera.rotationX + tilt) / 12;

		// Render
		scene.renderCamera( this.camera );
	}
}
}