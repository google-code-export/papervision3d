/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.animation.core 
{
/**
 * 
 */
public class BlendWeight 
{
	public var v:uint;
	
	public var weight:Number;
	
	/**
	 * 
	 * @param	vertexIndex
	 * @param	weight
	 * @return
	 */
	public function BlendWeight( vertexIndex:uint, weight:Number ):void
	{
		this.v = vertexIndex;
		this.weight = weight;
	}
}
}
