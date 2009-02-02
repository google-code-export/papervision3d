 package org.papervision3d.materials.special
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.util.FastRectangleTools;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.IParticleDrawer;
	/**
	 * A Particle material that is made from BitmapData object
	 * 
	 * @author Ralph Hauwert
 	 * @author Seb Lee-Delisle
  	 */
	public class BitmapParticleMaterial extends ParticleMaterial implements IParticleDrawer
	{
		
		
		private var renderRect:Rectangle; 
		
		public var particleBitmap : ParticleBitmap; 
		
		
	
		/**
		 * 
		 * @param bitmap	The BitmapData object to make the material from. 
		 * 
		 */		
		public function BitmapParticleMaterial(bitmap:*, scale: Number = 1, offsetx: Number = 0, offsety : Number = 0)
		{
			super(0,0);
				
			renderRect = new Rectangle() ;
			
			if(bitmap is BitmapData) 
			{
				
				particleBitmap = new ParticleBitmap(bitmap as BitmapData)
				{
					particleBitmap.scaleX = particleBitmap.scaleY = scale; 
				}	
						
				
				particleBitmap.offsetX = offsetx;
				particleBitmap.offsetY = offsety;
			}	
			else 
			if(bitmap is ParticleBitmap)
			{
				particleBitmap = bitmap as ParticleBitmap; 
				
			}
		
		}
		
		/**
		 * Draws the particle as part of the render cycle. 
		 *  
		 * @param particle			The particle we're drawing
		 * @param graphics			The graphics object we're drawing into
		 * @param renderSessionData	The renderSessionData for this render cycle.
		 * 
		 */	
		 
		override public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			var newscale : Number = particle.renderScale*particle.size;
			
			var cullingrect:Rectangle = renderSessionData.viewPort.cullingRectangle;
			
			renderRect = FastRectangleTools.intersection(cullingrect, particle.renderRect, renderRect); 
			//renderRect = cullingrect.intersection(particle.renderRect); 
			
			//graphics.lineStyle(0,0xffffff,1); 
			graphics.beginBitmapFill(particleBitmap.bitmap, particle.drawMatrix, false, smooth);
			graphics.drawRect(renderRect.x, renderRect.y, renderRect.width, renderRect.height);
			graphics.endFill();
			//graphics.lineStyle(); 
			
			/*graphics.beginFill(0xff0000,1);
			graphics.drawCircle(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y, 3);
			graphics.endFill(); 
			*/
			renderSessionData.renderStatistics.particles++;
			
		}
		/*
		public function copyMatrix(fromMatrix : Matrix, toMatrix : Matrix) : void
		{
			
			toMatrix.a = fromMatrix.a; 
			toMatrix.b = fromMatrix.b; 
			toMatrix.c = fromMatrix.c; 
			toMatrix.d = fromMatrix.d; 
			toMatrix.tx = fromMatrix.tx; 
			toMatrix.ty = fromMatrix.ty; 
			
		}*/
		 /**
		 * This is called during the projection cycle. It updates the rectangular area that 
		 * the particle is drawn into. It's important for the culling phase. 
		 *  
		 * @param particle	The particle whose renderRect we're updating. 
		 * 
		 */			
		override public function updateRenderRect(particle : Particle) : void
		{
			
			var renderrect:Rectangle = particle.renderRect; 
			var newscale : Number = particle.renderScale*particle.size;
			
			var osx:Number = particleBitmap.offsetX * newscale;
			var osy:Number = particleBitmap.offsetY * newscale;
			
			renderrect.x = particle.vertex3D.vertex3DInstance.x + osx;
			renderrect.y = particle.vertex3D.vertex3DInstance.y + osy;
			
			renderrect.width = particleBitmap.width * particleBitmap.scaleX * newscale; 
			renderrect.height = particleBitmap.height * particleBitmap.scaleY * newscale; 
			
			var drawMatrix : Matrix = particle.drawMatrix; 
			
			drawMatrix.identity(); 
			
			drawMatrix.scale(renderrect.width/particleBitmap.width, renderrect.height/particleBitmap.height); 
			drawMatrix.translate(renderrect.left, renderrect.top); 
			
			
			
			
			
		}
		
		
	}
}