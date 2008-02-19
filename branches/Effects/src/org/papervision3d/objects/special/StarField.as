package org.papervision3d.objects.special
{
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class StarField extends ParticleField
	{
		public var doScale:Boolean = false;
		public var particleScale:Number = 1;
		
		public function StarField(mat:ParticleMaterial, quantity:int = 200, fieldWidth:Number = 2000, fieldHeight:Number = 2000, fieldDepth:Number = 2000, doScale:Boolean=false, particleScale:Number=1)
		{
			super(mat, quantity, fieldWidth, fieldHeight, fieldDepth);
			
			this.doScale = doScale;
			this.particleScale = particleScale;
		}
		
		/**
		 * Project
		 */
		public override function project( parent :DisplayObject3D, renderSessionData:RenderSessionData ):Number
		{
			super.project(parent,renderSessionData);
			var p:Particle;
			var fz:Number = (renderSessionData.camera.focus*renderSessionData.camera.zoom);
			for each(p in particles){
				if(renderSessionData.viewPort.particleCuller.testParticle(p)){
					p.renderScale = doScale ? (fz / (renderSessionData.camera.focus + p.vertex3D.vertex3DInstance.z))*particleScale : particleScale;
					p.renderCommand.screenDepth = p.vertex3D.vertex3DInstance.z;
					renderSessionData.renderer.addToRenderList(p.renderCommand);	
				}else{
					renderSessionData.renderStatistics.culledParticles++;
				}
			}
			return 1;
		}
		
	}
}