package org.papervision3d.materials
{
	import org.papervision3d.core.draw.IFaceDrawer;
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;
	import flash.display.Graphics;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class BitmapWireframeMaterial extends BitmapMaterial implements IFaceDrawer
	{
		private static const BITMAP_WIDTH:int = 64;
		private static const BITMAP_HEIGHT:int = 64;
		
		private var uvMatrix:Matrix;
		
		public function BitmapWireframeMaterial(color:Number=0xFF00FF, alpha:Number=1)
		{
			super(new BitmapData(2,2,true));
			bitmap = new BitmapData(BITMAP_WIDTH,BITMAP_HEIGHT,true,0x00000000);
			lineColor = color;
			lineAlpha = alpha;	
			init();
		}
		
		private function init():void
		{
			createBitmapData();
			createStaticUVMatrix();
		}
		
		override public function drawFace3D(instance:DisplayObject3D, face3D:Face3D, graphics:Graphics, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D):int
		{
			if(bitmap){
				var x0:Number = v0.x;
				var y0:Number = v0.y;
				var x1:Number = v1.x;
				var y1:Number = v1.y;
				var x2:Number = v2.x;
				var y2:Number = v2.y;
				
				_triMatrix.a = x1 - x0;
				_triMatrix.b = y1 - y0;
				_triMatrix.c = x2 - x0;
				_triMatrix.d = y2 - y0;
				_triMatrix.tx = x0;
				_triMatrix.ty = y0;
					
				_localMatrix.a = uvMatrix.a;
				_localMatrix.b = uvMatrix.b;
				_localMatrix.c = uvMatrix.c;
				_localMatrix.d = uvMatrix.d;
				_localMatrix.tx = uvMatrix.tx;
				_localMatrix.ty = uvMatrix.ty;
				_localMatrix.concat(_triMatrix);
				
				graphics.beginBitmapFill( bitmap, _localMatrix, true, smooth);
				graphics.moveTo( x0, y0 );
				graphics.lineTo( x1, y1 );
				graphics.lineTo( x2, y2 );
				graphics.lineTo( x0, y0 );
				graphics.endFill();
				return 1;	
			}
			return 0;
		}
		
		private function createBitmapData():void
		{
			var sprite:Sprite = new Sprite();
			var graphics:Graphics = sprite.graphics;
			
			
			graphics.lineStyle(2,0xFFFFFF,1);
			graphics.moveTo( 1, 1 );
			graphics.lineTo( BITMAP_WIDTH-1,1 );
			graphics.lineTo( BITMAP_WIDTH-1,BITMAP_HEIGHT-1);
			graphics.lineTo( 1, 1 );
			graphics.endFill();
			
			bitmap.draw(sprite);
			
		}
		
		private function createStaticUVMatrix():void
		{
			var w  :Number = BITMAP_WIDTH;
			var h  :Number = BITMAP_HEIGHT;

			var u0 :Number = w * 1;
			var v0 :Number = h * ( 0 );
			var u1 :Number = w * 0;
			var v1 :Number = h * ( 0  );
			var u2 :Number = w * 1;
			var v2 :Number = h * ( 1 );
			
			// Precalculate matrix & correct for mip mapping
			var at :Number = ( u1 - u0 );
			var bt :Number = ( v1 - v0 );
			var ct :Number = ( u2 - u0 );
			var dt :Number = ( v2 - v0 );

			uvMatrix = new Matrix( at, bt, ct, dt, u0, v0 );
			uvMatrix.invert();	
		}
		
	}
}