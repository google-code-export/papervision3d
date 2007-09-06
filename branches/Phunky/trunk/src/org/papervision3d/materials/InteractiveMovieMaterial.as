package org.papervision3d.materials
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class InteractiveMovieMaterial extends MovieMaterial
	{
		public function InteractiveMovieMaterial(movieAsset:Sprite, transparent:Boolean=false, animated:Boolean=false)
		{
			super(movieAsset, transparent, animated);
		}
		
		/**
		 *  drawFace3D
		 */
		override public function drawFace3D(face3D:Triangle3D, graphics:Graphics, v0:Vertex3DInstance, v1:Vertex3DInstance, v2:Vertex3DInstance):int
		{
			var result:int = super.drawFace3D(face3D, graphics, v0, v1,v2);
			if(face3D.instance.interactiveSceneManager != null && result) face3D.instance.interactiveSceneManager.drawFace(face3D,v0.x, v1.x, v2.x, v0.y, v1.y, v2.y);
			return result;
		}
		
	}
}