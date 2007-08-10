/**
* @author De'Angelo Richardson 
*/
package org.papervision3d.utils
{
	import com.blitzagency.xray.logger.XrayLog;

	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.Matrix3D;
	import org.papervision3d.scenes.InteractiveScene3D;
	import org.papervision3d.utils.InteractiveSceneManager;
	import org.papervision3d.utils.InteractiveSprite;
	import org.papervision3d.utils.InteractiveUtils;

	public class Mouse3D extends DisplayObject3D
	{
		static private var UP 								:Number3D = new Number3D(0, 1, 0);
		
		static public var enabled							:Boolean = true;
		
		public function Mouse3D(initObject:Object=null):void
		{
			
		}
		
		public function updatePosition( face3d:Face3D, container:Sprite ):void
		{			
			var position:Number3D = new Number3D(0, 0, 0);
			var target:Number3D = new Number3D(face3d.faceNormal.x, face3d.faceNormal.y, face3d.faceNormal.z);
				
			var zAxis:Number3D = Number3D.sub(target, position);
			zAxis.normalize();
				
			if (zAxis.modulo > 0.1)
			{
				var xAxis:Number3D = Number3D.cross(zAxis, UP);
				xAxis.normalize();
				
				var yAxis:Number3D = Number3D.cross(zAxis, xAxis);
				yAxis.normalize();
				
				var look:Matrix3D = this.transform;
					
				look.n11 = xAxis.x;
				look.n21 = xAxis.y;
				look.n31 = xAxis.z;
				
				look.n12 = -yAxis.x;
				look.n22 = -yAxis.y;
				look.n32 = -yAxis.z;
				
				look.n13 = zAxis.x;
				look.n23 = zAxis.y;
				look.n33 = zAxis.z;
			}
			
			var m:Matrix3D = Matrix3D.IDENTITY;
			
			var v:Matrix3D = Matrix3D.IDENTITY;
					
			v.n14 = InteractiveUtils.getCoordAtPoint(face3d, container.mouseX, container.mouseY).x;
			v.n24 = InteractiveUtils.getCoordAtPoint(face3d, container.mouseX, container.mouseY).y;
			v.n34 = InteractiveUtils.getCoordAtPoint(face3d, container.mouseX, container.mouseY).z;
			
			m.calculateMultiply( face3d.face3DInstance.instance.world, v );
			
			x = m.n14;
			y = m.n24;
			z = m.n34;
		}
	}
}