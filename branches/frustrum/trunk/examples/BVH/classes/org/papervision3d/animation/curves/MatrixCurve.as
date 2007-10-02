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
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.Matrix3D;
	
	public class MatrixCurve extends AbstractCurve
	{
		public static const MATRIX_N11:String = "n11";
		public static const MATRIX_N12:String = "n12";
		public static const MATRIX_N13:String = "n13";
		public static const MATRIX_N14:String = "n14";
		public static const MATRIX_N21:String = "n21";
		public static const MATRIX_N22:String = "n22";
		public static const MATRIX_N23:String = "n23";
		public static const MATRIX_N24:String = "n24";
		public static const MATRIX_N31:String = "n31";
		public static const MATRIX_N32:String = "n32";
		public static const MATRIX_N33:String = "n33";
		public static const MATRIX_N34:String = "n34";
		
		public var matrix:Matrix3D;
		
		/**
		 * 
		 * @param	matrix
		 * @param	type
		 * @param	keys
		 * @param	values
		 * @param	interpolations
		 * @return
		 */
		public function MatrixCurve( matrix:Matrix3D, type:String, keys:Array=null, values:Array=null, interpolations:Array=null ):void
		{
			super(type, keys, values);
			
			this.matrix = matrix;
		}
		
		/**
		 * 
		 * @param	dt
		 * @return
		 */
		override public function update( dt:Number ):void
		{
			matrix[type] = evaluate(dt);
		}
	}
}
