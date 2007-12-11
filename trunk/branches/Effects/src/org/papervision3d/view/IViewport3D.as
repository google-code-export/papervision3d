package org.papervision3d.view
{
	/**
	 * @Author Ralph Hauwert
	 */
	public interface IViewport3D
	{
		function updateBeforeRender():void;
		function updateAfterRender():void;
	}
}