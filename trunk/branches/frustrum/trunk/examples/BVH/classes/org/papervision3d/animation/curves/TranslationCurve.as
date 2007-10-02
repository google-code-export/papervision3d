/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

/*
 * Copyright 2006-2007 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.papervision3d.animation.curves 
{
	import org.papervision3d.objects.DisplayObject3D;
	
	public class TranslationCurve extends AbstractCurve
	{
		public static const TRANSLATION_X	:String = "x";
		public static const TRANSLATION_Y	:String = "y";
		public static const TRANSLATION_Z	:String = "z";
		
		public var target:DisplayObject3D;
		
		/**
		 * 
		 * @param	target
		 * @param	type
		 * @param	keys
		 * @param	values
	 	 * @param	interpolations
		 * @return
		 */
		public function TranslationCurve( target:DisplayObject3D, type:String, keys:Array=null, values:Array=null, interpolations:Array=null):void
		{
			super( type, keys, values );
			
			this.target = target;
		}
	
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		override public function update( dt:Number ):void
		{
			switch( type )
			{
				case TRANSLATION_X:
					this.target.x = evaluate(dt);
					break;
				case TRANSLATION_Y:
					this.target.y = evaluate(dt);
					break;
				case TRANSLATION_Z:
					this.target.z = evaluate(dt);
					break;
				default:
					break;
			}
		}
	}
}
