
package {

	import flash.display.MovieClip;
	
	public class UIComponent3D extends MovieClip
	{
		[Inspectable ( type="Boolean", defaultValue=false, name="Clip content")]
		public var clipContent:Boolean = false;
		
		[Inspectable ( type="Boolean", defaultValue=false, name="Hahha content")]
		public var hahaha:Boolean = false;
		
		public function UIComponent3D():void
		{
			super();
			
			trace( "hehehe" );
		}
	}	
}