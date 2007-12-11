/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.animation.core 
{
	import org.papervision3d.core.proto.GeometryObject3D;
	import org.papervision3d.events.AnimationEvent;
	
	/**
	 * @author	Tim Knip 
	 */
	public class KeyFrameController extends AbstractController
	{
		/** targeted geometry. */
		public var geometry:GeometryObject3D;
		
		/**
		 * constructor.
		 * 
		 * @param	the targeted geometry.
		 * 
		 * @return
		 */
		public function KeyFrameController( geometry:GeometryObject3D ):void
		{
			super();
			
			this.geometry = geometry;
		}
		
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		override public function tick( dt:Number ):void
		{
			if( this.frames.length < 2 ) return;

			currentFrame = currentFrame < engine.currentFrame ? currentFrame : firstFrame;
			
			var frame:AnimationFrame = this.frames[currentFrame];
			
			if( !frame )
			{
				currentFrame = firstFrame;
				frame = this.frames[currentFrame];
			}	
			
			if( currentFrame == firstFrame )
				nextFrame = currentFrame + frame.duration;
				
			if( this.frames[engine.currentFrame] && engine.currentFrame > currentFrame )
			{				
				currentFrame = engine.currentFrame;
				
				frame = this.frames[currentFrame];
				
				nextFrame = currentFrame + frame.duration;
				nextFrame = nextFrame <= lastFrame ? nextFrame : firstFrame;
							
				this.duration = frame.duration;
				
				// flag the geometry dirty, so other controllers can take action.
				this.geometry.dirty = true;
				
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_NEXT_FRAME, currentFrame, lastFrame, frame.name));
			}
				
			this.split = (engine.currentFrame - currentFrame);
		}
	}
}
