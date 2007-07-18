package org.papervision3d.scenes
{
	import flash.display.Sprite;
	import org.papervision3d.objects.DisplayObject3D;
	import com.blitzagency.xray.logger.XrayLog;
	import org.papervision3d.utils.InteractiveSceneManager;
	import org.papervision3d.core.proto.CameraObject3D;

	public class InteractiveScene3D extends MovieScene3D
	{
		//new
		public var interactiveSceneManager:InteractiveSceneManager;
		
		public function InteractiveScene3D(container:Sprite)
		{
			super(container);
			
			interactiveSceneManager = new InteractiveSceneManager(this);
		}
		
		// ___________________________________________________________________ A D D C H I L D
		//
		//   AA   DDDDD  DDDDD   CCCC  HH  HH II LL     DDDDD
		//  AAAA  DD  DD DD  DD CC  CC HH  HH II LL     DD  DD
		// AA  AA DD  DD DD  DD CC     HHHHHH II LL     DD  DD
		// AAAAAA DD  DD DD  DD CC  CC HH  HH II LL     DD  DD
		// AA  AA DDDDD  DDDDD   CCCC  HH  HH II LLLLLL DDDDD
		/**
		* Adds a child DisplayObject3D instance to the scene.
		*
		* If you add a GeometryObject3D symbol, a new DisplayObject3D instance is created.
		*
		* [TODO: If you add a child object that already has a different display object container as a parent, the object is removed from the child list of the other display object container.]
		*
		* @param	child	The GeometryObject3D symbol or DisplayObject3D instance to add as a child of the scene.
		* @param	name	An optional name of the child to add or create. If no name is provided, the child name will be used.
		* @return	The DisplayObject3D instance that you have added or created.
		*/
		public override function addChild( child :DisplayObject3D, name :String=null ):DisplayObject3D
		{
			child = super.addChild(child, name);
			
			//new - setting the scene will spread to the child displayobject3d's
			child.scene = this;
			
			return child;
		}
		
		// ___________________________________________________________________ R E N D E R   C A M E R A
		//
		// RRRRR  EEEEEE NN  NN DDDDD  EEEEEE RRRRR
		// RR  RR EE     NNN NN DD  DD EE     RR  RR
		// RRRRR  EEEE   NNNNNN DD  DD EEEE   RRRRR
		// RR  RR EE     NN NNN DD  DD EE     RR  RR
		// RR  RR EEEEEE NN  NN DDDDD  EEEEEE RR  RR CAMERA
	
		/**
		* Generates an image from the camera's point of view and the visible models of the scene.
		*
		* @param	camera		camera to render from.
		*/
		public override function renderCamera( camera :CameraObject3D ):void
		{
			interactiveSceneManager.resetFaces();
			super.renderCamera( camera );
		}		
	}
}