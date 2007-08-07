package org.papervision3d.utils 
{
	import flash.geom.Point;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class InteractiveUtils 
	{
		public static function getMapCoordAtPoint(displayObject:DisplayObject3D, material:BitmapMaterial):Point        
		{            
			var x:Number = displayObject.scene.container.mouseX;
			var y:Number = displayObject.scene.container.mouseY;            
			var face:Face3D = displayObject.geometry.faces[0];                            
			var UV : Object = UVatPoint(x, y, face);            
			var v_x : Number = (face.uv[1].u - face.uv[0].u) * UV.v +  (face.uv[2].u - face.uv[0].u) * UV.u + face.uv[0].u;            
			var v_y : Number = (face.uv[1].v - face.uv[0].v ) * UV.v + (face.uv[2].v - face.uv[0].v) * UV.u + face.uv[0].v;                        
			return new Point( v_x * material.texture.width, material.texture.height - v_y * material.texture.height );        
		}                
			
		public static function UVatPoint(x:Number, y:Number, face:Face3D):Object        
		{                
			var v0_x : Number = face.v2.vertex2DInstance.x - face.v0.vertex2DInstance.x;            
			var v0_y : Number = face.v2.vertex2DInstance.y - face.v0.vertex2DInstance.y;            
			var v1_x : Number = face.v1.vertex2DInstance.x - face.v0.vertex2DInstance.x;            
			var v1_y : Number = face.v1.vertex2DInstance.y - face.v0.vertex2DInstance.y;            
			var v2_x : Number = x - face.v0.vertex2DInstance.x;            
			var v2_y : Number = y - face.v0.vertex2DInstance.y;                        
			var dot00 : Number = v0_x * v0_x + v0_y * v0_y;            
			var dot01 : Number = v0_x * v1_x + v0_y * v1_y;            
			var dot02 : Number = v0_x * v2_x + v0_y * v2_y;            
			var dot11 : Number = v1_x * v1_x + v1_y * v1_y;            
			var dot12 : Number = v1_x * v2_x + v1_y * v2_y;                        
			var invDenom : Number = 1 / (dot00 * dot11 - dot01 * dot01);            
			var u : Number = (dot11 * dot02 - dot01 * dot12) * invDenom;            
			var v : Number = (dot00 * dot12 - dot01 * dot02) * invDenom;                        
			return {u:u, v:v};        
		}
	}	
}
