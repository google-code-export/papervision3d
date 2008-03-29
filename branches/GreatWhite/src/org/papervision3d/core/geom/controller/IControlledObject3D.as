package org.papervision3d.core.geom.controller
{	
	public interface IControlledObject3D
	{
		/**
		 * Gets all controllers.
		 * 
		 * @return Array of AbstractController.
		 */ 
		function get controllers():Array;
		
		/**
		 * Adds a controller.
		 * 
		 * @param	controller	The controller to add.
		 * 
		 * return	The added controller or null on failure.
		 */ 
		function addController(controller:AbstractController):AbstractController;	
		
		/**
		 * Applies all controllers on the object.
		 */ 
		function applyControllers():void;
		
		/**
		 * Removes the specified controller.
		 * 
		 * @param	controller
		 * 
		 * return	The removed controller or null on failure.
		 */ 
		function removeController(controller:AbstractController):AbstractController;	
	}
}