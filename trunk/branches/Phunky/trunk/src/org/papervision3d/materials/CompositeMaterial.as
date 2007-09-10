package org.papervision3d.materials
{
	import flash.display.Graphics;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;

	public class CompositeMaterial extends MaterialObject3D implements IFaceDrawer
	{
		
		private var materials:Array;
		
		public function CompositeMaterial()
		{
			init();
		}
		
		private function init():void
		{
			materials = new Array();
		}
		
		public function addMaterial(material:MaterialObject3D):void
		{
			materials.push(material);
		}
		
		public function removeMaterial(material:MaterialObject3D):void
		{
			materials.splice(materials.indexOf(material),1);
		}
		
		public function removeAllMaterials(material:MaterialObject3D):void
		{
			materials = new Array();
		}
		
		override public function drawTriangle(face3D:Face3D, graphics:Graphics, renderSessionData:RenderSessionData):int
		{
			var num:int = 0;
			for each(var n:MaterialObject3D in materials){
				num += n.drawTriangle(face3D, graphics, renderSessionData);
			}
			return num;
		}
		
	}
}