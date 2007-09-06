package org.papervision3d.core.render.sort
{
	public class BasicRenderSorter implements IRenderSorter
	{
		public function sort(array:Array):void
		{
			array.sortOn("screenZ", Array.NUMERIC);
		}
		
	}
}