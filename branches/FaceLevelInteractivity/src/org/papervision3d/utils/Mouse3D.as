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

public class Mouse3D extends DisplayObject3D
{
	static public var enable:Boolean;
	
	static private var UP :Number3D = new Number3D(0, 1, 0);
	
	public function Mouse3D(initObject:Object=null):void
	{
		enable = true;
		this.x = x;
		this.y = y;
		this.z = z;
	}
	public function updatePosition(face:Face3D):void{
		var position:Number3D = new Number3D(0, 0, 0);
		var target:Number3D = new Number3D(face.faceNormal.x, face.faceNormal.y, face.faceNormal.z);
			
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
				
		v.n14 = face.getCoordAtPoint(face.container.mouseX,face.container.mouseY).x;
		v.n24 = face.getCoordAtPoint(face.container.mouseX,face.container.mouseY).y;
		v.n34 = face.getCoordAtPoint(face.container.mouseX,face.container.mouseY).z;
		
		m.calculateMultiply( face.face3DInstance.instance.world, v );
		
		x = m.n14;
		y = m.n24;
		z = m.n34;
	}
}
}