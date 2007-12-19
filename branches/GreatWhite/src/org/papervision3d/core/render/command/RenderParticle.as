package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import flash.display.Sprite;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.ParticleMaterial;

	public class RenderParticle extends RenderableListItem implements IRenderListItem
	{
	
		public var particle:Particle;
		public var renderer:ParticleMaterial;
		
		
		public function RenderParticle(particle:Particle)
		{
			super();
			this.particle = particle;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			particle.material.drawParticle(particle, renderSessionData.container.graphics, renderSessionData);
		}
		
	}
}