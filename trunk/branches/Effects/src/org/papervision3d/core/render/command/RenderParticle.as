package org.papervision3d.core.render.command
{
	
	/**
	 * @Author Ralph Hauwert
	 * 
	 * updated by Seb Lee-Delisle 
	 *  - added HitTestPoint2D so that it works with interactivity.
	 */
	 
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.layers.RenderLayer;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.core.render.data.RenderHitData;
	
	import flash.geom.Point;	
	public class RenderParticle extends RenderableListItem implements IRenderListItem
	{
	
		public var particle:Particle;
		public var container:RenderLayer;
		
		public var renderMat:ParticleMaterial; 
		
		
		public function RenderParticle(particle:Particle)
		{
			super();
			this.particle = particle;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			container = particle.material.renderLayer || particle.instance.renderLayer || renderSessionData.defaultRenderLayer;
			particle.material.drawParticle(particle, container.drawLayer.graphics, renderSessionData);
			
			container.faceCount++;
			container.screenDepth += this.screenDepth;
			
		}
		
		
		override public function hitTestPoint2D(point:Point, rhd:RenderHitData):RenderHitData
		{
			renderMat = particle.material;
			//if( !renderMat ) renderMat = triangle.instance.material;
			
			if(renderMat.interactive)
			{
				if(particle.renderRect.contains(point.x, point.y)) 
				{
					rhd.displayObject3D = particle.instance; 
					rhd.material = renderMat;
					rhd.renderable = particle; 
					rhd.hasHit = true;
					
					//TODO UPDATE 3D hit point and UV
					rhd.x = particle.x; 
					rhd.y = particle.y; 
					rhd.z = particle.z; 
					rhd.u = 0;
					rhd.v = 0; 
					return rhd; 
				}
				
			}
			return rhd;
		}
		
		
	}
}