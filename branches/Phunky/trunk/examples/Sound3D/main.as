/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org / blog.papervision3d.org / osflash.org/papervision3d
 */

// _______________________________________________________________________ 3D Sound

package
{
import flash.display.*;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.events.*;
import flash.ui.Keyboard;

// Import Papervision3D
import org.papervision3d.scenes.*;
import org.papervision3d.objects.*;
import org.papervision3d.cameras.*;
import org.papervision3d.materials.*;
import org.papervision3d.events.*;
import org.papervision3d.utils.*;



public class main extends Sprite
{
	// ___________________________________________________________________ 3D vars

	public var container :Sprite;
	public var scene     :Scene3D;
	public var camera    :FreeCamera3D;
	
	public var vsound    :Sound3D;
	public var sound1    :Sound3D;
	public var sound2    :Sound3D;
	
	public var box 	  	 :DisplayObject3D;
	public var disc 	 :DisplayObject3D;
	public var plane 	 :DisplayObject3D;
	public var material1 :MovieMaterial;
	public var material2 :MovieMaterial;
	public var material3 :MovieMaterial;
	
	
	public var topSpeed  :Number = 0;
	public var ltopSpeed :Number = 0;
	public var speed     :Number = 0;
	public var lspeed    :Number = 0;

	public var keyRight   :Boolean = false;
	public var keyLeft    :Boolean = false;
	public var keyForward :Boolean = false;
	public var keyReverse :Boolean = false;
	public var mouseIsDown:Boolean = false;


	// ___________________________main

	public function main()
	{
		stage.quality = "MEDIUM";
		stage.scaleMode = "noScale";

		stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );

		this.addEventListener( Event.ENTER_FRAME, loop3D );

		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		function mouseDownHandler(event:MouseEvent):void {
        	mouseIsDown = true;
		}
		function mouseUpHandler(event:MouseEvent):void {
        	mouseIsDown = false;
		}
		
		init3D();
	}

	public function init3D():void
	{
		container = new Sprite();
		addChild( this.container );
		container.x = 500;
		container.y = 300;
		
		this.scene = new Scene3D( this.container, true );
		
		camera = new FreeCamera3D();
		camera.z = -5000;
		camera.zoom = 10;
		camera.focus = 100;
		
		material1 = new MovieMaterial( new speakerbox() );
		material1.animated = true;
		material1.allowAutoResize = false;
		
		material2 = new MovieMaterial( new sphereMap(), true );
		material2.animated = true;
		material2.allowAutoResize = false;
		
		material3 = new MovieMaterial( new flvvideo() );
		material3.oneSide = false;
		material3.animated = true;
		material3.allowAutoResize = false;
		
		
		//______________________________________________________________add sound to each object
		
		box = scene.addChild( new Cube( new MaterialsList({all:material1}), 50, 50, 50) );
		sound1 = new Sound3D(new Sound(new URLRequest("samplemusic.mp3")));
		box.addChild(sound1);
		box.x = -1000;
		sound1.maxSoundDistance = 5000;
		sound1.play(0,5);
		
		
		plane = scene.addChild( new Plane( material3 ) );
		vsound = new Sound3D();
		vsound.soundChannel = material3.movie["flv"]; //controls the sound in video
		plane.addChild(vsound, "sound");
		plane.x = 1000;
		vsound.maxSoundDistance = 2000;
		//material3.movie["flv"].play();
		
		
		//sound from the library
		
		disc = scene.addChild( new Sphere( material2 ) );
		var ufo:Sound = new ufoSound();
		sound2 = new Sound3D( ufo );
		disc.addChild(sound2);
		disc.scaleY = .3;
		sound2.maxSoundDistance = 7000;
		sound2.play(0,99999);
		
		disc.z = 2000;
		disc.x = 4000;
	}

	//_______________________________________________________key controls
	
	public function keyDownHandler( event :KeyboardEvent ):void
	{
		switch( event.keyCode )
		{
			case "W".charCodeAt():
			case Keyboard.UP:
				keyForward = true;
				keyReverse = false;
				break;

			case "S".charCodeAt():
			case Keyboard.DOWN:
				keyReverse = true;
				keyForward = false;
				break;

			case "A".charCodeAt():
			case Keyboard.LEFT:
				keyLeft = true;
				keyRight = false;
				break;

			case "D".charCodeAt():
			case Keyboard.RIGHT:
				keyRight = true;
				keyLeft = false;
				break;
		}
	}


	public function keyUpHandler( event :KeyboardEvent ):void
	{
		switch( event.keyCode )
		{
			case "W".charCodeAt():
			case Keyboard.UP:
				keyForward = false;
				break;

			case "S".charCodeAt():
			case Keyboard.DOWN:
				keyReverse = false;
				break;

			case "A".charCodeAt():
			case Keyboard.LEFT:
				keyLeft = false;
				break;

			case "D".charCodeAt():
			case Keyboard.RIGHT:
				keyRight = false;
				break;
		}
	}

	public function movingCam():void
	{
		// Foward and Backward
		if( keyForward )
		{
			topSpeed = 50;
		}
		else if( keyReverse )
		{
			topSpeed = -50;
		}
		else
		{
			topSpeed = 0;
		}
		// Left and Right
		if( keyRight )
		{
			ltopSpeed = 50;
		}
		else if( keyLeft )
		{
			ltopSpeed = -50;
		}
		else
		{
			ltopSpeed = 0;
		}
		speed -= ( speed - topSpeed ) / 10;
		lspeed -= ( lspeed - ltopSpeed ) / 10;
		
	}
	
	//______________________________________loop
	
	public function loop3D( event :Event ):void
	{
		// camera movement
		camera.moveForward( speed );
		camera.moveRight( lspeed );
		movingCam();
		
		if(mouseIsDown)camera.rotationY -= (camera.y - container.mouseX) /180;
		
		//box.scale = (sound1.soundChannel.rightPeak + sound1.soundChannel.leftPeak) + 1;
		disc.moveForward( 100 );
		disc.rotationY -= 1;
		
		this.scene.renderCamera( camera );
	}
}
}