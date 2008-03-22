package org.papervision3d.core.animation
{
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface IAnimationDataProvider
	{
		/**
		 * Gets a animation channel by its name.
		 * 
		 * @param	name
		 * 
		 * @return the found channel.
		 */ 
		function getAnimationChannelByName(name:String):AnimationChannel3D;
		
		/**
		 * Gets all animation channels for a target. NOTE: when target is null, the object with this interface is used.
		 * 
		 * @param	target	The target to get the channels for.
		 * 
		 * @return	Array of AnimationChannel3D.
		 */ 
		function getAnimationChannelsByTarget(target:DisplayObject3D=null):Array;
		
		/**
		 * Gets animation channels by clip name.
		 * 
		 * @param	name	The clip name
		 * 
		 * @return	Array of AnimationChannel3D.
		 */ 
		function getAnimationChannelsByClip(name:String):Array;
	}
}