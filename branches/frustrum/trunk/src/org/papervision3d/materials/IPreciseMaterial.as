
package org.papervision3d.materials 
{
	import flash.display.Graphics;
	import org.papervision3d.core.render.data.RenderSessionData;	
	import org.papervision3d.core.render.draw.ITriangleDrawer;
		
	public interface IPreciseMaterial extends ITriangleDrawer
	{		
		function renderRec(graphics:Graphics, ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number, 
            ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number, index:Number, renderSessionData:RenderSessionData):void
		
		function renderTriangleBitmap(graphics:Graphics,a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, smooth:Boolean, repeat:Boolean):void
	}	
}
