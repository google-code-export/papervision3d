package org.papervision3d.materials
{
	import flash.display.Graphics;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.IParticleDrawer;

	public class ParticleMaterial extends MaterialObject3D implements IParticleDrawer
	{
		public function ParticleMaterial(color:Number, alpha:Number)
		{
			super();
			this.fillAlpha = alpha;
			this.fillColor = color;
		}
		
		public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			graphics.beginFill(fillColor, fillAlpha);
			//trace(particle.size);
			if(particle.size == 0){
				graphics.drawRect(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y,1,1);
			}else{
				graphics.drawRect(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y,particle.renderScale,particle.renderScale);
			}
			graphics.endFill();
		}
		
	}
}