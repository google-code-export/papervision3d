package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 */
	 
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.layers.RenderLayer;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.ParticleMaterial;

	public class RenderParticle extends RenderableListItem implements IRenderListItem
	{
	
		public var particle:Particle;
		public var renderer:ParticleMaterial;
		public var container:RenderLayer;
		
		
		public function RenderParticle(particle:Particle)
		{
			super();
			this.particle = particle;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			container = particle.material.renderLayer || particle.instance.renderLayer || renderSessionData.defaultRenderLayer;
			particle.material.drawParticle(particle, container.drawLayer.graphics, renderSessionData);
		}
		
	}
}